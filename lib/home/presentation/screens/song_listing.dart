
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:moz_updated_version/home/presentation/bloc/audio_bloc.dart';
import 'package:moz_updated_version/home/presentation/widgets/custom_drawer.dart';
import 'package:moz_updated_version/widgets/song_list_tile.dart';

class SongListScreen extends StatefulWidget {
  const SongListScreen({super.key});

  @override
  State<SongListScreen> createState() => _SongListScreenState();
}

class _SongListScreenState extends State<SongListScreen>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return PopScope(
      canPop: false,
      child: Scaffold(
        key: scaffoldKey,
        drawer: drawerWidget(context: context, scaffoldKey: scaffoldKey),
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: SafeArea(
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                surfaceTintColor: Colors.transparent,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarColor: Theme.of(context).scaffoldBackgroundColor,
                  systemNavigationBarColor: Theme.of(
                    context,
                  ).scaffoldBackgroundColor,
                ),
                centerTitle: true,
                shadowColor: Theme.of(context).scaffoldBackgroundColor,
                elevation: 1,
                expandedHeight: MediaQuery.of(context).size.height * 0.17,
                flexibleSpace: FlexibleSpaceBar(
                  title: Padding(
                    padding: EdgeInsets.only(
                      left: 0,
                      top: MediaQuery.of(context).size.height * 0.01,
                      right: MediaQuery.of(context).size.width * 0.07,
                    ),
                    child: Text(
                      "Moz MUSIC",
                      style: TextStyle(
                        fontFamily: 'rounder',
                        fontWeight: FontWeight.w500,
                        fontSize: MediaQuery.of(context).size.width * 0.06,
                        color: Theme.of(context).disabledColor,
                        letterSpacing: .1,
                      ),
                    ),
                  ),
                ),
                leading: IconButton(
                  onPressed: () {
                    scaffoldKey.currentState?.openDrawer();
                  },
                  icon: Transform.scale(
                    scale: MediaQuery.of(context).size.width * 0.004,
                    // child: SvgPicture.asset(
                    //   GetAsset.menu,
                    //   colorFilter: ColorFilter.mode(
                    //     Theme.of(context).cardColor,
                    //     BlendMode.srcIn,
                    //   ),
                    // ),
                    child: Icon(Icons.menu),
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () {
                      // Navigator.push(
                      //   context,
                      //   SearchAnimationNavigation(const SearchPage()),
                      // );
                    },
                    icon: Transform.scale(
                      scale: MediaQuery.of(context).size.width * 0.003,
                      // child: SvgPicture.asset(
                      //   GetAsset.search,
                      //   colorFilter: ColorFilter.mode(
                      //     Theme.of(context).cardColor,
                      //     BlendMode.srcIn,
                      //   ),
                      // ),
                      child: Icon(Icons.search),
                    ),
                    splashColor: Colors.transparent,
                  ),
                  // if (removeSongList.isSelect)
                  //   IconButton.filled(
                  //     style: IconButton.styleFrom(
                  //         backgroundColor: Colors.red[300]),
                  //     onPressed: () {
                  //       removeSongList.setValue = false;
                  //       setState(() {
                  //         selectedSongs.clear();
                  //       });
                  //     },
                  //     icon: const Icon(
                  //       Icons.clear,
                  //       color: Colors.white,
                  //     ),
                  //   ),
                  PopupMenuButton<String>(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    icon: Icon(
                      Icons.more_vert_rounded,
                      color: Theme.of(context).cardColor,
                    ),
                    color: Theme.of(context).splashColor,
                    onSelected: (value) {
                      if (value == 'sort') {
                        // showDialog<void>(
                        //   context: context,
                        //   builder: (BuildContext context) {
                        //     return SortOptionDialog(
                        //       selectedOption: homepageState.defaultSort,
                        //       onSelected: (value) {
                        //         homepageState.toggleValue(value);
                        //       },
                        //     );
                        //   },
                        // );
                      } else if (value == 'select') {
                        // homepageState.resetRemovedSongs();
                        // removeSongList.setValue = true;
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            value: 'sort',
                            child: ListTile(
                              leading: Icon(
                                Icons.sort,
                                color: Theme.of(context).cardColor,
                              ),
                              title: Text(
                                'Sort',
                                style: TextStyle(
                                  color: Theme.of(context).cardColor,
                                ),
                              ),
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'select',
                            child: ListTile(
                              leading: Icon(
                                Icons.select_all,
                                color: Theme.of(context).cardColor,
                              ),
                              title: Text(
                                'select Songs',
                                style: TextStyle(
                                  color: Theme.of(context).cardColor,
                                ),
                              ),
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                  ),
                ],
                pinned: true,
              ),
            ],
            body: BlocBuilder<AudioBloc, AudioState>(
              builder: (context, state) {
                if (state is SongsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is AudioError) {
                  return Center(child: Text("Error: ${state.message}"));
                }
                if (state is SongsLoaded) {
                  final songs = state.songs;
                  return AnimationLimiter(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      itemCount: songs.length,
                      itemBuilder: (context, index) {
                        final song = songs[index];
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
                                index: index,
                                disableOnTap: true,
                                onTap: () async {
                                  context.read<AudioBloc>().add(
                                    PlaySong(song, songs),
                                  );
                                 

                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (context) => NowPlayingScreen(),
                                  //   ),
                                  // );
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
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
