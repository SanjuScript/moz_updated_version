import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/screens/lyric_screen/presentation/widgets/lyric_line_widget.dart';
import 'package:moz_updated_version/screens/lyric_screen/presentation/widgets/lyrics_screen_content.dart';
import 'package:moz_updated_version/services/service_locator.dart';
import 'package:moz_updated_version/services/audio_handler.dart';
import '../cubit/lyrics_cubit.dart';
import 'dart:async';

class LyricsScreen extends StatefulWidget {
  final String artist;
  final String title;
  final String songId;

  const LyricsScreen({
    super.key,
    required this.artist,
    required this.title,
    required this.songId,
  });

  @override
  State<LyricsScreen> createState() => _LyricsScreenState();
}

class _LyricsScreenState extends State<LyricsScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final MozAudioHandler _audioHandler = sl<MozAudioHandler>();
  StreamSubscription? _positionSubscription;
  int _currentLineIndex = 0;
  List<LyricLine> _parsedLyrics = [];
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _listenToPosition();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  void _listenToPosition() {
    _positionSubscription = _audioHandler.positionStream.listen((position) {
      if (_parsedLyrics.isEmpty) return;

      final currentMs = position.inMilliseconds;
      int newIndex = _currentLineIndex;

      for (int i = 0; i < _parsedLyrics.length; i++) {
        if (_parsedLyrics[i].timestamp != null) {
          if (currentMs >= _parsedLyrics[i].timestamp! &&
              (i == _parsedLyrics.length - 1 ||
                  currentMs <
                      (_parsedLyrics[i + 1].timestamp ?? double.infinity))) {
            newIndex = i;
            break;
          }
        }
      }

      if (newIndex != _currentLineIndex) {
        setState(() => _currentLineIndex = newIndex);
        _animateTransition();
        _autoScroll(newIndex);
      }
    });
  }

  void _animateTransition() {
    _fadeController.forward(from: 0);
    _scaleController.forward(from: 0);
  }

  void _autoScroll(int index) {
    if (_scrollController.hasClients && index < _parsedLyrics.length) {
      final itemHeight = 100.0;
      final screenHeight = MediaQuery.of(context).size.height;
      final position =
          (index * itemHeight) - (screenHeight / 2) + (itemHeight / 2);

      _scrollController.animateTo(
        position.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _scrollController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        context.read<LyricsCubit>().getLyrics(widget.artist, widget.title);
        return LyricsScreenContent(
          artist: widget.artist,
          title: widget.title,
          scrollController: _scrollController,
          fadeController: _fadeController,
          scaleController: _scaleController,
          shimmerController: _shimmerController,
          currentLineIndex: _currentLineIndex,
          onParsedLyrics: (lyrics) => _parsedLyrics = lyrics,
          onSeek: (timestamp) =>
              _audioHandler.seek(Duration(milliseconds: timestamp)),
        );
      },
    );
  }
}
