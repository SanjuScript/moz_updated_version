import 'dart:async';

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:moz_updated_version/main.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:moz_updated_version/services/helpers/get_media_state.dart';

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> {
  final CarouselSliderController _carouselController =
      CarouselSliderController();
  int _currentIndex = 0;

  late final StreamSubscription<MediaState> _mediaSub;

  @override
  void initState() {
    super.initState();

    _mediaSub = audioHandler.mediaState$.listen((state) {
      final currentSong = state.mediaItem;
      final queue = state.queue;

      if (currentSong != null && queue.isNotEmpty) {
        final newIndex = queue.indexWhere((s) => s.id == currentSong.id);
        if (newIndex != -1 && newIndex != _currentIndex) {
          if (!mounted) return; // extra safety
          setState(() {
            _currentIndex = newIndex;
          });

          _carouselController.animateToPage(_currentIndex);
        }
      }
    });
  }

  @override
  void dispose() {
    _mediaSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<MediaState>(
        stream: audioHandler.mediaState$,
        builder: (context, snapshot) {
          final state = snapshot.data;

          if (state == null || state.queue.isEmpty) {
            return const Center(child: Text("No songs playing"));
          }

          final songs = state.queue;
          final currentSong = state.mediaItem;

          // Update current index
          if (currentSong != null) {
            _currentIndex = songs.indexWhere((s) => s.id == currentSong.id);
          }

          return SafeArea(
            child: Column(
              children: [
                // App bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        "Now Playing",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                // Carousel slider for album art
                Expanded(
                  child: CarouselSlider.builder(
                    carouselController: _carouselController,
                    itemCount: songs.length,
                    itemBuilder: (context, index, realIndex) {
                      final song = songs[index];
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(
                          height: 300,
                          width: 500,
                          child: QueryArtworkWidget(
                            id: int.parse(song.id),
                            type: ArtworkType.AUDIO,
                            keepOldArtwork: true,
                            artworkBorder: BorderRadius.circular(16),
                            nullArtworkWidget: Container(
                              color: Colors.grey.shade300,
                              child: const Icon(
                                Icons.music_note,
                                size: 80,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    options: CarouselOptions(
                      height: MediaQuery.of(context).size.height * 0.5,
                      enlargeCenterPage: true,
                      enableInfiniteScroll: false,
                      onScrolled: (value) {
                       if (!mounted) return;

                        setState(() {
                          _currentIndex = value!.toInt();
                        });

                        // Use index directly instead of parsing id
                        audioHandler.skipToQueueItem(value!.toInt());
                      },
                      onPageChanged: (index, reason) {
                        if (!mounted) return;

                        setState(() {
                          _currentIndex = index;
                        });

                        // Use index directly instead of parsing id
                        audioHandler.skipToQueueItem(index);
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Song title & artist
                Text(
                  songs[_currentIndex].title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  songs[_currentIndex].artist ?? "Unknown Artist",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),

                const SizedBox(height: 32),

                // Playback controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      iconSize: 40,
                      icon: const Icon(Icons.skip_previous),
                      onPressed: () => audioHandler.skipToPrevious(),
                    ),
                    const SizedBox(width: 32),
                    StreamBuilder<MediaState>(
                      stream: audioHandler.mediaState$,
                      builder: (context, snapshot) {
                        final state = snapshot.data;
                        final isPlaying = state?.isPlaying ?? false;

                        return IconButton(
                          iconSize: 60,
                          icon: Icon(
                            isPlaying ? Icons.pause_circle : Icons.play_circle,
                          ),
                          onPressed: () => isPlaying
                              ? audioHandler.pause()
                              : audioHandler.play(),
                        );
                      },
                    ),
                    const SizedBox(width: 32),
                    IconButton(
                      iconSize: 40,
                      icon: const Icon(Icons.skip_next),
                      onPressed: () => audioHandler.skipToNext(),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}
