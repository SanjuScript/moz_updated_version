import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:moz_updated_version/screens/settings/screens/contact_support/contact_support_screen.dart';
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

      _MenuItem(
        Icons.contact_support,
        "Contact Developer",
        onTap: () {
          sl<NavigationService>().navigateTo(
            SettingsScreen(),
            animation: NavigationAnimation.slide,
            slideAxis: AxisDirection.left,
          );

          Future.delayed(const Duration(milliseconds: 600), () {
            sl<NavigationService>().navigateTo(
              ContactSupportScreen(),
              animation: NavigationAnimation.slide,
              slideAxis: AxisDirection.left,
            );
          });
        },
      ),

      _MenuItem(Icons.contact_page, "About"),
      _MenuItem(Icons.privacy_tip, "Privacy Policy"),
    ];

    return Drawer(
      elevation: 12,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.9),
              Theme.of(context).colorScheme.secondary.withValues(alpha: 0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 12),
            Expanded(
              child: AnimationLimiter(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: menuItems.length,
                  itemBuilder: (context, index) {
                    final item = menuItems[index];
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 500),
                      child: SlideAnimation(
                        verticalOffset: 60,
                        curve: Curves.easeOutCubic,
                        child: FadeInAnimation(
                          child: _drawerItem(context, item),
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
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).hintColor,
        borderRadius: const BorderRadius.only(topRight: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 18,
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
                radius: 40,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.25),
                child: Icon(Icons.music_note, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 14),
              Text(
                "Moz Music",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  shadows: [
                    Shadow(
                      blurRadius: 6,
                      color: Colors.black38,
                      offset: Offset(1, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Feel the rhythm",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerItem(BuildContext context, _MenuItem item) {
    return GestureDetector(
      onTap: () {
        scaffoldKey.currentState?.closeDrawer();
        if (item.onTap != null) item.onTap!();
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Card(
          elevation: 6,
          shadowColor: Theme.of(
            context,
          ).colorScheme.primary.withValues(alpha: 0.25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 6,
            ),
            leading: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 400),
              tween: Tween(begin: 1.0, end: 1.05),
              curve: Curves.easeInOut,
              builder: (context, scale, child) {
                return Transform.scale(scale: scale, child: child);
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.2),
                      Theme.of(
                        context,
                      ).colorScheme.secondary.withValues(alpha: 0.2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.icon,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            title: Text(
              item.text,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            trailing: item.trailing,
          ),
        ),
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
