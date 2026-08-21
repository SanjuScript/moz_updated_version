import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/screens/ONLINE/bottom_nav/presentation/cubit/online_tab_cubit.dart';
import 'package:moz_updated_version/screens/ONLINE/home_screen/presentation/services/drawer_service.dart';
import 'package:moz_updated_version/screens/ONLINE/home_screen/presentation/widgets/update_available_icon.dart';
import 'package:moz_updated_version/screens/ONLINE/search_screen/presentation/ui/search_screen_on.dart';

class CustomSilverAppBar extends StatelessWidget {
  const CustomSilverAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final bool isDesktop = size.width > 800;

    final double mobileHeight = math.max(size.height * 0.25, 240.0);
    final double appBarHeight = isDesktop ? 300 : mobileHeight;

    return SliverAppBar(
      automaticallyImplyLeading: false,
      expandedHeight: appBarHeight,
      pinned: true,
      elevation: 0,
      stretch: false,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final double top = constraints.biggest.height;
          final double collapsedHeight =
              MediaQuery.of(context).padding.top + kToolbarHeight;
          final bool isCollapsed = top <= collapsedHeight;

          return FlexibleSpaceBar(
            centerTitle: false,
            titlePadding: isDesktop
                ? const EdgeInsets.only(left: 40, bottom: 18)
                : const EdgeInsets.only(left: 20, bottom: 14),
            title: Visibility(
              visible: isCollapsed,
              child: _collapsedWidget(context, isDesktop),
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
                  right: isDesktop ? -100 : -40,
                  size: isDesktop ? 400 : 200,
                  color: Colors.purpleAccent,
                ),
                _orb(
                  bottom: -50,
                  left: isDesktop ? -100 : -50,
                  size: isDesktop ? 350 : 180,
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
                    left: isDesktop ? 50 : 10,
                    right: isDesktop ? 50 : 20,
                    bottom: isDesktop ? 40 : 15,
                    child: isDesktop
                        ? _buildDesktopContent(context)
                        : _buildMobileContent(context),
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

  Widget _buildMobileContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _gradientText("Moz Music,", 32),
        _gradientText("Unlimited Vibes", 32),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.audiotrack_rounded,
              size: 16,
              color: Colors.white.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 6),
            Expanded(
              // Prevent text overflow horizontally
              child: Text(
                "Stream millions of songs online",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _premiumSearchBar(context, isDesktop: false),
      ],
    );
  }

  Widget _buildDesktopContent(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _gradientText("Moz Music,", 48),
              _gradientText("Unlimited Vibes", 48),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.audiotrack_rounded,
                    size: 20,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Stream millions of songs online",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: _premiumSearchBar(context, isDesktop: true),
        ),
      ],
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

Widget _premiumSearchBar(BuildContext context, {required bool isDesktop}) {
  final size = MediaQuery.sizeOf(context);
  final double width = isDesktop ? 400 : size.width - 40;

  return GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () {
      context.read<OnlineTabCubit>().changeTab(1);
    },
    child: Container(
      width: width,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white.withValues(alpha: 0.08),
        border: Border.all(color: Theme.of(context).cardColor, width: 1),
      ),
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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

Widget _collapsedWidget(BuildContext context, bool isDesktop) {
  return Row(
    children: [
      IconButton(
        onPressed: () {
          DrawerService.openDrawer();
          log("Drawer open tapped");
        },
        icon: const Icon(Icons.menu_rounded),
      ),
      const SizedBox(width: 10),
      const Text("Moz MUSIC"),
      const Spacer(),
      IconButton(
        onPressed: () {
          context.read<OnlineTabCubit>().changeTab(1);
        },
        icon: const Icon(Icons.search_rounded, size: 22),
      ),
      UpdateAvailableIcon(),
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
