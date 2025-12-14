import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:moz_updated_version/screens/ONLINE/home_screen/presentation/services/drawer_service.dart';
import 'package:moz_updated_version/screens/ONLINE/search_screen/presentation/ui/search_screen_on.dart';
import 'package:moz_updated_version/screens/song_list_screen/presentation/widgets/buttons/theme_change_button.dart';
import 'package:moz_updated_version/services/core/app_services.dart';

class CustomSilverAppBar extends StatelessWidget {
  const CustomSilverAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return SliverAppBar(
      automaticallyImplyLeading: false,
      expandedHeight: size.height * .31,
      pinned: true,
      elevation: 0,
      stretch: false,

      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final double top = constraints.biggest.height;
          final double collapsedHeight =
              MediaQuery.of(context).padding.top + kToolbarHeight;
          final bool isCollapsed = top <= collapsedHeight + 15;

          return FlexibleSpaceBar(
            centerTitle: false,
            titlePadding: const EdgeInsets.only(left: 20, bottom: 14),
            title: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: isCollapsed ? 1.0 : 0.0,
              child: _collapsedWidget(context),
            ),

            background: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        lighten(Theme.of(context).primaryColor, 0.12),
                        Theme.of(context).primaryColor,
                        darken(Theme.of(context).primaryColor, 0.25),
                        Colors.black,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),

                _orb(
                  top: -60,
                  right: -40,
                  size: 200,
                  color: Colors.purpleAccent,
                ),
                _orb(
                  bottom: -50,
                  left: -50,
                  size: 180,
                  color: Colors.pinkAccent,
                ),

                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        stops: const [0.0, 0.4, 1.0],
                        colors: [
                          Theme.of(
                            context,
                          ).scaffoldBackgroundColor.withOpacity(1.0),
                          Theme.of(
                            context,
                          ).scaffoldBackgroundColor.withOpacity(0.6),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                if (!isCollapsed)
                  Positioned(
                    left: 10,
                    right: 20,
                    bottom: 10,
                    top: size.height * .08,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _gradientText("Moz Music,", 32),
                        _gradientText("Unlimited Vibes", 32),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.audiotrack_rounded,
                              size: 16,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "Stream millions of songs online",
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        _premiumSearchBar(context),
                      ],
                    ),
                  ),

                Positioned(
                  top: 30,
                  left: 30,
                  child: Icon(
                    Icons.music_note_rounded,
                    size: 40,
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                Positioned(
                  top: 80,
                  right: 60,
                  child: Icon(
                    Icons.music_note_rounded,
                    size: 30,
                    color: Colors.white.withValues(alpha: 0.10),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

Widget _orb({
  double? top,
  double? bottom,
  double? left,
  double? right,
  required double size,
  required Color color,
}) {
  return Positioned(
    top: top,
    bottom: bottom,
    left: left,
    right: right,
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: 0.45),
            color.withValues(alpha: 0.25),
            Colors.transparent,
          ],
        ),
      ),
    ),
  );
}

Widget _premiumSearchBar(BuildContext context) {
  return GestureDetector(
    behavior: HitTestBehavior.opaque,

    onTap: () {
      log("Tapped");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => OnlineSearchScreen()),
      );
    },
    child: Container(
      width: MediaQuery.sizeOf(context).width - 40,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white.withValues(alpha: 0.08),
        border: Border.all(color: Theme.of(context).cardColor, width: 1),
      ),
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: Colors.white.withValues(alpha: 0.85),
            size: 26,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Search songs, artists, albums",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65),
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _collapsedWidget(BuildContext context) {
  return Row(
    children: [
      IconButton(
        onPressed: () {
          DrawerService.openDrawer();
          log("DRawer open tapped");
        },
        icon: Icon(Icons.menu_rounded),
      ),
      const SizedBox(width: 10),
      const Text("Moz MUSIC"),
      const Spacer(),
      IconButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => OnlineSearchScreen()),
          );
        },
        icon: Icon(Icons.search_rounded, size: 22),
      ),

      const SizedBox(width: 12),
    ],
  );
}

Widget _gradientText(String text, double size) {
  return Text(
    text,
    style: TextStyle(
      fontSize: size,
      fontWeight: FontWeight.w900,
      height: 1.1,
      letterSpacing: 0.5,
      color: Colors.white,
    ),
  );
}

Color darken(Color c, double amount) {
  final hsl = HSLColor.fromColor(c);
  return hsl.withLightness((hsl.lightness - amount).clamp(0, 1)).toColor();
}

Color lighten(Color c, double amount) {
  final hsl = HSLColor.fromColor(c);
  return hsl.withLightness((hsl.lightness + amount).clamp(0, 1)).toColor();
}
