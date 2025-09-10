import 'package:flutter/material.dart';
import 'package:moz_updated_version/core/animations/page_animations/up_transition.dart';
import 'package:moz_updated_version/screens/favorite_screen/presentation/ui/favorite_screen.dart';
import 'package:moz_updated_version/screens/mostly_played/presentation/ui/mostly_played_Screen.dart';
import 'package:moz_updated_version/screens/now_playing/presentation/ui/now_playing_screen.dart';
import 'package:moz_updated_version/screens/song_list_screen/presentation/ui/all_songs.dart';
import 'package:moz_updated_version/screens/song_list_screen/presentation/widgets/custom_drawer.dart';
import 'package:moz_updated_version/screens/mini_player/presentation/ui/mini_player.dart';
import 'package:moz_updated_version/screens/playlist_screen/presentation/ui/playlist_screen.dart';
import 'package:moz_updated_version/screens/recently_played/presentation/ui/recently_palyed.dart';

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
                if (value == 'menu') {
                  // TODO: sort logic
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'menu',
                  child: ListTile(
                    leading: Icon(Icons.menu),
                    title: Text('menu'),
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

        bottomNavigationBar: const MiniPlayer(),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
