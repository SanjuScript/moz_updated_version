import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/core/utils/bloc/audio_bloc.dart';
import 'package:moz_updated_version/screens/favorite_screen/presentation/cubit/favotite_cubit.dart';
import 'package:moz_updated_version/widgets/song_list_tile.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesCubit, FavotiteState>(
      builder: (context, state) {
        if (state is FavoritesLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is FavoritesError) {
          return Center(child: Text(state.message));
        }

        if (state is FavoritesLoaded) {
          final items = state.items;
          if (items.isEmpty) {
            return const Center(child: Text("No favorites yet"));
          }

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final song = items[index];
              return CustomSongTile(
                disableOnTap: true,
                song: song,
                onTap: () {
                  context.read<AudioBloc>().add(PlaySong(song, items));
                },
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
