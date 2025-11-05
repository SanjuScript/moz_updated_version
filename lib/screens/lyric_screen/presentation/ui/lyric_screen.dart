import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/screens/lyric_screen/presentation/widgets/lyric_line_widget.dart'
    show LyricLine;
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

  // Auto-scroll management
  bool _isAutoScrollEnabled = true;
  Timer? _scrollEndTimer;
  double _lastScrollPosition = 0;
  bool _isProgrammaticScroll = false;

  // Keys for each lyric line to get actual positions
  final Map<int, GlobalKey> _lyricKeys = {};

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _listenToPosition();
    _setupScrollListener();
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

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;

      final currentPosition = _scrollController.position.pixels;
      final delta = (currentPosition - _lastScrollPosition).abs();

      // Ignore tiny moves and programmatic scrolls
      if (!_isProgrammaticScroll && delta > 2) {
        // User-initiated scroll detected
        if (_isAutoScrollEnabled) {
          setState(() {
            _isAutoScrollEnabled = false;
          });
        }

        // Restart timer every time user scrolls
        _scrollEndTimer?.cancel();
        _scrollEndTimer = Timer(const Duration(seconds: 2), () {
          // Re-enable auto-scroll after user stops for 2s (optional)
          // setState(() => _isAutoScrollEnabled = true);
        });
      }

      _lastScrollPosition = currentPosition;
    });
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

        // Only auto-scroll if enabled
        if (_isAutoScrollEnabled) {
          _autoScrollToCenter(newIndex);
        }
      }
    });
  }

  void _animateTransition() {
    _fadeController.forward(from: 0);
    _scaleController.forward(from: 0);
  }

  void _autoScrollToCenter(int index) {
    if (!_scrollController.hasClients || index >= _parsedLyrics.length) return;

    _isProgrammaticScroll = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || !_scrollController.hasClients) return;

      final key = _lyricKeys[index];
      if (key?.currentContext == null) {
        _isProgrammaticScroll = false;
        return;
      }

      final renderBox = key!.currentContext!.findRenderObject() as RenderBox?;

      if (renderBox == null) {
        _isProgrammaticScroll = false;
        return;
      }

      final position = renderBox.localToGlobal(Offset.zero);
      final widgetHeight = renderBox.size.height;
      final screenHeight = MediaQuery.of(context).size.height;

      final currentScrollOffset = _scrollController.offset;
      final widgetTopPosition = position.dy;

      final screenCenter = screenHeight / 2;
      final widgetCenter = widgetHeight / 2;

      final targetScrollOffset =
          (currentScrollOffset +
                  widgetTopPosition -
                  screenCenter +
                  widgetCenter)
              .clamp(0.0, _scrollController.position.maxScrollExtent);

      await _scrollController.animateTo(
        targetScrollOffset,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );

      // Delay slightly to ensure animation finished
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) _isProgrammaticScroll = false;
      });
    });
  }

  void _jumpToCurrentLyric() {
    // Re-enable auto-scroll
    setState(() {
      _isAutoScrollEnabled = true;
    });

    // Jump to current lyric
    _autoScrollToCenter(_currentLineIndex);
  }

  GlobalKey getKeyForIndex(int index) {
    if (!_lyricKeys.containsKey(index)) {
      _lyricKeys[index] = GlobalKey();
    }
    return _lyricKeys[index]!;
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _scrollController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _shimmerController.dispose();
    _scrollEndTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        context.read<LyricsCubit>().getLyrics(
          int.parse(widget.songId),
          widget.title,
        );
        return LyricsScreenContent(
          id: int.parse(widget.songId),
          title: widget.title,
          artist: widget.artist,
          scrollController: _scrollController,
          fadeController: _fadeController,
          scaleController: _scaleController,
          shimmerController: _shimmerController,
          currentLineIndex: _currentLineIndex,
          onParsedLyrics: (lyrics) => _parsedLyrics = lyrics,
          onSeek: (timestamp) =>
              _audioHandler.seek(Duration(milliseconds: timestamp)),
          showJumpButton: !_isAutoScrollEnabled,
          onJumpToCurrentLyric: _jumpToCurrentLyric,
          getKeyForIndex: getKeyForIndex,
        );
      },
    );
  }
}
