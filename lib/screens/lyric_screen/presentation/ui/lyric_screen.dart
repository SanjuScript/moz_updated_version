import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/lyrics_cubit.dart';

class LyricsScreen extends StatelessWidget {
  final String artist;
  final String title;

  const LyricsScreen({super.key, required this.artist, required this.title});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LyricsCubit()..getLyrics(artist, title),
      child: Scaffold(
        appBar: AppBar(title: Text("$title - $artist")),
        body: BlocBuilder<LyricsCubit, LyricsState>(
          builder: (context, state) {
            if (state is LyricsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is LyricsLoaded) {
              final lines = state.lyrics.split("\n");
              return ListView.builder(
                itemCount: lines.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4.0,
                      horizontal: 12.0,
                    ),
                    child: Text(
                      lines[index],
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  );
                },
              );
            } else if (state is LyricsError) {
              return Center(child: Text(state.message));
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }
}
