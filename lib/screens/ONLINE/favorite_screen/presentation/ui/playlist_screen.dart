import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/core/extensions/capitalize.dart';
import 'package:moz_updated_version/core/helper/snackbar_helper.dart';
import 'package:moz_updated_version/data/firebase/logic/playlist/playlist_cubit.dart';
import 'package:moz_updated_version/data/model/song_playlist_model/online_song_playlist.dart';
import 'package:moz_updated_version/data/model/user_model/repository/user_repo.dart';
import 'package:moz_updated_version/screens/ONLINE/favorite_screen/presentation/ui/playlist_song_view.dart';
import 'package:moz_updated_version/screens/ONLINE/favorite_screen/presentation/widgets/empty_view.dart';
import 'package:moz_updated_version/screens/ONLINE/spotify_screen/ui/spotify_import_screen.dart';
import 'package:moz_updated_version/screens/mini_player/presentation/ui/mini_player.dart';
import 'package:moz_updated_version/screens/playlist_screen/presentation/widgets/playlist_add_dialogue.dart';
import 'package:moz_updated_version/services/service_locator.dart';
import 'package:moz_updated_version/widgets/custom_cached_image.dart';
import 'package:moz_updated_version/widgets/custom_menu/custom_dynamic_popmenu.dart';
import 'package:moz_updated_version/widgets/error_widget.dart';
import 'package:moz_updated_version/widgets/shimmers/shimmer_widget.dart';
import 'package:on_audio_query/on_audio_query.dart';

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
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        spacing: 5,
        children: [
          FloatingActionButton.extended(
            heroTag: "new_playlist_fab",
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
          FloatingActionButton.extended(
            heroTag: "spotify_import_fab",
            backgroundColor: theme.primaryColor,
            icon: const Icon(Icons.add),
            label: const Text("Import from spotify"),
            onPressed: () {
              AppSnackBar.info(
                context,
                "Still working on this option it will be available soon",
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<OnlinePlaylistCubit, OnlinePlaylistState>(
        builder: (context, state) {
          if (state is OnlinePlaylistLoading) {
            return Center(child: MozShimmer(width: 200, height: 120));
          }

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
                          PlaylistThumbnailWidget(
                            thumbnails: playlist.recentThumbnails,
                          ),
                          const SizedBox(width: 16),

                          // Playlist Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  playlist.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${playlist.songCount} ${playlist.songCount == 1 ? 'song' : 'songs'}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.textTheme.bodySmall?.color
                                        ?.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Menu
                          SongMenuBuilder.buildMenu(
                            context: context,
                            playlistId: playlist.id,
                            song: SongModel({}),
                            menuContext: SongMenuContext.playlist,
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
            return AppErrorView();
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
      bottomNavigationBar: MiniPlayer(),
    );
  }
}

class PlaylistThumbnailWidget extends StatelessWidget {
  final List<String> thumbnails;
  final double size;
  final double borderRadius;

  const PlaylistThumbnailWidget({
    super.key,
    required this.thumbnails,
    this.size = 64,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (thumbnails.isEmpty) {
      return Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          color: theme.primaryColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Icon(
          Icons.queue_music,
          color: theme.primaryColor,
          size: size * 0.5,
        ),
      );
    }

    if (thumbnails.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: CustomCachedImage(
          imageUrl: thumbnails[0],
          height: size,
          width: size,
          fit: BoxFit.cover,
        ),
      );
    }

    return SizedBox(
      height: size,
      width: size,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 1,
          crossAxisSpacing: 1,
        ),
        itemCount: 4,
        itemBuilder: (context, index) {
          if (index < thumbnails.length) {
            return CustomCachedImage(
              imageUrl: thumbnails[index],
              fit: BoxFit.cover,
              radius: 5,
            );
          } else {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: theme.primaryColor.withValues(alpha: 0.12),
              ),
              child: Icon(
                Icons.music_note,
                color: theme.primaryColor.withValues(alpha: 0.5),
                size: size * 0.25,
              ),
            );
          }
        },
      ),
    );
  }
}
