import 'package:equatable/equatable.dart';

// Main Equalizer Data
class EqualizerData extends Equatable {
  final bool enabled;
  final List<BandData> bands;
  final int? currentPreset;
  final BassBoostData bassBoost;
  final VirtualizerData virtualizer;
  final LoudnessData loudness;
  final ReverbData reverb;
  final EnvironmentalReverbData environmentalReverb;

  const EqualizerData({
    this.enabled = false,
    required this.bands,
    this.currentPreset,
    this.bassBoost = const BassBoostData(),
    this.virtualizer = const VirtualizerData(),
    this.loudness = const LoudnessData(),
    this.reverb = const ReverbData(),
    this.environmentalReverb = const EnvironmentalReverbData(), // NEW
  });

  EqualizerData copyWith({
    bool? enabled,
    List<BandData>? bands,
    int? currentPreset,
    BassBoostData? bassBoost,
    VirtualizerData? virtualizer,
    LoudnessData? loudness,
    ReverbData? reverb,
    EnvironmentalReverbData? environmentalReverb, // NEW
  }) {
    return EqualizerData(
      enabled: enabled ?? this.enabled,
      bands: bands ?? this.bands,
      currentPreset: currentPreset,
      bassBoost: bassBoost ?? this.bassBoost,
      virtualizer: virtualizer ?? this.virtualizer,
      loudness: loudness ?? this.loudness,
      reverb: reverb ?? this.reverb,
      environmentalReverb:
          environmentalReverb ?? this.environmentalReverb, // NEW
    );
  }

  @override
  List<Object?> get props => [
    enabled,
    bands,
    currentPreset,
    bassBoost,
    virtualizer,
    loudness,
    reverb,
    environmentalReverb, // NEW
  ];
}

// Band Data
class BandData extends Equatable {
  final int index;
  final int centerFreq;
  final int level;
  final int minLevel;
  final int maxLevel;

  const BandData({
    required this.index,
    required this.centerFreq,
    required this.level,
    required this.minLevel,
    required this.maxLevel,
  });

  BandData copyWith({
    int? index,
    int? centerFreq,
    int? level,
    int? minLevel,
    int? maxLevel,
  }) {
    return BandData(
      index: index ?? this.index,
      centerFreq: centerFreq ?? this.centerFreq,
      level: level ?? this.level,
      minLevel: minLevel ?? this.minLevel,
      maxLevel: maxLevel ?? this.maxLevel,
    );
  }

  @override
  List<Object?> get props => [index, centerFreq, level, minLevel, maxLevel];
}

// Bass Boost Data
class BassBoostData extends Equatable {
  final bool enabled;
  final int strength;

  const BassBoostData({this.enabled = false, this.strength = 0});

  BassBoostData copyWith({bool? enabled, int? strength}) {
    return BassBoostData(
      enabled: enabled ?? this.enabled,
      strength: strength ?? this.strength,
    );
  }

  @override
  List<Object?> get props => [enabled, strength];
}

// Virtualizer Data
class VirtualizerData extends Equatable {
  final bool enabled;
  final int strength;

  const VirtualizerData({this.enabled = false, this.strength = 0});

  VirtualizerData copyWith({bool? enabled, int? strength}) {
    return VirtualizerData(
      enabled: enabled ?? this.enabled,
      strength: strength ?? this.strength,
    );
  }

  @override
  List<Object?> get props => [enabled, strength];
}

// Loudness Data
class LoudnessData extends Equatable {
  final bool enabled;
  final int gain;

  const LoudnessData({this.enabled = false, this.gain = 0});

  LoudnessData copyWith({bool? enabled, int? gain}) {
    return LoudnessData(
      enabled: enabled ?? this.enabled,
      gain: gain ?? this.gain,
    );
  }

  @override
  List<Object?> get props => [enabled, gain];
}

// Reverb Data
class ReverbData extends Equatable {
  final bool enabled;
  final int preset;

  const ReverbData({this.enabled = false, this.preset = 0});

  ReverbData copyWith({bool? enabled, int? preset}) {
    return ReverbData(
      enabled: enabled ?? this.enabled,
      preset: preset ?? this.preset,
    );
  }

  @override
  List<Object?> get props => [enabled, preset];
}

// NEW: Environmental Reverb Data - More advanced room simulation
class EnvironmentalReverbData extends Equatable {
  final bool enabled;
  final int roomLevel; // Room effect level at mid frequencies (-9000 to 0 mB)
  final int
  roomHFLevel; // Relative room effect level at high frequencies (-9000 to 0 mB)
  final int decayTime; // Decay time (100 to 20000 ms)
  final int
  decayHFRatio; // Ratio of high frequency decay time to decay time (100 to 2000 permilles)
  final int reflectionsLevel; // Early reflections level (-9000 to 1000 mB)
  final int reflectionsDelay; // Early reflections delay (0 to 300 ms)
  final int reverbLevel; // Late reverberation level (-9000 to 2000 mB)
  final int reverbDelay; // Late reverberation delay (0 to 100 ms)
  final int
  diffusion; // Echo density in late reverberation (0 to 1000 permilles)
  final int
  density; // Modal density in late reverberation (0 to 1000 permilles)

  const EnvironmentalReverbData({
    this.enabled = false,
    this.roomLevel = -1000,
    this.roomHFLevel = -100,
    this.decayTime = 1490,
    this.decayHFRatio = 830,
    this.reflectionsLevel = -2602,
    this.reflectionsDelay = 7,
    this.reverbLevel = 200,
    this.reverbDelay = 11,
    this.diffusion = 1000,
    this.density = 1000,
  });

  EnvironmentalReverbData copyWith({
    bool? enabled,
    int? roomLevel,
    int? roomHFLevel,
    int? decayTime,
    int? decayHFRatio,
    int? reflectionsLevel,
    int? reflectionsDelay,
    int? reverbLevel,
    int? reverbDelay,
    int? diffusion,
    int? density,
  }) {
    return EnvironmentalReverbData(
      enabled: enabled ?? this.enabled,
      roomLevel: roomLevel ?? this.roomLevel,
      roomHFLevel: roomHFLevel ?? this.roomHFLevel,
      decayTime: decayTime ?? this.decayTime,
      decayHFRatio: decayHFRatio ?? this.decayHFRatio,
      reflectionsLevel: reflectionsLevel ?? this.reflectionsLevel,
      reflectionsDelay: reflectionsDelay ?? this.reflectionsDelay,
      reverbLevel: reverbLevel ?? this.reverbLevel,
      reverbDelay: reverbDelay ?? this.reverbDelay,
      diffusion: diffusion ?? this.diffusion,
      density: density ?? this.density,
    );
  }

  @override
  List<Object?> get props => [
    enabled,
    roomLevel,
    roomHFLevel,
    decayTime,
    decayHFRatio,
    reflectionsLevel,
    reflectionsDelay,
    reverbLevel,
    reverbDelay,
    diffusion,
    density,
  ];
}

// NEW: Preset for saving custom configurations
class AudioPresetData extends Equatable {
  final String name;
  final String? description;
  final EqualizerData settings;
  final DateTime createdAt;
  final bool isCustom;

  const AudioPresetData({
    required this.name,
    this.description,
    required this.settings,
    required this.createdAt,
    this.isCustom = true,
  });

  AudioPresetData copyWith({
    String? name,
    String? description,
    EqualizerData? settings,
    DateTime? createdAt,
    bool? isCustom,
  }) {
    return AudioPresetData(
      name: name ?? this.name,
      description: description ?? this.description,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'isCustom': isCustom,
      'enabled': settings.enabled,
      'bands': settings.bands
          .map((b) => {'index': b.index, 'level': b.level})
          .toList(),
      'bassBoost': {
        'enabled': settings.bassBoost.enabled,
        'strength': settings.bassBoost.strength,
      },
      'virtualizer': {
        'enabled': settings.virtualizer.enabled,
        'strength': settings.virtualizer.strength,
      },
      'loudness': {
        'enabled': settings.loudness.enabled,
        'gain': settings.loudness.gain,
      },
      'reverb': {
        'enabled': settings.reverb.enabled,
        'preset': settings.reverb.preset,
      },
      'environmentalReverb': {
        'enabled': settings.environmentalReverb.enabled,
        'roomLevel': settings.environmentalReverb.roomLevel,
        'roomHFLevel': settings.environmentalReverb.roomHFLevel,
        'decayTime': settings.environmentalReverb.decayTime,
        'decayHFRatio': settings.environmentalReverb.decayHFRatio,
        'reflectionsLevel': settings.environmentalReverb.reflectionsLevel,
        'reflectionsDelay': settings.environmentalReverb.reflectionsDelay,
        'reverbLevel': settings.environmentalReverb.reverbLevel,
        'reverbDelay': settings.environmentalReverb.reverbDelay,
        'diffusion': settings.environmentalReverb.diffusion,
        'density': settings.environmentalReverb.density,
      },
    };
  }

  @override
  List<Object?> get props => [name, description, settings, createdAt, isCustom];
}
