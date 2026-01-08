import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:moz_updated_version/screens/ONLINE/bottom_nav/presentation/ui/bottom_nav.dart';

class GoOnlineButton extends StatefulWidget {
  const GoOnlineButton({super.key});

  @override
  State<GoOnlineButton> createState() => _GoOnlineButtonState();
}

class _GoOnlineButtonState extends State<GoOnlineButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _shimmerController;
  late AnimationController _dismissController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _dismissAnimation;

  static const String _hiveBoxName = 'app_settings';
  static const String _dismissCountKey = 'go_online_dismiss_count';
  static const String _hidePermanentlyKey = 'go_online_hide_permanently';
  static const int _maxDismissBeforeHide = 2;

  bool? _isVisible;
  Box? _settingsBox;

  @override
  void initState() {
    super.initState();
    _initializeBox();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _dismissController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _dismissAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _dismissController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initializeBox() async {
    try {
      _settingsBox = await Hive.openBox(_hiveBoxName);
      final hidePermanently = _settingsBox!.get(
        _hidePermanentlyKey,
        defaultValue: false,
      );

      if (mounted) {
        setState(() {
          _isVisible = !hidePermanently;
        });

        if (_isVisible!) {
          _pulseController.repeat(reverse: true);
          _rotationController.repeat();
          _shimmerController.repeat();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isVisible = true;
        });
        _pulseController.repeat(reverse: true);
        _rotationController.repeat();
        _shimmerController.repeat();
      }
    }
  }

  Future<void> _handleClose() async {
    if (_settingsBox == null) return;

    final currentCount =
        _settingsBox!.get(_dismissCountKey, defaultValue: 0) as int;
    final newCount = currentCount + 1;

    await _settingsBox!.put(_dismissCountKey, newCount);

    await _dismissController.forward();

    if (newCount >= _maxDismissBeforeHide) {
      await _settingsBox!.put(_hidePermanentlyKey, true);
    }

    if (mounted) {
      setState(() {
        _isVisible = false;
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _shimmerController.dispose();
    _dismissController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isVisible == null) {
      return const SizedBox.shrink();
    }

    if (!_isVisible!) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _dismissAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _dismissAnimation.value == 0.0 ? 0.0 : _dismissAnimation.value,
          child: Opacity(
            opacity: _dismissAnimation.value == 0.0
                ? 0.0
                : _dismissAnimation.value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const OnlineBottomNavScreen(),
            ),
          );
        },
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _pulseController,
            _rotationController,
            _shimmerController,
          ]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                height: 180,
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? Colors.purple : Colors.blue).withValues(
                        alpha: 0.3 * _pulseAnimation.value,
                      ),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: (isDark ? Colors.blue : Colors.purple).withValues(
                        alpha: 0.2 * _pulseAnimation.value,
                      ),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Stack(
                    children: [
                      _buildAnimatedBackground(isDark),
                      _buildRotatingOrbs(isDark),
                      _buildShimmerOverlay(),
                      _buildGlassEffect(),
                      _buildContent(theme, isDark),
                      _buildCloseButton(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCloseButton() {
    return Positioned(
      top: 12,
      right: 12,
      child: GestureDetector(
        onTap: _handleClose,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground(bool isDark) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF6C63FF),
                    const Color(0xFF4834DF),
                    const Color(0xFF2D1B69),
                  ]
                : [
                    const Color(0xFF667eea),
                    const Color(0xFF764ba2),
                    const Color(0xFFf093fb),
                  ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildRotatingOrbs(bool isDark) {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right:
                -40 + (math.sin(_rotationController.value * 2 * math.pi) * 20),
            child: Transform.rotate(
              angle: _rotationController.value * 2 * math.pi,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left:
                -30 + (math.cos(_rotationController.value * 2 * math.pi) * 15),
            child: Transform.rotate(
              angle: -_rotationController.value * 2 * math.pi,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      (isDark ? Colors.blue : Colors.pink).withValues(
                        alpha: 0.3,
                      ),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 60,
            left: 40 + (math.sin(_rotationController.value * 3 * math.pi) * 10),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerOverlay() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _shimmerController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset((_shimmerController.value * 2 - 1) * 400, 0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.transparent,
                    Colors.white.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGlassEffect() {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.1),
                Colors.white.withValues(alpha: 0.05),
              ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(28),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme, bool isDark) {
    return Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.public_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const Spacer(),
                Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.greenAccent,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.greenAccent.withValues(
                                  alpha: 0.6,
                                ),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'LIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Go Online',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1,
                    letterSpacing: -0.5,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 2),
                        blurRadius: 4,
                        color: Color(0x4D000000),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Explore millions of tracks worldwide',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: isDark
                            ? const Color(0xFF4834DF)
                            : const Color(0xFF764ba2),
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
