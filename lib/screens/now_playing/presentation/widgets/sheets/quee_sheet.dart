import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:moz_updated_version/core/extensions/song_model_ext.dart';
import 'package:moz_updated_version/main.dart';
import 'package:moz_updated_version/widgets/buttons/play_pause_button.dart';
import 'package:moz_updated_version/widgets/song_list_tile.dart';

class QueueBottomSheet extends StatelessWidget {
  const QueueBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).scaffoldBackgroundColor.withValues(alpha: 0.6),

            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return StreamBuilder<List<MediaItem>>(
                stream: audioHandler.currentQueue$,
                builder: (context, snapshot) {
                  final queue = snapshot.data ?? [];

                  if (queue.isEmpty) {
                    return const Center(child: Text("No songs in queue"));
                  }

                  return ListView.builder(
                    controller: scrollController,
                    itemCount: queue.length,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    itemBuilder: (context, index) {
                      final song = queue[index];
                      return StreamBuilder<MediaItem?>(
                        key: ValueKey(song.id),
                        stream: audioHandler.mediaItem,
                        builder: (context, mediaSnapshot) {
                          final currentSong = mediaSnapshot.data;
                          final isPlaying = currentSong?.id == song.id;
                          return CustomSongTile(
                            song: song.toSongModel(),
                            showSheet: false,
                            isPlaying: isPlaying,
                            isTrailingChange: true,
                            trailing: isPlaying
                                ? PlayPauseButton()
                                : IconButton(
                                    onPressed: () async => await audioHandler
                                        .removeQueueItem(song),
                                    icon: const Icon(Icons.remove),
                                  ),
                            onTap: () async {
                              final originalIndex = audioHandler.mediaItems
                                  .indexWhere((m) => m.id == song.id);
                              await audioHandler.skipToQueueItem(originalIndex);
                            },
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

void showCurrentQueueSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    sheetAnimationStyle: const AnimationStyle(
      duration: Duration(milliseconds: 600),
      curve: Curves.easeInBack,
    ),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => const QueueBottomSheet(),
  );
}
