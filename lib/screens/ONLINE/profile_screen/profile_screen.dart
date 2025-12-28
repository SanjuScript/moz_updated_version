import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:moz_updated_version/core/extensions/capitalize.dart';
import 'package:moz_updated_version/data/model/user_model/repository/user_repo.dart';
import 'package:moz_updated_version/data/model/user_model/user_model.dart';
import 'package:moz_updated_version/screens/ONLINE/download_screen/cubit/download_songs_cubit.dart';
import 'package:moz_updated_version/screens/ONLINE/download_screen/ui/song_downloads_screen.dart';
import 'package:moz_updated_version/screens/ONLINE/profile_screen/widgets/loggin_required_screen.dart';
import 'package:moz_updated_version/screens/settings/screens/contact_support/contact_support_screen.dart';
import 'package:moz_updated_version/screens/settings/screens/setting_screen/settings_page.dart';
import 'package:moz_updated_version/screens/song_list_screen/presentation/widgets/buttons/theme_change_button.dart';
import 'package:moz_updated_version/services/core/app_services.dart';
import 'package:moz_updated_version/widgets/custom_cached_image.dart';

class ProfileStatsScreen extends StatefulWidget {
  const ProfileStatsScreen({super.key});

  @override
  State<ProfileStatsScreen> createState() => _ProfileStatsScreenState();
}

class _ProfileStatsScreenState extends State<ProfileStatsScreen>
    with SingleTickerProviderStateMixin {
  final int recentlyPlayedCount = 42;
  final int favoritesCount = 156;
  final int playlistsCount = 12;
  final int totalSongsPlayed = 1247;
  final String listeningTime = "127h 34m";

  @override
  void initState() {
    super.initState();
    context.read<DownloadSongsCubit>().loadDownloadedSongs();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    final primary = Theme.of(context).colorScheme.primary;

    return ValueListenableBuilder(
      valueListenable: Hive.box<UserModel>('mozuser').listenable(),
      builder: (context, box, child) {
        final user = box.get('current_user');

        if (user == null || !user.isLoggedIn) {
          return const LoginRequiredScreen();
        }

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).primaryColor.withValues(alpha: .9),
                  Theme.of(context).primaryColor.withValues(alpha: 0.4),
                  Theme.of(context).scaffoldBackgroundColor,
                ],
                stops: const [0.0, 0.40, 0.75],
              ),
            ),

            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 30,
                      horizontal: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.arrow_back_ios),
                        ),
                        Text(
                          '${user.name.formattedFirstNamePossessive} Profile',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SettingsScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.settings_outlined),
                        ),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        SizedBox(
                          height: size.height * .18,
                          width: size.width * .40,

                          child: CircleAvatar(
                            child: CustomCachedImage(
                              imageUrl: user!.photoUrl!,
                              radius: 100,
                              height: size.height * .18,
                              width: size.width * .40,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        Text(
                          user!.name ?? "Music Lover",
                          maxLines: 1,
                          style: TextStyle(
                            overflow: TextOverflow.fade,
                            color: Colors.white,
                            fontSize: size.width * .08,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.email_outlined,
                                size: 16,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                user.email ?? "Sign in to make your stats",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.amber.shade400,
                                Colors.orange.shade400,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amber.withValues(alpha: 0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, size: 16, color: Colors.white),
                              SizedBox(width: 6),
                              Text(
                                'BETA TESTER',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 30)),

                SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.analytics_outlined,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Your Music Stats',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          if (10 < 10) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    icon: Icons.headphones,
                                    value: totalSongsPlayed.toString(),
                                    label: 'Songs Played',
                                    gradient: [
                                      Colors.purple.shade400,
                                      Colors.purple.shade600,
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildStatCard(
                                    icon: Icons.access_time,
                                    value: listeningTime,
                                    label: 'Listening Time',
                                    gradient: [
                                      Colors.blue.shade400,
                                      Colors.blue.shade600,
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Secondary Stats Grid
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    icon: Icons.history,
                                    value: recentlyPlayedCount.toString(),
                                    label: 'Recently Played',
                                    gradient: [
                                      Colors.orange.shade400,
                                      Colors.orange.shade600,
                                    ],
                                    compact: true,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildStatCard(
                                    icon: Icons.favorite,
                                    value: favoritesCount.toString(),
                                    label: 'Favorites',
                                    gradient: [
                                      Colors.pink.shade400,
                                      Colors.pink.shade600,
                                    ],
                                    compact: true,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    icon: Icons.playlist_play,
                                    value: playlistsCount.toString(),
                                    label: 'Playlists',
                                    gradient: [
                                      Colors.teal.shade400,
                                      Colors.teal.shade600,
                                    ],
                                    compact: true,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildStatCard(
                                    icon: Icons.download_done,
                                    value: context
                                        .read<DownloadSongsCubit>()
                                        .downloadCount
                                        .toString(),
                                    label: 'Downloads',
                                    gradient: [
                                      Colors.green.shade400,
                                      Colors.green.shade600,
                                    ],
                                    compact: true,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              DownloadedSongsScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 30),
                          ] else ...[
                            Text("Your music stats will appear in next update"),
                            SizedBox(height: 20),
                            _buildActionButton(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DownloadedSongsScreen(),
                                  ),
                                );
                              },
                              icon: Icons.download_done_sharp,
                              title: "Your downloads",
                              subtitle:
                                  "${context.read<DownloadSongsCubit>().downloadCount.toString()} downloads",
                              gradient: [
                                Colors.green.shade400,
                                Colors.green.shade600,
                              ],
                            ),
                          ],

                          // // Quick Actions
                          // Text(
                          //   'Quick Actions',
                          //   style: TextStyle(
                          //     fontSize: 22,
                          //     fontWeight: FontWeight.bold,
                          //     color: Colors.grey.shade800,
                          //   ),
                          // ),
                          const SizedBox(height: 10),
                          _buildActionButton(
                            icon: Icons.rate_review_outlined,
                            title: 'Send Feedback',
                            subtitle: 'Help us improve the app',
                            gradient: [
                              Colors.blue.shade400,
                              Colors.blue.shade600,
                            ],
                          ),
                          const SizedBox(height: 12),

                          _buildActionButton(
                            icon: Icons.bug_report_outlined,
                            title: 'Report a Bug',
                            subtitle: 'Found something wrong?',
                            gradient: [
                              Colors.red.shade400,
                              Colors.red.shade600,
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Version Info
                          Center(
                            child: Text(
                              'MozMusic v1.0.4-beta',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade400,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required List<Color> gradient,
    void Function()? onTap,
    bool compact = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(compact ? 16 : 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: compact ? 24 : 32),
            SizedBox(height: compact ? 8 : 12),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: compact ? 20 : 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: compact ? 11 : 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradient,
    void Function()? onTap,
  }) {
    return InkWell(
      onTap:
          onTap ??
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ContactSupportScreen(),
              ),
            );
          },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: BorderRadius.circular(16),
          // border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
