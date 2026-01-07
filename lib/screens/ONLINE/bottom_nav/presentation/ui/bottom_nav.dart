import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/screens/ONLINE/bottom_nav/presentation/cubit/online_tab_cubit.dart';
import 'package:moz_updated_version/screens/ONLINE/favorite_screen/presentation/ui/favorite_screen.dart';
import 'package:moz_updated_version/screens/ONLINE/home_screen/presentation/ui/home_page.dart';
import 'package:moz_updated_version/screens/ONLINE/profile_screen/profile_screen.dart';
import 'package:moz_updated_version/screens/ONLINE/search_screen/presentation/ui/search_screen_on.dart';
import 'package:moz_updated_version/screens/mini_player/presentation/ui/mini_player.dart';
import 'package:moz_updated_version/services/one_time_dialogue_service.dart';

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
    ProfileStatsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      OneTimeDialog.show(
        context: context,
        dialogId: DialogIds.homeWelcome,
        content: DialogContents.homeWelcome,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    context.read<OnlineTabCubit>().changeTab(index);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnlineTabCubit, OnlineTabState>(
      listenWhen: (prev, curr) => prev.index != curr.index,
      listener: (context, state) {
        // Only animate if the page controller's current page is different
        if (_pageController.hasClients &&
            _pageController.page?.round() != state.index) {
          _pageController.animateToPage(
            state.index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
          );
        }
      },
      child: BlocBuilder<OnlineTabCubit, OnlineTabState>(
        builder: (context, state) {
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) return;

              if (state.index != 0) {
                context.read<OnlineTabCubit>().changeTab(0);
              } else {
                Navigator.pop(context);
              }
            },
            child: Scaffold(
              body: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged, // Add this
                physics: const PageScrollPhysics(), // Change this
                children: _pages,
              ),
              extendBody: true,
              bottomNavigationBar: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const MiniPlayer(),
                  BottomNavigationBar(
                    currentIndex: state.index,
                    type: BottomNavigationBarType.fixed,
                    selectedItemColor: Theme.of(context).primaryColor,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    onTap: (index) {
                      context.read<OnlineTabCubit>().changeTab(index);
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
                        icon: Icon(Icons.person_outline),
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
      ),
    );
  }
}
