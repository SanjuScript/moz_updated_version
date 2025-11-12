package com.mozmusic.app

import android.content.Context
import android.media.AudioManager
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : AudioServiceActivity() {
    private lateinit var equalizerManager: EqualizerManager
    private lateinit var volumeManager: VolumeManager
    private lateinit var safHandler: SAFHandler
    private lateinit var metadataManager: MetadataManager

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        equalizerManager = EqualizerManager()
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            EqualizerManager.CHANNEL_NAME
        ).setMethodCallHandler(equalizerManager)


        volumeManager = VolumeManager(this)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            VolumeManager.CHANNEL_NAME
        ).setMethodCallHandler(volumeManager)

        safHandler = SAFHandler(applicationContext, this)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SAFHandler.CHANNEL_NAME
        ).setMethodCallHandler(safHandler)

        // Metadata Editor setup
       metadataManager = MetadataManager(applicationContext, safHandler)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            MetadataManager.CHANNEL_NAME
        ).setMethodCallHandler(metadataManager)
    }
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: android.content.Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        safHandler.onActivityResult(requestCode, resultCode, data)
    }
}
