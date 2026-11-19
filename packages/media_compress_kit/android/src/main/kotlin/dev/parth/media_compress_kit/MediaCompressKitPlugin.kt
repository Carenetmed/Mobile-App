package dev.parth.media_compress_kit

import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
import androidx.annotation.OptIn
import androidx.media3.common.util.UnstableApi
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import java.io.File
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

/** A failure reported to Dart with one of the codes MediaCompressException knows. */
internal class MediaException(val code: String, message: String) : Exception(message)

@OptIn(markerClass = [UnstableApi::class])
class MediaCompressKitPlugin :
    FlutterPlugin,
    MethodCallHandler,
    EventChannel.StreamHandler,
    ActivityAware,
    PluginRegistry.ActivityResultListener {
    private lateinit var context: Context
    private lateinit var methods: MethodChannel
    private lateinit var events: EventChannel
    private var sink: EventChannel.EventSink? = null
    private val main = Handler(Looper.getMainLooper())

    // Big bitmaps use a lot of memory, so at most two images are decoded at once.
    private val executor: ExecutorService = Executors.newFixedThreadPool(2)
    private val videos = mutableMapOf<Int, VideoCompressor>()

    // Image jobs by id, set to true when cancelled.
    private val images = ConcurrentHashMap<Int, Boolean>()

    private var activity: ActivityPluginBinding? = null
    private var pickResult: Result? = null
    private var pickLimit: Int? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        methods = MethodChannel(binding.binaryMessenger, "media_compress_kit")
        methods.setMethodCallHandler(this)
        events = EventChannel(binding.binaryMessenger, "media_compress_kit/progress")
        events.setStreamHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methods.setMethodCallHandler(null)
        events.setStreamHandler(null)
        videos.values.toList().forEach { it.cancel() }
        videos.clear()
        executor.shutdown()
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() = onDetachedFromActivity()

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) =
        onAttachedToActivity(binding)

    override fun onDetachedFromActivity() {
        activity?.removeActivityResultListener(this)
        activity = null
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        sink = events
    }

    override fun onCancel(arguments: Any?) {
        sink = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getInfo" -> background(result) {
                MediaInfoReader.read(context, call.argument<String>("path")!!)
            }
            "compressImage" -> compressImage(call, result)
            "estimateImage" -> background(result) { ImageCompressor.estimate(context, call) }
            "pick" -> pick(call, result)
            "thumbnail" -> background(result) { Thumbnails.create(context, call) }
            "compressVideo" -> compressVideo(call, result)
            "cancel" -> {
                val id = call.argument<Int>("id")!!
                videos[id]?.cancel()
                images.replace(id, true)
                result.success(null)
            }
            "cacheDirectory" -> result.success(cacheDir(context).apply { mkdirs() }.absolutePath)
            "clearCache" -> background(result) {
                cacheDir(context).deleteRecursively()
                null
            }
            else -> result.notImplemented()
        }
    }

    private fun compressImage(call: MethodCall, result: Result) {
        val id = call.argument<Int>("id")!!
        images[id] = false
        val job = ImageCompressor.Job(
            progress = { progress -> main.post { sendProgress(id, progress) } },
            isCancelled = { images[id] == true },
        )
        background(result, onDone = { images.remove(id) }) {
            ImageCompressor.compress(context, call, job)
        }
    }

    private fun sendProgress(id: Int, progress: Double) {
        sink?.success(mapOf("id" to id, "progress" to progress))
    }

    private fun pick(call: MethodCall, result: Result) {
        val activity = activity?.activity
        if (activity == null) {
            result.error("FAILED", "The picker needs an activity.", null)
            return
        }
        if (pickResult != null) {
            result.error("FAILED", "The picker is already open.", null)
            return
        }
        pickResult = result
        pickLimit = call.argument<Int>("maxItems")
        val intent = Picker.intent(
            call.argument<String>("type")!!,
            call.argument<Boolean>("multiple")!!,
            pickLimit,
        )
        try {
            activity.startActivityForResult(intent, Picker.REQUEST_CODE)
        } catch (e: Exception) {
            pickResult = null
            result.error("UNSUPPORTED", "No picker on this device: $e", null)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != Picker.REQUEST_CODE) return false
        val result = pickResult ?: return true
        pickResult = null
        val uris = Picker.uris(resultCode, data, pickLimit)
        background(result) { uris.map { Picker.copy(context, it) } }
        return true
    }

    @OptIn(markerClass = [UnstableApi::class])
    private fun compressVideo(call: MethodCall, result: Result) {
        val id = call.argument<Int>("id")!!
        val compressor = try {
            VideoCompressor(context, call)
        } catch (e: MediaException) {
            result.error(e.code, e.message, null)
            return
        }
        videos[id] = compressor
        compressor.start(
            onProgress = { progress -> sendProgress(id, progress) },
            onDone = { map, error ->
                videos.remove(id)
                if (error != null) result.error(error.code, error.message, null)
                else result.success(map)
            },
        )
    }

    private fun background(result: Result, onDone: () -> Unit = {}, work: () -> Any?) {
        executor.execute {
            try {
                val value = work()
                main.post { result.success(value) }
            } catch (e: MediaException) {
                main.post { result.error(e.code, e.message, null) }
            } catch (e: OutOfMemoryError) {
                main.post { result.error("FAILED", "Out of memory: ${e.message}", null) }
            } catch (e: Exception) {
                main.post { result.error("FAILED", e.toString(), null) }
            } finally {
                onDone()
            }
        }
    }

    companion object {
        /** The folder in the app's cache that holds the files this plugin writes. */
        internal fun cacheDir(context: Context) = File(context.cacheDir, "media_compress_kit")

        /** [outputPath], or a new file named with [prefix] and [extension] in [cacheDir]. */
        internal fun outputFile(context: Context, outputPath: String?, prefix: String, extension: String): File {
            val file = if (outputPath != null) {
                File(outputPath)
            } else {
                File(cacheDir(context), "${prefix}_${System.currentTimeMillis()}_${(1000..9999).random()}.$extension")
            }
            file.parentFile?.mkdirs()
            return file
        }
    }
}
