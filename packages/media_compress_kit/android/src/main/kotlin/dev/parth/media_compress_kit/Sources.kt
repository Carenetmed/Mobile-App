package dev.parth.media_compress_kit

import android.content.Context
import android.media.MediaMetadataRetriever
import android.net.Uri
import java.io.File
import java.io.FileNotFoundException
import java.io.InputStream

/** Opens a file path or a `content://` URI the same way. */
internal object Sources {
    fun isContentUri(path: String) = path.startsWith("content://")

    fun uri(path: String): Uri = if (isContentUri(path)) Uri.parse(path) else Uri.fromFile(File(path))

    fun open(context: Context, path: String): InputStream = try {
        if (isContentUri(path)) {
            context.contentResolver.openInputStream(Uri.parse(path))
                ?: throw FileNotFoundException(path)
        } else {
            File(path).inputStream()
        }
    } catch (e: FileNotFoundException) {
        throw MediaException("FILE_NOT_FOUND", "Can't read $path: ${e.message}")
    } catch (e: SecurityException) {
        throw MediaException("FILE_NOT_FOUND", "No permission to read $path: ${e.message}")
    }

    fun size(context: Context, path: String): Long {
        if (!isContentUri(path)) {
            val file = File(path)
            if (!file.isFile) throw MediaException("FILE_NOT_FOUND", "No file at $path")
            return file.length()
        }
        try {
            context.contentResolver.openFileDescriptor(Uri.parse(path), "r").use {
                return it?.statSize ?: -1
            }
        } catch (e: Exception) {
            throw MediaException("FILE_NOT_FOUND", "Can't read $path: ${e.message}")
        }
    }

    fun retriever(context: Context, path: String): MediaMetadataRetriever {
        val retriever = MediaMetadataRetriever()
        try {
            if (isContentUri(path)) retriever.setDataSource(context, Uri.parse(path))
            else retriever.setDataSource(path)
        } catch (e: Exception) {
            retriever.release()
            throw MediaException("UNSUPPORTED", "Can't read $path as a video: ${e.message}")
        }
        return retriever
    }
}
