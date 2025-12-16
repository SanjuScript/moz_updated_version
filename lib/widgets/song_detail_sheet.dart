import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/core/helper/share_songs.dart';
import 'package:moz_updated_version/core/themes/cubit/theme_cubit.dart';
import 'package:moz_updated_version/core/utils/repository/Authentication/auth_guard.dart';
import 'package:moz_updated_version/data/firebase/logic/playlist/playlist_cubit.dart';
import 'package:moz_updated_version/services/service_locator.dart';
import 'package:moz_updated_version/widgets/add_to_playlis_dalogue.dart';
import 'package:moz_updated_version/widgets/online_playlist_dialogue.dart';
import 'package:on_audio_query/on_audio_query.dart';

class SongDetailsBottomSheet extends StatelessWidget {
  final SongModel song;

  const SongDetailsBottomSheet({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    final isIos = sl<ThemeCubit>().isIos;

    return isIos
        ? CupertinoActionSheet(
            title: Text(
              song.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            message: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.artist ?? "Unknown Artist",
                  style: const TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.inactiveGray,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  CupertinoIcons.music_albums,
                  "Album",
                  song.album ?? "Unknown",
                  withIcon: false,
                ),
                _buildInfoRow(
                  CupertinoIcons.music_note,
                  "Composer",
                  song.composer ?? "Not Available",
                  withIcon: false,
                ),
                _buildInfoRow(
                  CupertinoIcons.doc,
                  "Storage",
                  song.data ?? "Unavailable",
                  withIcon: false,
                ),
                _buildInfoRow(
                  CupertinoIcons.time,
                  "Duration",
                  _formatDuration(song.duration),
                  withIcon: false,
                ),
                _buildInfoRow(
                  CupertinoIcons.calendar,
                  "Date Added",
                  DateTime.fromMillisecondsSinceEpoch(
                    song.dateAdded ?? 0,
                  ).toLocal().toString().split(" ").first,
                  withIcon: false,
                ),
              ],
            ),
            actions: [
              CupertinoActionSheetAction(
                onPressed: () async {
                  Navigator.pop(context);
                  await ShareHelper.shareSong(filePath: song.data);
                },
                child: const Text("Share Song"),
              ),
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();

                  showAddToPlaylistDialog(context, songId: song.id);
                },
                child: const Text("Add to Playlist"),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: () => Navigator.pop(context),
              isDefaultAction: true,
              child: const Text("Cancel"),
            ),
          )
        : Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
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
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        Icons.album,
                        "Album",
                        song.album ?? "Unknown",
                      ),
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
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                        ),
                        onPressed: () async {
                          await ShareHelper.shareSong(filePath: song.data);
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
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 6,
                          shadowColor: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.4),
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          showAddToPlaylistDialog(context, songId: song.id);
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

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    bool withIcon = true,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (withIcon) ...[
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
        ],
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

void showSongDetailsSheet(BuildContext context, SongModel song) async {
  final isIos = sl<ThemeCubit>().isIos;

  final extras = song.getMap;
  final isOnline = extras["isOnline"] == true;

  if (isOnline) {
    final canProceed = await AuthGuard.ensureLoggedIn(context);
    if (!canProceed) return;
    // context.read<OnlinePlaylistCubit>().loadPlaylists();
    showOnlinePlaylistDalogue(context, songId: extras["pid"].toString());

    return;
  }
  if (isIos) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => SongDetailsBottomSheet(song: song),
    );
  } else {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      barrierColor: Colors.transparent,
      backgroundColor: Theme.of(context).dividerColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SongDetailsBottomSheet(song: song),
    );
  }
}
