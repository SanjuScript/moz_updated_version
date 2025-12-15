import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:moz_updated_version/core/helper/share_songs.dart';
import 'package:moz_updated_version/core/themes/cubit/theme_cubit.dart';
import 'package:moz_updated_version/core/utils/repository/Authentication/auth_guard.dart';
import 'package:moz_updated_version/main.dart';
import 'package:moz_updated_version/screens/settings/screens/equalizer_screen/ui/equalizer_screen.dart';
import 'package:moz_updated_version/screens/settings/screens/setting_screen/settings_page.dart';
import 'package:moz_updated_version/screens/settings/screens/sleep_timer_screen/presentation/ui/sleep_timer.dart';
import 'package:moz_updated_version/screens/settings/screens/song_detail_screen.dart/song_detail.dart';
import 'package:moz_updated_version/services/core/app_services.dart';
import 'package:moz_updated_version/widgets/add_to_playlis_dalogue.dart';
import 'package:moz_updated_version/widgets/custom_menu/custom_popmenu.dart';
import 'package:moz_updated_version/widgets/online_playlist_dialogue.dart';

class CurrentSongOptionsMenu extends StatelessWidget {
  const CurrentSongOptionsMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MediaItem?>(
      stream: audioHandler.mediaItem,
      builder: (context, snapshot) {
        final current = snapshot.data;

        return GlassPopMenuButton(
          icon: const Icon(Icons.more_vert_rounded),
          items: [
            GlassPopMenuEntry(
              value: 'add_to_playlist',
              child: const ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.playlist_add),
                title: Text('Add to Playlist'),
              ),
            ),
            GlassPopMenuEntry(
              value: 'sleep_timer',
              child: const ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.timer),
                title: Text('Sleep Timer'),
              ),
            ),
            GlassPopMenuEntry(
              value: 'share',
              child: const ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.share),
                title: Text('Share'),
              ),
            ),
            GlassPopMenuEntry(
              value: 'details',
              child: const ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.info_outline),
                title: Text('Details'),
              ),
            ),
            GlassPopMenuEntry(
              value: 'equalizer',
              child: const ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.equalizer),
                title: Text('Equalizer'),
              ),
            ),
            GlassPopMenuEntry(
              value: 'settings',
              child: const ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.settings),
                title: Text('Settings'),
              ),
            ),
          ],
          onSelected: (value) async {
            if (current == null) return;
            await _handleAction(context, value, current);
          },
        );
      },
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    String value,
    MediaItem current,
  ) async {
    switch (value) {
      case 'add_to_playlist':
        if (current.extras!["isOnline"] == true) {
          final canProceed = await AuthGuard.ensureLoggedIn(context);
          if (!canProceed) return;
          showOnlinePlaylistDalogue(context, songId: current.id);
          return;
        }
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
      case 'equalizer':
        sl<NavigationService>().navigateTo(
          EqualizerScreen(),
          animation: NavigationAnimation.fade,
        );
        break;
    }
  }
}
