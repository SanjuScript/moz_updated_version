Duration getDynamicMax(Duration playedDuration) {
  const thresholds = [
    Duration(hours: 1),
    Duration(hours: 5),
    Duration(hours: 10),
    Duration(hours: 25),
    Duration(hours: 40),
    Duration(hours: 75),
    Duration(hours: 100),
  ];

  for (final threshold in thresholds) {
    if (playedDuration < threshold) return threshold;
  }

  final hours = ((playedDuration.inHours / 25).ceil() * 25);
  return Duration(hours: hours);
}
