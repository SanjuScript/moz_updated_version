class UserStats {
  final int totalSongsPlayed;
  final Duration totalListeningTime;

  const UserStats({
    required this.totalSongsPlayed,
    required this.totalListeningTime,
  });

  factory UserStats.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const UserStats(
        totalSongsPlayed: 0,
        totalListeningTime: Duration.zero,
      );
    }

    return UserStats(
      totalSongsPlayed: (map['totalSongsPlayed'] ?? 0) as int,
      totalListeningTime: Duration(
        milliseconds: (map['totalListeningTimeMs'] ?? 0) as int,
      ),
    );
  }
}
