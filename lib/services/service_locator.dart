import 'package:get_it/get_it.dart';
import 'package:moz_updated_version/core/helper/color_extractor.dart/cubit/artworkcolorextractor_cubit.dart';
import 'package:moz_updated_version/core/themes/cubit/theme_cubit.dart';
import 'package:moz_updated_version/core/themes/repository/theme__ab_repo.dart';
import 'package:moz_updated_version/core/themes/repository/theme_repo.dart';
import 'package:moz_updated_version/core/utils/bloc/audio_bloc.dart';
import 'package:moz_updated_version/core/utils/repository/audio_repository/audio_repo.dart';
import 'package:moz_updated_version/core/utils/repository/audio_repository/audio_repository.dart';
import 'package:moz_updated_version/data/db/favorites/repository/favorite_ab.dart';
import 'package:moz_updated_version/data/db/favorites/repository/favorite_repository.dart';
import 'package:moz_updated_version/data/db/mostly_played/repository/mostly_played_ab.dart';
import 'package:moz_updated_version/data/db/mostly_played/repository/mostly_played_repository.dart';
import 'package:moz_updated_version/data/db/playlist/repository/playlist_ab_repo.dart';
import 'package:moz_updated_version/data/db/playlist/repository/playlist_repo.dart';
import 'package:moz_updated_version/data/db/recently_played/repository/recent_ab_repo.dart';
import 'package:moz_updated_version/data/db/recently_played/repository/recent_repository.dart';
import 'package:moz_updated_version/services/audio_handler.dart';
import 'package:moz_updated_version/services/navigation_service.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Repositories
  sl.registerLazySingleton<AudioRepository>(() => AudioRepositoryImpl());
  sl.registerLazySingleton<RecentAbRepo>(() => RecentlyPlayedRepository());
  sl.registerLazySingleton<MostlyPlayedRepo>(() => MostlyPlayedRepository());
  sl.registerLazySingleton<FavoriteAbRepo>(() => FavoriteRepository());
  sl.registerLazySingleton<PlaylistAbRepo>(() => PlaylistRepository());
  sl.registerLazySingleton<ThemeRepo>(() => ThemeRepository());

  // Register ThemeCubit
  sl.registerLazySingleton<ThemeCubit>(() => ThemeCubit());

  //color ectractor
  sl.registerLazySingleton<ArtworkColorCubit>(() => ArtworkColorCubit());

  // Audio Handler
  sl.registerLazySingleton<MozAudioHandler>(() => MozAudioHandler());
  sl.registerLazySingleton<AudioBloc>(() => AudioBloc());

  //Navigation handler
  sl.registerLazySingleton<NavigationService>(() => NavigationService());
}
