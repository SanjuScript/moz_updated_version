import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// ==================== DIALOG TRACKER SERVICE ====================
class DialogTrackerService {
  static const String _boxName = 'dialog_tracker';
  static Box? _box;

  static Future<void> initialize() async {
    _box = await Hive.openBox(_boxName);
  }

  static bool hasShown(String dialogId) {
    return _box?.get(dialogId, defaultValue: false) ?? false;
  }

  static Future<void> markAsShown(String dialogId) async {
    await _box?.put(dialogId, true);
  }

  static Future<void> reset(String dialogId) async {
    await _box?.delete(dialogId);
  }

  static Future<void> resetAll() async {
    await _box?.clear();
  }

  static List<String> getAllShownDialogs() {
    if (_box == null) return [];
    return _box!.keys.cast<String>().toList();
  }
}

// ==================== DIALOG IDS ====================
class DialogIds {
  static const String profileBetaWelcome = 'profile_beta_welcome';
  static const String profileFeatureUpdate = 'profile_feature_update';
  static const String homeWelcome = 'home_welcome';
  static const String homeNewFeature = 'home_new_features';
  static const String playerTutorial = 'player_tutorial';
  static const String playerQualitySettings = 'player_quality_settings';
  static const String searchTips = 'search_tips';
  static const String favoritesIntro = 'favorites_intro';
  static const String nowPlayingTips = 'now_playing_tips';
  static const String downloadFeature = 'download_feature';
  static const String offlineMode = 'offline_mode';
}

// ==================== DIALOG CONTENT CLASS ====================
class DialogContent {
  final String title;
  final String message;
  final IconData? icon;
  final Color? iconColor;
  final String? primaryButtonText;
  final String? secondaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onSecondaryPressed;

  const DialogContent({
    required this.title,
    required this.message,
    this.icon,
    this.iconColor,
    this.primaryButtonText,
    this.secondaryButtonText,
    this.onPrimaryPressed,
    this.onSecondaryPressed,
  });
}

// ==================== DIALOG CONTENTS REPOSITORY ====================
class DialogContents {
  // Now Playing Tips
  static const nowPlayingTips = DialogContent(
    title: 'Now Playing Tips 🎧',
    message:
        'Tap the audio artwork image to switch between the song artwork and lyrics.\n\n'
        'Tap again to return to the artwork view.\n\n'
        'Enjoy your music and happy listening!',

    icon: Icons.music_note,
    iconColor: Colors.deepPurple,
  );

  // Profile Welcome
  static const profileWelcome = DialogContent(
    title: 'Welcome to Your Profile! 👤',
    message:
        'Here you can view your listening stats, manage your playlists, '
        'and customize your music experience.\n\n'
        'Tap on any playlist to start listening!',
    icon: Icons.person,
    iconColor: Colors.blue,
  );

  // Home Welcome
  static const homeWelcome = DialogContent(
    title: 'Welcome to Moz! 🎵',
    message:
        'Discover new music, explore artist pages, and enjoy your favorite songs.\n\n'
        'Swipe through categories to find different genres and moods. '
        'The issue with artist pages is now fixed, and Moz Recommended playlists will be available to you soon.',

    icon: Icons.home,
    iconColor: Colors.green,
  );

  // Search Tips
  static const searchTips = DialogContent(
    title: 'Search Tips 🔍',
    message:
        'You can search for songs, artists, albums, and playlists.\n\n'
        'Try using filters to narrow down your results and find exactly what you\'re looking for!',
    icon: Icons.search,
    iconColor: Colors.orange,
  );

  // Favorites Intro
  static const favoritesIntro = DialogContent(
    title: 'Your Favorites ❤️',
    message:
        'Tap the heart icon on any song to add it to your favorites.\n\n'
        'Access your favorite songs anytime from this screen for quick playback!',
    icon: Icons.favorite,
    iconColor: Colors.red,
  );

  // Player Tutorial
  static const playerTutorial = DialogContent(
    title: 'Player Controls 🎮',
    message:
        'Swipe up for lyrics, tap the queue button to see what\'s next, '
        'and use the controls at the bottom to manage playback.\n\n'
        'Long press on a song to see more options!',
    icon: Icons.play_circle,
    iconColor: Colors.purple,
  );

  // Download Feature
  static const downloadFeature = DialogContent(
    title: 'Download Music 📥',
    message:
        'You can now download your favorite songs for offline listening!\n\n'
        'Just tap the download icon next to any song to save it to your device.',
    icon: Icons.download,
    iconColor: Colors.teal,
  );

  // Offline Mode
  static const offlineMode = DialogContent(
    title: 'Offline Mode 📴',
    message:
        'You\'re now in offline mode. You can only play downloaded songs.\n\n'
        'Connect to the internet to access your full music library!',
    icon: Icons.cloud_off,
    iconColor: Colors.grey,
  );

  // Quality Settings
  static const qualitySettings = DialogContent(
    title: 'Audio Quality ⚙️',
    message:
        'Adjust your streaming quality based on your internet connection.\n\n'
        'Higher quality uses more data but sounds better. '
        'Lower quality saves data and works better on slower connections.',
    icon: Icons.settings,
    iconColor: Colors.indigo,
    primaryButtonText: 'Open Settings',
  );

  // Feature Update
  static const featureUpdate = DialogContent(
    title: 'What\'s New! 🎉',
    message:
        'Check out the latest updates:\n\n'
        '• Bug fixes and optimized song playback\n'
        '• Artist pages are now available\n'
        '• Mini player now works across all screens\n'
        '• Glass effect removed for better performance '
        '(you can re-enable it from Settings if needed)\n'
        '• Overall performance improvements',

    icon: Icons.new_releases,
    iconColor: Colors.amber,
  );
}

// ==================== ONE-TIME DIALOG WIDGET ====================
class OneTimeDialog {
  /// Show a dialog only once using DialogContent
  ///
  /// Usage:
  /// ```dart
  /// OneTimeDialog.show(
  ///   context: context,
  ///   dialogId: DialogIds.nowPlayingTips,
  ///   content: DialogContents.nowPlayingTips,
  /// );
  /// ```
  static Future<void> show({
    required BuildContext context,
    required String dialogId,
    required DialogContent content,
    bool barrierDismissible = true,
    Duration delay = Duration.zero,
  }) async {
    if (DialogTrackerService.hasShown(dialogId)) {
      return;
    }

    if (delay > Duration.zero) {
      await Future.delayed(delay);
    }

    if (!context.mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => _OneTimeDialogContent(
        title: content.title,
        message: content.message,
        icon: content.icon,
        iconColor: content.iconColor,
        primaryButtonText: content.primaryButtonText ?? 'Got it!',
        secondaryButtonText: content.secondaryButtonText,
        onPrimaryPressed: content.onPrimaryPressed,
        onSecondaryPressed: content.onSecondaryPressed,
      ),
    );

    await DialogTrackerService.markAsShown(dialogId);
  }

  /// Show a dialog with manual parameters (legacy support)
  @deprecated
  static Future<void> showManual({
    required BuildContext context,
    required String dialogId,
    required String title,
    required String message,
    IconData? icon,
    Color? iconColor,
    String? primaryButtonText,
    String? secondaryButtonText,
    VoidCallback? onPrimaryPressed,
    VoidCallback? onSecondaryPressed,
    bool barrierDismissible = true,
    Duration delay = Duration.zero,
  }) async {
    await show(
      context: context,
      dialogId: dialogId,
      content: DialogContent(
        title: title,
        message: message,
        icon: icon,
        iconColor: iconColor,
        primaryButtonText: primaryButtonText,
        secondaryButtonText: secondaryButtonText,
        onPrimaryPressed: onPrimaryPressed,
        onSecondaryPressed: onSecondaryPressed,
      ),
      barrierDismissible: barrierDismissible,
      delay: delay,
    );
  }

  /// Show a custom dialog widget only once
  static Future<void> showCustom({
    required BuildContext context,
    required String dialogId,
    required Widget child,
    bool barrierDismissible = true,
    Duration delay = Duration.zero,
  }) async {
    if (DialogTrackerService.hasShown(dialogId)) {
      return;
    }

    if (delay > Duration.zero) {
      await Future.delayed(delay);
    }

    if (!context.mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => child,
    );

    await DialogTrackerService.markAsShown(dialogId);
  }
}

// ==================== DIALOG CONTENT WIDGET ====================
class _OneTimeDialogContent extends StatelessWidget {
  final String title;
  final String message;
  final IconData? icon;
  final Color? iconColor;
  final String primaryButtonText;
  final String? secondaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onSecondaryPressed;

  const _OneTimeDialogContent({
    required this.title,
    required this.message,
    this.icon,
    this.iconColor,
    required this.primaryButtonText,
    this.secondaryButtonText,
    this.onPrimaryPressed,
    this.onSecondaryPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = iconColor ?? Theme.of(context).primaryColor;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.5)
                  : Colors.black.withValues(alpha: 0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              // Gradient Background
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [const Color(0xFF1a1a2e), const Color(0xFF16213e)]
                          : [const Color(0xFFffffff), const Color(0xFFf8f9fa)],
                    ),
                  ),
                ),
              ),

              // Decorative circles
              Positioned(
                top: -40,
                right: -40,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        accentColor.withValues(alpha: 0.15),
                        accentColor.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -30,
                left: -30,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        accentColor.withValues(alpha: 0.1),
                        accentColor.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),

              // Glass effect overlay
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [
                                Colors.white.withValues(alpha: 0.05),
                                Colors.white.withValues(alpha: 0.02),
                              ]
                            : [
                                Colors.white.withValues(alpha: 0.7),
                                Colors.white.withValues(alpha: 0.3),
                              ],
                      ),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.white.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              accentColor,
                              accentColor.withValues(alpha: 0.7),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: accentColor.withValues(alpha: 0.4),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(icon, size: 40, color: Colors.white),
                      ),
                      const SizedBox(height: 24),
                    ],

                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 15,
                        color: isDark ? Colors.white70 : Colors.grey[700],
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),

                    // Buttons
                    Row(
                      children: [
                        if (secondaryButtonText != null) ...[
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                onSecondaryPressed?.call();
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                side: BorderSide(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.2)
                                      : Colors.grey.withValues(alpha: 0.3),
                                  width: 1.5,
                                ),
                                foregroundColor: isDark
                                    ? Colors.white70
                                    : Colors.black87,
                              ),
                              child: Text(
                                secondaryButtonText!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],

                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  accentColor,
                                  accentColor.withValues(alpha: 0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: accentColor.withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                onPrimaryPressed?.call();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                primaryButtonText,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
