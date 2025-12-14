import 'package:flutter/material.dart';
import 'package:moz_updated_version/core/utils/online_playback_repo/audio_playback_repository.dart';
import 'package:moz_updated_version/data/model/online_models/online_song_model.dart';
import 'package:moz_updated_version/services/core/app_services.dart';

class CollectionInfo extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<dynamic> songs;

  const CollectionInfo({
    super.key,
    required this.title,
    required this.subtitle,
    required this.songs,
  });

  @override
  Widget build(BuildContext context) {
    final totalDuration = songs.fold<int>(0, (sum, song) {
      return sum + (int.tryParse(song.duration ?? '0') ?? 0);
    });

    final hours = totalDuration ~/ 3600;
    final minutes = (totalDuration % 3600) ~/ 60;
    final size = MediaQuery.sizeOf(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${songs.length} songs',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 6),
              const Text('•'),
              const SizedBox(width: 6),
              Text(
                hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          SizedBox(
            height: size.height * .06,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Expanded(
                    // height: size.height * .06,
                    // width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: songs.isEmpty
                          ? null
                          : () {
                              sl<AudioPlaybackRepository>().playOnlineSong(
                                songs.cast<OnlineSongModel>(),
                                startIndex: 0,
                              );
                            },
                      icon: Icon(
                        Icons.play_arrow_rounded,
                        color: Theme.of(context).textTheme.labelMedium!.color,
                      ),
                      label: Text(
                        "Play",
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(
                          context,
                        ).primaryColor.withValues(alpha: .8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 10),

                  // InkWell(
                  //   onTap: () {
                  //     sl<MozAudioHandler>().setShuffleMode(
                  //       AudioServiceShuffleMode.all,
                  //     );
                  //   },
                  //   child: Container(
                  //     height: 40,
                  //     width: 40,
                  //     decoration: BoxDecoration(
                  //       color: Colors.grey[800],
                  //       shape: BoxShape.circle,
                  //     ),
                  //     child: Icon(
                  //       Icons.shuffle,
                  //       color: Theme.of(context).scaffoldBackgroundColor,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
