import 'package:flutter/material.dart';
import 'package:moz_updated_version/screens/song_list_screen/presentation/widgets/buttons/theme_change_button.dart';

class AppDrawer extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const AppDrawer({super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 8,
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
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                children: [
                  _drawerItem(
                    context,
                    icon: Icons.color_lens_outlined,
                    text: "Theme Mode",
                    trailing: const ChangeThemeButtonWidget(),
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.playlist_play_rounded,
                    text: "Play List",
                    onTap: () {
                      // navigation(const PlaylistScreen(), context, scaffoldKey);
                    },
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.favorite,
                    text: "Favorites",
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.search,
                    text: "Search Music",
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.timer,
                    text: "Sleep Timer",
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.settings,
                    text: "Settings",
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.contact_page,
                    text: "About",
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.privacy_tip,
                    text: "Privacy Policy",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 180,
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
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Icon(
                  Icons.music_note,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "My Music",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                "Feel the rhythm 🎵",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(
          text,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
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
