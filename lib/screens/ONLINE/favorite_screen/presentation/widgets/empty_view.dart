import 'package:flutter/material.dart';

class EmptyView extends StatelessWidget {
  final String title;
  final String desc;
  final IconData icon;
  final bool showButton;
  const EmptyView({
    super.key,
    required this.title,
    required this.desc,
    required this.icon,
    this.showButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GradientCircle(
            padding: 32,
            gradient: LinearGradient(
              colors: [
                theme.primaryColor.withValues(alpha: 0.1),
                theme.primaryColor.withValues(alpha: 0.1),
              ],
            ),
            child: GradientCircle(
              padding: 24,
              gradient: LinearGradient(
                colors: [
                  Colors.purple.withValues(alpha: 0.2),
                  Colors.pink.withValues(alpha: 0.2),
                ],
              ),
              child: Icon(icon, size: 80, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 32),
          Text(title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              desc,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall!.copyWith(fontSize: 14),
            ),
          ),
          const SizedBox(height: 32),
          if (showButton)
            _ActionButton(
              icon: Icons.explore,
              label: "Explore Music",
              onTap: () {
                // Navigate to explore / search
              },
            ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: theme.primaryColor.withValues(alpha: .7),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class GradientCircle extends StatelessWidget {
  final double padding;
  final Gradient gradient;
  final Widget child;

  const GradientCircle({
    super.key,
    required this.padding,
    required this.gradient,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(shape: BoxShape.circle, gradient: gradient),
      child: child,
    );
  }
}
