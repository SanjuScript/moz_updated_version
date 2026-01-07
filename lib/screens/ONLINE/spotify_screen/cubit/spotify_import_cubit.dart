import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;

import 'package:moz_updated_version/data/repository/saavn_repository.dart';
import 'package:moz_updated_version/data/spotify/spotify_api_service.dart';
import 'package:moz_updated_version/data/spotify/spotify_auth_service.dart';
import 'package:moz_updated_version/data/spotify/spotify_models.dart';
import 'package:moz_updated_version/services/service_locator.dart';

part 'spotify_import_state.dart';

class SpotifyImportCubit extends Cubit<SpotifyImportState> {
  SpotifyImportCubit() : super(SpotifyImportInitial());

  final _saavnRepo = sl<SaavnRepository>();
  SpotifyApiService? _spotifyApi;

  /// LOGIN + LOAD PROFILE + PLAYLISTS
  Future<void> loginAndLoadPlaylists() async {
    emit(SpotifyImportLoading());
    log('🔵 [SPOTIFY] loginAndLoadPlaylists() called');

    try {
      final token = SpotifyTokenStore.accessToken;

      // ─────────────────────────────
      // Already logged in
      // ─────────────────────────────
      if (token != null) {
        log('🟢 [SPOTIFY] Using existing token');
        _spotifyApi = SpotifyApiService(token);

        final user = await _spotifyApi!.getMe();
        final playlists = await _spotifyApi!.getUserPlaylists();

        emit(SpotifyConnected(user: user, playlists: playlists));
        return;
      }

      // ─────────────────────────────
      // Start Spotify login
      // ─────────────────────────────
      log('🟡 [SPOTIFY] No token → starting Spotify login');

      SpotifyAuthService().startLogin(
        onCode: (code) async {
          try {
            log('🟢 [SPOTIFY] Exchanging code for token');

            final accessToken = await _fetchSpotifyAccessToken(code);
            await SpotifyTokenStore.saveToken(accessToken);

            _spotifyApi = SpotifyApiService(accessToken);

            final user = await _spotifyApi!.getMe();
            final playlists = await _spotifyApi!.getUserPlaylists();

            emit(SpotifyConnected(user: user, playlists: playlists));
          } catch (e, st) {
            log('🔴 [SPOTIFY] Token exchange failed: $e', stackTrace: st);
            emit(SpotifyImportError(e.toString()));
          }
        },
        onError: (error) {
          log('🔴 [SPOTIFY] Spotify login failed: $error');
          emit(SpotifyImportError(error.toString()));
        },
      );
    } catch (e, st) {
      log('🔴 [SPOTIFY] loginAndLoadPlaylists FAILED: $e', stackTrace: st);
      emit(SpotifyImportError(e.toString()));
    }
  }

  /// ─────────────────────────────
  /// TOKEN EXCHANGE WITH LOGS
  /// ─────────────────────────────
  Future<String> _fetchSpotifyAccessToken(String code) async {
    log('🟡 [SPOTIFY] Exchanging code for token');

    final res = await http.post(
      Uri.parse('https://bb52b09a35aa.ngrok-free.app/spotify/token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'code': code}),
    );

    log('🟡 [SPOTIFY] Token endpoint status: ${res.statusCode}');

    if (res.statusCode != 200) {
      log('🔴 [SPOTIFY] Token exchange failed: ${res.body}');
      throw Exception('Spotify token exchange failed');
    }

    final data = jsonDecode(res.body);
    final token = data['access_token'];

    log('🟢 [SPOTIFY] Token received (length: ${token.length})');

    return token;
  }

  /// IMPORT PLAYLIST (example skeleton)
  Future<void> importPlaylist(SpotifyPlaylist playlist) async {
    if (_spotifyApi == null) return;

    emit(
      SpotifyImportingPlaylist(
        playlistName: playlist.name,
        totalTracks: playlist.totalTracks,
        importedTracks: 0,
      ),
    );

    final tracks = await _spotifyApi!.getPlaylistTracks(playlist.id);

    int imported = 0;

    for (final track in tracks) {
      // TODO: match & save via Saavn
      // await _saavnRepo.importTrack(track);
      imported++;

      emit(
        SpotifyImportingPlaylist(
          playlistName: playlist.name,
          totalTracks: tracks.length,
          importedTracks: imported,
        ),
      );
    }

    emit(
      SpotifyPlaylistImported(
        playlistName: playlist.name,
        importedCount: imported,
        totalCount: tracks.length,
      ),
    );
  }

  Future<void> printPlaylistTracksFromLink({
    String playlistLink =
        "https://open.spotify.com/playlist/1NPbQLLL8mFDXvHIIwmFwd?si=7hytVU2TRpaDj0LRdvj0WQ",
  }) async {
    try {
      final token = SpotifyTokenStore.accessToken;
      if (token == null) {
        throw Exception('Spotify not logged in');
      }

      final playlistId = extractPlaylistId(playlistLink);

      final api = SpotifyApiService(token);

      final tracks = await api.getPlaylistTracks(playlistId);
      log(tracks.toString());

      log('🎵 TOTAL TRACKS: ${tracks.length}', name: 'SPOTIFY');
    } catch (e, st) {
      log(
        'Failed to load playlist tracks: $e',
        stackTrace: st,
        name: 'SPOTIFY_ERROR',
      );
    }
  }

  String extractPlaylistId(String input) {
    if (input.startsWith('spotify:playlist:')) {
      return input.split(':').last;
    }

    final uri = Uri.parse(input);
    if (uri.pathSegments.contains('playlist')) {
      return uri.pathSegments.last;
    }

    throw Exception('Invalid Spotify playlist link');
  }
}
