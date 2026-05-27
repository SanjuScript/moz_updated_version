import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/core/constants/beta_info.dart';
import 'package:moz_updated_version/core/extensions/song_model_ext.dart';
import 'package:moz_updated_version/core/utils/online_playback_repo/audio_playback_repository.dart';
import 'package:moz_updated_version/data/firebase/logic/playlist_songs/playlistsongs_cubit.dart';
import 'package:moz_updated_version/screens/ONLINE/favorite_screen/presentation/widgets/empty_view.dart';
import 'package:moz_updated_version/screens/mini_player/presentation/ui/mini_player.dart';
import 'package:moz_updated_version/services/service_locator.dart';
import 'package:moz_updated_version/widgets/custom_menu/custom_dynamic_popmenu.dart';
import 'package:moz_updated_version/widgets/error_widget.dart';
import 'package:moz_updated_version/widgets/song_list_tile.dart';

class OnlinePlaylistSongsScreen extends StatefulWidget {
  final String playlistId;
  final String playlistName;

  const OnlinePlaylistSongsScreen({
    super.key,
    required this.playlistId,
    required this.playlistName,
  });

  @override
  State<OnlinePlaylistSongsScreen> createState() =>
      _OnlinePlaylistSongsScreenState();
}

class _OnlinePlaylistSongsScreenState extends State<OnlinePlaylistSongsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PlaylistsongsCubit>().loadPlaylistSongs(widget.playlistId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(widget.playlistName),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              betaInfo(context);
            },
          ),
        ],
      ),
      body: BlocBuilder<PlaylistsongsCubit, OnlinePlaylistsongsState>(
        builder: (context, state) {
          if (state is OnlinePlaylistSongsLoaded &&
              state.playlistId == widget.playlistId) {
            if (state.songs.isEmpty) {
              return const EmptyView(
                title: "Empty playlist",
                desc: "Add songs to start listening",
                icon: Icons.playlist_add_check,
                showButton: false,
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: state.songs.length,

              itemBuilder: (context, index) {
                final song = state.songs[index].toSongModel();

                return CustomSongTile(
                  showMoreTrailing: true,
                  menuContext: SongMenuContext.playlistsSongs,
                  playlistId: widget.playlistId,

                  song: song,
                  onTap: () {
                    sl<AudioPlaybackRepository>().playOnlineSong(
                      state.songs,
                      startIndex: index,
                    );
                  },
                );
              },
            );
          }

          if (state is OnlinePlaylistSongsError) {
            return AppErrorView();
          }

          return const Center(child: CircularProgressIndicator.adaptive());
        },
      ),
      bottomNavigationBar: MiniPlayer(),
    );
  }
}
