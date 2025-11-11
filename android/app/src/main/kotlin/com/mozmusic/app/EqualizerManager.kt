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
    private var visualizer: Visualizer? = null
    private var environmentalReverb: EnvironmentalReverb? = null
    
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
                "initEnvironmentalReverb" -> {
                    val audioSessionId = call.argument<Int>("audioSessionId") ?: 0
                    initEnvironmentalReverb(audioSessionId, result)
                }
                "setEnvironmentalReverbProperty" -> {
                    val property = call.argument<String>("property") ?: ""
                    val value = call.argument<Int>("value") ?: 0
                    setEnvironmentalReverbProperty(property, value, result)
                }
                "initializeVisualizer" -> {
                    val audioSessionId = call.argument<Int>("audioSessionId") ?: 0
                    initializeVisualizer(audioSessionId, result)
                }
                "getWaveform" -> {
                    getWaveform(result)
                }
                "getFft" -> {
                    getFft(result)
                }
                "saveSettings" -> {
                                    saveSettings(result)
                                }
                "loadSettings" -> {
                    val settings = call.argument<Map<String, Any>>("settings") ?: emptyMap()
                    loadSettings(settings, result)
                }
                "getBassBoostStrength" -> {
                    getBassBoostStrength(result)
                }
                "getVirtualizerStrength" -> {
                    getVirtualizerStrength(result)
                }
                "getCurrentPreset" -> {
                    getCurrentPreset(result)
                }
                "getBandFreqRange" -> {
                   val band = call.argument<Int>("band") ?: 0
                    getBandFreqRange(band, result)
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
private fun initEnvironmentalReverb(audioSessionId: Int, result: Result) {
    try {
        environmentalReverb = EnvironmentalReverb(0, audioSessionId).apply {
            enabled = false
        }
        result.success(true)
    } catch (e: Exception) {
        result.error("ENV_REVERB_INIT_ERROR", e.message, null)
    }
}

private fun getBassBoostStrength(result: Result) {
    try {
        val strength = bassBoost?.roundedStrength ?: 0
        result.success(strength.toInt())
    } catch (e: Exception) {
        result.error("GET_BASS_ERROR", e.message, null)
    }
}

private fun getVirtualizerStrength(result: Result) {
    try {
        val strength = virtualizer?.roundedStrength ?: 0
        result.success(strength.toInt())
    } catch (e: Exception) {
        result.error("GET_VIRTUALIZER_ERROR", e.message, null)
    }
}

private fun getCurrentPreset(result: Result) {
    try {
        val preset = equalizer?.currentPreset ?: -1
        result.success(preset.toInt())
    } catch (e: Exception) {
        result.error("GET_PRESET_ERROR", e.message, null)
    }
}

private fun getBandFreqRange(band: Int, result: Result) {
    try {
        val freqRange = equalizer?.getBandFreqRange(band.toShort())
        result.success(listOf(freqRange?.get(0) ?: 0, freqRange?.get(1) ?: 0))
    } catch (e: Exception) {
        result.error("GET_FREQ_RANGE_ERROR", e.message, null)
    }
}
private fun saveSettings(result: Result) {
    try {
        val settings = mutableMapOf<String, Any>()
        
        // Save equalizer bands
        val bands = mutableListOf<Int>()
        val numBands = equalizer?.numberOfBands?.toInt() ?: 0
        for (i in 0 until numBands) {
            bands.add(equalizer?.getBandLevel(i.toShort())?.toInt() ?: 0)
        }
        settings["bands"] = bands
        settings["enabled"] = equalizer?.enabled ?: false
        settings["currentPreset"] = equalizer?.currentPreset?.toInt() ?: -1
        
        // Save effects
        settings["bassBoost"] = bassBoost?.roundedStrength?.toInt() ?: 0
        settings["bassBoostEnabled"] = bassBoost?.enabled ?: false
        settings["virtualizer"] = virtualizer?.roundedStrength?.toInt() ?: 0
        settings["virtualizerEnabled"] = virtualizer?.enabled ?: false
        
        result.success(settings)
    } catch (e: Exception) {
        result.error("SAVE_SETTINGS_ERROR", e.message, null)
    }
}

private fun loadSettings(settings: Map<String, Any>, result: Result) {
    try {
        // Load equalizer
        val enabled = settings["enabled"] as? Boolean ?: false
        equalizer?.enabled = enabled
        
        val bands = settings["bands"] as? List<Int>
        bands?.forEachIndexed { index, level ->
            equalizer?.setBandLevel(index.toShort(), level.toShort())
        }
        
        // Load effects
        val bassBoostStrength = settings["bassBoost"] as? Int ?: 0
        bassBoost?.setStrength(bassBoostStrength.toShort())
        bassBoost?.enabled = settings["bassBoostEnabled"] as? Boolean ?: false
        
        val virtualizerStrength = settings["virtualizer"] as? Int ?: 0
        virtualizer?.setStrength(virtualizerStrength.toShort())
        virtualizer?.enabled = settings["virtualizerEnabled"] as? Boolean ?: false
        
        result.success(true)
    } catch (e: Exception) {
        result.error("LOAD_SETTINGS_ERROR", e.message, null)
    }
}

private fun setEnvironmentalReverbProperty(property: String, value: Int, result: Result) {
    try {
        when (property) {
            "roomLevel" -> environmentalReverb?.roomLevel = value.toShort()
            "roomHFLevel" -> environmentalReverb?.roomHFLevel = value.toShort()
            "decayTime" -> environmentalReverb?.decayTime = value
            "decayHFRatio" -> environmentalReverb?.decayHFRatio = value.toShort()
            "reflectionsLevel" -> environmentalReverb?.reflectionsLevel = value.toShort()
            "reflectionsDelay" -> environmentalReverb?.reflectionsDelay = value
            "reverbLevel" -> environmentalReverb?.reverbLevel = value.toShort()
            "reverbDelay" -> environmentalReverb?.reverbDelay = value
            "diffusion" -> environmentalReverb?.diffusion = value.toShort()
            "density" -> environmentalReverb?.density = value.toShort()
        }
        result.success(null)
    } catch (e: Exception) {
        result.error("SET_ENV_REVERB_ERROR", e.message, null)
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
    private fun initializeVisualizer(audioSessionId: Int, result: Result) {
    try {
        visualizer?.release()
        visualizer = Visualizer(audioSessionId).apply {
            captureSize = Visualizer.getCaptureSizeRange()[1]
            enabled = true
        }
        result.success(true)
    } catch (e: Exception) {
        result.error("VISUALIZER_INIT_ERROR", e.message, null)
    }
}

private fun getWaveform(result: Result) {
    try {
        val waveform = ByteArray(visualizer?.captureSize ?: 0)
        visualizer?.getWaveForm(waveform)
        result.success(waveform.toList())
    } catch (e: Exception) {
        result.error("GET_WAVEFORM_ERROR", e.message, null)
    }
}
private fun getFft(result: Result) {
    try {
        val fft = ByteArray(visualizer?.captureSize ?: 0)
        visualizer?.getFft(fft)
        result.success(fft.toList())
    } catch (e: Exception) {
        result.error("GET_FFT_ERROR", e.message, null)
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
