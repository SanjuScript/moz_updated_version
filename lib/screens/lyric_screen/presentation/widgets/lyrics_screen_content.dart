import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/core/helper/color_extractor.dart/cubit/artworkcolorextractor_cubit.dart';
import 'package:moz_updated_version/data/db/lyrics_db/lyrics_db_ab.dart';
import 'package:moz_updated_version/screens/lyric_screen/presentation/cubit/lyrics_cubit.dart';
import 'package:moz_updated_version/screens/lyric_screen/presentation/ui/saved_lyrics_screen.dart';
import 'package:moz_updated_version/screens/lyric_screen/presentation/widgets/action_buttons.dart';
import 'package:moz_updated_version/screens/lyric_screen/presentation/widgets/lyric_line_widget.dart';
import 'package:moz_updated_version/services/service_locator.dart';

class LyricsScreenContent extends StatelessWidget {
  final int id;
  final String title;
  final String artist;
  final ScrollController scrollController;
  final AnimationController fadeController;
  final AnimationController scaleController;
  final AnimationController shimmerController;
  final int currentLineIndex;
  final Function(List<LyricLine>) onParsedLyrics;
  final Function(int) onSeek;
  final GlobalKey Function(int) getKeyForIndex;

  const LyricsScreenContent({
    super.key,
    required this.id,
    required this.title,
    required this.artist,
    required this.scrollController,
    required this.fadeController,
    required this.scaleController,
    required this.shimmerController,
    required this.currentLineIndex,
    required this.onParsedLyrics,
    required this.onSeek,
    required this.getKeyForIndex,
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
    final artWorkColor = context.read<ArtworkColorCubit>();
    final primary = isDark
        ? artWorkColor.dominantColor.withValues(alpha: .70)
        : Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.35);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,

          colors: isDark
              ? [primary, Colors.black.withValues(alpha: 0.95)]
              : [primary.withValues(alpha: 0.20), Colors.white],
          stops: const [.1, .75],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(theme, isDark, context),
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

  Widget _buildHeader(ThemeData theme, bool isDark, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.labelMedium?.copyWith(
                    letterSpacing: -0.5,
                    fontSize: 20,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  artist,
                  style: theme.textTheme.titleMedium?.copyWith(
                    letterSpacing: -0.5,
                    fontSize: 12,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Row(
            children: [
              Hero(
                tag: "saved_lyrics_button",
                child: ActionButton(
                  isDark: isDark,
                  icon: Icons.library_music_rounded,
                  tooltip: "Saved Lyrics",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SavedLyricsScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              ActionButton(
                isDark: isDark,
                icon: Icons.download_rounded,
                tooltip: "Save for offline",
                onTap: () async {
                  final state = context.read<LyricsCubit>().state;
                  if (state is LyricsLoaded) {
                    await context.read<LyricsCubit>().saveCurrentLyrics(
                      id,
                      state.lyrics,
                    );
                    log(state.lyrics);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.white),
                              SizedBox(width: 12),
                              Text("Lyrics saved for offline use"),
                            ],
                          ),
                          backgroundColor: theme.primaryColor,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }
                  }
                },
              ),
            ],
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
                  valueColor: AlwaysStoppedAnimation(primary),
                ),
              ),
              Icon(Icons.music_note_rounded, size: 32, color: primary),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            "Loading lyrics...",
            style: theme.textTheme.bodyLarge?.copyWith(
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 200),
        physics: const BouncingScrollPhysics(),
        itemCount: lyrics.length,
        itemBuilder: (context, index) {
          return Container(
            key: getKeyForIndex(index),
            child: LyricLineWidget(
              line: lyrics[index],
              index: index,
              currentIndex: currentLineIndex,
              fadeController: fadeController,
              scaleController: scaleController,
              onTap: onSeek,
              isDark: isDark,
              theme: theme,
            ),
          );
        },
      ),
    );
  }
}
