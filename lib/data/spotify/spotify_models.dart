// ignore_for_file: public_member_api_docs, sort_constructors_first
class SpotifyPlaylist {
  final String id;
  final String name;
  final int totalTracks;

  SpotifyPlaylist({
    required this.id,
    required this.name,
    required this.totalTracks,
  });

  factory SpotifyPlaylist.fromJson(Map<String, dynamic> json) {
    return SpotifyPlaylist(
      id: json['id'],
      name: json['name'],
      totalTracks: json['tracks']['total'],
    );
  }
}

class SpotifyTrack {
  final String title;
  final String artist;

  SpotifyTrack({required this.title, required this.artist});

  factory SpotifyTrack.fromJson(Map<String, dynamic> json) {
    return SpotifyTrack(
      title: json['name'],
      artist: (json['artists'] as List).map((a) => a['name']).join(', '),
    );
  }

  @override
  String toString() => 'SpotifyTrack(title: $title, artist: $artist)';
}
