import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/core/extensions/capitalize.dart';
import 'package:moz_updated_version/data/firebase/logic/playlist/playlist_cubit.dart';
import 'package:moz_updated_version/data/model/user_model/repository/user_repo.dart';
import 'package:moz_updated_version/screens/ONLINE/favorite_screen/presentation/ui/playlist_song_view.dart';
import 'package:moz_updated_version/screens/ONLINE/favorite_screen/presentation/widgets/empty_view.dart';
import 'package:moz_updated_version/screens/playlist_screen/presentation/widgets/playlist_add_dialogue.dart';
import 'package:moz_updated_version/services/service_locator.dart';

class OnlinePlaylistScreen extends StatefulWidget {
  const OnlinePlaylistScreen({super.key});

  @override
  State<OnlinePlaylistScreen> createState() => _OnlinePlaylistScreenState();
}

class _OnlinePlaylistScreenState extends State<OnlinePlaylistScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OnlinePlaylistCubit>().loadPlaylists();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final username = sl<UserStorageAbRepo>().userName;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${username?.isNotEmpty == true ? username!.formattedFirstNamePossessive : "Your"} Playlists",
        ),
        centerTitle: false,
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: theme.primaryColor,
        icon: const Icon(Icons.add),
        label: const Text("New Playlist"),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => PlaylistDialog(
              title: "New Playlist",
              onSave: (name) async {
                if (name.trim().isEmpty) return;
                await context.read<OnlinePlaylistCubit>().createPlaylist(
                  name.trim(),
                );
              },
            ),
          );
        },
      ),

      body: BlocBuilder<OnlinePlaylistCubit, OnlinePlaylistState>(
        builder: (context, state) {
          if (state is OnlinePlaylistsLoaded) {
            if (state.playlists.isEmpty) {
              return const EmptyView(
                showButton: false,
                title: "No playlists yet",
                desc:
                    "Create playlists to organize your favorite songs\nand enjoy them anytime.",
                icon: Icons.queue_music,
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              itemCount: state.playlists.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final playlist = state.playlists[index];

                return Material(
                  color: theme.cardColor,
                  elevation: 1.5,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OnlinePlaylistSongsScreen(
                            playlistId: playlist.id,
                            playlistName: playlist.name,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.queue_music,
                              color: theme.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              playlist.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            onSelected: (value) {
                              if (value == 'delete') {
                                // _showDeleteDialog(context, playlist.id, playlist.name);
                                context
                                    .read<OnlinePlaylistCubit>()
                                    .deletePlaylist(playlist.id);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Delete playlist',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }

          if (state is OnlinePlaylistError) {
            return Center(
              child: Text(state.message, style: theme.textTheme.bodyMedium),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
