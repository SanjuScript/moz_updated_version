import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audio_service/audio_service.dart';
import 'package:moz_updated_version/data/model/online_models/online_song_model.dart';
import 'package:moz_updated_version/core/utils/saavn_format.dart';
import 'package:moz_updated_version/core/extensions/song_model_ext.dart';
import 'package:moz_updated_version/data/repository/saavn_repository.dart';
import 'package:moz_updated_version/services/audio_handler.dart';
import 'package:moz_updated_version/services/service_locator.dart';
import 'package:moz_updated_version/screens/now_playing/presentation/cubit/nowplaying_cubit.dart';
import 'package:moz_updated_version/widgets/song_list_tile.dart';

class SongRecoScreen extends StatefulWidget {
  final PageController pageController;

  const SongRecoScreen({
    super.key,
    required this.pageController,
  });

  @override
  State<SongRecoScreen> createState() => _SongRecoScreenState();
}

class _SongRecoScreenState extends State<SongRecoScreen> {
  final SaavnRepository _saavnRepo = sl<SaavnRepository>();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;
  List<OnlineSongModel> _recommendedSongs = [];
  String? _error;
  MediaItem? _inspiredBySong;

  double _dragStartY = 0;
  bool _isDraggingParent = false;

  @override
  void initState() {
    super.initState();
    final nowPlayingState = context.read<NowPlayingCubit>().state;
    if (nowPlayingState.currentSong != null) {
      _inspiredBySong = nowPlayingState.currentSong;
      _isLoading = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchRecommendations(nowPlayingState.currentSong!);
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchRecommendations(MediaItem currentSong) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      String? targetId;
      final isOnline = int.tryParse(currentSong.id) == null;

      if (isOnline) {
        targetId = currentSong.id;
      } else {
        final query = "${currentSong.title} ${currentSong.artist ?? ''}";
        final searchResult = await _saavnRepo.searchAll(query);
        final ids = searchResult['ids'] as List?;
        if (ids != null && ids.isNotEmpty) {
          targetId = ids.first.toString();
        }
      }

      if (targetId == null || targetId.isEmpty) {
        throw Exception("Could not find online counterpart for recommendation");
      }

      final rawList = await _saavnRepo.getSongRecommendations(targetId);
      final List<Map<String, dynamic>> safeList = [];
      for (final item in rawList) {
        if (item is Map) {
          safeList.add(Map<String, dynamic>.from(item));
        }
      }

      final formattedSongs = SaavnFormatter.formatSongs(safeList);
      final songs = formattedSongs
          .map((e) => OnlineSongModel.fromJson(e))
          .toList();

      if (mounted) {
        setState(() {
          _recommendedSongs = songs;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      developer.log(
        "Error fetching recommendations",
        error: e,
        stackTrace: stackTrace,
        name: "SongRecoScreen",
      );
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocBuilder<NowPlayingCubit, NowPlayingState>(
        builder: (context, state) {
          final currentSong = state.currentSong;

          if (currentSong == null) {
            return _buildEmptyState(
              icon: Icons.music_note_rounded,
              title: "Discover More Music",
              subtitle: "Start playing a song to get tailored recommendations.",
              theme: theme,
            );
          }

          final inspiredSong = _inspiredBySong ?? currentSong;

          return SafeArea(
            bottom: false,
            left: false,
            right: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(inspiredSong, theme),
                Expanded(
                  child: _buildContent(inspiredSong, theme),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(MediaItem currentSong, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.insights_rounded,
                color: theme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Recommended Tracks',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 28),
                color: isDark ? Colors.white70 : Colors.black54,
                onPressed: () {
                  if (widget.pageController.hasClients) {
                    widget.pageController.animateToPage(
                      0,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOutCubic,
                    );
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Inspired by "${currentSong.title}"',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white60 : Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(MediaItem currentSong, ThemeData theme) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return _buildEmptyState(
        icon: Icons.error_outline_rounded,
        title: "Couldn't load recommendations",
        subtitle: _error!,
        action: ElevatedButton.icon(
          onPressed: () => _fetchRecommendations(currentSong),
          icon: const Icon(Icons.refresh_rounded),
          label: const Text("Retry"),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.primaryColor,
            foregroundColor: Colors.white,
          ),
        ),
        theme: theme,
      );
    }

    if (_recommendedSongs.isEmpty) {
      return _buildEmptyState(
        icon: Icons.search_off_rounded,
        title: "No Recommendations Found",
        subtitle: "We couldn't find matching songs for this track.",
        theme: theme,
      );
    }

    return Listener(
      onPointerDown: (event) {
        _dragStartY = event.position.dy;
        _isDraggingParent = false;
      },
      onPointerMove: (event) {
        final deltaY = event.position.dy - _dragStartY;

        if (widget.pageController.hasClients &&
            _scrollController.hasClients &&
            _scrollController.offset <= 0 &&
            deltaY > 0) {
          _isDraggingParent = true;

          final newOffset = (widget.pageController.offset - event.delta.dy)
              .clamp(0.0, widget.pageController.position.maxScrollExtent);
          widget.pageController.position.jumpTo(newOffset);
        }
      },
      onPointerUp: (event) {
        if (_isDraggingParent && widget.pageController.hasClients) {
          final page = widget.pageController.page ?? 1.0;
          if (page < 0.85) {
            widget.pageController.animateToPage(
              0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
            );
          } else {
            widget.pageController.animateToPage(
              1,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
            );
          }
        }
      },
      child: ListView.builder(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _recommendedSongs.length,
        itemBuilder: (context, index) {
          final onlineSong = _recommendedSongs[index];
          final songModel = onlineSong.toSongModel();

          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 200 + (index * 40)),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 15 * (1 - value)),
                child: Opacity(opacity: value, child: child),
              );
            },
            child: CustomSongTile(
              song: songModel,
              showMoreTrailing: true,
              keepFavbtn: false,
              onTap: () async {
                await sl<MozAudioHandler>().setOnlinePlaylist(_recommendedSongs, index: index);
                await sl<MozAudioHandler>().play();
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? action,
    required ThemeData theme,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: isDark ? Colors.white30 : Colors.black26,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white38 : Colors.black45,
              ),
            ),
            if (action != null) ...[
              const SizedBox(height: 24),
              action,
            ],
          ],
        ),
      ),
    );
  }
}
