// EqualizerManager.swift
// Place this in: ios/Runner/EqualizerManager.swift

import AVFoundation
import Flutter

class EqualizerManager: NSObject, FlutterPlugin {
    private var audioEngine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    private var eq: AVAudioUnitEQ?
    private var reverb: AVAudioUnitReverb?
    private var distortion: AVAudioUnitDistortion?
    
    // Audio effects
    private var isEqualizerEnabled = false
    private var bassBoostEnabled = false
    private var virtualizerEnabled = false
    private var reverbEnabled = false
    private var loudnessEnabled = false
    
    private var bassBoostStrength: Float = 0
    private var virtualizerStrength: Float = 0
    private var loudnessGain: Float = 0
    
    // EQ Presets (Android-like)
    private let presets: [(name: String, gains: [Float])] = [
        ("Normal", [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]),
        ("Classical", [0, 0, 0, 0, 0, 0, -3, -3, -3, -4]),
        ("Dance", [4, 3, 1, 0, 0, -2, -3, -3, 0, 0]),
        ("Flat", [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]),
        ("Folk", [2, 0, 0, 1, -1, -1, 0, 1, 2, 1]),
        ("Heavy Metal", [3, 2, 0, -1, 1, 2, 0, 0, 2, 3]),
        ("Hip Hop", [4, 3, 0, 1, -1, -1, 0, -1, 1, 2]),
        ("Jazz", [2, 1, 1, 0, -1, -1, 0, 1, 2, 3]),
        ("Pop", [-1, -1, 0, 1, 2, 2, 1, 0, -1, -1]),
        ("Rock", [3, 2, -1, -2, -1, 1, 2, 3, 3, 3])
    ]
    
    static let channelName = "com.mozmusic.app/equalizer"
    
    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: channelName, binaryMessenger: registrar.messenger())
        let instance = EqualizerManager()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            guard let args = call.arguments as? [String: Any],
                  let audioSessionId = args["audioSessionId"] as? Int else {
                result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
                return
            }
            initialize(audioSessionId: audioSessionId, result: result)
            
        case "setEnabled":
            guard let args = call.arguments as? [String: Any],
                  let enabled = args["enabled"] as? Bool else {
                result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
                return
            }
            setEnabled(enabled: enabled, result: result)
            
        case "getNumberOfBands":
            getNumberOfBands(result: result)
            
        case "getBandLevelRange":
            getBandLevelRange(result: result)
            
        case "getCenterFreq":
            guard let args = call.arguments as? [String: Any],
                  let band = args["band"] as? Int else {
                result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
                return
            }
            getCenterFreq(band: band, result: result)
            
        case "setBandLevel":
            guard let args = call.arguments as? [String: Any],
                  let band = args["band"] as? Int,
                  let level = args["level"] as? Int else {
                result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
                return
            }
            setBandLevel(band: band, level: level, result: result)
            
        case "getBandLevel":
            guard let args = call.arguments as? [String: Any],
                  let band = args["band"] as? Int else {
                result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
                return
            }
            getBandLevel(band: band, result: result)
            
        case "getPresets":
            getPresets(result: result)
            
        case "usePreset":
            guard let args = call.arguments as? [String: Any],
                  let preset = args["preset"] as? Int else {
                result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
                return
            }
            usePreset(preset: preset, result: result)
            
        case "setBassBoost":
            guard let args = call.arguments as? [String: Any],
                  let strength = args["strength"] as? Int else {
                result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
                return
            }
            setBassBoost(strength: strength, result: result)
            
        case "setBassBoostEnabled":
            guard let args = call.arguments as? [String: Any],
                  let enabled = args["enabled"] as? Bool else {
                result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
                return
            }
            setBassBoostEnabled(enabled: enabled, result: result)
            
        case "setVirtualizer":
            guard let args = call.arguments as? [String: Any],
                  let strength = args["strength"] as? Int else {
                result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
                return
            }
            setVirtualizer(strength: strength, result: result)
            
        case "setVirtualizerEnabled":
            guard let args = call.arguments as? [String: Any],
                  let enabled = args["enabled"] as? Bool else {
                result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
                return
            }
            setVirtualizerEnabled(enabled: enabled, result: result)
            
        case "setReverb":
            guard let args = call.arguments as? [String: Any],
                  let preset = args["preset"] as? Int else {
                result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
                return
            }
            setReverb(preset: preset, result: result)
            
        case "setReverbEnabled":
            guard let args = call.arguments as? [String: Any],
                  let enabled = args["enabled"] as? Bool else {
                result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
                return
            }
            setReverbEnabled(enabled: enabled, result: result)
            
        case "setLoudnessGain":
            guard let args = call.arguments as? [String: Any],
                  let gain = args["gain"] as? Int else {
                result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
                return
            }
            setLoudnessGain(gain: gain, result: result)
            
        case "setLoudnessEnabled":
            guard let args = call.arguments as? [String: Any],
                  let enabled = args["enabled"] as? Bool else {
                result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
                return
            }
            setLoudnessEnabled(enabled: enabled, result: result)
            
        case "release":
            release(result: result)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // MARK: - Implementation
    
    private func initialize(audioSessionId: Int, result: @escaping FlutterResult) {
        do {
            // Release existing instances
            releaseAudioEngine()
            
            // Create audio engine
            audioEngine = AVAudioEngine()
            playerNode = AVAudioPlayerNode()
            
            // Create 10-band equalizer (matching Android)
            eq = AVAudioUnitEQ(numberOfBands: 10)
            
            // Configure EQ bands with standard frequencies
            let frequencies: [Float] = [31, 62, 125, 250, 500, 1000, 2000, 4000, 8000, 16000]
            for (index, frequency) in frequencies.enumerated() {
                let band = eq!.bands[index]
                band.frequency = frequency
                band.bandwidth = 1.0
                band.bypass = false
                band.filterType = .parametric
                band.gain = 0
            }
            
            // Create reverb unit
            reverb = AVAudioUnitReverb()
            reverb?.wetDryMix = 0
            
            // Create distortion for bass boost simulation
            distortion = AVAudioUnitDistortion()
            distortion?.wetDryMix = 0
            distortion?.preGain = 0
            
            // Attach nodes
            if let engine = audioEngine,
               let player = playerNode,
               let equalizer = eq,
               let reverbUnit = reverb,
               let distortionUnit = distortion {
                
                engine.attach(player)
                engine.attach(equalizer)
                engine.attach(reverbUnit)
                engine.attach(distortionUnit)
                
                // Connect: player -> distortion -> eq -> reverb -> output
                let format = engine.outputNode.inputFormat(forBus: 0)
                
                engine.connect(player, to: distortionUnit, format: format)
                engine.connect(distortionUnit, to: equalizer, format: format)
                engine.connect(equalizer, to: reverbUnit, format: format)
                engine.connect(reverbUnit, to: engine.mainMixerNode, format: format)
                
                try engine.start()
                player.play()
            }
            
            print("EqualizerManager: Initialized successfully")
            result(true)
            
        } catch {
            print("EqualizerManager: Initialization failed - \(error.localizedDescription)")
            result(FlutterError(code: "INIT_ERROR", message: error.localizedDescription, details: nil))
        }
    }
    
    private func setEnabled(enabled: Bool, result: @escaping FlutterResult) {
        isEqualizerEnabled = enabled
        eq?.bypass = !enabled
        result(nil)
    }
    
    private func getNumberOfBands(result: @escaping FlutterResult) {
        result(10) // Fixed 10 bands
    }
    
    private func getBandLevelRange(result: @escaping FlutterResult) {
        // iOS AVAudioUnitEQ supports -96 to 24 dB
        // Converting to millibels (Android uses millibels): -96dB = -9600, +24dB = +2400
        // But to match Android's typical range, we'll use -1500 to 1500 millibels
        result([-1500, 1500])
    }
    
    private func getCenterFreq(band: Int, result: @escaping FlutterResult) {
        guard let eq = eq, band >= 0 && band < eq.bands.count else {
            result(FlutterError(code: "INVALID_BAND", message: "Invalid band index", details: nil))
            return
        }
        
        // Return frequency in millihertz (Android format)
        let freqHz = eq.bands[band].frequency
        let freqMilliHz = Int(freqHz * 1000)
        result(freqMilliHz)
    }
    
    private func setBandLevel(band: Int, level: Int, result: @escaping FlutterResult) {
        guard let eq = eq, band >= 0 && band < eq.bands.count else {
            result(FlutterError(code: "INVALID_BAND", message: "Invalid band index", details: nil))
            return
        }
        
        // Convert millibels to dB: level is in millibels, divide by 100 to get dB
        let gainDB = Float(level) / 100.0
        eq.bands[band].gain = gainDB
        
        result(nil)
    }
    
    private func getBandLevel(band: Int, result: @escaping FlutterResult) {
        guard let eq = eq, band >= 0 && band < eq.bands.count else {
            result(FlutterError(code: "INVALID_BAND", message: "Invalid band index", details: nil))
            return
        }
        
        // Convert dB to millibels
        let gainDB = eq.bands[band].gain
        let gainMillibels = Int(gainDB * 100)
        result(gainMillibels)
    }
    
    private func getPresets(result: @escaping FlutterResult) {
        let presetNames = presets.map { $0.name }
        result(presetNames)
    }
    
    private func usePreset(preset: Int, result: @escaping FlutterResult) {
        guard preset >= 0 && preset < presets.count else {
            result(FlutterError(code: "INVALID_PRESET", message: "Invalid preset index", details: nil))
            return
        }
        
        guard let eq = eq else {
            result(FlutterError(code: "EQ_NOT_INITIALIZED", message: "Equalizer not initialized", details: nil))
            return
        }
        
        let gains = presets[preset].gains
        for (index, gain) in gains.enumerated() {
            if index < eq.bands.count {
                eq.bands[index].gain = gain
            }
        }
        
        result(nil)
    }
    
    private func setBassBoost(strength: Int, result: @escaping FlutterResult) {
        bassBoostStrength = Float(strength)
        
        if bassBoostEnabled {
            applyBassBoost()
        }
        
        result(nil)
    }
    
    private func setBassBoostEnabled(enabled: Bool, result: @escaping FlutterResult) {
        bassBoostEnabled = enabled
        
        if enabled {
            applyBassBoost()
        } else {
            distortion?.wetDryMix = 0
            distortion?.preGain = 0
        }
        
        result(nil)
    }
    
    private func applyBassBoost() {
        guard let distortion = distortion else { return }
        
        // Map strength (0-1000) to distortion parameters
        let normalizedStrength = bassBoostStrength / 1000.0
        
        distortion.loadFactoryPreset(.multiEverythingIsBroken)
        distortion.wetDryMix = normalizedStrength * 20 // 0-20%
        distortion.preGain = normalizedStrength * 10   // 0-10 dB
        
        // Also boost low frequencies in EQ
        if let eq = eq, eq.bands.count > 0 {
            let bassGain = normalizedStrength * 6 // 0-6 dB boost
            eq.bands[0].gain += bassGain  // 31 Hz
            if eq.bands.count > 1 {
                eq.bands[1].gain += bassGain * 0.7  // 62 Hz
            }
        }
    }
    
    private func setVirtualizer(strength: Int, result: @escaping FlutterResult) {
        virtualizerStrength = Float(strength)
        
        if virtualizerEnabled {
            applyVirtualizer()
        }
        
        result(nil)
    }
    
    private func setVirtualizerEnabled(enabled: Bool, result: @escaping FlutterResult) {
        virtualizerEnabled = enabled
        
        if enabled {
            applyVirtualizer()
        } else {
            // Reset reverb
            reverb?.wetDryMix = 0
        }
        
        result(nil)
    }
    
    private func applyVirtualizer() {
        guard let reverb = reverb else { return }
        
        // Map strength (0-1000) to reverb wet/dry mix
        let normalizedStrength = virtualizerStrength / 1000.0
        
        reverb.loadFactoryPreset(.smallRoom)
        reverb.wetDryMix = normalizedStrength * 40 // 0-40%
    }
    
    private func setReverb(preset: Int, result: @escaping FlutterResult) {
        guard let reverb = reverb else {
            result(FlutterError(code: "REVERB_NOT_INITIALIZED", message: "Reverb not initialized", details: nil))
            return
        }
        
        // Map Android reverb presets to iOS presets
        switch preset {
        case 0: reverb.loadFactoryPreset(.smallRoom)
        case 1: reverb.loadFactoryPreset(.mediumRoom)
        case 2: reverb.loadFactoryPreset(.largeRoom)
        case 3: reverb.loadFactoryPreset(.mediumHall)
        case 4: reverb.loadFactoryPreset(.largeHall)
        case 5: reverb.loadFactoryPreset(.plate)
        default: reverb.loadFactoryPreset(.smallRoom)
        }
        
        result(nil)
    }
    
    private func setReverbEnabled(enabled: Bool, result: @escaping FlutterResult) {
        reverbEnabled = enabled
        reverb?.bypass = !enabled
        result(nil)
    }
    
    private func setLoudnessGain(gain: Int, result: @escaping FlutterResult) {
        loudnessGain = Float(gain)
        
        if loudnessEnabled {
            applyLoudness()
        }
        
        result(nil)
    }
    
    private func setLoudnessEnabled(enabled: Bool, result: @escaping FlutterResult) {
        loudnessEnabled = enabled
        
        if enabled {
            applyLoudness()
        } else {
            audioEngine?.mainMixerNode.outputVolume = 1.0
        }
        
        result(nil)
    }
    
    private func applyLoudness() {
        guard let engine = audioEngine else { return }
        
        // Map gain (0-3000) to volume multiplier (1.0-2.0)
        let normalizedGain = loudnessGain / 3000.0
        let volume = 1.0 + normalizedGain
        
        engine.mainMixerNode.outputVolume = volume
    }
    
    private func release(result: @escaping FlutterResult) {
        releaseAudioEngine()
        result(nil)
    }
    
    private func releaseAudioEngine() {
        audioEngine?.stop()
        
        if let player = playerNode {
            player.stop()
        }
        
        eq = nil
        reverb = nil
        distortion = nil
        playerNode = nil
        audioEngine = nil
        
        print("EqualizerManager: Released")
    }
}