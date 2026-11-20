import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:moz_updated_version/data/firebase/logic/favorites/favorites_cubit.dart';
import 'package:moz_updated_version/data/firebase/logic/playlist/playlist_cubit.dart';
import 'package:moz_updated_version/data/model/user_model/user_model.dart';
import 'package:moz_updated_version/screens/ONLINE/bottom_nav/presentation/cubit/online_tab_cubit.dart';
import 'package:moz_updated_version/screens/ONLINE/download_screen/cubit/download_songs_cubit.dart';
import 'package:moz_updated_version/screens/ONLINE/download_screen/ui/song_downloads_screen.dart';
import 'package:moz_updated_version/screens/ONLINE/favorite_screen/presentation/ui/playlist_screen.dart';
import 'package:moz_updated_version/screens/ONLINE/profile_screen/user_stats_cubit/cubit/user_stats_cubit.dart';
import 'package:moz_updated_version/screens/ONLINE/profile_screen/widgets/loggin_required_screen.dart';
import 'package:moz_updated_version/screens/settings/screens/contact_support/contact_support_screen.dart';
import 'package:moz_updated_version/screens/settings/screens/dev_admin_screen/dev_admin_screen.dart';
import 'package:moz_updated_version/screens/settings/screens/setting_screen/settings_page.dart';
import 'package:moz_updated_version/services/navigation_service.dart'
    show navigationPageRoute;
import 'package:package_info_plus/package_info_plus.dart';

class ProfileStatsScreen extends StatefulWidget {
  const ProfileStatsScreen({super.key});

  @override
  State<ProfileStatsScreen> createState() => _ProfileStatsScreenState();
}

class _ProfileStatsScreenState extends State<ProfileStatsScreen> {
  @override
  void initState() {
    super.initState();
    if (!Platform.isIOS) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.read<DownloadSongsCubit>().loadDownloadedSongs();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: ValueListenableBuilder<Box<UserModel>>(
        valueListenable: Hive.box<UserModel>('mozuser').listenable(),
        builder: (context, box, _) {
          final user = box.get('current_user');
          if (user == null || !user.isLoggedIn) {
            return const LoginRequiredScreen();
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'YOUR SPACE',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontSize: 11,
                                  letterSpacing: 1.6,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Profile',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.7,
                                  color: theme.brightness == Brightness.dark
                                      ? Colors.white
                                      : const Color(0xFF141416),
                                ),
                              ),
                            ],
                          ),
                        ),
                        _RoundAction(
                          icon: Icons.settings_outlined,
                          label: 'Settings',
                          onTap: () => _push(context, SettingsScreen()),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: _ProfileHero(user: user),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 26, 20, 12),
                  child: _SectionHeading(
                    title: 'Listening',
                    subtitle: 'Your time with music',
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: BlocBuilder<UserStatsCubit, UserStatsState>(
                    builder: (context, state) {
                      final stats = state is UserStatsLoaded
                          ? state.stats
                          : null;
                      final played = stats?.totalSongsPlayed.toString() ?? '—';
                      final listening =
                          stats?.totalListeningTime ?? Duration.zero;
                      final listeningText = _formatDuration(listening);
                      return Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.music_note_rounded,
                              value: played,
                              label: 'Songs played',
                              accent: const Color(0xFF7863E9),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.headphones_rounded,
                              value: listeningText,
                              label: 'Listening time',
                              accent: const Color(0xFFE0B85F),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 26, 20, 12),
                  child: _SectionHeading(
                    title: 'Your library',
                    subtitle: 'Everything you have saved',
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      BlocBuilder<OnlineFavoritesCubit, OnlineFavoritesState>(
                        builder: (context, state) {
                          final count = state is OnlineFavoriteSongsLoaded
                              ? state.songs.length
                              : null;
                          return _NavigationTile(
                            icon: Icons.favorite_rounded,
                            iconColor: const Color(0xFFE17A91),
                            title: 'Favorites',
                            subtitle: count == null
                                ? 'Your liked songs'
                                : '$count ${count == 1 ? 'song' : 'songs'} saved',
                            onTap: () =>
                                context.read<OnlineTabCubit>().changeTab(2),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      BlocBuilder<OnlinePlaylistCubit, OnlinePlaylistState>(
                        builder: (context, state) {
                          final count = state is OnlinePlaylistsLoaded
                              ? state.playlists.length
                              : null;
                          return _NavigationTile(
                            icon: Icons.queue_music_rounded,
                            iconColor: const Color(0xFF7863E9),
                            title: 'Playlists',
                            subtitle: count == null
                                ? 'Your personal collections'
                                : '$count ${count == 1 ? 'playlist' : 'playlists'}',
                            onTap: () =>
                                _push(context, const OnlinePlaylistScreen()),
                          );
                        },
                      ),
                      if (!Platform.isIOS) ...[
                        const SizedBox(height: 10),
                        _NavigationTile(
                          icon: Icons.download_rounded,
                          iconColor: const Color(0xFF55A985),
                          title: 'Downloads',
                          subtitle: 'Music saved on this device',
                          onTap: () =>
                              _push(context, const DownloadedSongsScreen()),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 26, 20, 12),
                  child: _SectionHeading(
                    title: 'Account',
                    subtitle: 'Help and preferences',
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: Column(
                    children: [
                      _NavigationTile(
                        icon: Icons.tune_rounded,
                        iconColor: const Color(0xFF7187D9),
                        title: 'Settings',
                        subtitle: 'Playback and app preferences',
                        onTap: () => _push(context, SettingsScreen()),
                      ),
                      const SizedBox(height: 10),
                      _NavigationTile(
                        icon: Icons.support_agent_rounded,
                        iconColor: const Color(0xFFE0B85F),
                        title: 'Contact support',
                        subtitle: 'We’re here if you need us',
                        onTap: () =>
                            _push(context, const ContactSupportScreen()),
                      ),
                      if (user.email.trim().toLowerCase() ==
                          'npsanjay246@gmail.com') ...[
                        const SizedBox(height: 10),
                        _NavigationTile(
                          icon: Icons.admin_panel_settings_rounded,
                          iconColor: const Color(0xFF7863E9),
                          title: 'Developer console',
                          subtitle: 'App administration',
                          onTap: () => _push(context, const DevAdminScreen()),
                        ),
                      ],
                      const SizedBox(height: 20),
                      FutureBuilder<PackageInfo>(
                        future: PackageInfo.fromPlatform(),
                        builder: (context, snapshot) => Text(
                          'MOZ  •  VERSION ${snapshot.data?.version ?? '—'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.brightness == Brightness.dark
                                ? const Color(0xFF888899)
                                : const Color(0xFF777788),
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(navigationPageRoute(builder: (_) => page));
  }

  String _formatDuration(Duration duration) {
    if (duration.inMinutes < 1) return '0 min';
    if (duration.inHours < 1) return '${duration.inMinutes} min';
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return minutes == 0 ? '${hours}h' : '${hours}h ${minutes}m';
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final joined = MaterialLocalizations.of(
      context,
    ).formatMediumDate(user.createdAt);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF211B50), Color(0xFF17162F), Color(0xFF12121F)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF211B50).withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            top: -12,
            child: Opacity(
              opacity: 0.10,
              child: Image.asset('assets/icons/moz_icon.png', width: 110),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _Avatar(user: user),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name.trim().isEmpty
                              ? 'Music lover'
                              : user.name.trim(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          user.email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.68),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0CD7A).withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFF0CD7A).withValues(alpha: 0.28),
                      ),
                    ),
                    child: const Text(
                      'MOZ MEMBER',
                      style: TextStyle(
                        color: Color(0xFFF0CD7A),
                        fontSize: 10,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Since $joined',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.58),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final photo = user.photoUrl?.trim();
    return Container(
      width: 62,
      height: 62,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFF0CD7A).withValues(alpha: 0.75),
        ),
      ),
      child: CircleAvatar(
        backgroundColor: const Color(0xFF37305E),
        backgroundImage: photo != null && photo.isNotEmpty
            ? NetworkImage(photo)
            : null,
        child: photo == null || photo.isEmpty
            ? Text(
                user.name.trim().isEmpty
                    ? 'M'
                    : user.name.trim()[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              )
            : null,
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
            color: isDark ? Colors.white : const Color(0xFF141416),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark ? const Color(0xFFB0B0C0) : const Color(0xFF555566),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.accent,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B1A24) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.10)
              : Colors.black.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: 22),
          const SizedBox(height: 14),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: isDark ? Colors.white : const Color(0xFF141416),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFA0A0B0) : const Color(0xFF666677),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavigationTile extends StatelessWidget {
  const _NavigationTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Material(
      color: isDark ? const Color(0xFF1B1A24) : Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.06),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF141416),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? const Color(0xFFA0A0B0)
                            : const Color(0xFF666677),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isDark ? const Color(0xFF888899) : const Color(0xFF9999AA),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return IconButton.filledTonal(
      tooltip: label,
      onPressed: onTap,
      icon: Icon(icon),
      style: IconButton.styleFrom(
        backgroundColor: isDark ? const Color(0xFF1B1A24) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF141416),
        side: BorderSide(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
    );
  }
}
