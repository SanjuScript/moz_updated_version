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
    final username = sl<UserStorageAbRepo>().userName;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${username!.isNotEmpty ? username.formattedFirstNamePossessive : "Your"} Playlist",
        ),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => PlaylistDialog(
              title: "New Playlist",
              onSave: (name) async {
                if (name.isEmpty) return;
                await context.read<OnlinePlaylistCubit>().createPlaylist(name);
              },
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<OnlinePlaylistCubit, OnlinePlaylistState>(
        builder: (context, state) {
          if (state is OnlinePlaylistsLoaded) {
            if (state.playlists.isEmpty) {
              return const EmptyView(
                showButton: false,
                title: "No Playlists yet",
                desc: "Create your first playlist",
                icon: Icons.playlist_add,
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.playlists.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final playlist = state.playlists[index];

                return ListTile(
                  leading: const Icon(Icons.queue_music),
                  title: Text(
                    playlist.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OnlinePlaylistSongsScreen(
                          playlistId: playlist.id,
                          playlistName: playlist.name,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }

          if (state is OnlinePlaylistError) {
            return Center(child: Text(state.message));
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
