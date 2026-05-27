import 'package:audio_service/audio_service.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:moz_updated_version/data/db/app_settings/app_settings_db.dart';
import 'package:moz_updated_version/data/db/language_db/model/language_preference_model.dart';
import 'package:moz_updated_version/data/db/lyrics_db/lyrics_db_ab.dart';
import 'package:moz_updated_version/data/db/playlist/playlist_model.dart';
import 'package:moz_updated_version/data/model/user_model/user_model.dart';
import 'package:moz_updated_version/main.dart';
import 'package:moz_updated_version/screens/all_screens/presentation/model/tab_model.dart';
import 'package:moz_updated_version/services/app_cycle_events.dart';
import 'package:moz_updated_version/services/audio_handler.dart';
import 'package:moz_updated_version/services/core/firebase_service.dart';
import 'package:moz_updated_version/services/migration/migration_tracker.dart';
import 'package:moz_updated_version/services/one_time_dialogue_service.dart';
import 'package:moz_updated_version/services/service_locator.dart';

import '../../../data/model/download_song/download_song_model.dart'
    show DownloadedSongModelAdapter, DownloadedSongModel;

class AppInitializer {
  static Future<void> initialize() async {
    await _initializeFirebase();
    _setupErrorHandlers();
    await _loadEnvironment();
    await _initializeHive();
    await _initializeServices();
    await _initializeAudioService();
    _setupSystemUI();
  }

  static Future<void> _initializeFirebase() async {
    await FirebaseService.instance.initialize();
    MozLifecycleHandler().init();
  }

  static void _setupErrorHandlers() {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  static Future<void> _loadEnvironment() async {
    await dotenv.load(fileName: kReleaseMode ? '.env.prod' : '.env');
  }

  static Future<void> _initializeHive() async {
    await Hive.initFlutter();
    _registerHiveAdapters();
    await _openHiveBoxes();
  }

  static void _registerHiveAdapters() {
    if (!Hive.isAdapterRegistered(PlaylistAdapter().typeId)) {
      Hive.registerAdapter<Playlist>(PlaylistAdapter());
    }

    if (!Hive.isAdapterRegistered(TabModelAdapter().typeId)) {
      Hive.registerAdapter<TabModel>(TabModelAdapter());
    }

    if (!Hive.isAdapterRegistered(UserModelAdapter().typeId)) {
      Hive.registerAdapter<UserModel>(UserModelAdapter());
    }

    if (!Hive.isAdapterRegistered(LanguagePreferenceAdapter().typeId)) {
      Hive.registerAdapter<LanguagePreference>(LanguagePreferenceAdapter());
    }

    if (!Hive.isAdapterRegistered(DownloadedSongModelAdapter().typeId)) {
      Hive.registerAdapter<DownloadedSongModel>(DownloadedSongModelAdapter());
    }
  }

  static Future<void> _openHiveBoxes() async {
    await Future.wait([
      Hive.openBox<LanguagePreference>("languagePreferences"),
      Hive.openBox<DownloadedSongModel>("songDownloads"),
      Hive.openBox<TabModel>('tabs'),
      Hive.openBox<Playlist>('playlists'),
      Hive.openBox<Map>("RecentDB"),
      Hive.openBox<Map>("MostlyPlayedDB"),
      Hive.openBox<UserModel>('mozuser'),
      Hive.openBox('settingsBox'),
      Hive.openBox<Map>('FavoriteDB'),
      Hive.openBox<Map>('RemovedDB'),
      Hive.openBox<String>('FavoriteLyricsDB'),
      Hive.openBox<List<String>>('search_history_box'),
      Hive.openBox('spotify'),
    ]);
  }

  static Future<void> _initializeServices() async {
    await DialogTrackerService.initialize();
    await SettingsManager.init();
    await setupServiceLocator();

    sl<LyricsDbAb>().init();

    await MigrationTrackerService.initialize();

    if (kDebugMode) {
      SettingsManager.setAudioQuality('low');
    }
  }

  static Future<void> _initializeAudioService() async {
    audioHandler = await AudioService.init(
      builder: () => sl<MozAudioHandler>(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.moz.musicplayer.channel.audio',
        androidNotificationChannelName: 'Music Playback',
        androidNotificationOngoing: true,
        preloadArtwork: true,
      ),
    );
  }

  static void _setupSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Color.fromRGBO(0, 0, 0, 0)),
    );
  }
}
