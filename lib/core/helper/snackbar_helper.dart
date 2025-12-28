import 'package:flutter/material.dart';

enum PremiumSnackBarType { success, error, warning, info }

class AppSnackBar {
  static OverlayEntry? _currentOverlay;

  static void show(
    BuildContext context, {
    required String message,
    required PremiumSnackBarType type,
    Duration duration = const Duration(seconds: 3),
    bool showIcon = true,
  }) {
    _currentOverlay?.remove();
    _currentOverlay = null;

    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _PremiumSnackBarWidget(
        message: message,
        type: type,
        showIcon: showIcon,
        onDismiss: () {
          overlayEntry.remove();
          _currentOverlay = null;
        },
      ),
    );

    _currentOverlay = overlayEntry;
    overlay.insert(overlayEntry);

    Future.delayed(duration, () {
      if (_currentOverlay == overlayEntry) {
        overlayEntry.remove();
        _currentOverlay = null;
      }
    });
  }

  static void success(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message: message,
      type: PremiumSnackBarType.success,
      duration: duration,
    );
  }

  static void error(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message: message,
      type: PremiumSnackBarType.error,
      duration: duration,
    );
  }

  static void warning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message: message,
      type: PremiumSnackBarType.warning,
      duration: duration,
    );
  }

  static void info(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message: message,
      type: PremiumSnackBarType.info,
      duration: duration,
    );
  }
}

class _PremiumSnackBarWidget extends StatefulWidget {
  final String message;
  final PremiumSnackBarType type;
  final bool showIcon;
  final VoidCallback onDismiss;

  const _PremiumSnackBarWidget({
    required this.message,
    required this.type,
    required this.showIcon,
    required this.onDismiss,
  });

  @override
  State<_PremiumSnackBarWidget> createState() => _PremiumSnackBarWidgetState();
}

class _PremiumSnackBarWidgetState extends State<_PremiumSnackBarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  Color _getBackgroundColor(BuildContext context) {
    switch (widget.type) {
      case PremiumSnackBarType.success:
        return Theme.of(context).primaryColor;
      case PremiumSnackBarType.error:
        return const Color(0xFFEF4444);
      case PremiumSnackBarType.warning:
        return const Color(0xFFF59E0B);
      case PremiumSnackBarType.info:
        return const Color(0xFF3B82F6);
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case PremiumSnackBarType.success:
        return Icons.check_circle_rounded;
      case PremiumSnackBarType.error:
        return Icons.error_rounded;
      case PremiumSnackBarType.warning:
        return Icons.warning_rounded;
      case PremiumSnackBarType.info:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _getBackgroundColor(context);

    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onVerticalDragEnd: (details) {
                if (details.velocity.pixelsPerSecond.dy < 0) {
                  _dismiss();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: backgroundColor.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    if (widget.showIcon) ...[
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(_getIcon(), color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Text(
                        widget.message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _dismiss,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
