import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/core/extensions/song_model_ext.dart';
import 'package:moz_updated_version/main.dart';
import 'package:moz_updated_version/screens/now_playing/presentation/widgets/sheets/cubit/queue_cubit.dart';
import 'package:moz_updated_version/widgets/buttons/play_pause_button.dart';
import 'package:moz_updated_version/widgets/song_list_tile.dart';

class QueueBottomSheet extends StatelessWidget {
  const QueueBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
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
              return BlocBuilder<QueueCubit, List<MediaItem>>(
                builder: (context, queue) {
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
                            trailing: isPlaying ? PlayPauseButton() : null,
                            onTap: () async {
                              await context.read<QueueCubit>().skipTo(song);
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
