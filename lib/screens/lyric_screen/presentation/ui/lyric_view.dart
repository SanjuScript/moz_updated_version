import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/core/helper/lyrics_format.dart';
import 'package:moz_updated_version/core/helper/share_songs.dart';
import 'package:moz_updated_version/core/helper/snackbar_helper.dart';
import 'package:moz_updated_version/screens/lyric_screen/presentation/cubit/lyrics_cubit.dart';
import 'package:moz_updated_version/screens/lyric_screen/presentation/widgets/language_sheet.dart';
import 'package:moz_updated_version/screens/lyric_screen/presentation/widgets/lyric_view/sections/app_bar_section.dart';
import 'package:moz_updated_version/screens/lyric_screen/presentation/widgets/lyric_view/sections/controls_section.dart';
import 'package:moz_updated_version/screens/lyric_screen/presentation/widgets/lyric_view/sections/lyrics_content_section.dart';
import 'package:moz_updated_version/screens/lyric_screen/presentation/widgets/lyric_view/sections/song_info_section.dart';
import 'package:moz_updated_version/widgets/audio_artwork_widget.dart';
import 'package:on_audio_query/on_audio_query.dart';

class PremiumLyricsScreen extends StatefulWidget {
  final String title;
  final String artist;
  final String lyrics;
  final int songId;
  final bool forEdit;

  const PremiumLyricsScreen({
    super.key,
    required this.title,
    required this.artist,
    required this.lyrics,
    this.forEdit = false,
    required this.songId,
  });

  @override
  State<PremiumLyricsScreen> createState() => _PremiumLyricsScreenState();
}

class _PremiumLyricsScreenState extends State<PremiumLyricsScreen> {
  String? _selectedLanguageLabel; // e.g. "Tamil"
  String? _transliteratedLyrics;
  bool _isTransliterating = false;
  bool _hasTransliterated = false;
  bool _showTimestamps = true;

  final ScrollController _scrollController = ScrollController();

  final Map<String, String> _languages = const {
    'Tamil': 'ta',
    'Malayalam': 'ml',
    'Hindi': 'hi',
    'Telugu': 'te',
  };

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String get _displayLyrics =>
      formatLyrics(_transliteratedLyrics ?? widget.lyrics, _showTimestamps);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: Theme.of(context).scaffoldBackgroundColor,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            AppBarSection(
              onBack: () => Navigator.pop(context),
              onShare: _shareLyrics,
              onCopy: _copyLyrics,
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Hero(
                    tag: widget.songId,
                    child: SizedBox(
                      height: MediaQuery.sizeOf(context).height * .40,
                      width: MediaQuery.sizeOf(context).width * .90,
                      child: AudioArtWorkWidget(id: widget.songId, size: 500),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SongInfoSection(title: widget.title, artist: widget.artist),
                  const SizedBox(height: 24),
                  ControlsSection(
                    isTransliterating: _isTransliterating,
                    selectedLanguageLabel: _selectedLanguageLabel,
                    showTimestamps: _showTimestamps,
                    canSave:
                        _hasTransliterated && _transliteratedLyrics != null,
                    onPickLanguage: _pickLanguage,
                    onToggleTimestamps: (v) =>
                        setState(() => _showTimestamps = v),
                    onSave: () => _saveTransliteratedLyrics(context),
                  ),
                  const SizedBox(height: 32),
                  LyricsContentSection(lyrics: _displayLyrics),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickLanguage() async {
    if (_isTransliterating) return;

    final label = await showLanguageSheet(
      context: context,
      languages: _languages.keys.toList(),
      selected: _selectedLanguageLabel,
    );

    if (label == null) return;

    setState(() => _selectedLanguageLabel = label);
    await _performTransliteration(label);
  }

  Future<void> _performTransliteration(String label) async {
    setState(() => _isTransliterating = true);

    try {
      final code = _languages[label]!;
      final cubit = context.read<LyricsCubit>();
      final result = await cubit.transliterateLyrics(widget.lyrics, code);

      if (result == null || result.isEmpty) {
        throw Exception('Empty result');
      }

      setState(() {
        _transliteratedLyrics = result;
        _hasTransliterated = true;
        _isTransliterating = false;
      });
      _ok('Converted to Manglish successfully');
    } catch (e) {
      setState(() => _isTransliterating = false);
      _err('Failed to convert: ${e.toString()}');
    }
  }

  Future<void> _saveTransliteratedLyrics(BuildContext context) async {
    if (_transliteratedLyrics == null) return;
    try {
      await context.read<LyricsCubit>().saveCurrentLyrics(
        widget.songId,
        _transliteratedLyrics!,
      );
      _ok('Manglish lyrics saved successfully');
    } catch (_) {
      _err('Failed to save lyrics');
    }
  }

  void _shareLyrics() {
    ShareHelper.shareLyrics(
      lyrics: _displayLyrics,
      title: widget.title,
      artist: widget.artist,
    );
  }

  void _copyLyrics() {
    Clipboard.setData(ClipboardData(text: _displayLyrics));
    _ok('Lyrics copied to clipboard');
  }

  void _ok(String m) => AppSnackBar.success(context, m);
  void _err(String m) => AppSnackBar.error(context, m);
}
