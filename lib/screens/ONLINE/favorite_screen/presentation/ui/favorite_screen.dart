import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/core/extensions/song_model_ext.dart';
import 'package:moz_updated_version/data/firebase/logic/favorites/favorites_cubit.dart';
import 'package:moz_updated_version/data/model/online_models/online_song_model.dart';
import 'package:moz_updated_version/screens/playlist_screen/presentation/widgets/custom_tile_with_trailing.dart';
import 'package:moz_updated_version/widgets/song_list_tile.dart';

class OnlineFavoriteSongsScreen extends StatefulWidget {
  const OnlineFavoriteSongsScreen({super.key});

  @override
  State<OnlineFavoriteSongsScreen> createState() =>
      _OnlineFavoriteSongsScreenState();
}

class _OnlineFavoriteSongsScreenState extends State<OnlineFavoriteSongsScreen> {
  bool _loadedOnce = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_loadedOnce) {
      context.read<OnlineFavoritesCubit>().loadFavoriteSongs();
      _loadedOnce = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Favorites")),
      body: BlocBuilder<OnlineFavoritesCubit, OnlineFavoritesState>(
        builder: (context, state) {
          if (state is OnlineFavoritesInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is OnlineFavoritesIdsLoaded) {
            if (state.favoriteIds.isEmpty) {
              return const _EmptyView();
            }

            if (state.isLoadingSongs) {
              return const Center(child: CircularProgressIndicator());
            }

            return const Center(child: CircularProgressIndicator());
          }

          if (state is OnlineFavoritesError) {
            return _ErrorView(
              message: state.message,
              onRetry: () =>
                  context.read<OnlineFavoritesCubit>().loadFavoriteSongs(),
            );
          }

          if (state is OnlineFavoriteSongsLoaded) {
            if (state.songs.isEmpty) {
              return const _EmptyView();
            }

            return _FavoritesList(songs: state.songs);
          }

          return const SizedBox();
        },
      ),
    );
  }
}

class _FavoritesList extends StatelessWidget {
  final List<OnlineSongModel> songs;

  const _FavoritesList({required this.songs});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index].toSongModel();
        return CustomSongTile(song: song);
      },
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.favorite_border, size: 64, color: Colors.grey),
          SizedBox(height: 12),
          Text("No favorite songs yet", style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text("Retry")),
          ],
        ),
      ),
    );
  }
}
