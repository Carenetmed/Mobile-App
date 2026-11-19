package dev.parth.media_compress_kit

import android.content.Context
import android.graphics.Bitmap
import android.media.MediaMetadataRetriever
import android.os.Build
import io.flutter.plugin.common.MethodCall
import kotlin.math.max
import kotlin.math.min
import kotlin.math.roundToInt

internal object Thumbnails {
    fun create(context: Context, call: MethodCall): Map<String, Any> {
        val path = call.argument<String>("path")!!
        val positionUs = call.argument<Number>("positionMs")!!.toLong() * 1000
        val maxWidth = call.argument<Int>("maxWidth")!!
        val maxHeight = call.argument<Int>("maxHeight")!!
        val quality = call.argument<Int>("quality")!!
        Sources.size(context, path) // Fails early with FILE_NOT_FOUND.

        val retriever = Sources.retriever(context, path)
        val frame = try {
            fun int(key: Int) = retriever.extractMetadata(key)?.toIntOrNull() ?: 0
            val rotation = int(MediaMetadataRetriever.METADATA_KEY_VIDEO_ROTATION)
            var width = int(MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH)
            var height = int(MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT)
            if (rotation % 180 != 0) width = height.also { height = width }
            if (width <= 0 || height <= 0) throw MediaException("UNSUPPORTED", "$path is not a video this device can read.")
            val scale = min(1.0, min(maxWidth.toDouble() / width, maxHeight.toDouble() / height))
            val w = max(1, (width * scale).roundToInt())
            val h = max(1, (height * scale).roundToInt())
            val option = MediaMetadataRetriever.OPTION_CLOSEST
            val bitmap = if (Build.VERSION.SDK_INT >= 27) {
                retriever.getScaledFrameAtTime(positionUs, option, w, h)
            } else {
                retriever.getFrameAtTime(positionUs, option)?.let { full ->
                    Bitmap.createScaledBitmap(full, w, h, true).also { if (it !== full) full.recycle() }
                }
            }
            bitmap ?: throw MediaException("FAILED", "No frame at ${positionUs / 1000} ms in $path.")
        } finally {
            retriever.release()
        }

        val output = MediaCompressKitPlugin.outputFile(context, call.argument<String>("outputPath"), "THUMB", "jpg")
        output.outputStream().use { frame.compress(Bitmap.CompressFormat.JPEG, quality, it) }
        val result = mapOf(
            "path" to output.absolutePath,
            "width" to frame.width,
            "height" to frame.height,
            "size" to output.length(),
        )
        frame.recycle()
        return result
    }
}
