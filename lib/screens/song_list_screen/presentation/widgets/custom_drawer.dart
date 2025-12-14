import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:moz_updated_version/data/model/user_model/repository/user_repo.dart';
import 'package:moz_updated_version/data/model/user_model/user_model.dart';
import 'package:moz_updated_version/screens/search_screen/presentation/ui/search_screen.dart';
import 'package:moz_updated_version/screens/settings/screens/contact_support/contact_support_screen.dart';
import 'package:moz_updated_version/screens/settings/screens/faq/faq_screen.dart';
import 'package:moz_updated_version/screens/settings/screens/faq/helper/faq_model.dart';
import 'package:moz_updated_version/screens/settings/screens/privacy_policy/privacy_policy_screen.dart';
import 'package:moz_updated_version/screens/settings/screens/setting_screen/settings_page.dart';
import 'package:moz_updated_version/screens/settings/screens/sleep_timer_screen/presentation/ui/sleep_timer.dart';
import 'package:moz_updated_version/screens/song_list_screen/presentation/widgets/buttons/theme_change_button.dart';
import 'package:moz_updated_version/widgets/custom_cached_image.dart';

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
      _MenuItem(
        Icons.search,
        "Search Music",
        onTap: () {
          sl<NavigationService>().navigateTo(
            SearchSongsScreen(),
            animation: NavigationAnimation.slide,
            slideAxis: AxisDirection.left,
          );
        },
      ),
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

      _MenuItem(
        Icons.contact_page,
        "FAQ",
        onTap: () {
          sl<NavigationService>().navigateTo(
            FaqScreen(),
            animation: NavigationAnimation.slide,
            slideAxis: AxisDirection.left,
          );
        },
      ),
      _MenuItem(
        Icons.privacy_tip,
        "Privacy Policy",
        onTap: () {
          sl<NavigationService>().navigateTo(
            PrivacyPolicyScreen(),
            animation: NavigationAnimation.slide,
            slideAxis: AxisDirection.left,
          );
        },
      ),
    ];

    return SizedBox(
      child: Drawer(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 12,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(32),
            bottomRight: Radius.circular(32),
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
    final userRepo = sl<UserStorageAbRepo>();
    final user = userRepo.isLoggedIn() ? userRepo.getUser() : null;

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
          child: user != null
              ? _loggedInHeader(context, user)
              : _guestHeader(context),
        ),
      ),
    );
  }

  Widget _loggedInHeader(BuildContext context, UserModel user) {
    log(user.toString());
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 50,
          child: CustomCachedImage(imageUrl: user.photoUrl!, radius: 50),
        ),
        const SizedBox(height: 14),
        Text(
          user.name,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Text(
          "Premium Member", // or “Logged in”
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _guestHeader(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Theme.of(
            context,
          ).colorScheme.primary.withValues(alpha: 0.25),
          child: const Icon(Icons.music_note, color: Colors.white, size: 40),
        ),
        const SizedBox(height: 14),
        Text(
          "Moz Music",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
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
            child: Icon(item.icon),
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
