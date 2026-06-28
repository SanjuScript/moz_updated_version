import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:moz_updated_version/screens/ONLINE/auth/presentation/ui/google_sign_in_screen.dart';

class LoginRequiredScreen extends StatefulWidget {
  const LoginRequiredScreen({super.key});

  @override
  State<LoginRequiredScreen> createState() => _LoginRequiredScreenState();
}

class _LoginRequiredScreenState extends State<LoginRequiredScreen>
    with TickerProviderStateMixin {
  late final AnimationController _floatController;
  late final AnimationController _staggerController;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    // 6 items: header, title, subtitle, features, badge, button
    _fadeAnims = List.generate(6, (i) {
      final start = i * 0.12;
      final end = (start + 0.35).clamp(0.0, 1.0);
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    _slideAnims = List.generate(6, (i) {
      final start = i * 0.12;
      final end = (start + 0.35).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _staggerController.forward();
    });
  }

  @override
  void dispose() {
    _floatController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.sizeOf(context);

    final primaryColor = theme.primaryColor;
    final Color bg = isDark
        ? Color.lerp(primaryColor, const Color(0xFF0D0D12), 0.95) ?? const Color(0xFF0D0D12)
        : Color.lerp(primaryColor, const Color(0xFFF5F4F8), 0.95) ?? const Color(0xFFF5F4F8);
    final Color surface = isDark
        ? const Color(0xFF16151D)
        : const Color(0xFFFFFFFF);
    final Color accent = primaryColor;
    final Color accentSoft = isDark
        ? Color.lerp(primaryColor, const Color(0xFF0D0D12), 0.85) ?? const Color(0xFF2A2040)
        : Color.lerp(primaryColor, const Color(0xFFFFFFFF), 0.85) ?? const Color(0xFFEDE8FF);
    final Color textPrimary = isDark
        ? const Color(0xFFF0EEF8)
        : const Color(0xFF1A1625);
    final Color textMuted = isDark
        ? const Color(0xFF7B7590)
        : const Color(0xFF9490A8);
    final Color cardBorder = isDark
        ? const Color(0xFF252335)
        : const Color(0xFFE8E5F2);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // ── Decorative background orbs ──
          Positioned(
            top: -80,
            right: -60,
            child: AnimatedBuilder(
              animation: _floatController,
              builder: (_, __) => Transform.translate(
                offset: Offset(
                  0,
                  math.sin(_floatController.value * math.pi) * 12,
                ),
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        accent.withValues(alpha: isDark ? 0.18 : 0.12),
                        accent.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: size.height * 0.25,
            left: -90,
            child: AnimatedBuilder(
              animation: _floatController,
              builder: (_, __) => Transform.translate(
                offset: Offset(
                  0,
                  -math.sin(_floatController.value * math.pi) * 16,
                ),
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(
                          0xFFFF6B9D,
                        ).withValues(alpha: isDark ? 0.12 : 0.07),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Content ──
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),

                  // Hero icon
                  _Staggered(
                    fade: _fadeAnims[0],
                    slide: _slideAnims[0],
                    child: _HeroIcon(
                      accent: accent,
                      accentSoft: accentSoft,
                      floatAnim: _floatController,
                      isDark: isDark,
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Title
                  _Staggered(
                    fade: _fadeAnims[1],
                    slide: _slideAnims[1],
                    child: Column(
                      children: [
                        Text(
                          'Your Music,',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                            height: 1.1,
                            letterSpacing: -0.5,
                          ),
                        ),
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [accent, const Color(0xFFB06FFF)],
                          ).createShader(bounds),
                          child: Text(
                            'Everywhere.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.1,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Subtitle
                  _Staggered(
                    fade: _fadeAnims[2],
                    slide: _slideAnims[2],
                    child: Text(
                      'Sign in to unlock your full music experience — history, playlists, favorites, and seamless sync across all devices.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: textMuted,
                        height: 1.6,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // CTA button
                  _Staggered(
                    fade: _fadeAnims[5],
                    slide: _slideAnims[5],
                    child: _SignInButton(accent: accent),
                  ),
                  const SizedBox(height: 25),
                  // Feature cards
                  _Staggered(
                    fade: _fadeAnims[3],
                    slide: _slideAnims[3],
                    child: _FeatureGrid(
                      surface: surface,
                      cardBorder: cardBorder,
                      textPrimary: textPrimary,
                      textMuted: textMuted,
                      accent: accent,
                    ),
                  ),

                  const SizedBox(height: 24),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hero Icon ──────────────────────────────────────────────────────────────

class _HeroIcon extends StatelessWidget {
  final Color accent;
  final Color accentSoft;
  final AnimationController floatAnim;
  final bool isDark;

  const _HeroIcon({
    required this.accent,
    required this.accentSoft,
    required this.floatAnim,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: floatAnim,
        builder: (_, __) => Transform.translate(
          offset: Offset(0, math.sin(floatAnim.value * math.pi) * 8),
          child: SizedBox(
            width: 130,
            height: 130,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow ring
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        accent.withValues(alpha: 0.25),
                        accent.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
                // Mid ring
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentSoft,
                    border: Border.all(
                      color: accent.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                ),
                // Icon
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [accent, const Color(0xFFB06FFF)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.5),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.music_note_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                // Orbiting dot
                Transform.rotate(
                  angle: floatAnim.value * math.pi * 2,
                  child: Transform.translate(
                    offset: const Offset(50, 0),
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFFF6B9D),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFFFF6B9D,
                            ).withValues(alpha: 0.6),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Feature Grid ───────────────────────────────────────────────────────────

class _FeatureGrid extends StatelessWidget {
  final Color surface, cardBorder, textPrimary, textMuted, accent;

  const _FeatureGrid({
    required this.surface,
    required this.cardBorder,
    required this.textPrimary,
    required this.textMuted,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final features = [
      (
        icon: Icons.person_rounded,
        label: 'Profile & Preferences',
        sub: 'Your taste, your way',
        color: accent,
      ),
      (
        icon: Icons.history_rounded,
        label: 'Listening History',
        sub: 'Relive every track',
        color: const Color(0xFF4FACFE),
      ),
      (
        icon: Icons.favorite_rounded,
        label: 'Favorites & Playlists',
        sub: 'All your loved music',
        color: const Color(0xFFFF6B9D),
      ),
      (
        icon: Icons.sync_rounded,
        label: 'Cross-Device Sync',
        sub: 'Pick up where you left',
        color: const Color(0xFF43E97B),
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.35,
      children: features
          .map(
            (f) => _FeatureCard(
              icon: f.icon,
              label: f.label,
              sub: f.sub,
              color: f.color,
              surface: surface,
              cardBorder: cardBorder,
              textPrimary: textPrimary,
              textMuted: textMuted,
            ),
          )
          .toList(),
    );
  }
}

class _FeatureCard extends StatefulWidget {
  final IconData icon;
  final String label, sub;
  final Color color, surface, cardBorder, textPrimary, textMuted;

  const _FeatureCard({
    required this.icon,
    required this.label,
    required this.sub,
    required this.color,
    required this.surface,
    required this.cardBorder,
    required this.textPrimary,
    required this.textMuted,
  });

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.97,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _press;
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _press.reverse(),
      onTapUp: (_) => _press.forward(),
      onTapCancel: () => _press.forward(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: widget.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: widget.cardBorder, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(widget.icon, color: widget.color, size: 20),
              ),
              const Spacer(),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: widget.textPrimary,
                  height: 1.3,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 2),
              Text(
                widget.sub,
                style: TextStyle(
                  fontSize: 11,
                  color: widget.textMuted,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sign-In Button ─────────────────────────────────────────────────────────

class _SignInButton extends StatefulWidget {
  final Color accent;
  const _SignInButton({required this.accent});

  @override
  State<_SignInButton> createState() => _SignInButtonState();
}

class _SignInButtonState extends State<_SignInButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmer;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, a, __) => const GoogleSignInScreen(),
          transitionsBuilder: (_, anim, __, child) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
              child: child,
            ),
          ),
        ),
      ),
      child: AnimatedBuilder(
        animation: _shimmer,
        builder: (_, __) {
          return Container(
            height: 58,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [widget.accent, const Color(0xFFB06FFF)],
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.accent.withValues(alpha: 0.45),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Shimmer sweep
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Align(
                    alignment: Alignment(-1.5 + _shimmer.value * 4, 0),
                    child: Container(
                      width: 60,
                      height: 58,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0),
                            Colors.white.withValues(alpha: 0.18),
                            Colors.white.withValues(alpha: 0),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/icons/google.png',
                      width: 20,
                      height: 20,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.g_mobiledata_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Continue with Google',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Stagger Wrapper ────────────────────────────────────────────────────────

class _Staggered extends StatelessWidget {
  final Animation<double> fade;
  final Animation<Offset> slide;
  final Widget child;

  const _Staggered({
    required this.fade,
    required this.slide,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(position: slide, child: child),
    );
  }
}
