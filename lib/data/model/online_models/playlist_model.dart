import 'package:moz_updated_version/data/model/online_models/online_song_model.dart';

class PlaylistModel {
  final String id;
  final String name;
  final String type;
  final String image;
  final String permaUrl;
  final String fanCount;
  final String listCount;
  final List<String> subtitleDesc;
  final List<OnlineSongModel> songs;

  PlaylistModel({
    required this.id,
    required this.name,
    required this.type,
    required this.image,
    required this.permaUrl,
    required this.fanCount,
    required this.listCount,
    required this.subtitleDesc,
    required this.songs,
  });

  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    return PlaylistModel(
      id: json['listid'] ?? '',
      name: json['listname'] ?? '',
      type: json['type'] ?? '',
      image: json['image'] ?? '',
      permaUrl: json['perma_url'] ?? '',
      fanCount: json['fan_count'] ?? '0',
      listCount: json['list_count'] ?? '0',
      subtitleDesc: List<String>.from(json['subtitle_desc'] ?? []),
      songs: (json['songs'] as List<dynamic>? ?? [])
          .map((e) => OnlineSongModel.fromJson(e))
          .toList(),
    );
  }
}
