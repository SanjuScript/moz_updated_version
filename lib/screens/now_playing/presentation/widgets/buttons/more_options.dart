import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/core/extensions/song_model_ext.dart';
import 'package:moz_updated_version/core/helper/color_extractor.dart/cubit/artworkcolorextractor_cubit.dart';
import 'package:moz_updated_version/main.dart';
import 'package:moz_updated_version/screens/settings/screens/sleep_timer_screen/presentation/ui/sleep_timer.dart';
import 'package:moz_updated_version/services/core/app_services.dart';
import 'package:moz_updated_version/widgets/add_to_playlis_dalogue.dart'; // for your audioHandler

class CurrentSongOptionsMenu extends StatelessWidget {
  const CurrentSongOptionsMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MediaItem?>(
      stream: audioHandler.mediaItem,
      builder: (context, snapshot) {
        final current = snapshot.data;

        return BlocBuilder<ArtworkColorCubit, ArtworkColorState>(
          builder: (context, state) {
            return PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded),
              onSelected: (value) async {
                if (current == null) return;

                switch (value) {
                  case 'add_to_playlist':
                    showAddToPlaylistDialog(context, int.parse(current.id));
                    break;
                  case 'sleep_timer':
                    sl<NavigationService>().navigateTo(
                      SleepTimerScreen(),
                      animation: NavigationAnimation.fade,
                    );
                    break;
                  case 'share':
                    // share logic using current.extras?['uri']
                    break;
                  case 'details':
                    // show song details
                    break;
                  case 'settings':
                    // open settings
                    break;
                  case 'delete':
                    await audioHandler.removeQueueItem(current);
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
                PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.delete_outline),
                    title: Text('Delete'),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
