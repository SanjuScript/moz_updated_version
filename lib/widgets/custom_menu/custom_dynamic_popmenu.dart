import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/core/helper/delete_file.dart';
import 'package:moz_updated_version/core/helper/share_songs.dart';
import 'package:moz_updated_version/core/helper/snackbar_helper.dart';
import 'package:moz_updated_version/core/utils/downloads/cubit/download_cubit.dart';
import 'package:moz_updated_version/core/utils/repository/Authentication/auth_guard.dart';
import 'package:moz_updated_version/data/firebase/logic/favorites/favorites_cubit.dart';
import 'package:moz_updated_version/data/firebase/logic/playlist/playlist_cubit.dart';
import 'package:moz_updated_version/data/firebase/logic/playlist_songs/playlistsongs_cubit.dart';
import 'package:moz_updated_version/screens/ONLINE/download_screen/cubit/download_songs_cubit.dart';
import 'package:moz_updated_version/screens/favorite_screen/presentation/cubit/favotite_cubit.dart';
import 'package:moz_updated_version/screens/playlist_screen/presentation/widgets/playlist_add_dialogue.dart';
import 'package:moz_updated_version/screens/settings/screens/setting_screen/dialogues/general_dialogue.dart';
import 'package:moz_updated_version/services/core/analytics_service.dart';
import 'package:moz_updated_version/widgets/online_playlist_dialogue.dart';
import 'package:on_audio_query/on_audio_query.dart';

enum SongMenuContext {
  favorites,
  playlistsSongs,
  playlist,
  downloads,
  search,
  album,
  artist,
  queue,
}

class SongMenuBuilder {
  static Widget buildMenu({
    required BuildContext context,
    required SongModel song,
    required SongMenuContext menuContext,
    String? playlistId,
    VoidCallback? onRemove,
  }) {
    final extras = song.getMap;
    final isOnline = extras["isOnline"] == true;

    return PopupMenuButton<String>(
      position: PopupMenuPosition.over,
      padding: EdgeInsets.zero,
      iconSize: 22,
      icon: const Icon(Icons.more_vert),
      popUpAnimationStyle: AnimationStyle(
        curve: Curves.easeIn,
        duration: Duration(milliseconds: 500),
        reverseCurve: Curves.decelerate,
        reverseDuration: Duration(milliseconds: 600),
      ),
      onSelected: (value) => _handleMenuAction(
        context: context,
        action: value,
        playlistId: playlistId,
        song: song,
        onRemove: onRemove,
      ),
      itemBuilder: (context) => _buildMenuItems(
        context: context,
        menuContext: menuContext,
        isOnline: isOnline,
        song: song,
      ),
    );
  }

  static List<PopupMenuEntry<String>> _buildMenuItems({
    required BuildContext context,
    required SongMenuContext menuContext,
    required bool isOnline,
    required SongModel song,
  }) {
    if (menuContext == SongMenuContext.playlist) {
      return const [
        PopupMenuItem(
          value: 'rename_playlist',
          height: 40,
          child: _MenuRow(Icons.edit_outlined, 'Rename Playlist'),
        ),
        PopupMenuItem(
          value: 'delete_playlist',
          height: 40,
          child: _MenuRow(
            Icons.delete_outline,
            'Delete Playlist',
            color: Colors.red,
          ),
        ),
      ];
    }

    final items = <PopupMenuEntry<String>>[];
    final String? pid = song.getMap["pid"]?.toString();
    final bool hasPid = pid != null && pid.isNotEmpty;

    final bool isFavorite = hasPid
        ? context.read<OnlineFavoritesCubit>().isFavorite(pid)
        : context.read<FavoritesCubit>().isFavorite(song.id.toString());

    items.addAll([
      if (menuContext != SongMenuContext.favorites)
        PopupMenuItem(
          value: 'fav',
          height: 40,
          child: _MenuRow(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
            color: isFavorite ? Colors.red : null,
          ),
        ),
      const PopupMenuItem(
        value: 'playlist',
        height: 40,
        child: _MenuRow(Icons.playlist_add, 'Add to Playlist'),
      ),
    ]);
    if (menuContext == SongMenuContext.favorites) {
      items.add(
        const PopupMenuItem(
          value: 'remove_favorite',
          height: 40,
          child: _MenuRow(
            Icons.favorite,
            'Remove from Favorites',
            color: Colors.red,
          ),
        ),
      );
    } else if (menuContext == SongMenuContext.playlistsSongs) {
      items.add(
        const PopupMenuItem(
          value: 'remove_playlist',
          height: 40,
          child: _MenuRow(
            Icons.playlist_remove,
            'Remove from Playlist',
            color: Colors.red,
          ),
        ),
      );
    } else if (menuContext == SongMenuContext.downloads) {
      items.add(
        const PopupMenuItem(
          value: 'delete_download',
          height: 40,
          child: _MenuRow(
            Icons.delete_outline,
            'Delete Download',
            color: Colors.red,
          ),
        ),
      );
    }

    items.addAll([
      const PopupMenuItem(
        value: 'play_next',
        height: 40,
        child: _MenuRow(Icons.skip_next, 'Play Next'),
      ),
      const PopupMenuItem(
        value: 'add_queue',
        height: 40,
        child: _MenuRow(Icons.queue_music, 'Add to Queue'),
      ),
    ]);

    items.add(
      PopupMenuDivider(
        height: 8,
        color: Theme.of(context).textTheme.titleLarge!.color,
      ),
    );

    items.addAll([
      const PopupMenuItem(
        value: 'artist',
        height: 40,
        child: _MenuRow(Icons.person_outline, 'Go to Artist'),
      ),
      const PopupMenuItem(
        value: 'album',
        height: 40,
        child: _MenuRow(Icons.album_outlined, 'Go to Album'),
      ),
    ]);

    if (isOnline && menuContext != SongMenuContext.downloads) {
      items.add(
        const PopupMenuItem(
          value: 'download',
          height: 40,
          child: _MenuRow(Icons.download_rounded, 'Download'),
        ),
      );
    }

    if (!isOnline) {
      items.addAll([
        const PopupMenuItem(
          value: 'delete_download',
          height: 40,
          child: _MenuRow(
            Icons.delete_forever,
            'Delete song',
            color: Colors.red,
          ),
        ),
        const PopupMenuItem(
          value: 'share',
          height: 40,
          child: _MenuRow(Icons.share_outlined, 'Share'),
        ),
      ]);
    }

    return items;
  }

  static Future<void> _handleMenuAction({
    required BuildContext context,
    required String action,
    required SongModel song,
    VoidCallback? onRemove,
    String? playlistId,
  }) async {
    switch (action) {
      case 'fav':
        await _toggleFavorite(context, song);
        break;

      case 'playlist':
        _showPlaylistDialog(context, song);
        break;

      case 'remove_favorite':
        await _toggleFavorite(context, song);
        onRemove?.call();
        break;

      case 'remove_playlist':
        context.read<PlaylistsongsCubit>().removeSong(
          playlistId: playlistId!,
          songId: song.getMap["pid"] ?? '',
        );
        AppSnackBar.success(context, "${song.title} removed from playlist");
        break;
      case 'rename_playlist':
        showDialog(
          context: context,
          builder: (_) => PlaylistDialog(
            title: "Edit Playlist",
            onSave: (name) async {
              if (name.isNotEmpty && playlistId != null) {
                await context.read<OnlinePlaylistCubit>().updatePlaylistName(
                  playlistId: playlistId,
                  newName: name,
                );
              }
            },
          ),
        );
        break;

      case 'delete_playlist':
        if (playlistId != null) {
          deleteBoxDialogue(
            context,
            title: "Delete Playlist",
            description: "This action cannot be undone",
            onConfirm: () async {
              await context.read<OnlinePlaylistCubit>().deletePlaylist(
                playlistId,
              );
            },
          );
        }
        break;

      case 'delete_download':
        final result = await DeletAudioFile.deleteFile(song.data);
        if (result == "Files deleted successfully") {
          context.read<DownloadSongsCubit>().removeSongFromDb(song.id);
        }
        onRemove?.call();
        break;

      case 'download':
        _downloadSong(context, song);
        break;
      case 'share':
        ShareHelper.shareSong(filePath: song.data);
        break;

      case 'play_next':
      case 'add_queue':
      case 'artist':
      case 'album':
        _betaInfo(context);
        break;
    }
  }

  static Future<void> _toggleFavorite(
    BuildContext context,
    SongModel song,
  ) async {
    final songMap = song.getMap;
    final String? pid = songMap["pid"]?.toString();
    final bool hasPid = pid != null && pid.isNotEmpty;

    if (hasPid) {
      final canProceed = await AuthGuard.ensureLoggedIn(context);
      if (!canProceed) return;

      final cubit = context.read<OnlineFavoritesCubit>();
      await cubit.toggleFavorite(pid);
      await AnalyticsService.logAddToFavorites(pid, song.title);

      if (cubit.isFavorite(pid)) {
        AppSnackBar.success(context, "Added to Favorites");
      } else {
        AppSnackBar.warning(context, "Removed from Favorites");
      }
    } else {
      final cubit = context.read<FavoritesCubit>();
      await cubit.toggleFavorite(song);

      if (cubit.isFavorite(pid!)) {
        AppSnackBar.success(context, "Added to Favorites");
      } else {
        AppSnackBar.warning(context, "Removed from Favorites");
      }
    }
  }

  static void _showPlaylistDialog(BuildContext context, SongModel song) {
    final songId = song.getMap["pid"].toString();
    showOnlinePlaylistDalogue(context, songId: songId);
  }

  static void _downloadSong(BuildContext context, SongModel song) {
    context.read<DownloadCubit>().download(song, context);
  }

  static void _betaInfo(BuildContext context) {
    AppSnackBar.info(context, "This feature is coming soon!");
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _MenuRow(this.icon, this.label, {this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: 14, color: color)),
      ],
    );
  }
}
