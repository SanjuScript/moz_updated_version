import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:moz_updated_version/data/model/user_model/repository/user_repo.dart';
import 'package:moz_updated_version/services/core/app_services.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static final FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(
    analytics: _analytics,
  );

  static final userName = sl<UserStorageAbRepo>().userName ?? "NO NAME ";

  // Track screen views
  static Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  // Track song plays
  static Future<void> logSongPlay({
    required String songId,
    required String songName,
    required String source,
  }) async {
    await _analytics.logEvent(
      name: 'song_played by $userName',
      parameters: {
        'song_id': songId,
        'song_name': songName,
        'source': source,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // Track searches
  static Future<void> logSearch(String query, int resultsCount) async {
    await _analytics.logSearch(
      searchTerm: query,
      parameters: {'results_count': resultsCount, "Searched by": userName},
    );
  }

  // Track feature usage
  static Future<void> logFeatureUse(String featureName) async {
    await _analytics.logEvent(
      name: 'feature_used by $userName',
      parameters: {'feature_name': featureName},
    );
  }

  // Track errors (user-facing)
  static Future<void> logError(String errorType, String errorMessage) async {
    await _analytics.logEvent(
      name: 'user_error',
      parameters: {'error_type': errorType, 'error_message': errorMessage},
    );
  }

  // Track user engagement
  static Future<void> logSessionStart() async {
    await _analytics.logEvent(name: 'session_start');
  }

  static Future<void> logAddToFavorites(String songId, String songName) async {
    await _analytics.logEvent(
      name: 'add_to_favorites by $userName',
      parameters: {'song_id': songId, "song_name": songName},
    );
  }
}
