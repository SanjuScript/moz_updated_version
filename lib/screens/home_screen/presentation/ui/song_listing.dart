import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:moz_updated_version/screens/home_screen/presentation/bloc/audio_bloc.dart';
import 'package:moz_updated_version/screens/home_screen/presentation/widgets/custom_drawer.dart';
import 'package:moz_updated_version/screens/mini_player/presentation/ui/mini_player.dart';
import 'package:moz_updated_version/screens/now_playing/presentation/ui/now_playing_screen.dart';
import 'package:moz_updated_version/screens/playlist_screen/presentation/ui/playlist_screen.dart';
import 'package:moz_updated_version/widgets/song_list_tile.dart';

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
        drawer: drawerWidget(context: context, scaffoldKey: scaffoldKey),
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
                // TODO: implement search navigation
              },
              icon: const Icon(Icons.search),
            ),
            PopupMenuButton<String>(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              icon: const Icon(Icons.more_vert_rounded),
              onSelected: (value) {
                if (value == 'sort') {
                  // TODO: sort logic
                } else if (value == 'select') {
                  // TODO: select songs logic
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'sort',
                  child: ListTile(
                    leading: Icon(Icons.sort),
                    title: Text('Sort'),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'select',
                  child: ListTile(
                    leading: Icon(Icons.select_all),
                    title: Text('Select Songs'),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: Colors.redAccent,
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
          children: const [
            Center(child: Text("Home Section")), // Replace with actual widget
            Center(
              child: Text("Recently Played Section"),
            ), // Replace with actual widget
            SongView(), // All Songs
            Center(
              child: Text("Favorites Section"),
            ), // Replace with actual widget
            PlaylistScreen(), // Playlists
            Center(
              child: Text("Mostly Played Section"),
            ), // Replace with actual widget
          ],
        ),

        bottomNavigationBar: const MiniPlayer(),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class SongView extends StatelessWidget {
  const SongView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioBloc, AudioState>(
      builder: (context, state) {
        if (state is SongsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AudioError) {
          return Center(child: Text("Error: ${state.message}"));
        }
        if (state is SongsLoaded) {
          final songs = state.songs;
          final currentSong = state.currentSong;
          return AnimationLimiter(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 30),
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              itemCount: songs.length,
              itemBuilder: (context, index) {
                final song = songs[index];
                final isPlaying = currentSong?.id == song.id;
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: Duration(milliseconds: 400),
                  delay: const Duration(milliseconds: 100),
                  child: SlideAnimation(
                    duration: const Duration(milliseconds: 2500),
                    curve: Curves.fastLinearToSlowEaseIn,
                    child: FadeInAnimation(
                      duration: const Duration(milliseconds: 2500),
                      curve: Curves.fastLinearToSlowEaseIn,
                      child: CustomSongTile(
                        song: song,
                        disableOnTap: true,
                        onTap: () async {
                          context.read<AudioBloc>().add(PlaySong(song, songs));

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NowPlayingScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }
        return const Center(child: Text("No songs found"));
      },
    );
  }
}
