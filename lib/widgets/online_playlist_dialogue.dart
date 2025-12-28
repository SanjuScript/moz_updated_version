import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/core/helper/snackbar_helper.dart';
import 'package:moz_updated_version/data/firebase/logic/playlist/playlist_cubit.dart';
import 'package:moz_updated_version/screens/playlist_screen/presentation/widgets/froasted_dialogue.dart';
import 'package:moz_updated_version/screens/playlist_screen/presentation/widgets/playlist_add_dialogue.dart';

void showOnlinePlaylistDalogue(BuildContext context, {required String songId}) {
  context.read<OnlinePlaylistCubit>().loadPlaylists();

  showDialog(
    context: context,
    builder: (dContext) => _PlaylistSelectionDialog(songId: songId),
  );
}

class _PlaylistSelectionDialog extends StatefulWidget {
  final String songId;

  const _PlaylistSelectionDialog({required this.songId});

  @override
  State<_PlaylistSelectionDialog> createState() =>
      _PlaylistSelectionDialogState();
}

class _PlaylistSelectionDialogState extends State<_PlaylistSelectionDialog> {
  final Set<String> _selectedPlaylistIds = {};
  bool _isAdding = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FrostedDialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.playlist_add,
                    color: theme.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "Add to Playlist",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            BlocBuilder<OnlinePlaylistCubit, OnlinePlaylistState>(
              builder: (context, state) {
                if (state is! OnlinePlaylistsLoaded) {
                  return const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator.adaptive()),
                  );
                }

                if (state.playlists.isEmpty) {
                  return _buildEmptyState(context);
                }

                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.5,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: state.playlists.length,
                    separatorBuilder: (_, __) => Divider(
                      color: Colors.white.withValues(alpha: 0.1),
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      final playlist = state.playlists[index];
                      final isSelected = _selectedPlaylistIds.contains(
                        playlist.id,
                      );

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedPlaylistIds.remove(playlist.id);
                              } else {
                                _selectedPlaylistIds.add(playlist.id);
                              }
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? theme.primaryColor
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: isSelected
                                          ? theme.primaryColor
                                          : theme.disabledColor,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: isSelected
                                      ? const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 16,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),

                                Expanded(
                                  child: Text(
                                    playlist.name,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _createNewPlaylist(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: theme.primaryColor),
                      foregroundColor: theme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    child: const Text("New Playlist"),
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _selectedPlaylistIds.isEmpty || _isAdding
                        ? null
                        : () => _addToSelectedPlaylists(context),
                    icon: _isAdding
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check, size: 18),
                    label: Text(
                      _isAdding
                          ? "Adding..."
                          : "Add${_selectedPlaylistIds.isEmpty ? '' : ' (${_selectedPlaylistIds.length})'}",
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: theme.primaryColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: theme.disabledColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 5,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.queue_music, size: 48, color: theme.primaryColor),
          ),

          Text(
            "No Playlists Yet",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Create your first playlist to organize your favorite songs",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(),
          ),
        ],
      ),
    );
  }

  void _createNewPlaylist(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => PlaylistDialog(
        title: "New Playlist",
        onSave: (name) async {
          if (name.trim().isEmpty) return;

          final playlistId = await context
              .read<OnlinePlaylistCubit>()
              .createPlaylist(name.trim());

          if (playlistId != null) {
            await context.read<OnlinePlaylistCubit>().addSongToPlaylist(
              playlistId: playlistId,
              songId: widget.songId,
            );

            if (mounted) {
              Navigator.of(context).pop();
              AppSnackBar.success(context, "Added to $name");
            }
          }
        },
      ),
    );
  }

  Future<void> _addToSelectedPlaylists(BuildContext context) async {
    setState(() => _isAdding = true);

    try {
      final cubit = context.read<OnlinePlaylistCubit>();

      for (final playlistId in _selectedPlaylistIds) {
        await cubit.addSongToPlaylist(
          playlistId: playlistId,
          songId: widget.songId,
        );
      }

      if (mounted) {
        Navigator.of(context).pop();

        final count = _selectedPlaylistIds.length;
        AppSnackBar.success(
          context,
          count == 1 ? "Added to playlist" : "Added to $count playlists",
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, "Failed to add to playlists");
      }
    } finally {
      if (mounted) {
        setState(() => _isAdding = false);
      }
    }
  }
}
