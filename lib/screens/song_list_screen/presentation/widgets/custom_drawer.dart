import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:moz_updated_version/screens/settings/screens/setting_screen/settings_page.dart';
import 'package:moz_updated_version/screens/settings/screens/sleep_timer_screen/presentation/ui/sleep_timer.dart';
import 'package:moz_updated_version/screens/song_list_screen/presentation/widgets/buttons/theme_change_button.dart';

import '../../../../services/core/app_services.dart';

class AppDrawer extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const AppDrawer({super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      _MenuItem(
        Icons.color_lens_outlined,
        "Theme Mode",
        trailing: const ChangeThemeButtonWidget(),
      ),
      _MenuItem(Icons.playlist_play_rounded, "Play List", onTap: () {}),
      _MenuItem(Icons.favorite, "Favorites"),
      _MenuItem(Icons.search, "Search Music"),
      _MenuItem(
        Icons.timer,
        "Sleep Timer",
        onTap: () {
          sl<NavigationService>().navigateTo(
            SleepTimerScreen(),
            animation: NavigationAnimation.fade,
          );
        },
      ),
      _MenuItem(
        Icons.settings,
        "Settings",
        onTap: () {
          sl<NavigationService>().navigateTo(
            SettingsScreen(),
            animation: NavigationAnimation.fade,
          );
        },
      ),
      _MenuItem(Icons.contact_page, "About"),
      _MenuItem(Icons.privacy_tip, "Privacy Policy"),
    ];

    return Drawer(
      elevation: 12,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 8),
            Expanded(
              child: AnimationLimiter(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  itemCount: menuItems.length,
                  itemBuilder: (context, index) {
                    final item = menuItems[index];
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 400),
                      child: SlideAnimation(
                        verticalOffset: 40,
                        curve: Curves.easeOutCubic,
                        child: FadeInAnimation(
                          child: _drawerItem(
                            context,
                            icon: item.icon,
                            text: item.text,
                            trailing: item.trailing,
                            onTap: item.onTap,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(topRight: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 38,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Icon(Icons.music_note, color: Colors.white, size: 36),
              ),
              const SizedBox(height: 14),
              Text(
                "Moz Music",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Feel the rhythm 🎵",
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context, {
    required IconData icon,
    required String text,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 3,
      surfaceTintColor: Colors.transparent,
      shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        tileColor: Colors.transparent,
        leading: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 500),
          tween: Tween(begin: 1.0, end: 1.1),
          curve: Curves.easeInOut,
          builder: (context, scale, child) {
            return Transform.scale(scale: scale, child: child);
          },
          child: Container(
            padding: const EdgeInsets.all(10),

            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary),
          ),
        ),
        title: Text(
          text,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        trailing: trailing,
        onTap: () {
          scaffoldKey.currentState?.closeDrawer();
          if (onTap != null) onTap();
        },
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String text;
  final Widget? trailing;
  final VoidCallback? onTap;

  _MenuItem(this.icon, this.text, {this.trailing, this.onTap});
}
