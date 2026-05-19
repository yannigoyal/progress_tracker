package ghost.codes7.vaultlog

import android.content.ActivityNotFoundException
import android.content.ContentValues
import android.content.Intent
import android.media.MediaScannerConnection
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.io.IOException

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            DOWNLOADS_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "saveToDownloads" -> saveToDownloads(call, result)
                "openUri" -> openUri(call, result)
                else -> result.notImplemented()
            }
        }
    }

    private fun saveToDownloads(call: MethodCall, result: MethodChannel.Result) {
        val bytes = call.argument<ByteArray>("bytes")
        val fileName = call.argument<String>("fileName")
        val mimeType = call.argument<String>("mimeType")

        if (bytes == null || fileName.isNullOrBlank() || mimeType.isNullOrBlank()) {
            result.error("INVALID_ARGUMENTS", "Missing report file data.", null)
            return
        }

        try {
            val uri = saveReport(fileName, mimeType, bytes)
            result.success(
                mapOf(
                    "uri" to uri.toString(),
                    "displayPath" to "Downloads/$fileName",
                ),
            )
        } catch (error: Exception) {
            result.error("SAVE_FAILED", error.message ?: "Unable to save report.", null)
        }
    }

    private fun openUri(call: MethodCall, result: MethodChannel.Result) {
        val uri = call.argument<String>("uri")?.let(Uri::parse)
        val mimeType = call.argument<String>("mimeType")

        if (uri == null || mimeType.isNullOrBlank()) {
            result.error("INVALID_ARGUMENTS", "Missing report URI.", null)
            return
        }

        try {
            val intent = Intent(Intent.ACTION_VIEW).apply {
                setDataAndType(uri, mimeType)
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }
            startActivity(intent)
            result.success(null)
        } catch (error: ActivityNotFoundException) {
            result.error("OPEN_FAILED", "No app found to open this report.", null)
        } catch (error: Exception) {
            result.error("OPEN_FAILED", error.message ?: "Unable to open report.", null)
        }
    }

    private fun saveReport(fileName: String, mimeType: String, bytes: ByteArray): Uri {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            saveReportWithMediaStore(fileName, mimeType, bytes)
        } else {
            saveReportLegacy(fileName, mimeType, bytes)
        }
    }

    private fun saveReportWithMediaStore(
        fileName: String,
        mimeType: String,
        bytes: ByteArray,
    ): Uri {
        val values = ContentValues().apply {
            put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
            put(MediaStore.MediaColumns.MIME_TYPE, mimeType)
            put(MediaStore.MediaColumns.RELATIVE_PATH, Environment.DIRECTORY_DOWNLOADS)
            put(MediaStore.MediaColumns.IS_PENDING, 1)
        }
        val resolver = applicationContext.contentResolver
        val collection = MediaStore.Downloads.getContentUri(
            MediaStore.VOLUME_EXTERNAL_PRIMARY,
        )
        val uri = resolver.insert(collection, values)
            ?: throw IOException("Unable to create Downloads file.")

        var completed = false
        try {
            resolver.openOutputStream(uri)?.use { output ->
                output.write(bytes)
            } ?: throw IOException("Unable to write Downloads file.")

            values.clear()
            values.put(MediaStore.MediaColumns.IS_PENDING, 0)
            resolver.update(uri, values, null, null)
            completed = true
            return uri
        } finally {
            if (!completed) resolver.delete(uri, null, null)
        }
    }

    @Suppress("DEPRECATION")
    private fun saveReportLegacy(
        fileName: String,
        mimeType: String,
        bytes: ByteArray,
    ): Uri {
        val downloads = Environment.getExternalStoragePublicDirectory(
            Environment.DIRECTORY_DOWNLOADS,
        )
        if (!downloads.exists() && !downloads.mkdirs()) {
            throw IOException("Unable to create Downloads folder.")
        }

        val file = File(downloads, fileName)
        FileOutputStream(file).use { output -> output.write(bytes) }

        val values = ContentValues().apply {
            put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
            put(MediaStore.MediaColumns.MIME_TYPE, mimeType)
            put(MediaStore.MediaColumns.DATA, file.absolutePath)
        }
        val uri = contentResolver.insert(MediaStore.Files.getContentUri("external"), values)
            ?: Uri.fromFile(file)

        MediaScannerConnection.scanFile(
            this,
            arrayOf(file.absolutePath),
            arrayOf(mimeType),
            null,
        )
        return uri
    }

    private companion object {
        const val DOWNLOADS_CHANNEL = "vaultlog/downloads"
    }
}
