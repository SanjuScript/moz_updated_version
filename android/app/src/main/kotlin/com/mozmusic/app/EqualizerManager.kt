// EqualizerManager.kt
package com.mozmusic.app

import android.media.audiofx.*
import android.util.Log
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class EqualizerManager : MethodCallHandler {
    private var equalizer: Equalizer? = null
    private var bassBoost: BassBoost? = null
    private var virtualizer: Virtualizer? = null
    private var presetReverb: PresetReverb? = null
    private var loudnessEnhancer: LoudnessEnhancer? = null
    
    companion object {
        private const val TAG = "EqualizerManager"
        const val CHANNEL_NAME = "com.mozmusic.app/equalizer"
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        try {
            when (call.method) {
                "initialize" -> {
                    val audioSessionId = call.argument<Int>("audioSessionId") ?: 0
                    initialize(audioSessionId, result)
                }
                "setEnabled" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: false
                    setEnabled(enabled, result)
                }
                "getNumberOfBands" -> {
                    getNumberOfBands(result)
                }
                "getBandLevelRange" -> {
                    getBandLevelRange(result)
                }
                "getCenterFreq" -> {
                    val band = call.argument<Int>("band") ?: 0
                    getCenterFreq(band, result)
                }
                "setBandLevel" -> {
                    val band = call.argument<Int>("band") ?: 0
                    val level = call.argument<Int>("level") ?: 0
                    setBandLevel(band, level, result)
                }
                "getBandLevel" -> {
                    val band = call.argument<Int>("band") ?: 0
                    getBandLevel(band, result)
                }
                "getPresets" -> {
                    getPresets(result)
                }
                "usePreset" -> {
                    val preset = call.argument<Int>("preset") ?: 0
                    usePreset(preset, result)
                }
                "setBassBoost" -> {
                    val strength = call.argument<Int>("strength") ?: 0
                    setBassBoost(strength, result)
                }
                "setBassBoostEnabled" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: false
                    setBassBoostEnabled(enabled, result)
                }
                "setVirtualizer" -> {
                    val strength = call.argument<Int>("strength") ?: 0
                    setVirtualizer(strength, result)
                }
                "setVirtualizerEnabled" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: false
                    setVirtualizerEnabled(enabled, result)
                }
                "setReverb" -> {
                    val preset = call.argument<Int>("preset") ?: 0
                    setReverb(preset, result)
                }
                "setReverbEnabled" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: false
                    setReverbEnabled(enabled, result)
                }
                "setLoudnessGain" -> {
                    val gain = call.argument<Int>("gain") ?: 0
                    setLoudnessGain(gain, result)
                }
                "setLoudnessEnabled" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: false
                    setLoudnessEnabled(enabled, result)
                }
                "release" -> {
                    release(result)
                }
                else -> {
                    result.notImplemented()
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error in onMethodCall: ${e.message}", e)
            result.error("ERROR", e.message, null)
        }
    }

    private fun initialize(audioSessionId: Int, result: Result) {
        try {
            // Release existing instances
            release(null)
            
            // Initialize Equalizer
            equalizer = Equalizer(0, audioSessionId).apply {
                enabled = false
            }
            
            // Initialize Bass Boost
            bassBoost = BassBoost(0, audioSessionId).apply {
                enabled = false
            }
            
            // Initialize Virtualizer
            virtualizer = Virtualizer(0, audioSessionId).apply {
                enabled = false
            }
            
            // Initialize Preset Reverb
            presetReverb = PresetReverb(0, audioSessionId).apply {
                enabled = false
            }
            
            // Initialize Loudness Enhancer (API 19+)
            try {
                loudnessEnhancer = LoudnessEnhancer(audioSessionId).apply {
                    enabled = false
                }
            } catch (e: Exception) {
                Log.w(TAG, "LoudnessEnhancer not available: ${e.message}")
            }
            
            Log.d(TAG, "Equalizer initialized with session ID: $audioSessionId")
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "Error initializing equalizer: ${e.message}", e)
            result.error("INIT_ERROR", e.message, null)
        }
    }

    private fun setEnabled(enabled: Boolean, result: Result) {
        try {
            equalizer?.enabled = enabled
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "Error setting enabled: ${e.message}", e)
            result.error("SET_ENABLED_ERROR", e.message, null)
        }
    }

    private fun getNumberOfBands(result: Result) {
        try {
            val numberOfBands = equalizer?.numberOfBands?.toInt() ?: 0
            result.success(numberOfBands)
        } catch (e: Exception) {
            Log.e(TAG, "Error getting number of bands: ${e.message}", e)
            result.error("GET_BANDS_ERROR", e.message, null)
        }
    }

    private fun getBandLevelRange(result: Result) {
        try {
            val range = equalizer?.bandLevelRange ?: shortArrayOf(-1500, 1500)
            result.success(listOf(range[0].toInt(), range[1].toInt()))
        } catch (e: Exception) {
            Log.e(TAG, "Error getting band level range: ${e.message}", e)
            result.error("GET_RANGE_ERROR", e.message, null)
        }
    }

    private fun getCenterFreq(band: Int, result: Result) {
        try {
            val freq = equalizer?.getCenterFreq(band.toShort()) ?: 0
            result.success(freq)
        } catch (e: Exception) {
            Log.e(TAG, "Error getting center frequency: ${e.message}", e)
            result.error("GET_FREQ_ERROR", e.message, null)
        }
    }

    private fun setBandLevel(band: Int, level: Int, result: Result) {
        try {
            equalizer?.setBandLevel(band.toShort(), level.toShort())
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "Error setting band level: ${e.message}", e)
            result.error("SET_LEVEL_ERROR", e.message, null)
        }
    }

    private fun getBandLevel(band: Int, result: Result) {
        try {
            val level = equalizer?.getBandLevel(band.toShort()) ?: 0
            result.success(level.toInt())
        } catch (e: Exception) {
            Log.e(TAG, "Error getting band level: ${e.message}", e)
            result.error("GET_LEVEL_ERROR", e.message, null)
        }
    }

    private fun getPresets(result: Result) {
        try {
            val numberOfPresets = equalizer?.numberOfPresets?.toInt() ?: 0
            val presets = mutableListOf<String>()
            
            for (i in 0 until numberOfPresets) {
                val presetName = equalizer?.getPresetName(i.toShort()) ?: "Preset $i"
                presets.add(presetName)
            }
            
            result.success(presets)
        } catch (e: Exception) {
            Log.e(TAG, "Error getting presets: ${e.message}", e)
            result.error("GET_PRESETS_ERROR", e.message, null)
        }
    }

    private fun usePreset(preset: Int, result: Result) {
        try {
            equalizer?.usePreset(preset.toShort())
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "Error using preset: ${e.message}", e)
            result.error("USE_PRESET_ERROR", e.message, null)
        }
    }

    private fun setBassBoost(strength: Int, result: Result) {
        try {
            bassBoost?.setStrength(strength.toShort())
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "Error setting bass boost: ${e.message}", e)
            result.error("SET_BASS_ERROR", e.message, null)
        }
    }

    private fun setBassBoostEnabled(enabled: Boolean, result: Result) {
        try {
            bassBoost?.enabled = enabled
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "Error setting bass boost enabled: ${e.message}", e)
            result.error("SET_BASS_ENABLED_ERROR", e.message, null)
        }
    }

    private fun setVirtualizer(strength: Int, result: Result) {
        try {
            virtualizer?.setStrength(strength.toShort())
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "Error setting virtualizer: ${e.message}", e)
            result.error("SET_VIRTUALIZER_ERROR", e.message, null)
        }
    }

    private fun setVirtualizerEnabled(enabled: Boolean, result: Result) {
        try {
            virtualizer?.enabled = enabled
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "Error setting virtualizer enabled: ${e.message}", e)
            result.error("SET_VIRTUALIZER_ENABLED_ERROR", e.message, null)
        }
    }

    private fun setReverb(preset: Int, result: Result) {
        try {
            presetReverb?.preset = preset.toShort()
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "Error setting reverb: ${e.message}", e)
            result.error("SET_REVERB_ERROR", e.message, null)
        }
    }

    private fun setReverbEnabled(enabled: Boolean, result: Result) {
        try {
            presetReverb?.enabled = enabled
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "Error setting reverb enabled: ${e.message}", e)
            result.error("SET_REVERB_ENABLED_ERROR", e.message, null)
        }
    }

    private fun setLoudnessGain(gain: Int, result: Result) {
        try {
            loudnessEnhancer?.setTargetGain(gain)
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "Error setting loudness gain: ${e.message}", e)
            result.error("SET_LOUDNESS_ERROR", e.message, null)
        }
    }

    private fun setLoudnessEnabled(enabled: Boolean, result: Result) {
        try {
            loudnessEnhancer?.enabled = enabled
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "Error setting loudness enabled: ${e.message}", e)
            result.error("SET_LOUDNESS_ENABLED_ERROR", e.message, null)
        }
    }

    private fun release(result: Result?) {
        try {
            equalizer?.release()
            equalizer = null
            
            bassBoost?.release()
            bassBoost = null
            
            virtualizer?.release()
            virtualizer = null
            
            presetReverb?.release()
            presetReverb = null
            
            loudnessEnhancer?.release()
            loudnessEnhancer = null
            
            Log.d(TAG, "Equalizer released")
            result?.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "Error releasing equalizer: ${e.message}", e)
            result?.error("RELEASE_ERROR", e.message, null)
        }
    }
}
