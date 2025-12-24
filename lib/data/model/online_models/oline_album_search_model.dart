class OnlineAlbumSearchModel {
  final String id;
  final String title;
  final String image;
  final String music;
  final String artist;
  final String year;
  final String language;
  final int songCount;
  final String url;

  OnlineAlbumSearchModel({
    required this.id,
    required this.title,
    required this.image,
    required this.music,
    required this.artist,
    required this.year,
    required this.language,
    required this.songCount,
    required this.url,
  });

  factory OnlineAlbumSearchModel.fromJson(Map<String, dynamic> json) {
    return OnlineAlbumSearchModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      music: json['music']?.toString() ?? '',
      artist: json['artist']?.toString() ?? '',
      year: json['year']?.toString() ?? '',
      language: json['language']?.toString() ?? '',
      songCount: _toInt(json['song_count']),
      url: json['url']?.toString() ?? '',
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
