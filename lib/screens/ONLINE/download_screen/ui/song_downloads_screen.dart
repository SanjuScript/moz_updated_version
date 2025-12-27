import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/core/extensions/song_model_ext.dart';
import 'package:moz_updated_version/core/utils/bloc/audio_bloc.dart';
import 'package:moz_updated_version/data/db/download_songs/repository/download_repo.dart';
import 'package:moz_updated_version/screens/ONLINE/download_screen/cubit/download_songs_cubit.dart';
import 'package:moz_updated_version/screens/ONLINE/favorite_screen/presentation/widgets/empty_view.dart';
import 'package:moz_updated_version/widgets/song_list_tile.dart';
import 'package:on_audio_query/on_audio_query.dart';

import 'package:moz_updated_version/data/model/download_song/download_song_model.dart';

class DownloadedSongsScreen extends StatefulWidget {
  const DownloadedSongsScreen({super.key});

  @override
  State<DownloadedSongsScreen> createState() => _DownloadedSongsScreenState();
}

class _DownloadedSongsScreenState extends State<DownloadedSongsScreen> {
  final _audioQuery = OnAudioQuery();
  final _musicPath = '/storage/emulated/0/Music/MozMusic';

  /// MediaStore index: path → SongModel
  Map<String, SongModel> _mediaIndex = {};
  late Map<int, DownloadedSongModel> _hiveById;

  @override
  void initState() {
    super.initState();
    final hiveSongs = DownloadSongRepository.getAllSongs();
    _hiveById = {for (final s in hiveSongs) s.id: s};

    _indexMediaStore();
    context.read<DownloadSongsCubit>().loadDownloadedSongs();
  }

  Future<void> _indexMediaStore() async {
    final songs = await _audioQuery.querySongs(path: _musicPath);
    log(songs.map((e) => e.toString()).toString());
    _mediaIndex = {for (final s in songs) s.data: s};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Downloaded Songs'), centerTitle: false),
      body: BlocBuilder<DownloadSongsCubit, DownloadSongsState>(
        builder: (context, state) {
          if (state is DownloadSongsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DownloadSongsEmpty) {
            return EmptyView(
              title: "No downloads found",
              desc: "Download songs to see them here",
              icon: Icons.download_done,
              showButton: false,
            );
          }

          if (state is DownloadSongsLoaded) {
            return ListView.builder(
              itemCount: state.songs.length,
              itemBuilder: (_, index) {
                final DownloadedSongModel downloaded = state.songs[index];
                final file = File(downloaded.filePath);
                if (!file.existsSync()) {
                  return const SizedBox();
                }

                SongModel song;

                final mediaSong = _mediaIndex[downloaded.filePath];

                if (mediaSong != null && _hiveById.containsKey(mediaSong.id)) {
                  song = mediaSong.withHiveData(_hiveById[mediaSong.id]!);
                } else {
                  song = downloaded.toSongModel();
                }

                return CustomSongTile(
                  song: song,
                  keepFavbtn: false,
                  isTrailingChange: true,

                  trailing: IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.more_vert),
                  ),
                  onTap: () {
                    final playlist = <SongModel>[];

                    for (final e in state.songs) {
                      final media = _mediaIndex[e.filePath];
                      if (media != null && _hiveById.containsKey(media.id)) {
                        playlist.add(media.withHiveData(_hiveById[media.id]!));
                      } else {
                        playlist.add(e.toSongModel());
                      }
                    }

                    if (playlist.isEmpty) return;

                    final current = playlist.firstWhere(
                      (s) => s.getMap['_data'] == downloaded.filePath,
                      orElse: () => playlist.first,
                    );

                    context.read<AudioBloc>().add(PlaySong(current, playlist));
                  },
                );
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
