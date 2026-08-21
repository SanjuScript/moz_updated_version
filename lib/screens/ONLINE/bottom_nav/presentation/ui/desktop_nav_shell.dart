import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:moz_updated_version/screens/mini_player/presentation/ui/mini_player.dart';
import 'dart:io';

class DesktopNavShell extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;
  final Widget child;

  const DesktopNavShell({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sidebarColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5);
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                // Sidebar Navigation
                Container(
                  width: 220,
                  color: sidebarColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Drag Area for Sidebar (over the traffic lights)
                      if (Platform.isMacOS || Platform.isLinux)
                        const SizedBox(
                          height: 32,
                          child: DragToMoveArea(
                            child: SizedBox.expand(),
                          ),
                        ),
                      // Top padding for visual balance
                      const SizedBox(height: 16),
                      Expanded(
                        child: NavigationRail(
                          extended: true,
                          minExtendedWidth: 220,
                          backgroundColor: Colors.transparent,
                          selectedIndex: currentIndex,
                          onDestinationSelected: onTabSelected,
                          useIndicator: true,
                          indicatorColor: primaryColor.withValues(alpha: 0.15),
                          indicatorShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          selectedLabelTextStyle: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          unselectedLabelTextStyle: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black87,
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                          selectedIconTheme: IconThemeData(color: primaryColor, size: 22),
                          unselectedIconTheme: IconThemeData(
                            color: isDark ? Colors.white70 : Colors.black87,
                            size: 22,
                          ),
                          destinations: const [
                            NavigationRailDestination(
                              icon: Icon(Icons.home_outlined),
                              selectedIcon: Icon(Icons.home),
                              label: Text('Home'),
                            ),
                            NavigationRailDestination(
                              icon: Icon(Icons.search_outlined),
                              selectedIcon: Icon(Icons.search),
                              label: Text('Search'),
                            ),
                            NavigationRailDestination(
                              icon: Icon(Icons.favorite_border),
                              selectedIcon: Icon(Icons.favorite),
                              label: Text('Favorites'),
                            ),
                            NavigationRailDestination(
                              icon: Icon(Icons.person_outline),
                              selectedIcon: Icon(Icons.person),
                              label: Text('Profile'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Subtle divider
                VerticalDivider(
                  thickness: 1,
                  width: 1,
                  color: isDark ? Colors.white10 : Colors.black12,
                ),
                // Main Content Area
                Expanded(
                  child: Column(
                    children: [
                      // Top Drag Area for Main Content
                      if (Platform.isMacOS || Platform.isLinux)
                        const SizedBox(
                          height: 32,
                          child: DragToMoveArea(
                            child: SizedBox.expand(),
                          ),
                        ),
                      Expanded(child: child),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // MiniPlayer at the very bottom, spanning full width
          const MiniPlayer(),
        ],
      ),
    );
  }
}
