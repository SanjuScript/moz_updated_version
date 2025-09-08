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

          return CustomScrollView(
            slivers: [
              // ✅ AppBar with songs count only
              SliverAppBar(
                floating: true,
                snap: true,
                pinned: false,
                expandedHeight: 50,
                automaticallyImplyLeading: false,
                flexibleSpace: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Total ${items.length} Favorites",
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                ),
              ),

              // ✅ Songs list
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final song = items[index];
                    return CustomSongTile(
                      song: song,
                      onTap: () {
                        context.read<AudioBloc>().add(PlaySong(song, items));
                      },
                    );
                  },
                  childCount: items.length,
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
