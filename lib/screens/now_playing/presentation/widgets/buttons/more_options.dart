import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:moz_updated_version/core/helper/delete_file.dart';
import 'package:moz_updated_version/core/helper/share_songs.dart';
import 'package:moz_updated_version/main.dart';
import 'package:moz_updated_version/screens/settings/screens/setting_screen/settings_page.dart';
import 'package:moz_updated_version/screens/settings/screens/sleep_timer_screen/presentation/ui/sleep_timer.dart';
import 'package:moz_updated_version/screens/settings/screens/song_detail_screen.dart/song_detail.dart';
import 'package:moz_updated_version/services/core/app_services.dart';
import 'package:moz_updated_version/widgets/add_to_playlis_dalogue.dart';

class CurrentSongOptionsMenu extends StatelessWidget {
  const CurrentSongOptionsMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MediaItem?>(
      stream: audioHandler.mediaItem,
      builder: (context, snapshot) {
        final current = snapshot.data;
        log(current.toString());
        return PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded),
          onSelected: (value) async {
            if (current == null) return;

            switch (value) {
              case 'add_to_playlist':
                showAddToPlaylistDialog(context, songId: int.parse(current.id));
                break;
              case 'sleep_timer':
                sl<NavigationService>().navigateTo(
                  SleepTimerScreen(),
                  animation: NavigationAnimation.fade,
                );
                break;
              case 'share':
                await ShareHelper.shareSong(filePath: current.extras!["data"]);
                break;
              case 'details':
                sl<NavigationService>().navigateTo(
                  SongDetailScreen(song: current),
                  animation: NavigationAnimation.fade,
                );
                break;
              case 'settings':
                 sl<NavigationService>().navigateTo(
                  SettingsScreen(),
                  animation: NavigationAnimation.fade,
                );
                break;
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'add_to_playlist',
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.playlist_add),
                title: Text('Add to Playlist'),
              ),
            ),
            PopupMenuItem(
              value: 'sleep_timer',
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.timer),
                title: Text('Sleep Timer'),
              ),
            ),
            PopupMenuItem(
              value: 'share',
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.share),
                title: Text('Share'),
              ),
            ),
            PopupMenuItem(
              value: 'details',
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.info_outline),
                title: Text('Details'),
              ),
            ),
            PopupMenuItem(
              value: 'settings',
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.settings),
                title: Text('Settings'),
              ),
            ),
          ],
        );
      },
    );
  }
}
