class EqualizerData {
  final bool enabled;
  final List<BandData> bands;
  final int? currentPreset;
  final BassBoostData bassBoost;
  final VirtualizerData virtualizer;
  final ReverbData reverb;
  final LoudnessData loudness;

  EqualizerData({
    this.enabled = false,
    this.bands = const [],
    this.currentPreset,
    this.bassBoost = const BassBoostData(),
    this.virtualizer = const VirtualizerData(),
    this.reverb = const ReverbData(),
    this.loudness = const LoudnessData(),
  });

  EqualizerData copyWith({
    bool? enabled,
    List<BandData>? bands,
    int? currentPreset,
    BassBoostData? bassBoost,
    VirtualizerData? virtualizer,
    ReverbData? reverb,
    LoudnessData? loudness,
  }) {
    return EqualizerData(
      enabled: enabled ?? this.enabled,
      bands: bands ?? this.bands,
      currentPreset: currentPreset ?? this.currentPreset,
      bassBoost: bassBoost ?? this.bassBoost,
      virtualizer: virtualizer ?? this.virtualizer,
      reverb: reverb ?? this.reverb,
      loudness: loudness ?? this.loudness,
    );
  }
}

class BandData {
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

  BandData copyWith({int? level}) {
    return BandData(
      index: index,
      centerFreq: centerFreq,
      level: level ?? this.level,
      minLevel: minLevel,
      maxLevel: maxLevel,
    );
  }
}

class BassBoostData {
  final bool enabled;
  final int strength;

  const BassBoostData({this.enabled = false, this.strength = 0});

  BassBoostData copyWith({bool? enabled, int? strength}) {
    return BassBoostData(
      enabled: enabled ?? this.enabled,
      strength: strength ?? this.strength,
    );
  }
}

class VirtualizerData {
  final bool enabled;
  final int strength;

  const VirtualizerData({this.enabled = false, this.strength = 0});

  VirtualizerData copyWith({bool? enabled, int? strength}) {
    return VirtualizerData(
      enabled: enabled ?? this.enabled,
      strength: strength ?? this.strength,
    );
  }
}

class ReverbData {
  final bool enabled;
  final int preset;

  const ReverbData({this.enabled = false, this.preset = 0});

  ReverbData copyWith({bool? enabled, int? preset}) {
    return ReverbData(
      enabled: enabled ?? this.enabled,
      preset: preset ?? this.preset,
    );
  }
}

class LoudnessData {
  final bool enabled;
  final int gain;

  const LoudnessData({this.enabled = false, this.gain = 0});

  LoudnessData copyWith({bool? enabled, int? gain}) {
    return LoudnessData(
      enabled: enabled ?? this.enabled,
      gain: gain ?? this.gain,
    );
  }
}
