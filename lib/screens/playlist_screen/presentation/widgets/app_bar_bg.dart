import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/core/utils/bloc/audio_bloc.dart';
import 'package:moz_updated_version/data/db/playlist/playlist_model.dart';
import 'package:moz_updated_version/widgets/audio_artwork_widget.dart';
import 'package:on_audio_query/on_audio_query.dart';

class AppBarBackground extends StatelessWidget {
  final List<SongModel> songsInPlaylist;
  final Playlist playlist;
  final bool isCollapsed;
  const AppBarBackground({
    super.key,
    required this.songsInPlaylist,
    required this.playlist,
    required this.isCollapsed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        AudioArtWorkWidget(id: songsInPlaylist.first.id, size: 500, radius: 0),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).scaffoldBackgroundColor.withValues(alpha: .2),
                Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 1),
              ],
            ),
          ),
        ),
        if (!isCollapsed)
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      playlist.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "${songsInPlaylist.length} songs",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                InkWell(
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  onTap: () {
                    context.read<AudioBloc>().add(
                      PlaySong(
                        songsInPlaylist.first,
                        songsInPlaylist,
                        playlistKey: playlist.key,
                      ),
                    );
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.pink,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(0, 4),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
