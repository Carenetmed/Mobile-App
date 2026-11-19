package dev.parth.media_compress_kit

import java.io.File
import java.io.RandomAccessFile
import java.nio.ByteBuffer

/** MP4 file fixes. */
internal object Mp4 {
    private class Box(val type: String, val offset: Long, val size: Long)

    private val containers = setOf("moov", "trak", "mdia", "minf", "stbl", "edts", "mvex", "udta")

    /**
     * Removes the empty `free` box Media3 reserves after `moov` (about 400 KB,
     * so the index fits at the front of the file for streaming). The index
     * stays at the front; only the unused space goes, and the chunk offsets
     * are moved back by its size. Files laid out differently are left as is.
     */
    fun dropReservedSpace(file: File) {
        val boxes = mutableListOf<Box>()
        RandomAccessFile(file, "r").use { input ->
            var offset = 0L
            val length = input.length()
            while (offset + 8 <= length) {
                input.seek(offset)
                var size = input.readInt().toLong() and 0xFFFFFFFFL
                val type = ByteArray(4).also { input.readFully(it) }.toString(Charsets.US_ASCII)
                if (size == 1L) size = input.readLong()
                if (size == 0L) size = length - offset
                if (size < 8) return
                boxes.add(Box(type, offset, size))
                offset += size
            }
        }
        val moovIndex = boxes.indexOfFirst { it.type == "moov" }
        val free = boxes.getOrNull(moovIndex + 1)
        val mdat = boxes.getOrNull(moovIndex + 2)
        if (moovIndex < 0 || free?.type != "free" || mdat?.type != "mdat") return
        val moov = boxes[moovIndex]
        if (moov.size > Int.MAX_VALUE) return

        val moovBytes = ByteArray(moov.size.toInt())
        RandomAccessFile(file, "r").use { input ->
            input.seek(moov.offset)
            input.readFully(moovBytes)
        }
        if (!shiftChunkOffsets(ByteBuffer.wrap(moovBytes), 8, moovBytes.size, free.size)) return

        val temp = File(file.parentFile, "${file.name}.tmp")
        RandomAccessFile(file, "r").use { input ->
            temp.outputStream().buffered(1 shl 16).use { output ->
                fun copy(from: Long, to: Long) {
                    input.seek(from)
                    val buffer = ByteArray(1 shl 16)
                    var left = to - from
                    while (left > 0) {
                        val read = input.read(buffer, 0, minOf(buffer.size.toLong(), left).toInt())
                        if (read < 0) break
                        output.write(buffer, 0, read)
                        left -= read
                    }
                }
                copy(0, moov.offset)
                output.write(moovBytes)
                copy(free.offset + free.size, input.length())
            }
        }
        if (!temp.renameTo(file)) {
            file.delete()
            temp.renameTo(file)
        }
    }

    /** Subtracts [shift] from every `stco` and `co64` entry in [start, end). */
    private fun shiftChunkOffsets(buffer: ByteBuffer, start: Int, end: Int, shift: Long): Boolean {
        var position = start
        while (position + 8 <= end) {
            val size = buffer.getInt(position).toLong() and 0xFFFFFFFFL
            val type = String(ByteArray(4) { buffer.get(position + 4 + it) }, Charsets.US_ASCII)
            if (size < 8 || position + size > end) return false
            val boxEnd = (position + size).toInt()
            when (type) {
                in containers -> if (!shiftChunkOffsets(buffer, position + 8, boxEnd, shift)) return false
                "stco" -> {
                    val count = buffer.getInt(position + 12)
                    for (i in 0 until count) {
                        val at = position + 16 + i * 4
                        val value = (buffer.getInt(at).toLong() and 0xFFFFFFFFL) - shift
                        if (value < 0) return false
                        buffer.putInt(at, value.toInt())
                    }
                }
                "co64" -> {
                    val count = buffer.getInt(position + 12)
                    for (i in 0 until count) {
                        val at = position + 16 + i * 8
                        val value = buffer.getLong(at) - shift
                        if (value < 0) return false
                        buffer.putLong(at, value)
                    }
                }
            }
            position = boxEnd
        }
        return true
    }
}
