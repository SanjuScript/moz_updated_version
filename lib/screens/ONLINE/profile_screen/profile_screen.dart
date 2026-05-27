import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:moz_updated_version/core/extensions/capitalize.dart';
import 'package:moz_updated_version/data/firebase/logic/favorites/favorites_cubit.dart';
import 'package:moz_updated_version/data/firebase/logic/playlist/playlist_cubit.dart';
import 'package:moz_updated_version/data/model/user_model/user_model.dart';
import 'package:moz_updated_version/screens/ONLINE/download_screen/cubit/download_songs_cubit.dart';
import 'package:moz_updated_version/screens/ONLINE/download_screen/ui/song_downloads_screen.dart';
import 'package:moz_updated_version/screens/ONLINE/profile_screen/user_stats_cubit/cubit/user_stats_cubit.dart';
import 'package:moz_updated_version/screens/ONLINE/profile_screen/widgets/loggin_required_screen.dart';
import 'package:moz_updated_version/screens/settings/screens/contact_support/contact_support_screen.dart';
import 'package:moz_updated_version/screens/settings/screens/setting_screen/settings_page.dart';
import 'package:moz_updated_version/services/one_time_dialogue_service.dart';
import 'package:moz_updated_version/widgets/custom_cached_image.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ProfileStatsScreen
// ─────────────────────────────────────────────────────────────────────────────

class ProfileStatsScreen extends StatefulWidget {
  const ProfileStatsScreen({super.key});

  @override
  State<ProfileStatsScreen> createState() => _ProfileStatsScreenState();
}

class _ProfileStatsScreenState extends State<ProfileStatsScreen>
    with TickerProviderStateMixin {
  late final AnimationController _bgPulse;
  late final AnimationController _stagger;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;
  final ScrollController _scroll = ScrollController();
  double _headerOpacity = 0;

  @override
  void initState() {
    super.initState();
    context.read<DownloadSongsCubit>().loadDownloadedSongs();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      OneTimeDialog.show(
        context: context,
        dialogId: DialogIds.profileFeatureUpdate,
        content: DialogContents.featureUpdate,
      );
    });

    _bgPulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    // 7 stagger layers: appbar, avatar, name+badge, stats-top, stats-bottom, actions, version
    _stagger = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _fadeAnims = List.generate(7, (i) {
      final start = i * 0.10;
      final end = (start + 0.30).clamp(0.0, 1.0);
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _stagger,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    _slideAnims = List.generate(7, (i) {
      final start = i * 0.10;
      final end = (start + 0.30).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0, 0.25),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _stagger,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });

    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) _stagger.forward();
    });

    _scroll.addListener(() {
      final op = (_scroll.offset / 80).clamp(0.0, 1.0);
      if ((op - _headerOpacity).abs() > 0.01) {
        setState(() => _headerOpacity = op);
      }
    });
  }

  @override
  void dispose() {
    _bgPulse.dispose();
    _stagger.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.sizeOf(context);

    // Colour tokens
    final Color bg = isDark ? const Color(0xFF0B0B11) : const Color(0xFFF2F1F7);
    final Color surface = isDark
        ? const Color(0xFF161520)
        : const Color(0xFFFFFFFF);
    final Color accent = const Color(0xFF7C5CFC);
    final Color accentB = const Color(0xFFB06FFF);
    final Color textPrimary = isDark
        ? const Color(0xFFF0EEF8)
        : const Color(0xFF1A1625);
    final Color textMuted = isDark
        ? const Color(0xFF6E6887)
        : const Color(0xFF9B97AC);
    final Color cardBorder = isDark
        ? const Color(0xFF252235)
        : const Color(0xFFE5E2F0);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: ValueListenableBuilder(
        valueListenable: Hive.box<UserModel>('mozuser').listenable(),
        builder: (context, box, _) {
          final user = box.get('current_user');
          if (user == null || !user.isLoggedIn) {
            return const LoginRequiredScreen();
          }

          return Scaffold(
            backgroundColor: bg,
            extendBodyBehindAppBar: true,
            body: Stack(
              children: [
                // ── Atmospheric background ──────────────────────────────
                _AtmosphericBg(
                  pulse: _bgPulse,
                  accent: accent,
                  accentB: accentB,
                  isDark: isDark,
                  size: size,
                ),

                // ── Floating AppBar overlay ─────────────────────────────
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    color: bg.withValues(alpha: _headerOpacity * 0.95),
                    child: SafeArea(
                      bottom: false,
                      child: _Staggered(
                        fade: _fadeAnims[0],
                        slide: _slideAnims[0],
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Row(
                            children: [
                              _NavBtn(
                                icon: Icons.arrow_back_ios_new_rounded,
                                onTap: () => Navigator.pop(context),
                                isDark: isDark,
                              ),
                              const Spacer(),
                              AnimatedOpacity(
                                opacity: _headerOpacity,
                                duration: const Duration(milliseconds: 150),
                                child: Text(
                                  user.name.formattedFirstNamePossessive,
                                  style: TextStyle(
                                    color: textPrimary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              _NavBtn(
                                icon: Icons.settings_outlined,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => SettingsScreen(),
                                    ),
                                  );
                                },
                                isDark: isDark,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Main scrollable content ─────────────────────────────
                CustomScrollView(
                  controller: _scroll,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Top padding for appbar
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: MediaQuery.paddingOf(context).top + 56,
                      ),
                    ),

                    // ── Avatar + Name ──────────────────────────────────
                    SliverToBoxAdapter(
                      child: _Staggered(
                        fade: _fadeAnims[1],
                        slide: _slideAnims[1],
                        child: _AvatarSection(
                          user: user,
                          size: size,
                          accent: accent,
                          accentB: accentB,
                          pulse: _bgPulse,
                        ),
                      ),
                    ),

                    // ── Name + badge ──────────────────────────────────
                    SliverToBoxAdapter(
                      child: _Staggered(
                        fade: _fadeAnims[2],
                        slide: _slideAnims[2],
                        child: _NameBadgeSection(
                          user: user,
                          accent: accent,
                          accentB: accentB,
                          textPrimary: textPrimary,
                          textMuted: textMuted,
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 36)),

                    // ── Stats sheet ────────────────────────────────────
                    SliverToBoxAdapter(
                      child: Container(
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(36),
                            topRight: Radius.circular(36),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Section header
                              _Staggered(
                                fade: _fadeAnims[3],
                                slide: _slideAnims[3],
                                child: _SectionLabel(
                                  icon: Icons.bar_chart_rounded,
                                  label: 'Music Stats',
                                  accent: accent,
                                  textPrimary: textPrimary,
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Listening-time + songs hero row
                              _Staggered(
                                fade: _fadeAnims[3],
                                slide: _slideAnims[3],
                                child: BlocBuilder<UserStatsCubit, UserStatsState>(
                                  builder: (context, state) {
                                    if (state is UserStatsLoaded) {
                                      final time = formatListeningTime(
                                        state.stats.totalListeningTime,
                                      );
                                      return Row(
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: _HeroStatCard(
                                              icon: Icons.graphic_eq_rounded,
                                              value: state
                                                  .stats
                                                  .totalSongsPlayed
                                                  .toString(),
                                              label: 'Songs Played',
                                              gradientColors: const [
                                                Color(0xFF7C5CFC),
                                                Color(0xFFB06FFF),
                                              ],
                                              surface: surface,
                                              cardBorder: cardBorder,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            flex: 4,
                                            child: _HeroStatCard(
                                              icon: Icons
                                                  .access_time_filled_rounded,
                                              value:
                                                  '${time.hours} ${time.minutes}',
                                              label: 'Total Listen Time',
                                              gradientColors: const [
                                                Color(0xFF4FACFE),
                                                Color(0xFF00F2FE),
                                              ],
                                              surface: surface,
                                              cardBorder: cardBorder,
                                              wide: true,
                                            ),
                                          ),
                                        ],
                                      );
                                    }
                                    if (state is UserStatsLoading) {
                                      return _StatsShimmer(
                                        surface: surface,
                                        cardBorder: cardBorder,
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Secondary stats row
                              _Staggered(
                                fade: _fadeAnims[4],
                                slide: _slideAnims[4],
                                child: Row(
                                  children: [
                                    // Recently played
                                    Expanded(
                                      child: _SmallStatCard(
                                        icon: Icons.history_rounded,
                                        value: '–',
                                        label: 'Recent',
                                        sub: 'Coming soon',
                                        color: const Color(0xFFFF9A56),
                                        surface: surface,
                                        cardBorder: cardBorder,
                                      ),
                                    ),
                                    const SizedBox(width: 10),

                                    // Favorites
                                    Expanded(
                                      child:
                                          BlocBuilder<
                                            OnlineFavoritesCubit,
                                            OnlineFavoritesState
                                          >(
                                            builder: (ctx, state) {
                                              final count =
                                                  state
                                                      is OnlineFavoriteSongsLoaded
                                                  ? state.songs.length
                                                        .toString()
                                                  : '…';
                                              return _SmallStatCard(
                                                icon: Icons.favorite_rounded,
                                                value: count,
                                                label: 'Favourites',
                                                color: const Color(0xFFFF6B9D),
                                                surface: surface,
                                                cardBorder: cardBorder,
                                              );
                                            },
                                          ),
                                    ),
                                    const SizedBox(width: 10),

                                    // Playlists
                                    Expanded(
                                      child:
                                          BlocBuilder<
                                            OnlinePlaylistCubit,
                                            OnlinePlaylistState
                                          >(
                                            builder: (ctx, state) {
                                              final count =
                                                  state is OnlinePlaylistsLoaded
                                                  ? state.playlists.length
                                                        .toString()
                                                  : '…';
                                              return _SmallStatCard(
                                                icon:
                                                    Icons.playlist_play_rounded,
                                                value: count,
                                                label: 'Playlists',
                                                color: const Color(0xFF43E97B),
                                                surface: surface,
                                                cardBorder: cardBorder,
                                              );
                                            },
                                          ),
                                    ),
                                    const SizedBox(width: 10),

                                    // Downloads
                                    Expanded(
                                      child: _SmallStatCard(
                                        icon: Icons.download_done_rounded,
                                        value: context
                                            .read<DownloadSongsCubit>()
                                            .downloadCount
                                            .toString(),
                                        label: 'Downloads',
                                        color: const Color(0xFF38BDF8),
                                        surface: surface,
                                        cardBorder: cardBorder,
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                DownloadedSongsScreen(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 32),

                              // Actions header
                              _Staggered(
                                fade: _fadeAnims[5],
                                slide: _slideAnims[5],
                                child: _SectionLabel(
                                  icon: Icons.bolt_rounded,
                                  label: 'Quick Actions',
                                  accent: accent,
                                  textPrimary: textPrimary,
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Action cards
                              _Staggered(
                                fade: _fadeAnims[5],
                                slide: _slideAnims[5],
                                child: Column(
                                  children: [
                                    _ActionCard(
                                      icon: Icons.rate_review_outlined,
                                      title: 'Send Feedback',
                                      subtitle:
                                          'Help us shape the next version',
                                      iconColor: const Color(0xFF7C5CFC),
                                      surface: surface,
                                      cardBorder: cardBorder,
                                      textPrimary: textPrimary,
                                      textMuted: textMuted,
                                    ),
                                    const SizedBox(height: 10),
                                    _ActionCard(
                                      icon: Icons.bug_report_outlined,
                                      title: 'Report a Bug',
                                      subtitle: 'Something feels off? Tell us',
                                      iconColor: const Color(0xFFFF6B9D),
                                      surface: surface,
                                      cardBorder: cardBorder,
                                      textPrimary: textPrimary,
                                      textMuted: textMuted,
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 32),

                              // Version
                              _Staggered(
                                fade: _fadeAnims[6],
                                slide: _slideAnims[6],
                                child: Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.music_note_rounded,
                                        size: 12,
                                        color: textMuted,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        'MozMusic v1.0.4-beta',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: textMuted,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 110),
                            ],
                          ),
                        ),
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

// ─────────────────────────────────────────────────────────────────────────────
// Atmospheric animated background
// ─────────────────────────────────────────────────────────────────────────────

class _AtmosphericBg extends StatelessWidget {
  final AnimationController pulse;
  final Color accent, accentB;
  final bool isDark;
  final Size size;

  const _AtmosphericBg({
    required this.pulse,
    required this.accent,
    required this.accentB,
    required this.isDark,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulse,
      builder: (_, __) {
        final t = pulse.value;
        return SizedBox.expand(
          child: CustomPaint(
            painter: _BgPainter(
              t: t,
              accent: accent,
              accentB: accentB,
              isDark: isDark,
              size: size,
            ),
          ),
        );
      },
    );
  }
}

class _BgPainter extends CustomPainter {
  final double t;
  final Color accent, accentB;
  final bool isDark;
  final Size size;

  const _BgPainter({
    required this.t,
    required this.accent,
    required this.accentB,
    required this.isDark,
    required this.size,
  });

  @override
  void paint(Canvas canvas, Size sz) {
    final h = sz.height;
    final w = sz.width;

    // base fill
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..color = isDark ? const Color(0xFF0B0B11) : const Color(0xFFF2F1F7),
    );

    // top-left orb
    final p1 = Paint()
      ..shader =
          RadialGradient(
            colors: [
              accent.withValues(alpha: isDark ? 0.30 : 0.20),
              accent.withValues(alpha: 0),
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(w * 0.15, h * 0.12 + t * 20),
              radius: 220,
            ),
          );
    canvas.drawCircle(Offset(w * 0.15, h * 0.12 + t * 20), 220, p1);

    // top-right orb
    final p2 = Paint()
      ..shader =
          RadialGradient(
            colors: [
              accentB.withValues(alpha: isDark ? 0.22 : 0.15),
              accentB.withValues(alpha: 0),
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(w * 0.9, h * 0.06 - t * 15),
              radius: 180,
            ),
          );
    canvas.drawCircle(Offset(w * 0.9, h * 0.06 - t * 15), 180, p2);

    // bottom warm orb
    final p3 = Paint()
      ..shader =
          RadialGradient(
            colors: [
              const Color(0xFFFF6B9D).withValues(alpha: isDark ? 0.12 : 0.07),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(w * 0.7, h * 0.40 + t * 10),
              radius: 160,
            ),
          );
    canvas.drawCircle(Offset(w * 0.7, h * 0.40 + t * 10), 160, p3);
  }

  @override
  bool shouldRepaint(_BgPainter old) => old.t != t;
}

// ─────────────────────────────────────────────────────────────────────────────
// Avatar section with ring animation
// ─────────────────────────────────────────────────────────────────────────────

class _AvatarSection extends StatelessWidget {
  final UserModel user;
  final Size size;
  final Color accent, accentB;
  final AnimationController pulse;

  const _AvatarSection({
    required this.user,
    required this.size,
    required this.accent,
    required this.accentB,
    required this.pulse,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: pulse,
        builder: (_, __) {
          final t = pulse.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              // Outer pulse ring
              Container(
                width: 116 + t * 8,
                height: 116 + t * 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [
                      accent.withValues(alpha: 0.6 - t * 0.3),
                      accentB.withValues(alpha: 0.3 - t * 0.15),
                      accent.withValues(alpha: 0.6 - t * 0.3),
                    ],
                  ),
                ),
              ),
              // White gap ring
              Container(
                width: 108,
                height: 108,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
              ),
              // Avatar
              SizedBox(
                width: 98,
                height: 98,
                child: CircleAvatar(
                  radius: 49,
                  child: ClipOval(
                    child: CustomCachedImage(
                      imageUrl: user.photoUrl ?? '',
                      radius: 49,
                      height: 98,
                      width: 98,
                    ),
                  ),
                ),
              ),
              // Online dot
              Positioned(
                bottom: 6,
                right: 6,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF43E97B),
                    border: Border.all(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      width: 2.5,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Name + email + MOZ badge
// ─────────────────────────────────────────────────────────────────────────────

class _NameBadgeSection extends StatelessWidget {
  final UserModel user;
  final Color accent, accentB, textPrimary, textMuted;

  const _NameBadgeSection({
    required this.user,
    required this.accent,
    required this.accentB,
    required this.textPrimary,
    required this.textMuted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Text(
          user.name ?? 'Music Lover',
          maxLines: 1,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: textPrimary,
            letterSpacing: -0.5,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.email_outlined, size: 13, color: textMuted),
            const SizedBox(width: 5),
            Text(
              user.email ?? 'No email',
              style: TextStyle(
                fontSize: 13,
                color: textMuted,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.amber.shade500, Colors.orange.shade400],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified_rounded, size: 13, color: Colors.white),
              SizedBox(width: 6),
              Text(
                'MOZ MEMBER',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero stat card (songs played / listening time)
// ─────────────────────────────────────────────────────────────────────────────

class _HeroStatCard extends StatefulWidget {
  final IconData icon;
  final String value, label;
  final List<Color> gradientColors;
  final Color surface, cardBorder;
  final bool wide;

  const _HeroStatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.gradientColors,
    required this.surface,
    required this.cardBorder,
    this.wide = false,
  });

  @override
  State<_HeroStatCard> createState() => _HeroStatCardState();
}

class _HeroStatCardState extends State<_HeroStatCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );
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
        animation: _press,
        builder: (_, child) =>
            Transform.scale(scale: _press.value, child: child),
        child: Container(
          height: 120,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: widget.gradientColors[0].withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  widget.icon,
                  color: Colors.white,
                  size: widget.wide ? 18 : 18,
                ),
              ),
              const Spacer(),
              Text(
                widget.value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: widget.wide ? 22 : 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small stat card (4-column row)
// ─────────────────────────────────────────────────────────────────────────────

class _SmallStatCard extends StatefulWidget {
  final IconData icon;
  final String value, label;
  final String? sub;
  final Color color, surface, cardBorder;
  final VoidCallback? onTap;

  const _SmallStatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.surface,
    required this.cardBorder,
    this.sub,
    this.onTap,
  });

  @override
  State<_SmallStatCard> createState() => _SmallStatCardState();
}

class _SmallStatCardState extends State<_SmallStatCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.94,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _press.reverse(),
      onTapUp: (_) => _press.forward(),
      onTapCancel: () => _press.forward(),
      child: AnimatedBuilder(
        animation: _press,
        builder: (_, child) =>
            Transform.scale(scale: _press.value, child: child),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          decoration: BoxDecoration(
            color: widget.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: widget.cardBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(widget.icon, color: widget.color, size: 16),
              ),
              const SizedBox(height: 8),
              Text(
                widget.value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: widget.color,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF6E6887)
                      : const Color(0xFF9B97AC),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (widget.sub != null) ...[
                const SizedBox(height: 1),
                Text(
                  widget.sub!,
                  style: TextStyle(
                    fontSize: 8.5,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF4A4760)
                        : const Color(0xFFBBB7CC),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Action card
// ─────────────────────────────────────────────────────────────────────────────

class _ActionCard extends StatefulWidget {
  final IconData icon;
  final String title, subtitle;
  final Color iconColor, surface, cardBorder, textPrimary, textMuted;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.surface,
    required this.cardBorder,
    required this.textPrimary,
    required this.textMuted,
  });

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.97,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ContactSupportScreen()),
      ),
      onTapDown: (_) => _press.reverse(),
      onTapUp: (_) => _press.forward(),
      onTapCancel: () => _press.forward(),
      child: AnimatedBuilder(
        animation: _press,
        builder: (_, child) =>
            Transform.scale(scale: _press.value, child: child),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: widget.cardBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: widget.iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(widget.icon, color: widget.iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: widget.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: widget.textMuted,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: widget.textMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section label
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accent, textPrimary;

  const _SectionLabel({
    required this.icon,
    required this.label,
    required this.accent,
    required this.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: accent),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: textPrimary,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Nav icon button
// ─────────────────────────────────────────────────────────────────────────────

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;

  const _NavBtn({
    required this.icon,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isDark ? Colors.white : const Color(0xFF1A1625),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats shimmer placeholder
// ─────────────────────────────────────────────────────────────────────────────

class _StatsShimmer extends StatefulWidget {
  final Color surface, cardBorder;
  const _StatsShimmer({required this.surface, required this.cardBorder});

  @override
  State<_StatsShimmer> createState() => _StatsShimmerState();
}

class _StatsShimmerState extends State<_StatsShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _shimmer = CurvedAnimation(parent: _anim, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmer,
      builder: (_, __) {
        return Row(
          children: [
            Expanded(flex: 3, child: _shimBox(120, 22, full: true)),
            const SizedBox(width: 12),
            Expanded(flex: 4, child: _shimBox(120, 22, full: true)),
          ],
        );
      },
    );
  }

  Widget _shimBox(double h, double radius, {bool full = false}) {
    return Container(
      height: h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: const Alignment(-1, 0),
          end: Alignment(_shimmer.value * 3 - 1, 0),
          colors: [
            widget.surface,
            widget.cardBorder.withValues(alpha: 0.6),
            widget.surface,
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stagger wrapper
// ─────────────────────────────────────────────────────────────────────────────

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

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

({String hours, String minutes}) formatListeningTime(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  return (hours: '${h}h', minutes: '${m}m');
}
