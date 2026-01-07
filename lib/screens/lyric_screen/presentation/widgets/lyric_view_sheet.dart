import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/core/helper/snackbar_helper.dart';
import 'package:moz_updated_version/screens/lyric_screen/presentation/cubit/lyrics_cubit.dart';

class LyricsViewerBottomSheet extends StatefulWidget {
  final String title;
  final String artist;
  final String lyrics;
  final ScrollController? controller;
  final int songId; // Add this

  const LyricsViewerBottomSheet({
    super.key,
    required this.title,
    required this.artist,
    required this.lyrics,
    required this.songId, // Add this
    this.controller,
  });

  @override
  State<LyricsViewerBottomSheet> createState() =>
      _LyricsViewerBottomSheetState();
}

class _LyricsViewerBottomSheetState extends State<LyricsViewerBottomSheet> {
  String? _selectedLanguage;
  String? _transliteratedLyrics;
  bool _isTransliterating = false;
  bool _hasTransliterated = false;

  final Map<String, String> _languages = {
    'Tamil': 'ta',
    'Malayalam': 'ml',
    'Hindi': 'hi',
    'Telugu': 'te',
  };

  @override
  Widget build(BuildContext context) {
    final displayLyrics = _transliteratedLyrics ?? widget.lyrics;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header with title and close button
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.artist,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Language selection dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.translate,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedLanguage,
                        hint: const Text('Convert to Manglish'),
                        isExpanded: true,
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: Theme.of(context).primaryColor,
                        ),
                        items: _languages.entries.map((entry) {
                          return DropdownMenuItem(
                            value: entry.key,
                            child: Text('${entry.key} → Manglish'),
                          );
                        }).toList(),
                        onChanged: _isTransliterating
                            ? null
                            : (value) {
                                setState(() {
                                  _selectedLanguage = value;
                                });
                                if (value != null) {
                                  _performTransliteration(value);
                                }
                              },
                      ),
                    ),
                  ),
                  if (_isTransliterating)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Save button (only show after transliteration)
          if (_hasTransliterated && _transliteratedLyrics != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _saveTransliteratedLyrics(context),
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save Manglish Lyrics'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ),

          const Divider(height: 24),

          // Lyrics content
          Expanded(
            child: SingleChildScrollView(
              controller: widget.controller,
              padding: const EdgeInsets.all(24.0),
              child: Text(
                displayLyrics,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.8,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performTransliteration(String language) async {
    setState(() {
      _isTransliterating = true;
    });

    try {
      final sourceLang = _languages[language]!;
      final cubit = context.read<LyricsCubit>();

      final result = await cubit.transliterateLyrics(widget.lyrics, sourceLang);

      if (result != null && result.isNotEmpty) {
        setState(() {
          _transliteratedLyrics = result;
          _hasTransliterated = true;
          _isTransliterating = false;
        });

        if (mounted) {
          AppSnackBar.success(context, "Converted to Manglish successfully");
        }
      } else {
        throw Exception('Failed to transliterate');
      }
    } catch (e) {
      setState(() {
        _isTransliterating = false;
      });

      if (mounted) {
        AppSnackBar.error(context, "Failed to convert: ${e.toString()}");
      }
    }
  }

  Future<void> _saveTransliteratedLyrics(BuildContext context) async {
    if (_transliteratedLyrics == null) return;

    try {
      await context.read<LyricsCubit>().saveCurrentLyrics(
        widget.songId.toString(),
        _transliteratedLyrics!,
      );

      if (mounted) {
        AppSnackBar.success(context, "Manglish lyrics saved successfully");
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, "Failed to save lyrics");
      }
    }
  }
}
