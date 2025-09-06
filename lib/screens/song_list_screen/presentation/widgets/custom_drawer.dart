import 'package:flutter/material.dart';
import 'package:moz_updated_version/screens/song_list_screen/presentation/widgets/buttons/theme_change_button.dart';
import 'package:provider/provider.dart';


Widget drawerWidget(
    {required BuildContext context,
    required GlobalKey<ScaffoldState> scaffoldKey}) {
  return Drawer(
    child: Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          Container(
            height: 150,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
             
            ),
            
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                listDrawerItems(
                    context: context,
                    leadingIcon: Icons.color_lens_outlined,
                    onTap: () {},
                    text: 'Theme Mode',
                    isTrailingVisible: true),
                listDrawerItems(
                    context: context,
                    leadingIcon: Icons.playlist_play_rounded,
                    onTap: () {
                      // navigation(const PlaylistScreen(), context, scaffoldKey);
                    },
                    text: 'Play List'),
                listDrawerItems(
                    context: context,
                    leadingIcon: Icons.favorite,
                    onTap: () {
                      // navigation(const FavoriteScreen(), context, scaffoldKey);
                    },
                    text: 'Favorites'),
                listDrawerItems(
                    context: context,
                    leadingIcon: Icons.search,
                    onTap: () {
                      // navigation(const SearchPage(), context, scaffoldKey);
                    },
                    text: 'Search Music '),
                listDrawerItems(
                    context: context,
                    leadingIcon: Icons.timer,
                    onTap: () {
                      // sleepTimerBottomModalSheet(context);
                    },
                    text: 'Sleep Timer'),
                listDrawerItems(
                    context: context,
                    leadingIcon: Icons.settings,
                    onTap: () {
                      // navigation(const Settings(), context, scaffoldKey);
                    },
                    text: 'Settings'),
                listDrawerItems(
                    context: context,
                    leadingIcon: Icons.contact_page,
                    onTap: () {
                      // navigation(const AboutPage(), context, scaffoldKey);
                    },
                    text: 'About'),
                listDrawerItems(
                    context: context,
                    leadingIcon: Icons.settings,
                    onTap: () {
                      // navigation(
                      //     const PrivacyPolicyPage(), context, scaffoldKey);
                    },
                    text: 'Privacy Policy'),

                    ChangeThemeButtonWidget()
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget themeSetter({
  required BuildContext context,
}) {
  return Container(
    height: 100,
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20), color: Colors.red),
  );
}

Widget listDrawerItems(
    {required BuildContext context,
    required IconData leadingIcon,
    required void Function() onTap,
    required String text,
    Widget? trailingIcon,
    bool isTrailingVisible = false}) {
  return ListTile(
    onTap: onTap,
    leading: Icon(
      leadingIcon,
    ),
    title: Text(
      text,
      
    ),
    // trailing: isTrailingVisible ? ChangeThemeButtonWidget() : trailingIcon,
    trailing: isTrailingVisible ? trailingIcon: trailingIcon,
  );
}

void navigation(Widget child, BuildContext context,
    GlobalKey<ScaffoldState> scaffoldKey) async {
  // await Navigator.push(
  //   context,
  //   SearchAnimationNavigation(child),
  // );
  scaffoldKey.currentState?.closeDrawer();
}
