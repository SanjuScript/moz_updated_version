import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/core/utils/bloc/audio_bloc.dart';
import 'package:moz_updated_version/screens/playlist_screen/presentation/cubit/playlist_cubit.dart';
import 'package:moz_updated_version/widgets/song_list_tile.dart';
import 'package:on_audio_query/on_audio_query.dart';

class CustomTileWithTrailing extends StatelessWidget {
  final List<SongModel> songsInPlaylist;
  final int index;
  final int playlistkey;
  const CustomTileWithTrailing({
    super.key,
    required this.songsInPlaylist,
    required this.index,
    required this.playlistkey,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaylistCubit, PlaylistState>(
      builder: (context, state) {
        if (state is! PlaylistLoaded) return const SizedBox();

        final song = songsInPlaylist[index];
        final isSelecting = state.isSelecting;
        final isSelected = state.selectedSongIds.contains(song.id);

        return CustomSongTile(
          song: song,
          isTrailingChange: isSelecting,
          trailing: Checkbox(
            value: isSelected,
            onChanged: (_) {
              context.read<PlaylistCubit>().toggleSongSelection(song.id);
            },
          ),
          onTap: () {
            if (!isSelecting) {
              context.read<AudioBloc>().add(
                PlaySong(song, songsInPlaylist, playlistKey: playlistkey),
              );
            } else {
              context.read<PlaylistCubit>().toggleSongSelection(song.id);
            }
          },
        );
      },
    );
  }
}
