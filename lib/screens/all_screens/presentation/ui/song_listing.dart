import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/screens/album_screen/presentation/ui/album_screen.dart';
import 'package:moz_updated_version/screens/all_screens/presentation/cubit/tab_cubit.dart';
import 'package:moz_updated_version/screens/favorite_screen/presentation/ui/favorite_screen.dart';
import 'package:moz_updated_version/screens/home_screen/presentation/ui/home_screen.dart';
import 'package:moz_updated_version/screens/mostly_played/presentation/ui/mostly_played_Screen.dart';
import 'package:moz_updated_version/screens/search_screen/presentation/ui/search_screen.dart';
import 'package:moz_updated_version/screens/settings/screens/setting_screen/settings_page.dart';
import 'package:moz_updated_version/screens/song_list_screen/presentation/cubit/allsongs_cubit.dart';
import 'package:moz_updated_version/screens/song_list_screen/presentation/ui/all_songs.dart';
import 'package:moz_updated_version/screens/song_list_screen/presentation/widgets/bottom_nav.dart';
import 'package:moz_updated_version/screens/song_list_screen/presentation/widgets/custom_drawer.dart';
import 'package:moz_updated_version/screens/playlist_screen/presentation/ui/playlist_screen.dart';
import 'package:moz_updated_version/screens/recently_played/presentation/ui/recently_palyed.dart';
import 'package:moz_updated_version/services/navigation_service.dart';
import 'package:moz_updated_version/services/service_locator.dart';
import 'package:moz_updated_version/widgets/custom_menu/custom_popmenu.dart';

class SongListScreen extends StatefulWidget {
  const SongListScreen({super.key});

  @override
  State<SongListScreen> createState() => _SongListScreenState();
}

class _SongListScreenState extends State<SongListScreen>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;

  final tabs = const [
    Tab(text: "Mostly Played"),
    Tab(text: "Recently Played"),
    Tab(text: "Home"),
    Tab(text: "All Songs"),
    Tab(text: "Albums"),
    Tab(text: "Favorites"),
    Tab(text: "Playlists"),
  ];

  final tabViews = [
    MostlyPlayedScreen(),
    RecentlyPlayedScreen(),
    HomeScreen(),
    AllSongScreen(),
    AlbumScreen(),
    FavoritesScreen(),
    PlaylistScreen(),
  ];

  @override
  void initState() {
    super.initState();
    final initialIndex = context.read<TabCubit>().state;
    _tabController = TabController(
      length: 7,
      vsync: this,
      initialIndex: initialIndex,
    );

    context.read<TabCubit>().stream.listen((index) {
      if (_tabController.index != index) {
        _tabController.animateTo(index);
      }
    });

    _tabController.addListener(() {
      if (_tabController.indexIsChanging == false) {
        context.read<TabCubit>().changeTab(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        final cubit = context.read<AllSongsCubit>();
        final state = cubit.state;

        if (state is AllSongsLoaded && state.isSelecting) {
          cubit.disableSelectionMode();
        } else {
          final currentIndex = context.read<TabCubit>().state;
          if (currentIndex != 2) {
            context.read<TabCubit>().changeTab(2);
          } else {
            SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
        key: scaffoldKey,
        drawer: AppDrawer(scaffoldKey: scaffoldKey),
        extendBody: true,
        extendBodyBehindAppBar: false,

        appBar: AppBar(
          titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(),
          title: const Text("Moz MUSIC"),
          centerTitle: false,
          elevation: 2,
          leading: IconButton(
            onPressed: () {
              scaffoldKey.currentState?.openDrawer();
            },
            icon: const Icon(Icons.menu),
          ),
          actions: [
            IconButton(
              onPressed: () {
                sl<NavigationService>().navigateTo(
                  SearchSongsScreen(),
                  animation: NavigationAnimation.slide,
                  slideAxis: AxisDirection.left,
                );
              },
              icon: const Icon(Icons.search),
            ),
            GlassPopMenuButton(
              icon: const Icon(Icons.more_vert_rounded),
              items: [
                GlassPopMenuEntry(
                  value: 'select',
                  child: ListTile(
                    leading: const Icon(Icons.domain_verification),
                    title: const Text('Select'),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                GlassPopMenuEntry(
                  value: 'settings',
                  child: ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Settings'),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'select') {
                  if (context.read<AllSongsCubit>().goBack) {
                    context.read<AllSongsCubit>().enableSelectionMode();
                  } else {
                    context.read<AllSongsCubit>().disableSelectionMode();
                  }
                } else if (value == "settings") {
                  sl<NavigationService>().navigateTo(SettingsScreen());
                }
              },
            ),
          ],
          bottom: TabBar(
            tabAlignment: TabAlignment.center,
            indicatorAnimation: TabIndicatorAnimation.elastic,
            controller: _tabController,
            isScrollable: true,
            tabs: tabs,
          ),
        ),

        body: TabBarView(controller: _tabController, children: tabViews),

        bottomNavigationBar: BottomNavigationWidgetForAllSongs(),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

