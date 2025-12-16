import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// ==================== DIALOG TRACKER SERVICE ====================
class DialogTrackerService {
  static const String _boxName = 'dialog_tracker';
  static Box? _box;

  // Initialize Hive box (call this in main.dart)
  static Future<void> initialize() async {
    _box = await Hive.openBox(_boxName);
  }

  // Check if a dialog has been shown
  static bool hasShown(String dialogId) {
    return _box?.get(dialogId, defaultValue: false) ?? false;
  }

  // Mark a dialog as shown
  static Future<void> markAsShown(String dialogId) async {
    await _box?.put(dialogId, true);
  }

  // Reset a specific dialog (for testing or re-showing)
  static Future<void> reset(String dialogId) async {
    await _box?.delete(dialogId);
  }

  // Reset all dialogs (useful for testing)
  static Future<void> resetAll() async {
    await _box?.clear();
  }

  // Get all shown dialog IDs (for debugging)
  static List<String> getAllShownDialogs() {
    if (_box == null) return [];
    return _box!.keys.cast<String>().toList();
  }
}

// ==================== DIALOG IDS (Define all your dialog identifiers) ====================
class DialogIds {
  // Profile Screen
  static const String profileBetaWelcome = 'profile_beta_welcome';
  static const String profileFeatureUpdate = 'profile_feature_update';

  // Home Screen
  static const String homeWelcome = 'home_welcome';
  static const String homeNewFeature = 'home_new_feature';

  // Player Screen
  static const String playerTutorial = 'player_tutorial';
  static const String playerQualitySettings = 'player_quality_settings';

  // Search Screen
  static const String searchTips = 'search_tips';

  // Favorites Screen
  static const String favoritesIntro = 'favorites_intro';

  // Add more as needed...
}

// ==================== ONE-TIME DIALOG WIDGET ====================
class OneTimeDialog {
  /// Show a dialog only once based on dialogId
  ///
  /// Usage:
  /// ```dart
  /// OneTimeDialog.show(
  ///   context: context,
  ///   dialogId: DialogIds.homeWelcome,
  ///   title: 'Welcome!',
  ///   message: 'Thanks for using our app',
  ///   icon: Icons.celebration,
  /// );
  /// ```
  static Future<void> show({
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
    // Check if dialog has already been shown
    if (DialogTrackerService.hasShown(dialogId)) {
      return;
    }

    // Optional delay before showing
    if (delay > Duration.zero) {
      await Future.delayed(delay);
    }

    // Check if context is still valid after delay
    if (!context.mounted) return;

    // Show the dialog
    await showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => _OneTimeDialogContent(
        title: title,
        message: message,
        icon: icon,
        iconColor: iconColor,
        primaryButtonText: primaryButtonText ?? 'Got it!',
        secondaryButtonText: secondaryButtonText,
        onPrimaryPressed: onPrimaryPressed,
        onSecondaryPressed: onSecondaryPressed,
      ),
    );

    // Mark as shown
    await DialogTrackerService.markAsShown(dialogId);
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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon (if provided)
            if (icon != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (iconColor ?? Colors.blue).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 48, color: iconColor ?? Colors.blue),
              ),
              const SizedBox(height: 20),
            ],

            // Title
            Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Message
            Text(
              message,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                // Secondary Button (if provided)
                if (secondaryButtonText != null) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onSecondaryPressed?.call();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(secondaryButtonText!),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],

                // Primary Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onPrimaryPressed?.call();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: iconColor ?? Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(primaryButtonText),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
