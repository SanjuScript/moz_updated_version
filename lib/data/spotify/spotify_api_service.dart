import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'spotify_models.dart';

class SpotifyUser {
  final String id;
  final String displayName;
  final String email;
  final String? imageUrl;

  SpotifyUser({
    required this.id,
    required this.displayName,
    required this.email,
    this.imageUrl,
  });

  factory SpotifyUser.fromJson(Map<String, dynamic> json) {
    return SpotifyUser(
      id: json['id'],
      displayName: json['display_name'] ?? '',
      email: json['email'] ?? '',
      imageUrl: (json['images'] as List).isNotEmpty
          ? json['images'][0]['url']
          : null,
    );
  }
}

class SpotifyApiService {
  final String accessToken;

  SpotifyApiService(this.accessToken);

  Map<String, String> get _headers => {'Authorization': 'Bearer $accessToken'};

  Future<List<SpotifyPlaylist>> getUserPlaylists() async {
    final res = await http.get(
      Uri.parse('https://api.spotify.com/v1/me/playlists?limit=50'),
      headers: _headers,
    );

    final data = jsonDecode(res.body);
    log(data.toString(), name: "SPOTIFY PLALIST");
    return (data['items'] as List)
        .map((e) => SpotifyPlaylist.fromJson(e))
        .toList();
  }

  Future<SpotifyUser> getMe() async {
    final res = await http.get(
      Uri.parse('https://api.spotify.com/v1/me'),
      headers: _headers,
    );

    log('🟡 [SPOTIFY_API] /me status: ${res.statusCode}');
    log('🟡 [SPOTIFY_API] /me raw body: ${res.body}');

    if (res.statusCode != 200) {
      throw Exception('Spotify /me failed (${res.statusCode}): ${res.body}');
    }

    final data = jsonDecode(res.body);
    return SpotifyUser.fromJson(data);
  }

  Future<List<SpotifyTrack>> getPlaylistTracks(String playlistId) async {
    List<SpotifyTrack> tracks = [];
    int offset = 0;

    while (true) {
      final res = await http.get(
        Uri.parse(
          'https://api.spotify.com/v1/playlists/$playlistId/tracks'
          '?limit=100&offset=$offset',
        ),
        headers: _headers,
      );

      final data = jsonDecode(res.body);
      final items = data['items'] as List;

      tracks.addAll(
        items
            .where((e) => e['track'] != null)
            .map((e) => SpotifyTrack.fromJson(e['track'])),
      );

      if (items.length < 100) break;
      offset += 100;
    }

    return tracks;
  }
}
