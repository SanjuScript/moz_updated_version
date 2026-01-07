import 'package:cloud_firestore/cloud_firestore.dart';

class UserMusicStats {
  final int totalSongsPlayed;
  final int totalListeningTimeSec;

  UserMusicStats({
    required this.totalSongsPlayed,
    required this.totalListeningTimeSec,
  });

  Map<String, dynamic> toMap() {
    return {
      'totalSongsPlayed': totalSongsPlayed,
      'totalListeningTimeSec': totalListeningTimeSec,
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }
}
