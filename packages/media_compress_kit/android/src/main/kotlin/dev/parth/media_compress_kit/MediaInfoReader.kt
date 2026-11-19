package dev.parth.media_compress_kit

import android.content.Context
import android.graphics.BitmapFactory
import android.media.MediaExtractor
import android.media.MediaFormat
import android.media.MediaMetadataRetriever
import android.net.Uri
import android.os.Build
import androidx.exifinterface.media.ExifInterface

internal object MediaInfoReader {
    fun read(context: Context, path: String): Map<String, Any?> {
        val size = Sources.size(context, path)
        return readImage(context, path, size) ?: readVideo(context, path, size)
    }

    private fun readImage(context: Context, path: String, size: Long): Map<String, Any?>? {
        val bounds = BitmapFactory.Options().apply { inJustDecodeBounds = true }
        Sources.open(context, path).use { BitmapFactory.decodeStream(it, null, bounds) }
        if (bounds.outWidth <= 0 || bounds.outHeight <= 0) return null
        val orientation = exifOrientation(context, path)
        val swapped = Orientation.swapsSides(orientation)
        return mapOf(
            "type" to "image",
            "size" to size,
            "width" to if (swapped) bounds.outHeight else bounds.outWidth,
            "height" to if (swapped) bounds.outWidth else bounds.outHeight,
            "mimeType" to bounds.outMimeType,
            "rotation" to Orientation.degrees(orientation),
        )
    }

    fun exifOrientation(context: Context, path: String): Int = try {
        Sources.open(context, path).use {
            ExifInterface(it).getAttributeInt(
                ExifInterface.TAG_ORIENTATION,
                ExifInterface.ORIENTATION_NORMAL,
            )
        }
    } catch (e: Exception) {
        ExifInterface.ORIENTATION_NORMAL
    }

    private fun readVideo(context: Context, path: String, size: Long): Map<String, Any?> {
        val retriever = Sources.retriever(context, path)
        try {
            fun int(key: Int) = retriever.extractMetadata(key)?.toIntOrNull()
            fun long(key: Int) = retriever.extractMetadata(key)?.toLongOrNull()
            val width = int(MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH)
            val height = int(MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT)
            if (width == null || height == null || width <= 0 || height <= 0) {
                throw MediaException("UNSUPPORTED", "$path is not an image or video this device can read.")
            }
            val rotation = int(MediaMetadataRetriever.METADATA_KEY_VIDEO_ROTATION) ?: 0
            val durationMs = long(MediaMetadataRetriever.METADATA_KEY_DURATION)
            val tracks = readTracks(context, path)
            var frameRate = tracks.frameRate
            if (frameRate == null && Build.VERSION.SDK_INT >= 28 && durationMs != null && durationMs > 0) {
                val frames = int(MediaMetadataRetriever.METADATA_KEY_VIDEO_FRAME_COUNT)
                if (frames != null) frameRate = frames * 1000.0 / durationMs
            }
            val swapped = rotation % 180 != 0
            return mapOf(
                "type" to "video",
                "size" to size,
                "width" to if (swapped) height else width,
                "height" to if (swapped) width else height,
                "rotation" to ((rotation % 360) + 360) % 360,
                "durationMs" to durationMs,
                "mimeType" to retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_MIMETYPE),
                "bitrate" to long(MediaMetadataRetriever.METADATA_KEY_BITRATE),
                "frameRate" to frameRate,
                "videoBitrate" to tracks.videoBitrate,
                "audioBitrate" to tracks.audioBitrate,
                "hasAudio" to (retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_HAS_AUDIO) == "yes"),
            )
        } finally {
            retriever.release()
        }
    }

    private class Tracks(val frameRate: Double?, val videoBitrate: Int?, val audioBitrate: Int?)

    private fun readTracks(context: Context, path: String): Tracks {
        val extractor = MediaExtractor()
        try {
            if (Sources.isContentUri(path)) extractor.setDataSource(context, Uri.parse(path), null)
            else extractor.setDataSource(path)
            var frameRate: Double? = null
            var videoBitrate: Int? = null
            var audioBitrate: Int? = null
            for (i in 0 until extractor.trackCount) {
                val format = extractor.getTrackFormat(i)
                val mime = format.getString(MediaFormat.KEY_MIME) ?: continue
                val bitrate = if (format.containsKey(MediaFormat.KEY_BIT_RATE)) {
                    format.getInteger(MediaFormat.KEY_BIT_RATE)
                } else {
                    null
                }
                if (mime.startsWith("video/") && videoBitrate == null) {
                    videoBitrate = bitrate
                    if (format.containsKey(MediaFormat.KEY_FRAME_RATE)) {
                        frameRate = try {
                            format.getInteger(MediaFormat.KEY_FRAME_RATE).toDouble()
                        } catch (e: ClassCastException) {
                            format.getFloat(MediaFormat.KEY_FRAME_RATE).toDouble()
                        }
                    }
                } else if (mime.startsWith("audio/") && audioBitrate == null) {
                    audioBitrate = bitrate
                }
            }
            return Tracks(frameRate, videoBitrate, audioBitrate)
        } catch (e: Exception) {
            return Tracks(null, null, null)
        } finally {
            extractor.release()
        }
    }
}

/** EXIF orientation helpers. */
internal object Orientation {
    fun swapsSides(orientation: Int) = when (orientation) {
        ExifInterface.ORIENTATION_TRANSPOSE,
        ExifInterface.ORIENTATION_ROTATE_90,
        ExifInterface.ORIENTATION_TRANSVERSE,
        ExifInterface.ORIENTATION_ROTATE_270 -> true
        else -> false
    }

    fun degrees(orientation: Int) = when (orientation) {
        ExifInterface.ORIENTATION_ROTATE_90, ExifInterface.ORIENTATION_TRANSPOSE -> 90
        ExifInterface.ORIENTATION_ROTATE_180, ExifInterface.ORIENTATION_FLIP_VERTICAL -> 180
        ExifInterface.ORIENTATION_ROTATE_270, ExifInterface.ORIENTATION_TRANSVERSE -> 270
        else -> 0
    }
}
