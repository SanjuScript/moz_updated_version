import 'package:flutter/material.dart';
import 'package:moz_updated_version/widgets/add_to_playlis_dalogue.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:share_plus/share_plus.dart';

class SongDetailsBottomSheet extends StatelessWidget {
  final SongModel song;
  final VoidCallback onAddToPlaylist;

  const SongDetailsBottomSheet({
    super.key,
    required this.song,
    required this.onAddToPlaylist,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: Theme.of(context).dividerColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              height: 5,
              width: 50,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          Text(
            song.title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            song.artist ?? "Unknown Artist",
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey, fontSize: 14),
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildInfoRow(Icons.album, "Album", song.album ?? "Unknown"),
                const Divider(),
                _buildInfoRow(
                  Icons.music_note,
                  "Composer",
                  song.composer ?? "Not Available",
                ),
                const Divider(),
                _buildInfoRow(
                  Icons.storage,
                  "Storage",
                  song.data ?? "Unavailable",
                ),
                const Divider(),
                _buildInfoRow(
                  Icons.access_time,
                  "Duration",
                  _formatDuration(song.duration),
                ),
                const Divider(),
                _buildInfoRow(
                  Icons.calendar_today,
                  "Date Added",
                  DateTime.fromMillisecondsSinceEpoch(
                    song.dateAdded ?? 0,
                  ).toLocal().toString().split(" ").first,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 1.4,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    foregroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () {
                    Share.shareXFiles([
                      XFile(song.data),
                    ], text: "Check out this song: ${song.title}");
                  },
                  icon: const Icon(Icons.share),
                  label: const Text(
                    "Share",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: ElevatedButton.icon(
                  style:
                      ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 6,
                        shadowColor: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.4),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                      ).copyWith(
                        backgroundColor: WidgetStateProperty.resolveWith((
                          states,
                        ) {
                          if (states.contains(WidgetState.pressed)) {
                            return Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.9);
                          }
                          return Theme.of(context).colorScheme.primary;
                        }),
                      ),
                  onPressed: () {
                    GlobalWidgets.showAddToPlaylistDialog(context, song);
                  },
                  icon: const Icon(Icons.playlist_add),
                  label: const Text(
                    "Add to Playlist",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  String _formatDuration(int? ms) {
    if (ms == null) return "Unknown";
    final duration = Duration(milliseconds: ms);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}
