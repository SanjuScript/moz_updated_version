import 'package:get_it/get_it.dart';
import 'package:moz_updated_version/core/helper/color_extractor.dart/cubit/artworkcolorextractor_cubit.dart';
import 'package:moz_updated_version/core/themes/cubit/theme_cubit.dart';
import 'package:moz_updated_version/core/themes/repository/theme__ab_repo.dart';
import 'package:moz_updated_version/core/themes/repository/theme_repo.dart';
import 'package:moz_updated_version/core/utils/bloc/audio_bloc.dart';
import 'package:moz_updated_version/core/utils/online_playback_repo/audio_playback_repository.dart';
import 'package:moz_updated_version/core/utils/online_playback_repo/audio_playback_repository_impl.dart';
import 'package:moz_updated_version/core/utils/repository/album_repository/album_repository.dart';
import 'package:moz_updated_version/core/utils/repository/album_repository/album_repository_impl.dart';
import 'package:moz_updated_version/core/utils/repository/artists_repository/artists_repo.dart';
import 'package:moz_updated_version/core/utils/repository/artists_repository/artists_repository.dart';
import 'package:moz_updated_version/core/utils/repository/audio_repository/audio_repo.dart';
import 'package:moz_updated_version/core/utils/repository/audio_repository/audio_repository.dart';
import 'package:moz_updated_version/core/utils/repository/lyric_repository/lyric_repo.dart';
import 'package:moz_updated_version/core/utils/repository/lyric_repository/lyric_repository.dart';
import 'package:moz_updated_version/core/utils/repository/user_repository/user_repo.dart';
import 'package:moz_updated_version/data/db/favorites/repository/favorite_ab.dart';
import 'package:moz_updated_version/data/db/favorites/repository/favorite_repository.dart';
import 'package:moz_updated_version/data/db/lyrics_db/fav_lyrics_db.dart';
import 'package:moz_updated_version/data/db/lyrics_db/fav_lyrics_repository.dart';
import 'package:moz_updated_version/data/db/lyrics_db/lyrics_db_ab.dart';
import 'package:moz_updated_version/data/db/lyrics_db/lyrics_db_reposiory.dart';
import 'package:moz_updated_version/data/db/mostly_played/repository/mostly_played_ab.dart';
import 'package:moz_updated_version/data/db/mostly_played/repository/mostly_played_repository.dart';
import 'package:moz_updated_version/data/db/playlist/repository/playlist_ab_repo.dart';
import 'package:moz_updated_version/data/db/playlist/repository/playlist_repo.dart';
import 'package:moz_updated_version/data/db/recently_played/repository/recent_ab_repo.dart';
import 'package:moz_updated_version/data/db/recently_played/repository/recent_repository.dart';
import 'package:moz_updated_version/data/db/removed/repository/removed_ab_repo.dart';
import 'package:moz_updated_version/data/db/removed/repository/removed_repository.dart';
import 'package:moz_updated_version/data/model/user_model/repository/user_repo.dart';
import 'package:moz_updated_version/data/model/user_model/repository/user_repo_impl.dart';
import 'package:moz_updated_version/screens/favorite_screen/presentation/cubit/favotite_cubit.dart';
import 'package:moz_updated_version/screens/home_screen/presentation/cubit/library_counts_cubit.dart';
import 'package:moz_updated_version/screens/lyric_screen/presentation/cubit/lyrics_cubit.dart';
import 'package:moz_updated_version/screens/mostly_played/presentation/cubit/mostlyplayed_cubit.dart';
import 'package:moz_updated_version/screens/playlist_screen/presentation/cubit/playlist_cubit.dart';
import 'package:moz_updated_version/screens/recently_played/presentation/cubit/recently_played_cubit.dart';
import 'package:moz_updated_version/screens/removed_screen/presentation/cubit/removed_cubit.dart';
import 'package:moz_updated_version/screens/settings/screens/equalizer_screen/cubit/equalizer_cubit.dart';
import 'package:moz_updated_version/screens/settings/screens/sleep_timer_screen/presentation/repository/sleep_ab_repo.dart';
import 'package:moz_updated_version/screens/settings/screens/sleep_timer_screen/presentation/repository/sleep_repository.dart';
import 'package:moz_updated_version/services/audio_handler.dart';
import 'package:moz_updated_version/services/equillizer_service.dart';
import 'package:moz_updated_version/services/lyrics_service.dart';
import 'package:moz_updated_version/services/navigation_service.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // ----------------
  // Repositories
  // ----------------
  sl.registerLazySingleton<AudioRepository>(() => AudioRepositoryImpl());
  sl.registerLazySingleton<AlbumRepository>(() => AlbumRepositoryImpl());
  sl.registerLazySingleton<ArtistRepository>(() => ArtistRepositoryImpl());
  sl.registerLazySingleton<RecentAbRepo>(() => RecentlyPlayedRepository());
  sl.registerLazySingleton<MostlyPlayedRepo>(() => MostlyPlayedRepository());
  sl.registerLazySingleton<FavoriteAbRepo>(() => FavoriteRepository());
  sl.registerLazySingleton<RemovedAbRepo>(() => RemovedRepository());
  sl.registerLazySingleton<PlaylistAbRepo>(() => PlaylistRepository());
  sl.registerLazySingleton<ThemeRepo>(() => ThemeRepository());
  sl.registerLazySingleton<ISleepTimerRepository>(() => SleepTimerRepository());
  sl.registerLazySingleton<LyricsRepository>(() => LyricsRepositoryImpl());
  sl.registerLazySingleton<LyricsDbAb>(() => LyricsLocalRepository());
  sl.registerLazySingleton<FavoriteLyricsAbRepo>(
    () => FavoriteLyricsRepository(),
  );
  sl.registerLazySingleton<AudioPlaybackRepository>(
    () => AudioPlaybackRepositoryImpl(sl<MozAudioHandler>()),
  );
  sl.registerLazySingleton<UserRepository>(() => UserRepository());
  sl.registerLazySingleton<UserStorageAbRepo>(() => UserStorageRepository());

  // ----------------
  // Cubits
  // ----------------
  sl.registerLazySingleton<LibraryCountsCubit>(() => LibraryCountsCubit());
  sl.registerLazySingleton<ThemeCubit>(() => ThemeCubit());
  sl.registerLazySingleton<ArtworkColorCubit>(() => ArtworkColorCubit());
  sl.registerLazySingleton<LyricsCubit>(() => LyricsCubit());

  // music data cubits
  sl.registerLazySingleton<FavoritesCubit>(() => FavoritesCubit());
  sl.registerLazySingleton<RecentlyPlayedCubit>(() => RecentlyPlayedCubit());
  sl.registerLazySingleton<MostlyPlayedCubit>(() => MostlyPlayedCubit());
  sl.registerLazySingleton<RemovedCubit>(() => RemovedCubit());
  sl.registerLazySingleton<PlaylistCubit>(() => PlaylistCubit());
  sl.registerLazySingleton<EqualizerCubit>(() => EqualizerCubit());

  // ----------------
  // Core
  // ----------------
  sl.registerLazySingleton<MozAudioHandler>(() => MozAudioHandler());
  sl.registerLazySingleton<AudioBloc>(() => AudioBloc());
  sl.registerLazySingleton<NavigationService>(() => NavigationService());
  sl.registerLazySingleton<EqualizerService>(() => EqualizerService());

  // ----------------
  // BackgroundServices
  // ----------------
  sl.registerLazySingleton<BackgroundLyricsService>(
    () => BackgroundLyricsService(),
  );
}
