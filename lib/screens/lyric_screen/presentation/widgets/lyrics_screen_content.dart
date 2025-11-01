import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/screens/lyric_screen/presentation/cubit/lyrics_cubit.dart';
import 'package:moz_updated_version/screens/lyric_screen/presentation/widgets/lyric_line_widget.dart';

class LyricsScreenContent extends StatelessWidget {
  final String artist;
  final String title;
  final ScrollController scrollController;
  final AnimationController fadeController;
  final AnimationController scaleController;
  final AnimationController shimmerController;
  final int currentLineIndex;
  final Function(List<LyricLine>) onParsedLyrics;
  final Function(int) onSeek;

  const LyricsScreenContent({
    super.key,
    required this.artist,
    required this.title,
    required this.scrollController,
    required this.fadeController,
    required this.scaleController,
    required this.shimmerController,
    required this.currentLineIndex,
    required this.onParsedLyrics,
    required this.onSeek,
  });

  List<LyricLine> _parseLyrics(String lyrics) {
    final lines = lyrics.split("\n");
    final List<LyricLine> parsed = [];
    final regex = RegExp(r'\[(\d{2}):(\d{2})\.(\d{2})\](.*)');

    for (var line in lines) {
      final match = regex.firstMatch(line.trim());
      if (match != null) {
        final minutes = int.parse(match.group(1)!);
        final seconds = int.parse(match.group(2)!);
        final centiseconds = int.parse(match.group(3)!);
        final text = match.group(4)?.trim() ?? "";

        final timestamp =
            (minutes * 60 * 1000) + (seconds * 1000) + (centiseconds * 10);

        if (text.isNotEmpty) {
          parsed.add(LyricLine(text: text, timestamp: timestamp));
        }
      } else if (line.trim().isNotEmpty) {
        parsed.add(LyricLine(text: line.trim(), timestamp: null));
      }
    }

    return parsed;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,

      body: _buildBody(context, theme, isDark),
    );
  }

  Widget _buildBody(BuildContext context, ThemeData theme, bool isDark) {
    final primary = Theme.of(context).scaffoldBackgroundColor;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  primary.withValues(alpha: 0.9),
                  primary.withValues(alpha: 0.7),
                  primary.withValues(alpha: 0.5),
                  primary.withValues(alpha: 0.3),
                ]
              : [
                  const Color(0xFFfafafa),
                  const Color(0xFFf0f0f5),
                  const Color(0xFFe8e8f0),
                  const Color(0xFFdcdce8),
                ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(theme, isDark),
            Expanded(
              child: BlocBuilder<LyricsCubit, LyricsState>(
                builder: (context, state) {
                  if (state is LyricsLoading) {
                    return _buildLoadingState(theme, isDark, context);
                  } else if (state is LyricsLoaded) {
                    final parsedLyrics = _parseLyrics(state.lyrics);
                    onParsedLyrics(parsedLyrics);

                    if (parsedLyrics.isEmpty) {
                      return _buildEmptyState(theme, isDark);
                    }

                    return _buildLyricsList(
                      context,
                      parsedLyrics,
                      theme,
                      isDark,
                    );
                  } else if (state is LyricsError) {
                    return _buildErrorState(state, theme, isDark);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: shimmerController,
            builder: (context, child) {
              return ShaderMask(
                shaderCallback: (bounds) {
                  return LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [Colors.white, Colors.white70, Colors.white]
                        : [Colors.black87, Colors.black54, Colors.black87],
                    stops: [
                      shimmerController.value - 0.3,
                      shimmerController.value,
                      shimmerController.value + 0.3,
                    ],
                  ).createShader(bounds);
                },
                child: Text(
                  title,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.1),
              ),
            ),
            child: Text(
              artist,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isDark ? Colors.white70 : Colors.black54,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(
    ThemeData theme,
    bool isDark,
    BuildContext context,
  ) {
    final primary = Theme.of(context).primaryColor;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation(
                    isDark ? primary : Colors.blue,
                  ),
                ),
              ),
              Icon(
                Icons.music_note_rounded,
                size: 32,
                color: isDark ? primary : Colors.blue,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            "Loading lyrics...",
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDark ? Colors.white70 : Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lyrics_outlined,
            size: 80,
            color: isDark ? Colors.white24 : Colors.black26,
          ),
          const SizedBox(height: 16),
          Text(
            "No lyrics available",
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDark ? Colors.white54 : Colors.black45,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(LyricsError state, ThemeData theme, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.red.withValues(alpha: 0.1)
                  : Colors.red.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.music_off_rounded,
              size: 64,
              color: Colors.red.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              state.message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isDark ? Colors.white54 : Colors.black45,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLyricsList(
    BuildContext context,
    List<LyricLine> lyrics,
    ThemeData theme,
    bool isDark,
  ) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.white,
            Colors.white,
            Colors.transparent,
          ],
          stops: const [0.0, 0.1, 0.9, 1.0],
        ).createShader(bounds);
      },
      blendMode: BlendMode.dstIn,
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 100),
        physics: const BouncingScrollPhysics(),
        itemCount: lyrics.length,
        itemBuilder: (context, index) {
          return LyricLineWidget(
            line: lyrics[index],
            index: index,
            currentIndex: currentLineIndex,
            fadeController: fadeController,
            scaleController: scaleController,
            onTap: onSeek,
            isDark: isDark,
            theme: theme,
          );
        },
      ),
    );
  }
}
