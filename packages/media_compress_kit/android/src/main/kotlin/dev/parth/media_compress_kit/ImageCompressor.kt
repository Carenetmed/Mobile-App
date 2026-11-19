package dev.parth.media_compress_kit

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Matrix
import android.os.Build
import androidx.exifinterface.media.ExifInterface
import io.flutter.plugin.common.MethodCall
import java.io.ByteArrayOutputStream
import java.io.File
import kotlin.math.max
import kotlin.math.roundToInt
import kotlin.math.sqrt

internal object ImageCompressor {
    private const val MIN_QUALITY = 10

    /** Reports progress from 0 to 1 and throws CANCELLED when cancelled. */
    class Job(private val progress: (Double) -> Unit, private val isCancelled: () -> Boolean) {
        fun step(value: Double) {
            if (isCancelled()) throw MediaException("CANCELLED", "The compression was cancelled.")
            progress(value)
        }
    }

    fun compress(context: Context, call: MethodCall, job: Job): Map<String, Any> {
        val path = call.argument<String>("path")!!
        val width = call.argument<Int>("width")!!
        val height = call.argument<Int>("height")!!
        val format = call.argument<String>("format")!!
        val quality = call.argument<Int>("quality")!!
        val maxBytes = call.argument<Number>("maxBytes")?.toLong()
        val metadata = call.argument<String>("metadata")!!

        val compressFormat = compressFormat(format)
        val orientation = MediaInfoReader.exifOrientation(context, path)
        job.step(0.05)
        var bitmap = decode(context, path, width, height, orientation)
        if (format == "jpeg" && bitmap.hasAlpha()) bitmap = onWhite(bitmap)
        job.step(0.5)

        // EXIF tags copied below take some room; keep it out of the budget.
        val budget = maxBytes?.let { if (metadata != "removeAll" && it > 64 * 1024) it - 16 * 1024 else it }
        var bytes = encode(bitmap, compressFormat, quality)
        // Fitting a size limit takes several encodes; each moves the bar on.
        var attempts = 0
        val encoded = { job.step(0.7 + 0.25 * (1 - Math.pow(0.85, (++attempts).toDouble()))) }
        encoded()
        if (budget != null) {
            var rounds = 0
            while (bytes.size > budget && rounds < 8) {
                if (compressFormat != Bitmap.CompressFormat.PNG) {
                    val fitting = highestQualityUnder(bitmap, compressFormat, quality, budget, encoded)
                    if (fitting != null) {
                        bytes = fitting
                        break
                    }
                }
                // Even the lowest quality is too big, so scale down by about
                // the missing factor and try again.
                val scale = (sqrt(budget.toDouble() / bytes.size) * 0.95).coerceIn(0.3, 0.9)
                val w = max(1, (bitmap.width * scale).roundToInt())
                val h = max(1, (bitmap.height * scale).roundToInt())
                if (w < 16 || h < 16) break
                val smaller = Bitmap.createScaledBitmap(bitmap, w, h, true)
                if (smaller !== bitmap) bitmap.recycle()
                bitmap = smaller
                bytes = encode(bitmap, compressFormat, quality)
                encoded()
                rounds++
            }
        }

        val output = MediaCompressKitPlugin.outputFile(
            context,
            call.argument<String>("outputPath"),
            "IMG",
            if (format == "jpeg") "jpg" else format,
        )
        job.step(0.96)
        output.writeBytes(bytes)
        if (metadata != "removeAll") {
            copyMetadata(context, path, output, metadata == "keepAll", bitmap.width, bitmap.height)
        }
        val result = mapOf(
            "path" to output.absolutePath,
            "size" to output.length(),
            "width" to bitmap.width,
            "height" to bitmap.height,
        )
        bitmap.recycle()
        return result
    }

    /**
     * Bits per pixel of two small copies encoded as asked, for size
     * estimates: the trend between them extends to the full size.
     */
    fun estimate(context: Context, call: MethodCall): Map<String, Any> {
        val path = call.argument<String>("path")!!
        val width = call.argument<Int>("width")!!
        val height = call.argument<Int>("height")!!
        val format = call.argument<String>("format")!!
        val quality = call.argument<Int>("quality")!!
        val compressFormat = compressFormat(format)
        val orientation = MediaInfoReader.exifOrientation(context, path)
        val samples = SAMPLE_SIDES.map { side ->
            val scale = minOf(1.0, side.toDouble() / max(width, height))
            val w = max(1, (width * scale).roundToInt())
            val h = max(1, (height * scale).roundToInt())
            var bitmap = decode(context, path, w, h, orientation)
            if (format == "jpeg" && bitmap.hasAlpha()) bitmap = onWhite(bitmap)
            val bytes = encode(bitmap, compressFormat, quality)
            val pixels = bitmap.width * bitmap.height
            bitmap.recycle()
            listOf(pixels, bytes.size * 8.0 / pixels)
        }
        return mapOf("samples" to samples)
    }

    private val SAMPLE_SIDES = listOf(400, 800)

    private fun compressFormat(format: String): Bitmap.CompressFormat = when (format) {
        "jpeg" -> Bitmap.CompressFormat.JPEG
        "png" -> Bitmap.CompressFormat.PNG
        "webp" -> if (Build.VERSION.SDK_INT >= 30) {
            Bitmap.CompressFormat.WEBP_LOSSY
        } else {
            @Suppress("DEPRECATION")
            Bitmap.CompressFormat.WEBP
        }
        "heic" -> throw MediaException("UNSUPPORTED", "HEIC output is only available on iOS. Use jpeg or webp on Android.")
        else -> throw MediaException("INVALID_ARGUMENT", "Unknown image format $format")
    }

    /** Decodes [path] upright, at exactly [width] x [height] (the size as displayed). */
    private fun decode(context: Context, path: String, width: Int, height: Int, orientation: Int): Bitmap {
        val bounds = BitmapFactory.Options().apply { inJustDecodeBounds = true }
        Sources.open(context, path).use { BitmapFactory.decodeStream(it, null, bounds) }
        if (bounds.outWidth <= 0) throw MediaException("UNSUPPORTED", "$path is not an image this device can decode.")

        // The stored pixels are sideways for 90 and 270 degree orientations.
        val swapped = Orientation.swapsSides(orientation)
        val storedWidth = if (swapped) height else width
        val storedHeight = if (swapped) width else height
        var sample = 1
        while (bounds.outWidth / (sample * 2) >= storedWidth && bounds.outHeight / (sample * 2) >= storedHeight) {
            sample *= 2
        }
        val options = BitmapFactory.Options().apply {
            inSampleSize = sample
            inPreferredConfig = Bitmap.Config.ARGB_8888
        }
        val decoded = Sources.open(context, path).use { BitmapFactory.decodeStream(it, null, options) }
            ?: throw MediaException("UNSUPPORTED", "$path is not an image this device can decode.")

        val matrix = Matrix()
        matrix.postScale(storedWidth.toFloat() / decoded.width, storedHeight.toFloat() / decoded.height)
        when (orientation) {
            ExifInterface.ORIENTATION_FLIP_HORIZONTAL -> matrix.postScale(-1f, 1f)
            ExifInterface.ORIENTATION_ROTATE_180 -> matrix.postRotate(180f)
            ExifInterface.ORIENTATION_FLIP_VERTICAL -> matrix.postScale(1f, -1f)
            ExifInterface.ORIENTATION_TRANSPOSE -> {
                matrix.postRotate(90f)
                matrix.postScale(-1f, 1f)
            }
            ExifInterface.ORIENTATION_ROTATE_90 -> matrix.postRotate(90f)
            ExifInterface.ORIENTATION_TRANSVERSE -> {
                matrix.postRotate(-90f)
                matrix.postScale(-1f, 1f)
            }
            ExifInterface.ORIENTATION_ROTATE_270 -> matrix.postRotate(-90f)
        }
        if (matrix.isIdentity) return decoded
        val result = Bitmap.createBitmap(decoded, 0, 0, decoded.width, decoded.height, matrix, true)
        if (result !== decoded) decoded.recycle()
        return result
    }

    /** JPEG has no transparency; without this, transparent pixels turn black. */
    private fun onWhite(bitmap: Bitmap): Bitmap {
        val result = Bitmap.createBitmap(bitmap.width, bitmap.height, Bitmap.Config.ARGB_8888)
        Canvas(result).apply {
            drawColor(Color.WHITE)
            drawBitmap(bitmap, 0f, 0f, null)
        }
        bitmap.recycle()
        return result
    }

    private fun encode(bitmap: Bitmap, format: Bitmap.CompressFormat, quality: Int): ByteArray {
        val stream = ByteArrayOutputStream()
        if (!bitmap.compress(format, quality, stream)) {
            throw MediaException("FAILED", "The image encoder failed.")
        }
        return stream.toByteArray()
    }

    /** The best-quality encoding under [budget], by binary search, or null if none fits. */
    private fun highestQualityUnder(
        bitmap: Bitmap,
        format: Bitmap.CompressFormat,
        quality: Int,
        budget: Long,
        encoded: () -> Unit,
    ): ByteArray? {
        var low = MIN_QUALITY
        var high = quality - 1
        var best: ByteArray? = null
        while (low <= high) {
            val mid = (low + high) / 2
            val bytes = encode(bitmap, format, mid)
            encoded()
            if (bytes.size <= budget) {
                best = bytes
                low = mid + 1
            } else {
                high = mid - 1
            }
        }
        return best
    }

    private val tags = listOf(
        ExifInterface.TAG_DATETIME,
        ExifInterface.TAG_DATETIME_ORIGINAL,
        ExifInterface.TAG_DATETIME_DIGITIZED,
        ExifInterface.TAG_OFFSET_TIME,
        ExifInterface.TAG_OFFSET_TIME_ORIGINAL,
        ExifInterface.TAG_OFFSET_TIME_DIGITIZED,
        ExifInterface.TAG_SUBSEC_TIME,
        ExifInterface.TAG_SUBSEC_TIME_ORIGINAL,
        ExifInterface.TAG_SUBSEC_TIME_DIGITIZED,
        ExifInterface.TAG_MAKE,
        ExifInterface.TAG_MODEL,
        ExifInterface.TAG_SOFTWARE,
        ExifInterface.TAG_ARTIST,
        ExifInterface.TAG_COPYRIGHT,
        ExifInterface.TAG_IMAGE_DESCRIPTION,
        ExifInterface.TAG_USER_COMMENT,
        ExifInterface.TAG_LENS_MAKE,
        ExifInterface.TAG_LENS_MODEL,
        ExifInterface.TAG_EXPOSURE_TIME,
        ExifInterface.TAG_F_NUMBER,
        ExifInterface.TAG_APERTURE_VALUE,
        ExifInterface.TAG_SHUTTER_SPEED_VALUE,
        ExifInterface.TAG_BRIGHTNESS_VALUE,
        ExifInterface.TAG_EXPOSURE_BIAS_VALUE,
        ExifInterface.TAG_EXPOSURE_PROGRAM,
        ExifInterface.TAG_EXPOSURE_MODE,
        ExifInterface.TAG_PHOTOGRAPHIC_SENSITIVITY,
        ExifInterface.TAG_METERING_MODE,
        ExifInterface.TAG_FLASH,
        ExifInterface.TAG_FOCAL_LENGTH,
        ExifInterface.TAG_FOCAL_LENGTH_IN_35MM_FILM,
        ExifInterface.TAG_WHITE_BALANCE,
        ExifInterface.TAG_SCENE_CAPTURE_TYPE,
    )

    private val locationTags = listOf(
        ExifInterface.TAG_GPS_LATITUDE,
        ExifInterface.TAG_GPS_LATITUDE_REF,
        ExifInterface.TAG_GPS_LONGITUDE,
        ExifInterface.TAG_GPS_LONGITUDE_REF,
        ExifInterface.TAG_GPS_ALTITUDE,
        ExifInterface.TAG_GPS_ALTITUDE_REF,
        ExifInterface.TAG_GPS_TIMESTAMP,
        ExifInterface.TAG_GPS_DATESTAMP,
        ExifInterface.TAG_GPS_PROCESSING_METHOD,
        ExifInterface.TAG_GPS_IMG_DIRECTION,
        ExifInterface.TAG_GPS_IMG_DIRECTION_REF,
        ExifInterface.TAG_GPS_SPEED,
        ExifInterface.TAG_GPS_SPEED_REF,
    )

    /** Copies the source's EXIF tags to [output], which is already upright. */
    private fun copyMetadata(context: Context, path: String, output: File, withLocation: Boolean, width: Int, height: Int) {
        try {
            val source = Sources.open(context, path).use { ExifInterface(it) }
            val target = ExifInterface(output.absolutePath)
            val copied = if (withLocation) tags + locationTags else tags
            for (tag in copied) {
                source.getAttribute(tag)?.let { target.setAttribute(tag, it) }
            }
            target.setAttribute(ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_NORMAL.toString())
            target.setAttribute(ExifInterface.TAG_PIXEL_X_DIMENSION, width.toString())
            target.setAttribute(ExifInterface.TAG_PIXEL_Y_DIMENSION, height.toString())
            target.saveAttributes()
        } catch (e: Exception) {
            // The image itself is fine; it just keeps no metadata.
        }
    }
}
