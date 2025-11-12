import 'dart:developer';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:moz_updated_version/core/helper/color_extractor.dart/cubit/artworkcolorextractor_cubit.dart';
import 'package:moz_updated_version/core/helper/cubit/player_settings_cubit.dart';
import 'package:moz_updated_version/core/themes/cubit/theme_cubit.dart';
import 'package:moz_updated_version/core/themes/custom_theme.dart';
import 'package:moz_updated_version/core/themes/repository/theme_repo.dart';
import 'package:moz_updated_version/data/db/lyrics_db/lyrics_db_ab.dart';
import 'package:moz_updated_version/data/db/lyrics_db/lyrics_db_reposiory.dart';
import 'package:moz_updated_version/data/db/playlist/playlist_model.dart';
import 'package:moz_updated_version/core/utils/bloc/audio_bloc.dart';
import 'package:moz_updated_version/screens/album_screen/presentation/cubit/album_cubit.dart';
import 'package:moz_updated_version/screens/all_screens/presentation/cubit/tab_confiq_cubit.dart';
import 'package:moz_updated_version/screens/all_screens/presentation/cubit/tab_cubit.dart';
import 'package:moz_updated_version/screens/all_screens/presentation/model/tab_model.dart';
import 'package:moz_updated_version/screens/artists_screen/presentation/cubit/artist_cubit.dart';
import 'package:moz_updated_version/screens/favorite_screen/presentation/cubit/favotite_cubit.dart';
import 'package:moz_updated_version/screens/home_screen/presentation/cubit/library_counts_cubit.dart';
import 'package:moz_updated_version/screens/lyric_screen/presentation/cubit/lyrics_cubit.dart';
import 'package:moz_updated_version/screens/mostly_played/presentation/cubit/mostlyplayed_cubit.dart';
import 'package:moz_updated_version/screens/now_playing/presentation/cubit/nowplaying_cubit.dart';
import 'package:moz_updated_version/screens/now_playing/presentation/widgets/sheets/cubit/queue_cubit.dart';
import 'package:moz_updated_version/screens/playlist_screen/presentation/cubit/playlist_cubit.dart';
import 'package:moz_updated_version/screens/removed_screen/presentation/cubit/removed_cubit.dart';
import 'package:moz_updated_version/screens/settings/screens/equalizer_screen/cubit/equalizer_cubit.dart';
import 'package:moz_updated_version/screens/settings/screens/sleep_timer_screen/presentation/cubit/sleeptimer_cubit.dart';
import 'package:moz_updated_version/screens/settings/screens/storage_location_screen/cubit/storage_cubit.dart';
import 'package:moz_updated_version/screens/song_list_screen/presentation/cubit/allsongs_cubit.dart';
import 'package:moz_updated_version/screens/all_screens/presentation/ui/song_listing.dart';
import 'package:moz_updated_version/screens/recently_played/presentation/cubit/recently_played_cubit.dart';
import 'package:moz_updated_version/services/audio_handler.dart';
import 'package:moz_updated_version/services/lyrics_service.dart';
import 'package:moz_updated_version/services/navigation_service.dart';
import 'package:moz_updated_version/services/service_locator.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

late final MozAudioHandler audioHandler;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //initialize hive
  await Hive.initFlutter();

  //Register Hive Playlist Model
  if (!Hive.isAdapterRegistered(PlaylistAdapter().typeId)) {
    Hive.registerAdapter(PlaylistAdapter());
  }

  //Register Hive Tab Model
  if (!Hive.isAdapterRegistered(TabModelAdapter().typeId)) {
    Hive.registerAdapter(TabModelAdapter());
  }

  //Initialize box for tabs
  await Hive.openBox<TabModel>('tabs');

  //Initialize box for playlists
  await Hive.openBox<Playlist>('playlists');

  //Initialize box for Recently Played
  await Hive.openBox<Map>("RecentDB");

  //Initialize box for Recently Played
  await Hive.openBox<Map>("MostlyPlayedDB");

  //Initialize hive for settings
  await Hive.openBox('settingsBox');

  //Initialize hive for favorites
  await Hive.openBox<Map>('FavoriteDB');

  //Initialize hive for removed songs
  await Hive.openBox<Map>('RemovedDB');

  //Initialize hive for fav lyrics
  await Hive.openBox<String>('FavoriteLyricsDB');

  //initialize get it service locator
  await setupServiceLocator();

  //LyricsDb
  sl<LyricsDbAb>().init();

  //initialize audio handler
  audioHandler = await AudioService.init(
    builder: () => sl<MozAudioHandler>(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.moz.musicplayer.channel.audio',
      androidNotificationChannelName: 'Music Playback',
      androidNotificationOngoing: true,
      preloadArtwork: true,
    ),
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Color.fromRGBO(0, 0, 0, 0)),
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AudioBloc>()),
        BlocProvider(create: (_) => sl<ThemeCubit>()),
        BlocProvider(create: (_) => AllSongsCubit()..loadSongs()),
        BlocProvider(create: (_) => FavoritesCubit()..load()),
        BlocProvider(create: (_) => NowPlayingCubit()),
        BlocProvider(create: (_) => GetIt.I<ArtworkColorCubit>()),
        BlocProvider(create: (_) => PlayerSettingsCubit()),
        BlocProvider(create: (_) => MostlyPlayedCubit()..load()),
        BlocProvider(create: (_) => PlaylistCubit()..loadPlaylists()),
        BlocProvider(create: (_) => RecentlyPlayedCubit()..load()),
        BlocProvider(create: (_) => AlbumCubit()..loadAlbums()),
        BlocProvider(create: (_) => ArtistCubit()..loadArtists()),
        BlocProvider(create: (_) => SleepTimerCubit()),
        BlocProvider(create: (_) => QueueCubit()),
        BlocProvider(create: (_) => RemovedCubit()..load()),
        BlocProvider(create: (_) => TabCubit()),
        BlocProvider(create: (_) => TabConfigCubit()..loadTabs()),
        BlocProvider(create: (_) => StorageCubit()),
        BlocProvider(create: (_) => sl<LibraryCountsCubit>()),
        BlocProvider(create: (_) => sl<LyricsCubit>()),
        BlocProvider(create: (_) => sl<EqualizerCubit>()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late BackgroundLyricsService _lyricsService;
  @override
  void initState() {
    super.initState();

    // Initialize background lyrics service
    _lyricsService = sl<BackgroundLyricsService>();
    _lyricsService.startListening();

    ReceiveSharingIntent.instance.reset();
    // App opened from shared audio
    ReceiveSharingIntent.instance.getInitialMedia().then((
      List<SharedMediaFile> files,
    ) {
      if (files.isNotEmpty) {
        _handleSharedAudio(files.first.path);
      }
    });

    // App already open -> receive audio
    ReceiveSharingIntent.instance.getMediaStream().listen(
      (List<SharedMediaFile> files) {
        if (files.isNotEmpty) {
          _handleSharedAudio(files.first.path);
        }
      },
      onError: (err) {
        debugPrint("ReceiveSharingIntent error: $err");
      },
    );
  }

  void _handleSharedAudio(String path) {
    context.read<AudioBloc>().add(PlayExternalSong(path));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        final themeWithPlatform = state.themeData.copyWith(
          platform: state.platform,
        );
        log(state.platform.name.toString());
        return MaterialApp(
          home: SongListScreen(),
          navigatorKey: sl<NavigationService>().navigatorKey,
          debugShowCheckedModeBanner: false,
          theme: themeWithPlatform,

          builder: (context, child) {
            SystemChrome.setSystemUIOverlayStyle(
              SystemUiOverlayStyle(
                statusBarIconBrightness:
                    state.themeData ==
                        CustomThemes.darkThemeMode(primary: state.primaryColor)
                    ? Brightness.light
                    : Brightness.dark,
              ),
            );
            return AnimatedTheme(
              data: themeWithPlatform,
              duration: const Duration(milliseconds: 250),
              child: child!,
            );
          },
        );
      },
    );
  }
}
