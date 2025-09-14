import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/screens/favorite_screen/presentation/ui/favorite_screen.dart';
import 'package:moz_updated_version/screens/mostly_played/presentation/ui/mostly_played_Screen.dart';
import 'package:moz_updated_version/screens/song_list_screen/presentation/cubit/allsongs_cubit.dart';
import 'package:moz_updated_version/screens/song_list_screen/presentation/ui/all_songs.dart';
import 'package:moz_updated_version/screens/song_list_screen/presentation/widgets/bottom_nav.dart';
import 'package:moz_updated_version/screens/song_list_screen/presentation/widgets/custom_drawer.dart';
import 'package:moz_updated_version/screens/mini_player/presentation/ui/mini_player.dart';
import 'package:moz_updated_version/screens/playlist_screen/presentation/ui/playlist_screen.dart';
import 'package:moz_updated_version/screens/recently_played/presentation/ui/recently_palyed.dart';
import 'package:moz_updated_version/services/navigation_service.dart';
import 'package:moz_updated_version/services/service_locator.dart';

class SongListScreen extends StatefulWidget {
  const SongListScreen({super.key});

  @override
  State<SongListScreen> createState() => _SongListScreenState();
}

class _SongListScreenState extends State<SongListScreen>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this, initialIndex: 2);
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
          if (_tabController.index != 2) {
            _tabController.animateTo(2);
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
            IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
            PopupMenuButton<String>(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              icon: const Icon(Icons.more_vert_rounded),
              onSelected: (value) {
                if (value == 'select') {
                  if (context.read<AllSongsCubit>().goBack) {
                    context.read<AllSongsCubit>().enableSelectionMode();
                  } else {
                    context.read<AllSongsCubit>().disableSelectionMode();
                  }
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'select',
                  child: ListTile(
                    leading: Icon(Icons.domain_verification),
                    title: Text('select'),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
          bottom: TabBar(
            tabAlignment: TabAlignment.center,
            indicatorAnimation: TabIndicatorAnimation.elastic,
            controller: _tabController,
            isScrollable: true,
            tabs: const [
              Tab(text: "Home"),
              Tab(text: "Recently Played"),
              Tab(text: "All Songs"),
              Tab(text: "Favorites"),
              Tab(text: "Playlists"),
              Tab(text: "Mostly Played"),
            ],
          ),
        ),

        body: TabBarView(
          controller: _tabController,
          children: [
            Center(child: Text("Home Section")),
            RecentlyPlayedScreen(),
            AllSongScreen(),
            FavoritesScreen(),
            PlaylistScreen(),
            MostlyPlayedScreen(),
          ],
        ),

        bottomNavigationBar: BottomNavigationWidgetForAllSongs(),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
