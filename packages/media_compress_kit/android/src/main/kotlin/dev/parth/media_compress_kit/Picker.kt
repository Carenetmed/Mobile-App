package dev.parth.media_compress_kit

import android.app.Activity
import android.content.ClipData
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.ext.SdkExtensions
import android.provider.MediaStore
import android.provider.OpenableColumns
import android.webkit.MimeTypeMap
import java.io.File

/**
 * The system's media picker. It needs no storage permission: Android 11 and
 * later (with the SDK extension) show the Photo Picker, older versions the
 * document picker. Picked files are copied into the plugin's cache.
 */
internal object Picker {
    const val REQUEST_CODE = 0x6d63 // "mc"

    fun intent(type: String, multiple: Boolean, maxItems: Int?): Intent {
        val mimeType = when (type) {
            "image" -> "image/*"
            "video" -> "video/*"
            else -> null
        }
        if (isPhotoPickerAvailable()) {
            return Intent(MediaStore.ACTION_PICK_IMAGES).apply {
                mimeType?.let { setType(it) }
                if (multiple) {
                    val limit = MediaStore.getPickImagesMaxLimit()
                    putExtra(MediaStore.EXTRA_PICK_IMAGES_MAX, minOf(maxItems ?: limit, limit))
                }
            }
        }
        return Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            if (mimeType != null) {
                setType(mimeType)
            } else {
                setType("*/*")
                putExtra(Intent.EXTRA_MIME_TYPES, arrayOf("image/*", "video/*"))
            }
            putExtra(Intent.EXTRA_ALLOW_MULTIPLE, multiple)
        }
    }

    private fun isPhotoPickerAvailable(): Boolean = when {
        Build.VERSION.SDK_INT >= 33 -> true
        Build.VERSION.SDK_INT >= 30 -> SdkExtensions.getExtensionVersion(Build.VERSION_CODES.R) >= 2
        else -> false
    }

    /** The picked URIs in [data], at most [maxItems]. */
    fun uris(resultCode: Int, data: Intent?, maxItems: Int?): List<Uri> {
        if (resultCode != Activity.RESULT_OK || data == null) return emptyList()
        val clip: ClipData? = data.clipData
        val uris = if (clip != null) {
            (0 until clip.itemCount).map { clip.getItemAt(it).uri }
        } else {
            listOfNotNull(data.data)
        }
        return if (maxItems != null) uris.take(maxItems) else uris
    }

    /** Copies [uri] into the cache, keeping its name, and returns the file's path. */
    fun copy(context: Context, uri: Uri): String {
        val resolver = context.contentResolver
        var name: String? = null
        resolver.query(uri, arrayOf(OpenableColumns.DISPLAY_NAME), null, null, null)?.use { cursor ->
            if (cursor.moveToFirst()) name = cursor.getString(0)
        }
        var fileName = (name ?: "media").replace(Regex("[/\\\\:*?\"<>|]"), "_")
        if (!fileName.contains('.')) {
            MimeTypeMap.getSingleton().getExtensionFromMimeType(resolver.getType(uri))?.let {
                fileName += ".$it"
            }
        }
        // A folder per pick keeps the original names without clashes.
        val folder = File(MediaCompressKitPlugin.cacheDir(context), "picked/${System.nanoTime()}")
        folder.mkdirs()
        val file = File(folder, fileName)
        val input = resolver.openInputStream(uri)
            ?: throw MediaException("FILE_NOT_FOUND", "Can't read the picked file.")
        input.use { source -> file.outputStream().use { source.copyTo(it, 1 shl 16) } }
        return file.absolutePath
    }
}
