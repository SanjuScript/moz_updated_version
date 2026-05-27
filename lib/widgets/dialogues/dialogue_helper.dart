import 'package:flutter/material.dart';

enum ClearDialogType {
  logout,
  clearPlaylists,
  clearFavorites,
  clearRecentlyPlayed,
  clearMostlyPlayed,
  clearSettings,
  deletePlaylist,
  clearHistory,
}

class ClearDialogConfig {
  final String title;
  final String description;
  final String confirmText;
  final String cancelText;
  final Color? confirmColor;
  final IconData? icon;
  final Color? iconColor;

  const ClearDialogConfig({
    required this.title,
    required this.description,
    required this.confirmText,
    this.cancelText = "Cancel",
    this.confirmColor,
    this.icon,
    this.iconColor,
  });

  factory ClearDialogConfig.fromType(ClearDialogType type) {
    switch (type) {
      case ClearDialogType.logout:
        return const ClearDialogConfig(
          title: "Log out?",
          description: "You'll need to sign in again to access your account.",
          confirmText: "Log out",
          confirmColor: Colors.redAccent,
          icon: Icons.logout_rounded,
          iconColor: Colors.redAccent,
        );

      case ClearDialogType.clearPlaylists:
        return const ClearDialogConfig(
          title: "Clear all playlists?",
          description:
              "This will permanently delete all your playlists. This action cannot be undone.",
          confirmText: "Clear All",
          confirmColor: Colors.redAccent,
          icon: Icons.playlist_remove_rounded,
          iconColor: Colors.redAccent,
        );

      case ClearDialogType.clearFavorites:
        return const ClearDialogConfig(
          title: "Clear all favorites?",
          description:
              "All songs will be removed from your favorites list. You can add them back anytime.",
          confirmText: "Clear Favorites",
          confirmColor: Colors.orange,
          icon: Icons.heart_broken_rounded,
          iconColor: Colors.orange,
        );

      case ClearDialogType.clearRecentlyPlayed:
        return const ClearDialogConfig(
          title: "Clear recently played?",
          description:
              "Your recently played history will be permanently cleared. This action cannot be undone.",
          confirmText: "Clear History",
          confirmColor: Colors.deepOrange,
          icon: Icons.history_rounded,
          iconColor: Colors.deepOrange,
        );

      case ClearDialogType.clearMostlyPlayed:
        return const ClearDialogConfig(
          title: "Clear mostly played?",
          description:
              "This will reset your play count statistics. All songs will start from zero plays.",
          confirmText: "Clear Stats",
          confirmColor: Colors.purple,
          icon: Icons.bar_chart_rounded,
          iconColor: Colors.purple,
        );

      case ClearDialogType.clearSettings:
        return const ClearDialogConfig(
          title: "Reset all settings?",
          description:
              "All app settings will be restored to default values. Your music library will not be affected.",
          confirmText: "Reset Settings",
          confirmColor: Colors.amber,
          icon: Icons.settings_backup_restore_rounded,
          iconColor: Colors.amber,
        );

      case ClearDialogType.deletePlaylist:
        return const ClearDialogConfig(
          title: "Delete playlist?",
          description:
              "This playlist will be permanently deleted. Songs in the playlist will not be affected.",
          confirmText: "Delete",
          confirmColor: Colors.redAccent,
          icon: Icons.delete_forever_rounded,
          iconColor: Colors.redAccent,
        );

      case ClearDialogType.clearHistory:
        return const ClearDialogConfig(
          title: "Clear listening history?",
          description:
              "This will clear both recently played and mostly played history.",
          confirmText: "Clear All History",
          confirmColor: Colors.red,
          icon: Icons.delete_sweep_rounded,
          iconColor: Colors.red,
        );
    }
  }
}
