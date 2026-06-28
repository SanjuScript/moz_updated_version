package com.mozmusic.app

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.os.Parcelable
import android.provider.OpenableColumns
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : AudioServiceActivity() {
    private lateinit var equalizerManager: EqualizerManager
    private var externalAudioChannel: MethodChannel? = null
    private var initialAudioPath: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        intent?.let { handleIntent(it, isInitial = true) }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleIntent(intent, isInitial = false)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        equalizerManager = EqualizerManager(this)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            EqualizerManager.CHANNEL_NAME
        ).setMethodCallHandler(equalizerManager)

        externalAudioChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.mozmusic.app/external_audio_handler"
        ).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "getInitialAudio" -> {
                        val path = initialAudioPath
                        initialAudioPath = null
                        result.success(path)
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            }
        }
    }

    private fun handleIntent(intent: Intent, isInitial: Boolean) {
        if (Intent.ACTION_VIEW == intent.action || Intent.ACTION_SEND == intent.action) {
            val uri = if (Intent.ACTION_SEND == intent.action) {
                intent.getParcelableExtra<Parcelable>(Intent.EXTRA_STREAM) as? Uri
            } else {
                intent.data
            }
            uri?.let {
                val resolvedPath = resolveAndCacheUri(it)
                if (resolvedPath != null) {
                    if (isInitial) {
                        initialAudioPath = resolvedPath
                    } else {
                        externalAudioChannel?.invokeMethod("onAudioOpened", resolvedPath)
                    }
                }
            }
        }
    }

    private fun resolveAndCacheUri(uri: Uri): String? {
        try {
            val contentResolver = contentResolver
            var fileName = "temp_external_audio.mp3"
            
            contentResolver.query(uri, null, null, null, null)?.use { cursor ->
                val nameIndex = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                if (nameIndex != -1 && cursor.moveToFirst()) {
                    val name = cursor.getString(nameIndex)
                    if (!name.isNullOrEmpty()) {
                        fileName = name
                    }
                }
            }

            // Sanitize filename
            fileName = File(fileName).name

            val externalAudioDir = File(cacheDir, "external_audio")
            if (!externalAudioDir.exists()) {
                externalAudioDir.mkdirs()
            } else {
                // Clean up previous files to avoid storage build-up
                externalAudioDir.listFiles()?.forEach { file ->
                    try {
                        file.delete()
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }
                }
            }

            val tempFile = File(externalAudioDir, fileName)

            contentResolver.openInputStream(uri)?.use { inputStream ->
                FileOutputStream(tempFile).use { outputStream ->
                    inputStream.copyTo(outputStream)
                }
            }

            return tempFile.absolutePath
        } catch (e: Exception) {
            e.printStackTrace()
            return null
        }
    }
}
