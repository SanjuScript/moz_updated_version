import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:moz_updated_version/core/utils/bloc/audio_bloc.dart';
import 'package:moz_updated_version/screens/song_list_screen/presentation/cubit/allsongs_cubit.dart';
import 'package:moz_updated_version/widgets/song_list_tile.dart';
import 'package:on_audio_query/on_audio_query.dart';

class SearchSongsScreen extends StatelessWidget {
  SearchSongsScreen({super.key});

  final ValueNotifier<String> _searchQuery = ValueNotifier("");

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Search Songs",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: false,
      ),
      body: BlocBuilder<AllSongsCubit, AllsongsState>(
        builder: (context, state) {
          if (state is AllSongsLoading) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (state is AllSongsError) {
            return Center(
              child: Text(
                "Error: ${state.message}",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            );
          }

          if (state is AllSongsLoaded) {
            final songs = state.songs;

            return Column(
              children: [
                SizedBox(height: MediaQuery.sizeOf(context).height * .10),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: TextEditingController()
                        ..text = _searchQuery.value,
                      decoration: InputDecoration(
                        hintText: "Search by title, artist, album...",
                        prefixIcon: Icon(
                          Icons.search,
                          color: theme.colorScheme.primary,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 20,
                        ),
                      ),
                      onChanged: (val) =>
                          _searchQuery.value = val.toLowerCase(),
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                ),
                Expanded(
                  child: BlocBuilder<AudioBloc, AudioState>(
                    builder: (context, audioState) {
                      return ValueListenableBuilder<String>(
                        valueListenable: _searchQuery,
                        builder: (context, query, _) {
                          final filteredSongs = query.isEmpty
                              ? songs
                              : songs
                                    .where(
                                      (s) =>
                                          s.title.toLowerCase().contains(
                                            query,
                                          ) ||
                                          (s.artist ?? "")
                                              .toLowerCase()
                                              .contains(query) ||
                                          (s.album ?? "")
                                              .toLowerCase()
                                              .contains(query),
                                    )
                                    .toList();

                          if (filteredSongs.isEmpty) {
                            return Center(
                              child: Text(
                                "No songs found",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 16,
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: filteredSongs.length,
                            itemBuilder: (context, index) {
                              final song = filteredSongs[index];

                              final tile = CustomSongTile(
                                song: song,
                                isTrailingChange: false,
                                onTap: () {
                                  context.read<AudioBloc>().add(
                                    PlaySong(song, filteredSongs),
                                  );
                                },
                              );

                              if (index < 10) {
                                return AnimationConfiguration.staggeredList(
                                  position: index,
                                  duration: const Duration(milliseconds: 400),
                                  child: SlideAnimation(
                                    verticalOffset: 50,
                                    child: FadeInAnimation(child: tile),
                                  ),
                                );
                              }
                              return tile;
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
