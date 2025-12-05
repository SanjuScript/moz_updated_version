import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/core/utils/bloc/audio_bloc.dart';
import 'package:moz_updated_version/data/db/playlist/playlist_model.dart';
import 'package:moz_updated_version/data/db/playlist/repository/playlist_ab_repo.dart';
import 'package:moz_updated_version/screens/playlist_screen/presentation/ui/songs_view.dart';
import 'package:moz_updated_version/screens/song_list_screen/presentation/cubit/allsongs_cubit.dart';
import 'package:moz_updated_version/services/navigation_service.dart';
import 'package:moz_updated_version/services/service_locator.dart';
import 'package:moz_updated_version/widgets/audio_artwork_widget.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'dart:ui';

class CurrentPlaylistWidget extends StatefulWidget {
  const CurrentPlaylistWidget({super.key});

  @override
  State<CurrentPlaylistWidget> createState() => _CurrentPlaylistWidgetState();
}

class _CurrentPlaylistWidgetState extends State<CurrentPlaylistWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioBloc, AudioState>(
      builder: (context, state) {
        final audioBloc = context.read<AudioBloc>();
        final playlistKey = audioBloc.currentPlaylistKey;

        if (playlistKey == null || state is! SongPlaying) {
          return const SizedBox();
        }

        final playlist = sl<PlaylistAbRepo>().getPlaylist(playlistKey);
        if (playlist == null) return const SizedBox();

        final allSongsCubit = context.watch<AllSongsCubit>();
        if (allSongsCubit.state is! AllSongsLoaded) {
          return const SizedBox();
        }

        final allSongs = (allSongsCubit.state as AllSongsLoaded).songs;
        final songs = allSongs
            .where((song) => playlist.songIds.contains(song.id))
            .toList();

        if (songs.isEmpty) return const SizedBox();

        return _PlaylistStackView(
          playlist: playlist,
          songs: songs,
          currentSongId: state.currentSong?.id,
        );
      },
    );
  }
}

class _PlaylistStackView extends StatelessWidget {
  final Playlist playlist;
  final List<SongModel> songs;
  final int? currentSongId;

  const _PlaylistStackView({
    required this.playlist,
    required this.songs,
    required this.currentSongId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PlaylistHeader(playlist: playlist, count: songs.length),
          const SizedBox(height: 24),
          SizedBox(
            height: 220,
            child: NotificationListener<ScrollNotification>(
              onNotification: (_) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  (context as Element).markNeedsBuild();
                });
                return true;
              },
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(left: 24),
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  final song = songs[index];
                  // final isPlaying = currentSongId == song.id;
                  final scroll = (Scrollable.of(context)?.position.pixels ?? 0);
                  final position = scroll / 200.0;
                  final offset = (index - position);
                  final scale = 1 - (offset.abs() * 0.06);
                  final translateX = offset * -28;
                  final rotation = offset * 0.05;

                  return Transform.translate(
                    offset: Offset(translateX, 0),
                    child: Transform.rotate(
                      angle: rotation,
                      child: Transform.scale(
                        scale: scale.clamp(0.88, 1.0),
                        child: _StackCard(song: song, songs: songs),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaylistHeader extends StatelessWidget {
  final Playlist playlist;
  final int count;

  const _PlaylistHeader({required this.playlist, required this.count});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      onTap: () {
        sl<NavigationService>().navigateTo(
          PlaylistSongsScreen(playlistkey: playlist.key),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.queue_music_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playlist.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "$count songs - Now playing",
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StackCard extends StatelessWidget {
  final SongModel song;
  final List<SongModel> songs;

  const _StackCard({required this.song, required this.songs});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        context.read<AudioBloc>().add(
          PlaySong(
            song,
            songs,
            playlistKey: context.read<AudioBloc>().currentPlaylistKey,
          ),
        );
      },
      child: Container(
        width: 170,
        margin: const EdgeInsets.only(right: 16, bottom: 8, top: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.4)
                  : Colors.black.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned.fill(child: AudioArtWorkWidget(id: song.id)),

              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.0),
                        Colors.black.withValues(alpha: 0.3),
                        Colors.black.withValues(alpha: 0.85),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),

              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.3,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      song.artist ?? "Unknown Artist",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.75),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
