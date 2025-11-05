import 'package:flutter/material.dart';
import 'package:moz_updated_version/screens/song_list_screen/presentation/widgets/buttons/theme_change_button.dart';

class AppBarSection extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onShare;
  final VoidCallback onCopy;

  const AppBarSection({
    super.key,
    required this.onBack,
    required this.onShare,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: true,
      backgroundColor: bg,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        onPressed: onBack,
      ),

      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, size: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          onSelected: (v) => v == 'share' ? onShare() : onCopy(),
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'share',
              child: Row(
                children: [
                  Icon(Icons.share_outlined, size: 20),
                  SizedBox(width: 12),
                  Text('Share'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'copy',
              child: Row(
                children: [
                  Icon(Icons.copy_outlined, size: 20),
                  SizedBox(width: 12),
                  Text('Copy Lyrics'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
