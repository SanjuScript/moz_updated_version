import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:moz_updated_version/core/themes/cubit/theme_cubit.dart';
import 'package:moz_updated_version/core/themes/custom_theme.dart';
import 'package:moz_updated_version/core/themes/repository/theme_repo.dart';
import 'package:moz_updated_version/core/utils/repository/audio_repository/audio_repository.dart';
import 'package:moz_updated_version/data/db/playlist_model.dart';
import 'package:moz_updated_version/screens/home_screen/presentation/bloc/audio_bloc.dart';
import 'package:moz_updated_version/screens/home_screen/presentation/ui/song_listing.dart';
import 'package:moz_updated_version/services/audio_handler.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

late final MozAudioHandler audioHandler;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //initialize audio handler
  audioHandler = await AudioService.init(
    builder: () => MozAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.moz.musicplayer.channel.audio',
      androidNotificationChannelName: 'Music Playback',
      androidNotificationOngoing: true,
      preloadArtwork: true,
    ),
  );

  //initialize hive
  await Hive.initFlutter();

  //Register Hive Playlist Model
  if (!Hive.isAdapterRegistered(PlaylistAdapter().typeId)) {
    Hive.registerAdapter(PlaylistAdapter());
  }

  //Initialize box for playlists
  await Hive.openBox<Playlist>('playlists');

  //Initialize hive for settings
  await Hive.openBox('settingsBox');

  //Repositories
  final audioRepo = AudioRepositoryImpl();
  final themeRepo = ThemeRepository();

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
        BlocProvider(create: (_) => AudioBloc(audioRepo)..add(LoadSongs())),
        BlocProvider(create: (_) => ThemeCubit(themeRepo)),
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
  @override
  void initState() {
    super.initState();
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
        return MaterialApp(
          home: SongListScreen(),
          debugShowCheckedModeBanner: false,
          theme: state.themeData,
          builder: (context, child) {
            SystemChrome.setSystemUIOverlayStyle(
              SystemUiOverlayStyle(
                statusBarIconBrightness:
                    state.themeData == CustomThemes.darkThemeMode
                    ? Brightness.light
                    : Brightness.dark,
              ),
            );
            View.of(context).platformDispatcher.platformBrightness;
            return child!;
          },
        );
      },
    );
  }
}
