import 'package:flutter/material.dart';
import 'package:moz_updated_version/screens/playlist_screen/presentation/widgets/froasted_dialogue.dart';
import 'package:moz_updated_version/services/reset_service.dart';

Future<void> showResetDialog(BuildContext context) async {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return FrostedDialog(
        blurEnd: 20,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Reset Moz Music",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
              const SizedBox(height: 12),
              const Text(
                "Are you sure you want to reset Moz Music?",
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 12),
              const Text(
                "This will permanently delete the following:",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              const Text("• All Playlists"),
              const Text("• Recently Played songs"),
              const Text("• Mostly Played data"),
              const Text("• Favorite songs"),
              const Text("• Removed songs list"),
              const Text("• Settings"),
              const SizedBox(height: 14),
              const Text(
                "After reset, the app will restart fresh like a new install.",
                style: TextStyle(color: Colors.redAccent, fontSize: 14),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      await AppResetService.fullResetApp(context);
                    },
                    icon: const Icon(
                      Icons.cleaning_services,
                      color: Colors.white,
                    ),
                    label: const Text(
                      "Reset Now",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
