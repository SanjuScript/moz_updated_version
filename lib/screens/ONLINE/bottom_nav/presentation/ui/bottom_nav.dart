import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/screens/ONLINE/bottom_nav/presentation/cubit/online_tab_cubit.dart';
import 'package:moz_updated_version/screens/ONLINE/favorite_screen/presentation/ui/favorite_screen.dart';
import 'package:moz_updated_version/screens/ONLINE/home_screen/presentation/ui/home_page.dart';
import 'package:moz_updated_version/screens/ONLINE/profile_screen/profile_screen.dart';
import 'package:moz_updated_version/screens/ONLINE/search_screen/presentation/ui/search_screen_on.dart';
import 'package:moz_updated_version/screens/mini_player/presentation/ui/mini_player.dart';
import 'package:moz_updated_version/screens/song_list_screen/presentation/widgets/buttons/theme_change_button.dart';

class OnlineBottomNavScreen extends StatefulWidget {
  const OnlineBottomNavScreen({super.key});

  @override
  State<OnlineBottomNavScreen> createState() => _OnlineBottomNavScreenState();
}

class _OnlineBottomNavScreenState extends State<OnlineBottomNavScreen> {
  late final PageController _pageController;

  final List<Widget> _pages = const [
    HomeScreenOn(),
    OnlineSearchScreen(),
    OnlineFavoriteSongsScreen(),
    DummyProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnlineTabCubit, OnlineTabState>(
      builder: (context, state) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            final cubit = context.read<OnlineTabCubit>();
            final index = cubit.state.index;

            if (index != 0) {
              _pageController.animateToPage(
                0,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInCubic,
              );
            } else {
              Navigator.pop(context);
            }
          },
          child: Scaffold(
            body: PageView(
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (index) {
                context.read<OnlineTabCubit>().changeTab(index);
              },
              children: _pages,
            ),
            extendBody: true,
            bottomNavigationBar: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MiniPlayer(),
                BottomNavigationBar(
                  currentIndex: state.index,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: Theme.of(context).primaryColor,
                  onTap: (index) {
                    context.read<OnlineTabCubit>().changeTab(index);
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                    );
                  },
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home_outlined),
                      activeIcon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.search_outlined),
                      activeIcon: Icon(Icons.search),
                      label: 'Search',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.favorite_border),
                      activeIcon: Icon(Icons.favorite),
                      label: 'Favorites',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person),
                      activeIcon: Icon(Icons.person),
                      label: 'Profile',
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
