import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;

import 'package:moz_updated_version/core/animations/custom_paint_animations/sign_in_screen_animation.dart';
import 'package:moz_updated_version/core/helper/snackbar_helper.dart';
import 'package:moz_updated_version/core/utils/repository/Authentication/auth_repo.dart';

class GoogleSignInScreen extends StatefulWidget {
  const GoogleSignInScreen({super.key});

  @override
  State<GoogleSignInScreen> createState() => _GoogleSignInScreenState();
}

class _GoogleSignInScreenState extends State<GoogleSignInScreen>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _waveController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService().signInWithGoogle();
      // Navigation is handled inside signInWithGoogle
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, 'Sign in failed: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0a0e27),
      body: Stack(
        children: [
          // Animated background waves
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                return CustomPaint(
                  painter: WavePainter(animation: _waveController.value),
                );
              },
            ),
          ),

          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF0a0e27).withValues(alpha: 0.3),
                    const Color(0xFF0a0e27).withValues(alpha: 0.9),
                  ],
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    const Spacer(flex: 2),

                    // Music icon with glow effect
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF6C63FF), Color(0xFFFF6584)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF6C63FF,
                            ).withValues(alpha: 0.5),
                            blurRadius: 40,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.music_note_rounded,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 48),

                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFFFF6584)],
                      ).createShader(bounds),
                      child: Text(
                        'Moz Music',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 35,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Text(
                      'Your music, your vibe',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),

                    const EqualizerBars(),
                    const Spacer(flex: 2),

                    Text(
                      'Stream millions of songs',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.6),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),

                    _MusicGoogleSignInButton(
                      onPressed: _handleSignIn,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: 24),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text.rich(
                        TextSpan(
                          text: 'By continuing, you agree to our ',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                          children: [
                            const TextSpan(
                              text: 'Terms',
                              style: TextStyle(
                                color: Color(0xFF6C63FF),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(
                              text: ' and ',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                            ),
                            const TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(
                                color: Color(0xFF6C63FF),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MusicGoogleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const _MusicGoogleSignInButton({
    required this.onPressed,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1a1a1a),
        minimumSize: const Size(double.infinity, 64),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        elevation: 2,
        disabledBackgroundColor: Colors.white.withValues(alpha: 0.7),
      ),
      child: isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset("assets/icons/google_icon.svg"),
                const SizedBox(width: 12),
                const Text(
                  'Continue with Google',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
    );
  }
}

// EqualizerBars remains the same...
class EqualizerBars extends StatefulWidget {
  const EqualizerBars({super.key});

  @override
  State<EqualizerBars> createState() => _EqualizerBarsState();
}

class _EqualizerBarsState extends State<EqualizerBars>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(5, (index) {
              final delay = index * 0.1;
              final height =
                  8.0 +
                  (math.sin((_controller.value + delay) * math.pi * 2) * 15);
              return Container(
                width: 4,
                height: height + 15,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Color(0xFF6C63FF), Color(0xFFFF6584)],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
