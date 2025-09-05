import 'package:get_it/get_it.dart';
import 'package:moz_updated_version/core/utils/repository/audio_repository/audio_repo.dart';
import 'package:moz_updated_version/core/utils/repository/audio_repository/audio_repository.dart';
import 'package:moz_updated_version/data/db/recently_played/repository/recent_ab_repo.dart';
import 'package:moz_updated_version/data/db/recently_played/repository/recent_repository.dart';
import 'package:moz_updated_version/services/audio_handler.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Repositories
  sl.registerLazySingleton<AudioRepository>(() => AudioRepositoryImpl());
  sl.registerLazySingleton<RecentAbRepo>(() => RecentlyPlayedRepository());

  // Audio Handler
  sl.registerLazySingleton<MozAudioHandler>(() => MozAudioHandler());
}
