// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class PlaylistModelOnline extends Equatable {
  final String id;
  final String name;
  final DateTime? createdAt;
  final int songCount;
  final List<String> recentThumbnails;

  const PlaylistModelOnline({
    required this.id,
    required this.name,
    this.createdAt,
    this.songCount = 0,
    this.recentThumbnails = const [],
  });

  factory PlaylistModelOnline.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PlaylistModelOnline(
      id: doc.id,
      name: data['name'] ?? 'Unnamed Playlist',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      songCount: data['songCount'] ?? 0,
      recentThumbnails: List<String>.from(data['recentThumbnails'] ?? []),
    );
  }

  PlaylistModelOnline copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    int? songCount,
    List<String>? recentThumbnails,
  }) {
    return PlaylistModelOnline(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      songCount: songCount ?? this.songCount,
      recentThumbnails: recentThumbnails ?? this.recentThumbnails,
    );
  }

  @override
  List<Object?> get props => [id, name, createdAt, songCount, recentThumbnails];
}
