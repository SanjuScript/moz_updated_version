package com.mozmusic.app

import android.content.Context
import android.media.AudioManager
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class VolumeManager(private val context: Context) : MethodChannel.MethodCallHandler {
    companion object {
        const val CHANNEL_NAME = "com.mozmusic.app/volume"
    }
    
    private val audioManager: AudioManager = 
        context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
    
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getCurrentVolume" -> {
                val volume = audioManager.getStreamVolume(AudioManager.STREAM_MUSIC)
                result.success(volume)
            }
            "getMaxVolume" -> {
                val maxVolume = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
                result.success(maxVolume)
            }
            "setVolume" -> {
                val volume = call.argument<Int>("volume")
                if (volume != null) {
                    audioManager.setStreamVolume(
                        AudioManager.STREAM_MUSIC, 
                        volume, 
                        AudioManager.FLAG_SHOW_UI
                    )
                    result.success(null)
                } else {
                    result.error("INVALID_ARGUMENT", "Volume cannot be null", null)
                }
            }
            else -> result.notImplemented()
        }
    }
}
