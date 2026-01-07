// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:moz_updated_version/screens/lyric_screen/presentation/cubit/lyrics_cubit.dart';
// import 'package:moz_updated_version/screens/lyric_screen/presentation/widgets/lyric_line_widget.dart';
// import 'package:moz_updated_version/screens/lyric_screen/presentation/widgets/lyrics_screen_content.dart';
// import 'package:moz_updated_version/services/audio_handler.dart';
// import 'package:moz_updated_version/services/service_locator.dart';
// import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

// class LyricsScreen extends StatefulWidget {
//   final String artist;
//   final String title;
//   final String songId;

//   const LyricsScreen({
//     super.key,
//     required this.artist,
//     required this.title,
//     required this.songId,
//   });

//   @override
//   State<LyricsScreen> createState() => _LyricsScreenState();
// }

// class _LyricsScreenState extends State<LyricsScreen>
//     with TickerProviderStateMixin {
//   final ItemScrollController _itemScrollController = ItemScrollController();
//   final ItemPositionsListener _itemPositionsListener =
//       ItemPositionsListener.create();
//   final MozAudioHandler _audioHandler = sl<MozAudioHandler>();

//   StreamSubscription? _positionSubscription;
//   int _currentLineIndex = 0;
//   List<LyricLine> _parsedLyrics = [];
//   bool _isUserScrolling = false;
//   Timer? _reEnableAutoScrollTimer;

//   // NEW: Track scrolling state
//   bool _isAutoScrolling = false;
//   int _lastAutoScrolledIndex = -1;
//   Timer? _scrollDebounceTimer;

//   late AnimationController _fadeController;
//   late AnimationController _scaleController;
//   late AnimationController _shimmerController;

//   @override
//   void initState() {
//     super.initState();
//     _initAnimations();
//     _fetchLyrics();
//     _listenToPosition();
//     _setupScrollListener();
//   }

//   @override
//   void didUpdateWidget(LyricsScreen oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.songId != widget.songId) {
//       setState(() {
//         _currentLineIndex = 0;
//         _parsedLyrics = [];
//         _isUserScrolling = false;
//         _lastAutoScrolledIndex = -1;
//       });
//       _fetchLyrics();
//     }
//   }

//   void _fetchLyrics() {
//     context.read<LyricsCubit>().getLyrics(widget.songId);
//   }

//   void _initAnimations() {
//     _fadeController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 400),
//     );
//     _scaleController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 400),
//     );
//     _shimmerController = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 2),
//     )..repeat();
//   }

//   void _setupScrollListener() {
//     _itemPositionsListener.itemPositions.addListener(() {});
//   }

//   void _listenToPosition() {
//     _positionSubscription = _audioHandler.positionStream.listen((position) {
//       if (_parsedLyrics.isEmpty) return;

//       final currentMs = position.inMilliseconds;
//       int newIndex = 0;

//       for (int i = 0; i < _parsedLyrics.length; i++) {
//         if (_parsedLyrics[i].timestamp != null) {
//           final currentTimestamp = _parsedLyrics[i].timestamp!;

//           final nextTimestamp = (i < _parsedLyrics.length - 1)
//               ? (_parsedLyrics[i + 1].timestamp ?? 999999999)
//               : 999999999;

//           if (currentMs >= currentTimestamp && currentMs < nextTimestamp) {
//             newIndex = i;
//             break;
//           }
//         }
//       }

//       if (newIndex != _currentLineIndex) {
//         setState(() {
//           _currentLineIndex = newIndex;
//         });

//         _animateTransition();

//         // Only scroll if not user scrolling AND not already scrolling
//         if (!_isUserScrolling && !_isAutoScrolling) {
//           _debouncedScrollToCenter(newIndex);
//         }
//       }
//     });
//   }

//   // NEW: Debounced scroll to prevent rapid successive scrolls
//   void _debouncedScrollToCenter(int index) {
//     // Cancel any pending scroll
//     _scrollDebounceTimer?.cancel();

//     // Only scroll if we haven't already scrolled to this index
//     if (_lastAutoScrolledIndex == index) {
//       return;
//     }

//     // Small delay to allow rapid line changes to settle
//     _scrollDebounceTimer = Timer(const Duration(milliseconds: 50), () {
//       if (mounted && !_isUserScrolling && !_isAutoScrolling) {
//         _scrollToCenter(index);
//       }
//     });
//   }

//   void _scrollToCenter(int index) {
//     if (!mounted) return;
//     if (_parsedLyrics.isEmpty) return;
//     if (index < 0 || index >= _parsedLyrics.length) return;

//     // Prevent overlapping scrolls
//     if (_isAutoScrolling) return;

//     if (!_itemScrollController.isAttached) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (mounted && _itemScrollController.isAttached) {
//           _performScroll(index);
//         }
//       });
//       return;
//     }

//     _performScroll(index);
//   }

//   // NEW: Separate method to perform actual scroll with state tracking
//   void _performScroll(int index) {
//     _isAutoScrolling = true;
//     _lastAutoScrolledIndex = index;

//     _itemScrollController.scrollTo(
//       index: index,
//       duration: const Duration(milliseconds: 600),
//       curve: Curves.easeInOutCubic,
//       alignment: 0.5,
//     );

//     // Reset scrolling flag after animation completes
//     Future.delayed(const Duration(milliseconds: 650), () {
//       if (mounted) {
//         _isAutoScrolling = false;
//       }
//     });
//   }

//   void _animateTransition() {
//     _fadeController.forward(from: 0.0);
//     _scaleController.forward(from: 0.0);
//   }

//   void _onUserScrollStart() {
//     setState(() => _isUserScrolling = true);
//     _reEnableAutoScrollTimer?.cancel();
//     _scrollDebounceTimer?.cancel();
//   }

//   void _onUserScrollEnd() {
//     _reEnableAutoScrollTimer?.cancel();
//     _reEnableAutoScrollTimer = Timer(const Duration(seconds: 2), () {
//       if (mounted) {
//         setState(() {
//           _isUserScrolling = false;
//           _lastAutoScrolledIndex = -1; // Reset so it can scroll again
//         });
//         _scrollToCenter(_currentLineIndex);
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _positionSubscription?.cancel();
//     _fadeController.dispose();
//     _scaleController.dispose();
//     _shimmerController.dispose();
//     _reEnableAutoScrollTimer?.cancel();
//     _scrollDebounceTimer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return LyricsScreenContent(
//       id: widget.songId,
//       title: widget.title,
//       artist: widget.artist,
//       itemScrollController: _itemScrollController,
//       itemPositionsListener: _itemPositionsListener,
//       fadeController: _fadeController,
//       scaleController: _scaleController,
//       shimmerController: _shimmerController,
//       currentLineIndex: _currentLineIndex,
//       onParsedLyrics: (lyrics) {
//         if (_parsedLyrics.length != lyrics.length ||
//             (_parsedLyrics.isNotEmpty &&
//                 lyrics.isNotEmpty &&
//                 _parsedLyrics[0].text != lyrics[0].text)) {
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             if (mounted) {
//               setState(() {
//                 _parsedLyrics = lyrics;
//                 _lastAutoScrolledIndex = -1; // Reset on new lyrics
//               });
//             }
//           });
//         }
//       },
//       onSeek: (timestamp) {
//         _audioHandler.seek(Duration(milliseconds: timestamp));
//         setState(() {
//           _isUserScrolling = false;
//           _lastAutoScrolledIndex = -1;
//         });
//         _scrollToCenter(_currentLineIndex);
//       },
//       onUserScrollStart: _onUserScrollStart,
//       onUserScrollEnd: _onUserScrollEnd,
//     );
//   }
// }

//EASY

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/screens/lyric_screen/presentation/cubit/lyrics_cubit.dart';
import 'package:moz_updated_version/screens/lyric_screen/presentation/widgets/lyric_line_widget.dart';
import 'package:moz_updated_version/screens/lyric_screen/presentation/widgets/lyrics_screen_content.dart';
import 'package:moz_updated_version/services/audio_handler.dart';
import 'package:moz_updated_version/services/service_locator.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

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
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();
  final MozAudioHandler _audioHandler = sl<MozAudioHandler>();

  StreamSubscription? _positionSubscription;
  int _currentLineIndex = 0;
  List<LyricLine> _parsedLyrics = [];
  bool _isUserScrolling = false;
  Timer? _reEnableAutoScrollTimer;

  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _shimmerController;
  bool _autoScrollInProgress = false;
  int _lastScrolledIndex = -1;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _fetchLyrics();
    _listenToPosition();
    _setupScrollListener();
  }

  @override
  void didUpdateWidget(LyricsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.songId != widget.songId) {
      setState(() {
        _currentLineIndex = 0;
        _parsedLyrics = [];
        _isUserScrolling = false;
      });
      _fetchLyrics();
    }
  }

  void _fetchLyrics() {
    context.read<LyricsCubit>().getLyrics(widget.songId);
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
    _itemPositionsListener.itemPositions.addListener(() {});
  }

  void _listenToPosition() {
    _positionSubscription = _audioHandler.positionStream.listen((position) {
      if (_parsedLyrics.isEmpty) return;

      final currentMs = position.inMilliseconds;
      int newIndex = 0;

      for (int i = 0; i < _parsedLyrics.length; i++) {
        if (_parsedLyrics[i].timestamp != null) {
          final currentTimestamp = _parsedLyrics[i].timestamp!;

          final nextTimestamp = (i < _parsedLyrics.length - 1)
              ? (_parsedLyrics[i + 1].timestamp ?? 999999999)
              : 999999999;

          if (currentMs >= currentTimestamp && currentMs < nextTimestamp) {
            newIndex = i;
            break;
          }
        }
      }

      if (newIndex != _currentLineIndex) {
        setState(() {
          _currentLineIndex = newIndex;
        });

        _animateTransition();

        if (!_isUserScrolling) {
          _scrollToCenter(newIndex);
        }
      }
    });
  }

  void _scrollToCenter(int index) {
    if (!mounted) return;
    if (_parsedLyrics.isEmpty) return;
    if (index < 0 || index >= _parsedLyrics.length) return;

    if (!_itemScrollController.isAttached) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _itemScrollController.isAttached) {
          _itemScrollController.scrollTo(
            index: index,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutCubic,
            alignment: 0.5,
          );
        }
      });
      return;
    }

    _itemScrollController.scrollTo(
      index: index,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
      alignment: 0.5,
    );
  }

  void _animateTransition() {
    _fadeController.forward(from: 0.0);
    _scaleController.forward(from: 0.0);
  }

  void _onUserScrollStart() {
    setState(() => _isUserScrolling = true);
    _reEnableAutoScrollTimer?.cancel();
  }

  void _onUserScrollEnd() {
    _reEnableAutoScrollTimer?.cancel();
    _reEnableAutoScrollTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isUserScrolling = false);
        _scrollToCenter(_currentLineIndex);
      }
    });
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _fadeController.dispose();
    _scaleController.dispose();
    _shimmerController.dispose();
    _reEnableAutoScrollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LyricsScreenContent(
      id: widget.songId,
      title: widget.title,
      artist: widget.artist,
      itemScrollController: _itemScrollController,
      itemPositionsListener: _itemPositionsListener,
      fadeController: _fadeController,
      scaleController: _scaleController,
      shimmerController: _shimmerController,
      currentLineIndex: _currentLineIndex,
      onParsedLyrics: (lyrics) {
        if (_parsedLyrics.length != lyrics.length ||
            (_parsedLyrics.isNotEmpty &&
                lyrics.isNotEmpty &&
                _parsedLyrics[0].text != lyrics[0].text)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _parsedLyrics = lyrics);
          });
        }
      },
      onSeek: (timestamp) {
        _audioHandler.seek(Duration(milliseconds: timestamp));
        setState(() => _isUserScrolling = false);
        _scrollToCenter(_currentLineIndex);
      },
      onUserScrollStart: _onUserScrollStart,
      onUserScrollEnd: _onUserScrollEnd,
    );
  }
}
