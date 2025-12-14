import 'dart:ui';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:moz_updated_version/core/extensions/media_item_ext.dart';
import 'package:moz_updated_version/core/extensions/song_model_ext.dart';
import 'package:moz_updated_version/core/utils/online_playback_repo/audio_playback_repository.dart';
import 'package:moz_updated_version/data/model/online_models/album_model.dart';
import 'package:moz_updated_version/data/model/online_models/online_song_model.dart';
import 'package:moz_updated_version/screens/ONLINE/album_screen/presentation/cubit/collection_cubit.dart';
import 'package:moz_updated_version/screens/ONLINE/album_screen/presentation/widgets/collection_app_bar.dart';
import 'package:moz_updated_version/screens/ONLINE/album_screen/presentation/widgets/collection_info.dart';
import 'package:moz_updated_version/screens/mini_player/presentation/ui/mini_player.dart';
import 'package:moz_updated_version/services/audio_handler.dart';
import 'package:moz_updated_version/services/core/app_services.dart';
import 'package:moz_updated_version/widgets/custom_lottie.dart';
import 'package:moz_updated_version/widgets/song_list_tile.dart';

class OnlineAlbumScreen extends StatelessWidget {
  const OnlineAlbumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const MiniPlayer(),
      body: BlocBuilder<CollectionCubitForOnline, CollectionStateForOnline>(
        builder: (context, state) {
          if (state is CollectionLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AlbumLoaded) {
            final album = state.album;

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                CollectionAppBar(album.toUI),
                SliverToBoxAdapter(
                  child: CollectionInfo(
                    title: album.title ?? album.name ?? '',
                    subtitle: album.primaryArtists ?? '',
                    songs: album.songs ?? const [],
                  ),
                ),
                _SongList(album.songs ?? const []),
              ],
            );
          }

          if (state is PlaylistLoaded) {
            final playlist = state.playlist;

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                CollectionAppBar(playlist.toUI),
                SliverToBoxAdapter(
                  child: CollectionInfo(
                    title: playlist.name,
                    subtitle: playlist.type ?? 'Playlist',
                    songs: playlist.songs,
                  ),
                ),
                _SongList(playlist.songs),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _SongList extends StatelessWidget {
  final List<OnlineSongModel> onlineSongs;

  const _SongList(this.onlineSongs);

  @override
  Widget build(BuildContext context) {
    final songs = onlineSongs ?? [];

    return StreamBuilder<MediaItem?>(
      stream: sl<MozAudioHandler>().mediaItem,
      builder: (context, snapshot) {
        final currentMedia = snapshot.data;
        final currentId = currentMedia?.id;

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final song = songs[index];
              final onlineSong = song.toSongModel();

              final bool isPlaying =
                  currentId != null &&
                  currentId == onlineSong.getMap["pid"].toString();

              return CustomSongTile(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                song: onlineSong,
                isTrailingChange: true,
                // isPlaying: isPlaying, // ✅ highlight flag
                onTap: () {
                  sl<AudioPlaybackRepository>().playOnlineSong(
                    songs,
                    startIndex: index,
                  );
                },
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isPlaying)
                      Text(
                        _formatDuration(song.duration),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                    if (isPlaying)
                      CustomLottie(
                        asset: "assets/lotties/audio_playing.json",
                        width: 50,
                        height: 50,
                      ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.more_vert),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              );
            }, childCount: songs.length),
          ),
        );
      },
    );
  }
}

String _formatDuration(String? seconds) {
  if (seconds == null) return '';
  final s = int.tryParse(seconds) ?? 0;
  final m = s ~/ 60;
  final r = s % 60;
  return '$m:${r.toString().padLeft(2, '0')}';
}
