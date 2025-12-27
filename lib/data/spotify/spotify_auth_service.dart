import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

import 'package:hive/hive.dart';
import 'dart:developer';
import 'package:app_links/app_links.dart';
import 'package:url_launcher/url_launcher.dart';

class SpotifyTokenStore {
  static final Box _box = Hive.box('spotify');

  static String? get accessToken => _box.get('access_token');

  static Future<void> saveToken(String token) async {
    await _box.put('access_token', token);
  }

  static Future<void> clear() async {
    await _box.delete('access_token');
  }

  static bool get hasToken => accessToken != null;
}

class SpotifyAuthService {
  static const _clientId = 'cde53dc239e043e2a4542ea706c58af7';
  static const _redirectUri = 'mozapp://spotify';

  static const _scopes = [
    'playlist-read-private',
    'playlist-read-collaborative',
    'user-read-email',
  ];

  final AppLinks _appLinks = AppLinks();
  bool _listening = false;

  String buildAuthUrl() {
    final uri = Uri.https('accounts.spotify.com', '/authorize', {
      'client_id': _clientId,
      'response_type': 'code',
      'redirect_uri': _redirectUri,
      'scope': _scopes.join(' '),
      'show_dialog': 'true',
    });

    log('🔵 [SPOTIFY_AUTH] Auth URL: $uri');
    return uri.toString();
  }

  Future<void> startLogin({
    required Function(String code) onCode,
    required Function(Object error) onError,
  }) async {
    if (_listening) return;
    _listening = true;

    log('🟡 [SPOTIFY_AUTH] Starting Spotify login');

    // Listen for redirect
    _appLinks.uriLinkStream.listen(
      (uri) async {
        log('🟢 [SPOTIFY_AUTH] Deep link received: $uri');

        final code = uri.queryParameters['code'];
        final error = uri.queryParameters['error'];

        if (error != null) {
          _listening = false;
          onError(Exception('Spotify OAuth error: $error'));
          return;
        }

        if (code != null) {
          log(
            '🟢 [SPOTIFY_AUTH] Auth code received: ${code.substring(0, 6)}***',
          );
          _listening = false;
          onCode(code);
        }
      },
      onError: (e) {
        _listening = false;
        onError(e);
      },
    );

    // Launch external auth
    final url = buildAuthUrl();
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
}
