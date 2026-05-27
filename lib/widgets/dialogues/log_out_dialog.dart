import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/core/themes/cubit/theme_cubit.dart';
import 'package:moz_updated_version/screens/playlist_screen/presentation/widgets/froasted_dialogue.dart';
import 'package:moz_updated_version/services/service_locator.dart';
import 'package:moz_updated_version/widgets/dialogues/dialogue_helper.dart';

void showClearDialog(
  BuildContext context, {
  ClearDialogType? type,
  ClearDialogConfig? config,
  required VoidCallback onConfirm,
}) {
  assert(
    type != null || config != null,
    'Either type or config must be provided',
  );

  final dialogConfig = config ?? ClearDialogConfig.fromType(type!);

  if (sl<ThemeCubit>().isIos) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => FrostedDialog(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _ClearDialogContent(
            isIos: true,
            config: dialogConfig,
            onConfirm: onConfirm,
          ),
        ),
      ),
    );
  } else {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => FrostedDialog(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _ClearDialogContent(
            isIos: false,
            config: dialogConfig,
            onConfirm: onConfirm,
          ),
        ),
      ),
    );
  }
}

class _ClearDialogContent extends StatelessWidget {
  final bool isIos;
  final ClearDialogConfig config;
  final VoidCallback onConfirm;

  const _ClearDialogContent({
    required this.isIos,
    required this.config,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon and Title Row
        Row(
          children: [
            if (config.icon != null) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (config.iconColor ?? theme.colorScheme.primary)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  config.icon,
                  color: config.iconColor ?? theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                config.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Text(
          config.description,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),

        Row(
          children: [
            Expanded(
              child: isIos
                  ? CupertinoButton(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(12),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        config.cancelText,
                        style: TextStyle(
                          color: isDark
                              ? CupertinoColors.white
                              : CupertinoColors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: theme.colorScheme.outline.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                      child: Text(
                        config.cancelText,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.8,
                          ),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 12),

            // Confirm Button
            Expanded(
              child: isIos
                  ? CupertinoButton(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      color:
                          config.confirmColor ??
                          (isIos
                              ? CupertinoColors.systemRed
                              : Colors.redAccent),
                      borderRadius: BorderRadius.circular(12),
                      onPressed: () {
                        Navigator.pop(context);
                        onConfirm();
                      },
                      child: Text(
                        config.confirmText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onConfirm();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor:
                            config.confirmColor ?? Colors.redAccent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        config.confirmText,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
            ),
          ],
        ),
      ],
    );
  }
}
