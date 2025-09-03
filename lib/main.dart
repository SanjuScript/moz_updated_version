import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:moz_updated_version/core/themes/cubit/theme_cubit.dart';
import 'package:moz_updated_version/core/utils/repository/audio_repository/audio_repository.dart';
import 'package:moz_updated_version/core/utils/repository/theme_repository/theme_repository.dart';
import 'package:moz_updated_version/home/presentation/bloc/audio_bloc.dart';
import 'package:moz_updated_version/home/presentation/screens/song_listing.dart';
import 'package:moz_updated_version/services/audio_handler.dart';

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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return MaterialApp(
          home: SongListScreen(),
          debugShowCheckedModeBanner: false,
          theme: state.themeData,
          builder: (context, child) {
            SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle());
            View.of(context).platformDispatcher.platformBrightness;
            return child!;
          },
        );
      },
    );
  }
}
