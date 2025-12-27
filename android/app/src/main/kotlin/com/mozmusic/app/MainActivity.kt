package com.mozmusic.app
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : AudioServiceActivity() {
    private lateinit var equalizerManager: EqualizerManager

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        equalizerManager = EqualizerManager()

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            EqualizerManager.CHANNEL_NAME
        ).setMethodCallHandler(equalizerManager)

    }

}
