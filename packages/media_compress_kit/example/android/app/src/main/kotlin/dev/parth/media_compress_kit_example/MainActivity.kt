package dev.parth.media_compress_kit_example

import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.media.MediaCodec
import android.media.MediaCodecInfo
import android.media.MediaFormat
import android.media.MediaMuxer
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.nio.ByteBuffer
import java.nio.ByteOrder
import kotlin.concurrent.thread
import kotlin.math.PI
import kotlin.math.cos
import kotlin.math.sin

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val main = Handler(Looper.getMainLooper())
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "sample_media").setMethodCallHandler { call, result ->
            when (call.method) {
                "makeVideo" -> thread {
                    try {
                        SampleVideo.make(
                            path = call.argument<String>("path")!!,
                            width = call.argument<Int>("width")!!,
                            height = call.argument<Int>("height")!!,
                            seconds = call.argument<Number>("seconds")!!.toDouble(),
                            fps = call.argument<Int>("fps")!!,
                            rotation = call.argument<Int>("rotation")!!,
                            audio = call.argument<Boolean>("audio")!!,
                            bitrate = call.argument<Int>("bitrate")!!,
                        )
                        main.post { result.success(null) }
                    } catch (e: Exception) {
                        main.post { result.error("FAILED", e.toString(), null) }
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}

/**
 * Makes a test video without needing any real footage: animated shapes on a
 * moving gradient, with a tone for audio. [rotation] is stored as metadata,
 * the way phones store portrait videos.
 */
object SampleVideo {
    private class Sample(val data: ByteArray, val timeUs: Long, val flags: Int)

    fun make(path: String, width: Int, height: Int, seconds: Double, fps: Int, rotation: Int, audio: Boolean, bitrate: Int) {
        val (videoFormat, videoSamples) = encodeVideo(width, height, seconds, fps, bitrate, rotation)
        val audioTrack = if (audio) encodeAudio(seconds) else null
        val muxer = MediaMuxer(path, MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4)
        muxer.setOrientationHint(rotation)
        val videoIndex = muxer.addTrack(videoFormat)
        val audioIndex = audioTrack?.let { muxer.addTrack(it.first) }
        muxer.start()
        val info = MediaCodec.BufferInfo()
        fun write(track: Int, sample: Sample) {
            info.set(0, sample.data.size, sample.timeUs, sample.flags)
            muxer.writeSampleData(track, ByteBuffer.wrap(sample.data), info)
        }
        videoSamples.forEach { write(videoIndex, it) }
        if (audioIndex != null) audioTrack.second.forEach { write(audioIndex, it) }
        muxer.stop()
        muxer.release()
    }

    private fun encodeVideo(width: Int, height: Int, seconds: Double, fps: Int, bitrate: Int, rotation: Int): Pair<MediaFormat, List<Sample>> {
        val format = MediaFormat.createVideoFormat(MediaFormat.MIMETYPE_VIDEO_AVC, width, height).apply {
            setInteger(MediaFormat.KEY_COLOR_FORMAT, MediaCodecInfo.CodecCapabilities.COLOR_FormatSurface)
            setInteger(MediaFormat.KEY_BIT_RATE, bitrate)
            setInteger(MediaFormat.KEY_FRAME_RATE, fps)
            setInteger(MediaFormat.KEY_I_FRAME_INTERVAL, 1)
        }
        val encoder = MediaCodec.createEncoderByType(MediaFormat.MIMETYPE_VIDEO_AVC)
        encoder.configure(format, null, null, MediaCodec.CONFIGURE_FLAG_ENCODE)
        val surface = encoder.createInputSurface()
        encoder.start()
        val samples = mutableListOf<Sample>()
        var outputFormat: MediaFormat? = null
        var firstTimeUs = -1L

        // A surface stamps each frame with the time it is posted, so frames
        // are drawn in real time to get the right frame rate.
        fun drain(endOfStream: Boolean) {
            val info = MediaCodec.BufferInfo()
            while (true) {
                val index = encoder.dequeueOutputBuffer(info, if (endOfStream) 10_000 else 0)
                when {
                    index == MediaCodec.INFO_TRY_AGAIN_LATER -> if (!endOfStream) return
                    index == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED -> outputFormat = encoder.outputFormat
                    index >= 0 -> {
                        val buffer = encoder.getOutputBuffer(index)!!
                        if (info.flags and MediaCodec.BUFFER_FLAG_CODEC_CONFIG == 0 && info.size > 0) {
                            if (firstTimeUs < 0) firstTimeUs = info.presentationTimeUs
                            val data = ByteArray(info.size)
                            buffer.position(info.offset)
                            buffer.get(data)
                            samples.add(Sample(data, info.presentationTimeUs - firstTimeUs, info.flags and MediaCodec.BUFFER_FLAG_KEY_FRAME))
                        }
                        encoder.releaseOutputBuffer(index, false)
                        if (info.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0) return
                    }
                }
            }
        }

        val frames = (seconds * fps).toInt()
        val start = System.nanoTime()
        val paint = Paint(Paint.ANTI_ALIAS_FLAG)
        for (frame in 0 until frames) {
            val canvas = surface.lockHardwareCanvas()
            // Draw upright as displayed: turned a quarter left in the stored
            // frame, which the rotation metadata turns back.
            canvas.save()
            if (rotation == 90) {
                canvas.translate(0f, height.toFloat())
                canvas.rotate(-90f)
                drawFrame(canvas, height, width, frame / fps.toDouble(), paint)
            } else {
                drawFrame(canvas, width, height, frame / fps.toDouble(), paint)
            }
            canvas.restore()
            surface.unlockCanvasAndPost(canvas)
            drain(false)
            val next = start + ((frame + 1) * 1_000_000_000L / fps)
            val wait = (next - System.nanoTime()) / 1_000_000
            if (wait > 0) Thread.sleep(wait)
        }
        encoder.signalEndOfInputStream()
        drain(true)
        encoder.stop()
        encoder.release()
        surface.release()
        return outputFormat!! to samples
    }

    private fun drawFrame(canvas: Canvas, width: Int, height: Int, time: Double, paint: Paint) {
        val hue = ((time * 40) % 360).toFloat()
        canvas.drawColor(Color.HSVToColor(floatArrayOf(hue, 0.55f, 0.35f)))
        val unit = minOf(width, height).toFloat()
        for (i in 0 until 7) {
            val angle = time * (0.6 + i * 0.15) + i
            val x = width / 2f + (width * 0.38f) * cos(angle).toFloat()
            val y = height / 2f + (height * 0.38f) * sin(angle * 1.3).toFloat()
            paint.color = Color.HSVToColor(220, floatArrayOf((hue + i * 50) % 360, 0.75f, 1f))
            canvas.drawCircle(x, y, unit * (0.08f + 0.02f * i), paint)
        }
        // Fine stripes give the encoder real detail to work with.
        paint.color = Color.argb(60, 255, 255, 255)
        val step = unit / 24
        var x = ((time * 80) % step).toFloat()
        while (x < width) {
            canvas.drawRect(x, 0f, x + step / 3, height.toFloat(), paint)
            x += step
        }
        paint.color = Color.WHITE
        paint.textSize = unit / 9
        paint.textAlign = Paint.Align.CENTER
        canvas.drawText("%.1f s".format(time), width / 2f, height / 2f + unit / 30, paint)
        // An arrow pointing up, so a wrong rotation is easy to spot.
        paint.textSize = unit / 6
        canvas.drawText("↑", width / 2f, height * 0.25f, paint)
    }

    private fun encodeAudio(seconds: Double): Pair<MediaFormat, List<Sample>> {
        val sampleRate = 44100
        val channels = 2
        val format = MediaFormat.createAudioFormat(MediaFormat.MIMETYPE_AUDIO_AAC, sampleRate, channels).apply {
            setInteger(MediaFormat.KEY_AAC_PROFILE, MediaCodecInfo.CodecProfileLevel.AACObjectLC)
            setInteger(MediaFormat.KEY_BIT_RATE, 192_000)
        }
        val encoder = MediaCodec.createEncoderByType(MediaFormat.MIMETYPE_AUDIO_AAC)
        encoder.configure(format, null, null, MediaCodec.CONFIGURE_FLAG_ENCODE)
        encoder.start()
        val totalFrames = (seconds * sampleRate).toLong()
        var written = 0L
        var inputDone = false
        val samples = mutableListOf<Sample>()
        var outputFormat: MediaFormat? = null
        val info = MediaCodec.BufferInfo()
        while (true) {
            if (!inputDone) {
                val index = encoder.dequeueInputBuffer(10_000)
                if (index >= 0) {
                    val buffer = encoder.getInputBuffer(index)!!.order(ByteOrder.LITTLE_ENDIAN)
                    buffer.clear()
                    val frames = minOf(1024L, totalFrames - written, (buffer.capacity() / (2 * channels)).toLong()).toInt()
                    for (i in 0 until frames) {
                        val t = (written + i).toDouble() / sampleRate
                        val value = (sin(2 * PI * 440 * t) * 0.3 + sin(2 * PI * 660 * t) * 0.2) * Short.MAX_VALUE
                        repeat(channels) { buffer.putShort(value.toInt().toShort()) }
                    }
                    val timeUs = written * 1_000_000 / sampleRate
                    written += frames
                    inputDone = written >= totalFrames
                    encoder.queueInputBuffer(index, 0, frames * 2 * channels, timeUs, if (inputDone) MediaCodec.BUFFER_FLAG_END_OF_STREAM else 0)
                }
            }
            val index = encoder.dequeueOutputBuffer(info, 10_000)
            if (index == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED) {
                outputFormat = encoder.outputFormat
            } else if (index >= 0) {
                val buffer = encoder.getOutputBuffer(index)!!
                if (info.flags and MediaCodec.BUFFER_FLAG_CODEC_CONFIG == 0 && info.size > 0) {
                    val data = ByteArray(info.size)
                    buffer.position(info.offset)
                    buffer.get(data)
                    samples.add(Sample(data, info.presentationTimeUs, 0))
                }
                encoder.releaseOutputBuffer(index, false)
                if (info.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0) break
            }
        }
        encoder.stop()
        encoder.release()
        return outputFormat!! to samples
    }
}
