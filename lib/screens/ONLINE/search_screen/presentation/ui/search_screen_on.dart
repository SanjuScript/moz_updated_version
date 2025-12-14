import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/core/extensions/song_model_ext.dart';
import 'package:moz_updated_version/data/model/online_models/online_song_model.dart';
import 'package:moz_updated_version/main.dart';
import 'package:moz_updated_version/screens/ONLINE/search_screen/presentation/cubit/jio_saavn_cubit.dart';
import 'package:moz_updated_version/screens/mini_player/presentation/ui/mini_player.dart';
import 'package:moz_updated_version/screens/now_playing/presentation/ui/page_view.dart';
import 'package:moz_updated_version/services/audio_handler.dart';
import 'package:moz_updated_version/services/core/app_services.dart';
import 'package:moz_updated_version/widgets/song_list_tile.dart';

class OnlineSearchScreen extends StatefulWidget {
  const OnlineSearchScreen({Key? key}) : super(key: key);

  @override
  State<OnlineSearchScreen> createState() => _OnlineSearchScreenState();
}

class _OnlineSearchScreenState extends State<OnlineSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  void _search() {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    context.read<JioSaavnCubit>().searchSongs(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Online Songs'), elevation: 0),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: BlocBuilder<JioSaavnCubit, JioSaavnState>(
              builder: (context, state) {
                if (state is JioSaavnSearchLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is JioSaavnSearchError) {
                  return _buildError(state.message);
                }

                if (state is JioSaavnSearchSuccess) {
                  final results = state.songs;
                  if (results.isEmpty) {
                    return _buildEmpty();
                  }
                  return _buildResults(results);
                }

                return _buildEmpty();
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: MiniPlayer(),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Search for songs...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        context.read<JioSaavnCubit>().reset();
                        setState(() {});
                      },
                    )
                  : null,
              filled: true,

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (_) => _search(),
            onChanged: (_) => setState(() {}),
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: _search,
          child: Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[800],
            ),
            child: const Icon(Icons.search),
          ),
        ),
      ],
    );
  }

  Widget _buildResults(List<OnlineSongModel> results) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final song = results[index];
              final songModel = song.toSongModel();

              return CustomSongTile(
                song: songModel,
                isTrailingChange: true,
                trailing: IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.more_vert_rounded),
                ),
                onTap: () async {
                  // log(
                  //   results[index].artists!.map((e) => e.id).toString(),
                  //   name: "ARTISTSSSS",
                  // );
                  _playFromIndex(results, index);

                  // if (audioHandler.isPlaying.isBroadcast) {
                  //   Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => NowplayingPageView(),
                  //     ),
                  //   );
                  // }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.cloud_queue, size: 80, color: Colors.grey[400]),
        const SizedBox(height: 16),
        Text(
          'Search for online songs',
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    ),
  );

  Widget _buildError(String msg) => Center(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Text(msg, style: const TextStyle(color: Colors.red)),
    ),
  );

  void _playFromIndex(List<OnlineSongModel> songs, int index) async {
    try {
      await sl<MozAudioHandler>().setOnlinePlaylist(songs, index: index);
      await sl<MozAudioHandler>().play();
    } catch (e) {
      _error("Error playing: $e");
    }
  }

  void _error(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text(msg)));
  }
}
