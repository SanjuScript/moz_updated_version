import 'dart:ui';
import 'package:flutter/material.dart';

class FrostedDialog extends StatefulWidget {
  final Widget child;
  final double blurEnd;
  final Duration duration;
  final BorderRadiusGeometry borderRadius;

  const FrostedDialog({
    super.key,
    required this.child,
    this.blurEnd = 18,
    this.duration = const Duration(milliseconds: 300),
    this.borderRadius = const BorderRadius.all(Radius.circular(15)),
  });

  @override
  State<FrostedDialog> createState() => _FrostedDialogState();
}

class _FrostedDialogState extends State<FrostedDialog>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = Tween<double>(
      begin: 0,
      end: widget.blurEnd,
    ).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _sigma => _animation.value;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return ClipRRect(
            borderRadius: widget.borderRadius,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: _sigma, sigmaY: _sigma),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).scaffoldBackgroundColor.withValues(alpha: .7),
                  borderRadius: widget.borderRadius,
                ),
                child: widget.child,
              ),
            ),
          );
        },
      ),
    );
  }
}
