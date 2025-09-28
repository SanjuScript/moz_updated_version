import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:moz_updated_version/data/db/playlist/playlist_model.dart';
import 'package:moz_updated_version/screens/all_screens/presentation/ui/song_listing.dart';
import 'package:moz_updated_version/screens/favorite_screen/presentation/cubit/favotite_cubit.dart';
import 'package:moz_updated_version/screens/mostly_played/presentation/cubit/mostlyplayed_cubit.dart';
import 'package:moz_updated_version/screens/playlist_screen/presentation/cubit/playlist_cubit.dart';
import 'package:moz_updated_version/screens/recently_played/presentation/cubit/recently_played_cubit.dart';
import 'package:moz_updated_version/screens/settings/screens/setting_screen/dialogues/general_dialogue.dart';
import 'package:moz_updated_version/services/core/app_services.dart';
import 'package:moz_updated_version/services/service_locator.dart';

class AppResetService {
  static Future<void> fullResetApp(BuildContext context) async {
    await Hive.box<Playlist>('playlists').clear();
    await Hive.box<Map>('RecentDB').clear();
    await Hive.box<Map>('MostlyPlayedDB').clear();
    await Hive.box('settingsBox').clear();
    await Hive.box<Map>('FavoriteDB').clear();
    await Hive.box<Map>('RemovedDB').clear();
    await Hive.close();

    sl<NavigationService>().replaceWith(SongListScreen());
  }

  static Future<void> clearPlaylists(BuildContext context) async {
    await deleteBoxDialogue(
      context,
      title: "Clear Playlists",
      description:
          "This will permanently delete all your playlists. This action cannot be undone.",
      onConfirm: () async {
        sl<PlaylistCubit>().deleteAllPlaylist();
      },
    );
  }

  static Future<void> clearFavorites(BuildContext context) async {
    await deleteBoxDialogue(
      context,
      title: "Clear Favorites",
      description:
          "This will remove all your favorite songs from the app. This action cannot be undone.",
      onConfirm: () async {
        await sl<FavoritesCubit>().clearFavs();
      },
    );
  }

  static Future<void> clearRecentlyPlayed(BuildContext context) async {
    await deleteBoxDialogue(
      context,
      title: "Clear Recently Played",
      description:
          "This will clear your recently played songs history. This action cannot be undone.",
      onConfirm: () async {
        await sl<RecentlyPlayedCubit>().clear();
      },
    );
  }

  static Future<void> clearMostlyPlayed(BuildContext context) async {
    await deleteBoxDialogue(
      context,
      title: "Clear Mostly Played",
      description:
          "This will reset your most played songs data. This action cannot be undone.",
      onConfirm: () async {
        await sl<MostlyPlayedCubit>().clear();
      },
    );
  }

  static Future<void> clearRemovedSongs(BuildContext context) async {
    await deleteBoxDialogue(
      context,
      title: "Clear Removed Songs",
      description:
          "This will remove all songs from your removed songs list. This action cannot be undone.",
      onConfirm: () async {
        await Hive.box<Map>('RemovedDB').clear();
      },
    );
  }

  static Future<void> clearSettings(BuildContext context) async {
    await deleteBoxDialogue(
      context,
      title: "Clear Settings",
      description:
          "This will reset all your app preferences back to default. This action cannot be undone.",
      onConfirm: () async {
        await Hive.box('settingsBox').clear();
      },
    );
  }

  static Future<void> fullReset(BuildContext context) async {
    await deleteBoxDialogue(
      context,
      title: "Full Reset",
      description:
          "This will delete ALL app data:\n\n"
          "• Playlists\n"
          "• Favorites\n"
          "• Recently Played\n"
          "• Mostly Played\n"
          "• Removed Songs\n"
          "• Settings\n\n"
          "After reset, Moz Music will restart like a fresh install.",
      onConfirm: () async {
        await fullResetApp(context);
      },
      restartAfter: true,
    );
  }
}
