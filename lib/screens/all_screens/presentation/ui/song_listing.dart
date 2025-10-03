import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/screens/album_screen/presentation/ui/album_screen.dart';
import 'package:moz_updated_version/screens/all_screens/presentation/cubit/tab_cubit.dart';
import 'package:moz_updated_version/screens/all_screens/presentation/cubit/tab_confiq_cubit.dart';
import 'package:moz_updated_version/screens/artists_screen/presentation/ui/artists_screen.dart';
import 'package:moz_updated_version/screens/favorite_screen/presentation/ui/favorite_screen.dart';
import 'package:moz_updated_version/screens/home_screen/presentation/ui/home_screen.dart';
import 'package:moz_updated_version/screens/mostly_played/presentation/ui/mostly_played_Screen.dart';
import 'package:moz_updated_version/screens/song_list_screen/presentation/cubit/allsongs_cubit.dart';
import 'package:moz_updated_version/screens/song_list_screen/presentation/ui/all_songs.dart';
import 'package:moz_updated_version/screens/song_list_screen/presentation/widgets/bottom_nav.dart';
import 'package:moz_updated_version/screens/song_list_screen/presentation/widgets/custom_drawer.dart';
import 'package:moz_updated_version/screens/playlist_screen/presentation/ui/playlist_screen.dart';
import 'package:moz_updated_version/screens/recently_played/presentation/ui/recently_palyed.dart';
import 'package:moz_updated_version/services/navigation_service.dart';
import 'package:moz_updated_version/services/service_locator.dart';
import 'package:moz_updated_version/widgets/custom_menu/custom_popmenu.dart';
import 'package:moz_updated_version/screens/search_screen/presentation/ui/search_screen.dart';
import 'package:moz_updated_version/screens/settings/screens/setting_screen/settings_page.dart';
import 'package:moz_updated_version/screens/all_screens/presentation/model/tab_model.dart';

class SongListScreen extends StatefulWidget {
  const SongListScreen({super.key});

  @override
  State<SongListScreen> createState() => _SongListScreenState();
}

class _SongListScreenState extends State<SongListScreen>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;
  List<TabModel> enabledTabs = [];
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();

    final tabConfigCubit = context.read<TabConfigCubit>();

    enabledTabs = tabConfigCubit.state.where((t) => t.enabled).toList();
    currentIndex = _getInitialIndex(tabConfigCubit);

    _tabController = TabController(
      length: enabledTabs.length,
      vsync: this,
      initialIndex: currentIndex,
    );

    final tabCubit = context.read<TabCubit>();
    tabCubit.stream.listen((idx) {
      if (idx < _tabController.length && idx != _tabController.index) {
        _tabController.animateTo(idx);
      }
    });

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        context.read<TabCubit>().changeTab(_tabController.index);
      }
    });

    tabConfigCubit.stream.listen((tabs) {
      final newEnabled = tabs.where((t) => t.enabled).toList();

      bool changed =
          newEnabled.length != enabledTabs.length ||
          !List.generate(
            newEnabled.length,
            (i) => newEnabled[i].title == enabledTabs[i].title,
          ).every((e) => e);

      if (changed) {
        setState(() {
          enabledTabs = newEnabled;
          currentIndex = _getInitialIndex(tabConfigCubit);
          _tabController.dispose();
          _tabController = TabController(
            length: enabledTabs.length,
            vsync: this,
            initialIndex: currentIndex,
          );
          _tabController.addListener(() {
            if (!_tabController.indexIsChanging) {
              context.read<TabCubit>().changeTab(_tabController.index);
            }
          });
        });
      }
    });
  }

  int _getInitialIndex(TabConfigCubit cubit) {
    String defaultTabTitle = cubit.getDefaultTab(enabledTabs);
    int idx = enabledTabs.indexWhere((t) => t.title == defaultTabTitle);
    if (idx != -1) return idx;
    return 0;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _getTabView(String title) {
    switch (title) {
      case "Mostly Played":
        return MostlyPlayedScreen();
      case "Recently Played":
        return RecentlyPlayedScreen();
      case "Home":
        return HomeScreen();
      case "All Songs":
        return AllSongScreen();
      case "Albums":
        return AlbumScreen();
      case "Artists":
        return ArtistScreen();
      case "Favorites":
        return FavoritesScreen();
      case "Playlists":
        return PlaylistScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final tabWidgets = enabledTabs.map((t) => Tab(text: t.title)).toList();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final cubit = context.read<AllSongsCubit>();
        final state = cubit.state;
        if (state is AllSongsLoaded && state.isSelecting) {
          cubit.disableSelectionMode();
        } else {
          final idx = context.read<TabCubit>().state;
          if (idx != 2) {
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
          title: const Text("Moz MUSIC"),
          centerTitle: false,
          elevation: 2,
          leading: IconButton(
            onPressed: () => scaffoldKey.currentState?.openDrawer(),
            icon: const Icon(Icons.menu),
          ),
          actions: [
            IconButton(
              onPressed: () => sl<NavigationService>().navigateTo(
                SearchSongsScreen(),
                animation: NavigationAnimation.slide,
                slideAxis: AxisDirection.left,
              ),
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
                  final cubit = context.read<AllSongsCubit>();
                  cubit.goBack
                      ? cubit.enableSelectionMode()
                      : cubit.disableSelectionMode();
                } else if (value == "settings") {
                  sl<NavigationService>().navigateTo(SettingsScreen());
                }
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorAnimation: TabIndicatorAnimation.elastic,
            tabAlignment: TabAlignment.center,
            tabs: tabWidgets,
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: enabledTabs.map((t) => _getTabView(t.title)).toList(),
        ),
        bottomNavigationBar: BottomNavigationWidgetForAllSongs(),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
