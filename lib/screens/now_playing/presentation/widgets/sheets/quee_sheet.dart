import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/core/extensions/song_model_ext.dart';
import 'package:moz_updated_version/screens/now_playing/presentation/widgets/sheets/cubit/queue_cubit.dart';
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
                  return Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.withAlpha(100),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Playing Next",
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ReorderableListView.builder(
                          scrollController: scrollController,
                          itemCount: queue.length,
                          padding: const EdgeInsets.only(bottom: 20),
                          onReorder: (oldIndex, newIndex) {
                            context.read<QueueCubit>().reorderQueue(oldIndex, newIndex);
                          },
                          itemBuilder: (context, index) {
                            final song = queue[index];
                            return Container(
                              key: ValueKey('${song.id}_$index'),
                              child: CustomSongTile(
                                song: song.toSongModel(),
                                showSheet: false,
                                showMoreTrailing: true,
                                onTap: () async {
                                  await context.read<QueueCubit>().skipToIndex(index);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
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
