import 'package:flutter/material.dart';
import 'package:moz_updated_version/screens/mostly_played/presentation/helper/get_dynamic_time.dart';
import 'package:moz_updated_version/widgets/song_list_tile.dart';
import 'package:on_audio_query/on_audio_query.dart';

class MostlyPlayedSongTile extends StatelessWidget {
  final SongModel song;
  final int playCount;
  final Duration playedDuration;
  final List<SongModel> allSongs;
  final void Function()? onTap;

  const MostlyPlayedSongTile({
    super.key,
    required this.song,
    required this.playCount,
    required this.playedDuration,
    required this.allSongs,
    this.onTap,
  });

  String _formatDuration(Duration duration) {
    if (duration.inHours >= 1) {
      return "${duration.inHours}h ${(duration.inMinutes % 60)}m";
    } else if (duration.inMinutes >= 1) {
      return "${duration.inMinutes}m ${(duration.inSeconds % 60)}s";
    } else {
      return "${duration.inSeconds}s";
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxDuration = getDynamicMax(playedDuration);

    final playedFraction =
        (playedDuration.inMilliseconds / maxDuration.inMilliseconds).clamp(
          0.0,
          1.0,
        );

    return Column(
      children: [
        CustomSongTile(
          isTrailingChange: true,
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                playCount.toString(),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              Text(
                "Played",
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  shadows: const [
                    BoxShadow(
                      color: Color.fromARGB(34, 107, 107, 107),
                      blurRadius: 15,
                      offset: Offset(-2, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
          song: song,
          onTap: onTap,
        ),

        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.sizeOf(context).width * .25,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinearProgressIndicator(
                value: playedFraction,
                minHeight: 6,
                backgroundColor: Colors.grey.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
                valueColor: AlwaysStoppedAnimation(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Played for ${_formatDuration(playedDuration)} ",
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
