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
  Timer? _reEnableAutoScrollTimer;
  bool _isUserScrolling = false;
  double _lastScrollOffset = 0;
  int _scrollIdleFrames = 0;
  static const int _idleFramesThreshold = 15; // ~250ms at 60fps

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

      final currentOffset = _scrollController.offset;
      final delta = (currentOffset - _lastScrollOffset).abs();

      // Detect if user is manually scrolling (delta > small threshold)
      if (delta > 1.0) {
        // User is actively scrolling
        if (!_isUserScrolling) {
          setState(() {
            _isUserScrolling = true;
            _isAutoScrollEnabled = false;
          });
        }

        // Reset idle counter
        _scrollIdleFrames = 0;

        // Cancel any pending re-enable timer
        _reEnableAutoScrollTimer?.cancel();

        // Start a new timer to re-enable auto-scroll after user stops
        _reEnableAutoScrollTimer = Timer(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _isAutoScrollEnabled = true;
              _isUserScrolling = false;
            });
            // Immediately scroll to current line when re-enabling
            _autoScrollToCenter(_currentLineIndex);
          }
        });
      } else {
        // Scroll has stopped or minimal movement
        _scrollIdleFrames++;
      }

      _lastScrollOffset = currentOffset;
    });
  }

  void _listenToPosition() {
    _positionSubscription = _audioHandler.positionStream.listen((position) {
      if (_parsedLyrics.isEmpty) return;

      final currentMs = position.inMilliseconds;
      int newIndex = _currentLineIndex;

      // Find the current lyric line based on timestamp
      for (int i = 0; i < _parsedLyrics.length; i++) {
        if (_parsedLyrics[i].timestamp != null) {
          final currentTimestamp = _parsedLyrics[i].timestamp!;
          final nextTimestamp = (i < _parsedLyrics.length - 1)
              ? (_parsedLyrics[i + 1].timestamp ?? double.infinity)
              : double.infinity;

          if (currentMs >= currentTimestamp && currentMs < nextTimestamp) {
            newIndex = i;
            break;
          }
        }
      }

      // Update current line and trigger animations
      if (newIndex != _currentLineIndex) {
        setState(() => _currentLineIndex = newIndex);
        _animateTransition();

        // Auto-scroll only if enabled and user is not scrolling
        if (_isAutoScrollEnabled && !_isUserScrolling) {
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
    if (!_scrollController.hasClients ||
        index >= _parsedLyrics.length ||
        _isUserScrolling) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || !_scrollController.hasClients || _isUserScrolling) {
        return;
      }

      final key = _lyricKeys[index];
      if (key?.currentContext == null) return;

      final renderBox = key!.currentContext!.findRenderObject() as RenderBox?;
      if (renderBox == null) return;

      try {
        final position = renderBox.localToGlobal(Offset.zero);
        final widgetHeight = renderBox.size.height;
        final screenHeight = MediaQuery.of(context).size.height;

        final currentScrollOffset = _scrollController.offset;
        final widgetTopPosition = position.dy;

        // Calculate target scroll position to center the current line
        final screenCenter = screenHeight / 2;
        final widgetCenter = widgetHeight / 2;

        final targetScrollOffset =
            (currentScrollOffset +
                    widgetTopPosition -
                    screenCenter +
                    widgetCenter)
                .clamp(
                  _scrollController.position.minScrollExtent,
                  _scrollController.position.maxScrollExtent,
                );

        // Check if we actually need to scroll
        final scrollDelta = (targetScrollOffset - currentScrollOffset).abs();
        if (scrollDelta < 5) return; // Already close enough

        // Temporarily mark as programmatic scroll
        final wasUserScrolling = _isUserScrolling;
        _isUserScrolling = false;

        await _scrollController.animateTo(
          targetScrollOffset,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
        );

        // Restore user scrolling state
        if (mounted) {
          _isUserScrolling = wasUserScrolling;
        }
      } catch (e) {
        // Handle any errors during scroll
        if (mounted) {
          _isUserScrolling = false;
        }
      }
    });
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
    _reEnableAutoScrollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        String? artistInfo;
        try {
          artistInfo = widget.artist.isNotEmpty ? widget.artist : null;
        } catch (e) {
          artistInfo = null;
        }
        context.read<LyricsCubit>().getLyrics(
          widget.songId, // Pass as string
          widget.title,
          artist: artistInfo,
        );

        return LyricsScreenContent(
          id: widget.songId,
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
          getKeyForIndex: getKeyForIndex,
        );
      },
    );
  }
}
