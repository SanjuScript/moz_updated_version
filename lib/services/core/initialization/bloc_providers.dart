import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:moz_updated_version/core/helper/color_extractor.dart/cubit/artworkcolorextractor_cubit.dart';
import 'package:moz_updated_version/core/helper/cubit/player_settings_cubit.dart';
import 'package:moz_updated_version/core/themes/cubit/theme_cubit.dart';
import 'package:moz_updated_version/core/utils/bloc/audio_bloc.dart';
import 'package:moz_updated_version/core/utils/downloads/cubit/download_cubit.dart';
import 'package:moz_updated_version/data/firebase/logic/favorites/favorites_cubit.dart';
import 'package:moz_updated_version/data/firebase/logic/playlist/playlist_cubit.dart';
import 'package:moz_updated_version/data/firebase/logic/playlist_songs/playlistsongs_cubit.dart';
import 'package:moz_updated_version/data/model/user_model/repository/user_repo.dart';
import 'package:moz_updated_version/screens/ONLINE/album_screen/presentation/cubit/collection_cubit.dart';
import 'package:moz_updated_version/screens/ONLINE/auth/presentation/cubit/auth_cubit.dart';
import 'package:moz_updated_version/screens/ONLINE/bottom_nav/presentation/cubit/online_tab_cubit.dart';
import 'package:moz_updated_version/screens/ONLINE/download_screen/cubit/download_songs_cubit.dart';
import 'package:moz_updated_version/screens/ONLINE/home_screen/presentation/cubit/jio_saavn_home_cubit.dart';
import 'package:moz_updated_version/screens/ONLINE/profile_screen/user_stats_cubit/cubit/user_stats_cubit.dart';
import 'package:moz_updated_version/screens/ONLINE/recently_played/presentation/cubit/online_recently_played_cubit.dart';
import 'package:moz_updated_version/screens/ONLINE/search_screen/presentation/auto_complete_cubit/auto_complete_cubit.dart';
import 'package:moz_updated_version/screens/ONLINE/search_screen/presentation/cubit/jio_saavn_cubit.dart';
import 'package:moz_updated_version/screens/ONLINE/search_screen/presentation/search_history_cubit/search_history_cubit.dart';
import 'package:moz_updated_version/screens/ONLINE/spotify_screen/cubit/spotify_import_cubit.dart';
import 'package:moz_updated_version/screens/album_screen/presentation/cubit/album_cubit.dart';
import 'package:moz_updated_version/screens/all_screens/presentation/cubit/tab_confiq_cubit.dart';
import 'package:moz_updated_version/screens/all_screens/presentation/cubit/tab_cubit.dart';
import 'package:moz_updated_version/screens/artists_screen/presentation/cubit/artist_cubit.dart';
import 'package:moz_updated_version/screens/favorite_screen/presentation/cubit/favotite_cubit.dart';
import 'package:moz_updated_version/screens/home_screen/presentation/cubit/library_counts_cubit.dart';
import 'package:moz_updated_version/screens/lyric_screen/presentation/cubit/lyrics_cubit.dart';
import 'package:moz_updated_version/screens/mostly_played/presentation/cubit/mostlyplayed_cubit.dart';
import 'package:moz_updated_version/screens/now_playing/presentation/cubit/nowplaying_cubit.dart';
import 'package:moz_updated_version/screens/now_playing/presentation/widgets/sheets/cubit/queue_cubit.dart';
import 'package:moz_updated_version/screens/playlist_screen/presentation/cubit/playlist_cubit.dart';
import 'package:moz_updated_version/screens/recently_played/presentation/cubit/recently_played_cubit.dart';
import 'package:moz_updated_version/screens/removed_screen/presentation/cubit/removed_cubit.dart';
import 'package:moz_updated_version/screens/settings/screens/equalizer_screen/cubit/equalizer_cubit.dart';
import 'package:moz_updated_version/screens/settings/screens/setting_screen/settings_cubit/cubit/settings_cubit.dart';
import 'package:moz_updated_version/screens/settings/screens/sleep_timer_screen/presentation/cubit/sleeptimer_cubit.dart';
import 'package:moz_updated_version/screens/settings/screens/storage_location_screen/cubit/storage_cubit.dart';
import 'package:moz_updated_version/screens/song_list_screen/presentation/cubit/allsongs_cubit.dart';
import 'package:moz_updated_version/services/device_type_detector/cubit/device_type_cubit.dart';

import '../app_services.dart';

final List<BlocProvider> appBlocProviders = [
  BlocProvider(create: (_) => sl<AudioBloc>()),
  BlocProvider(create: (_) => sl<ThemeCubit>()),
  BlocProvider(create: (_) => AllSongsCubit()..loadSongs()),
  BlocProvider(create: (_) => FavoritesCubit()..load()),
  BlocProvider(create: (_) => DeviceTypeCubit()),
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
  BlocProvider(create: (_) => JioSaavnCubit()),
  BlocProvider(create: (_) => JioSaavnHomeCubit()),
  BlocProvider(create: (_) => CollectionCubitForOnline()),
  BlocProvider(create: (_) => OnlineFavoritesCubit()),
  BlocProvider(create: (_) => OnlineTabCubit()),
  BlocProvider(create: (_) => SearchHistoryCubit()),
  BlocProvider(create: (_) => OnlinePlaylistCubit()),
  BlocProvider(create: (_) => PlaylistsongsCubit()),
  BlocProvider(create: (_) => AuthCubit()),
  BlocProvider(create: (_) => AutocompleteCubit()),
  BlocProvider(create: (_) => SpotifyImportCubit()),
  BlocProvider(create: (_) => DownloadCubit()),
  BlocProvider(create: (_) => DownloadSongsCubit()),
  BlocProvider(create: (_) => SettingsCubit()),
  BlocProvider(create: (_) => UserStatsCubit()),
  BlocProvider(create: (_) => OnlineRecentlyPlayedCubit()),
];
