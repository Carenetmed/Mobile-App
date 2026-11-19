package dev.parth.media_compress_kit

import android.content.Context
import android.media.MediaCodecInfo
import android.media.MediaMetadataRetriever
import android.os.Handler
import android.os.Looper
import androidx.media3.common.Effect
import androidx.media3.common.C
import androidx.media3.common.MediaItem
import androidx.media3.common.MimeTypes
import androidx.media3.common.util.UnstableApi
import androidx.media3.effect.FrameDropEffect
import androidx.media3.effect.Presentation
import androidx.media3.transformer.AudioEncoderSettings
import androidx.media3.transformer.Composition
import androidx.media3.transformer.DefaultEncoderFactory
import androidx.media3.transformer.EditedMediaItem
import androidx.media3.transformer.EditedMediaItemSequence
import androidx.media3.transformer.Effects
import androidx.media3.transformer.ExportException
import androidx.media3.transformer.ExportResult
import androidx.media3.transformer.ProgressHolder
import androidx.media3.transformer.Transformer
import androidx.media3.transformer.VideoEncoderSettings
import io.flutter.plugin.common.MethodCall
import java.io.File
import kotlin.concurrent.thread

/** One video compression with Media3 Transformer. Runs on the main thread. */
@UnstableApi
internal class VideoCompressor(private val context: Context, call: MethodCall) {
    private val path = call.argument<String>("path")!!
    private val width = call.argument<Int>("width")!!
    private val height = call.argument<Int>("height")!!
    private val videoBitrate = call.argument<Number>("videoBitrate")!!.toInt()
    private val audioBitrate = call.argument<Number>("audioBitrate")!!.toInt()
    private val includeAudio = call.argument<Boolean>("includeAudio")!!
    private val frameRate = call.argument<Number>("frameRate")?.toFloat()
    private val startMs = call.argument<Number>("startMs")?.toLong()
    private val endMs = call.argument<Number>("endMs")?.toLong()
    private val codec = call.argument<String>("codec")!!
    private val constantBitrate = call.argument<Boolean>("constantBitrate") ?: false
    private val output: File

    private val handler = Handler(Looper.getMainLooper())
    private var transformer: Transformer? = null
    private var finished = false
    private var onDone: ((Map<String, Any>?, MediaException?) -> Unit)? = null

    init {
        Sources.size(context, path) // Fails early with FILE_NOT_FOUND.
        output = MediaCompressKitPlugin.outputFile(context, call.argument<String>("outputPath"), "VID", "mp4")
    }

    fun start(onProgress: (Double) -> Unit, onDone: (Map<String, Any>?, MediaException?) -> Unit) {
        this.onDone = onDone
        val encoders = DefaultEncoderFactory.Builder(context)
            .setRequestedVideoEncoderSettings(videoSettings())
            .setRequestedAudioEncoderSettings(AudioEncoderSettings.Builder().setBitrate(audioBitrate).build())
            .setEnableFallback(true)
            .build()
        val transformer = Transformer.Builder(context)
            .setVideoMimeType(if (codec == "hevc") MimeTypes.VIDEO_H265 else MimeTypes.VIDEO_H264)
            .setAudioMimeType(MimeTypes.AUDIO_AAC)
            .setEncoderFactory(encoders)
            .addListener(object : Transformer.Listener {
                override fun onCompleted(composition: Composition, exportResult: ExportResult) {
                    // Rewriting the file can take a moment, so not on the main thread.
                    thread {
                        try {
                            Mp4.dropReservedSpace(output)
                        } catch (e: Exception) {
                            // The file still plays; it is just bigger.
                        }
                        val map = result(exportResult)
                        handler.post { finish(map, null) }
                    }
                }

                override fun onError(composition: Composition, exportResult: ExportResult, exportException: ExportException) {
                    output.delete()
                    finish(null, error(exportException))
                }
            })
            .build()
        this.transformer = transformer

        val item = MediaItem.Builder().setUri(Sources.uri(path))
        if (startMs != null || endMs != null) {
            val clipping = MediaItem.ClippingConfiguration.Builder()
            startMs?.let { clipping.setStartPositionMs(it) }
            endMs?.let { clipping.setEndPositionMs(it) }
            item.setClippingConfiguration(clipping.build())
        }
        val effects = mutableListOf<Effect>(
            Presentation.createForWidthAndHeight(width, height, Presentation.LAYOUT_SCALE_TO_FIT),
        )
        frameRate?.let { effects.add(FrameDropEffect.createDefaultFrameDropEffect(it)) }
        val edited = EditedMediaItem.Builder(item.build())
            .setRemoveAudio(!includeAudio)
            .setEffects(Effects(listOf(), effects))
            .build()
        // Requiring audio makes Transformer emit AAC silence for silent sources.
        val sequence = EditedMediaItemSequence.Builder(
            setOf(C.TRACK_TYPE_AUDIO, C.TRACK_TYPE_VIDEO),
        ).addItem(edited).build()
        val composition = Composition.Builder(sequence)
            // HDR video from recent phones plays washed out on many screens
            // and apps; standard dynamic range plays right everywhere.
            .setHdrMode(Composition.HDR_MODE_TONE_MAP_HDR_TO_SDR_USING_OPEN_GL)
            .build()

        try {
            transformer.start(composition, output.absolutePath)
        } catch (e: Exception) {
            output.delete()
            finish(null, MediaException("FAILED", e.toString()))
            return
        }

        val holder = ProgressHolder()
        handler.post(object : Runnable {
            override fun run() {
                if (finished) return
                if (transformer.getProgress(holder) == Transformer.PROGRESS_STATE_AVAILABLE) {
                    onProgress(holder.progress / 100.0)
                }
                handler.postDelayed(this, 200)
            }
        })
    }

    private fun videoSettings(): VideoEncoderSettings {
        val settings = VideoEncoderSettings.Builder().setBitrate(videoBitrate)
        if (constantBitrate) {
            // Variable bitrate can overshoot a lot; constant sticks closer.
            settings.setBitrateMode(MediaCodecInfo.EncoderCapabilities.BITRATE_MODE_CBR)
        }
        return settings.build()
    }

    fun cancel() {
        if (finished) return
        transformer?.cancel()
        output.delete()
        finish(null, MediaException("CANCELLED", "The compression was cancelled."))
    }

    private fun finish(result: Map<String, Any>?, error: MediaException?) {
        if (finished) return
        finished = true
        handler.removeCallbacksAndMessages(null)
        onDone?.invoke(result, error)
    }

    private fun result(exportResult: ExportResult): Map<String, Any> {
        var width = this.width
        var height = this.height
        var durationMs = exportResult.durationMs
        val retriever = MediaMetadataRetriever()
        try {
            retriever.setDataSource(output.absolutePath)
            fun int(key: Int) = retriever.extractMetadata(key)?.toIntOrNull()
            val w = int(MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH)
            val h = int(MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT)
            val rotation = int(MediaMetadataRetriever.METADATA_KEY_VIDEO_ROTATION) ?: 0
            if (w != null && h != null) {
                width = if (rotation % 180 != 0) h else w
                height = if (rotation % 180 != 0) w else h
            }
            retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)?.toLongOrNull()?.let {
                durationMs = it
            }
        } catch (e: Exception) {
            // Keep the planned size.
        } finally {
            retriever.release()
        }
        return mapOf(
            "path" to output.absolutePath,
            "size" to output.length(),
            "width" to width,
            "height" to height,
            "durationMs" to durationMs,
        )
    }

    private fun error(e: ExportException): MediaException {
        val code = when (e.errorCode) {
            ExportException.ERROR_CODE_IO_FILE_NOT_FOUND,
            ExportException.ERROR_CODE_IO_NO_PERMISSION -> "FILE_NOT_FOUND"
            ExportException.ERROR_CODE_DECODING_FORMAT_UNSUPPORTED,
            ExportException.ERROR_CODE_ENCODING_FORMAT_UNSUPPORTED,
            ExportException.ERROR_CODE_DECODER_INIT_FAILED -> "UNSUPPORTED"
            else -> "FAILED"
        }
        return MediaException(code, "${e.errorCodeName}: ${e.message}")
    }
}
