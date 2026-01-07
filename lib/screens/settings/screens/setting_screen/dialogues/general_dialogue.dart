import 'package:flutter/material.dart';
import 'package:moz_updated_version/core/helper/snackbar_helper.dart';
import 'package:moz_updated_version/screens/playlist_screen/presentation/widgets/froasted_dialogue.dart';
import 'package:moz_updated_version/services/reset_service.dart';

Future<void> deleteBoxDialogue(
  BuildContext context, {
  required String title,
  required String description,
  required Future<void> Function() onConfirm,
  bool restartAfter = false,
}) async {
  return showDialog(
    context: context,
    builder: (context) {
      return FrostedDialog(
        blurEnd: 20,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: const TextStyle(fontSize: 16, height: 1.5),
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
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.pop(context);

                      await onConfirm();

                      if (restartAfter) {
                        AppResetService.fullResetApp(context);
                      } else {
                        AppSnackBar.success(context, "$title cleared");
                      }
                    },
                    child: const Text(
                      "Confirm",
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
