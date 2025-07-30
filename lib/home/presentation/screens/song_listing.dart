import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:moz_updated_version/home/presentation/provider/home_provider.dart';
import 'package:moz_updated_version/home/presentation/widgets/audio_artwork_sep.dart';
import 'package:moz_updated_version/home/presentation/widgets/custom_drawer.dart';
import 'package:moz_updated_version/main.dart';
import 'package:moz_updated_version/services/audio_handler.dart';
import 'package:moz_updated_version/widgets/song_list_tile.dart';
import 'package:provider/provider.dart';
import 'package:audio_service/audio_service.dart';

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
    final songProvider = Provider.of<SongProvider>(context);

    return PopScope(
      canPop: false,
      child: Scaffold(
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
            body: FutureBuilder(
              future: songProvider.loadSongs(),
              builder: (context, snapshot) {
                final songs = songProvider.songs;

                return AnimationLimiter(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    itemCount: songs.length,
                    itemBuilder: (context, index) {
                      final song = songs[index];
                      return AnimationConfiguration.staggeredList(
                        position: index,
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
                                await audioHandler.setPlaylist(songs);
                                await audioHandler.playFromIndex(index);
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

class NowPlayingCarousel extends StatefulWidget {
  final List<MediaItem> queue;
  final int currentIndex;
  final void Function(int index) onPageChanged;

  const NowPlayingCarousel({
    super.key,
    required this.queue,
    required this.currentIndex,
    required this.onPageChanged,
  });

  @override
  State<NowPlayingCarousel> createState() => _NowPlayingCarouselState();
}

class _NowPlayingCarouselState extends State<NowPlayingCarousel> {
  late CarouselSliderController _carouselController;

  @override
  void initState() {
    super.initState();
    _carouselController = CarouselSliderController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carouselController.jumpToPage(widget.currentIndex);
    });
  }

  @override
  void didUpdateWidget(covariant NowPlayingCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _carouselController.animateToPage(
        widget.currentIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      carouselController: _carouselController,
      itemCount: widget.queue.length,
      itemBuilder: (context, index, realIdx) {
        final mediaItem = widget.queue[index];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Hero(
            tag: 'artwork_${mediaItem.id}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: mediaItem.artUri != null
                  ? AudioArtworkDefiner(
                      id: int.tryParse(mediaItem.id.split('/').last) ?? 0,
                    )
                  : Image.asset(
                      'assets/images/placeholder.jpg',
                      fit: BoxFit.cover,
                    ),
            ),
          ),
        );
      },
      options: CarouselOptions(
        height: 350,
        enlargeCenterPage: true,
        viewportFraction: 0.8, // 10–15% of next/prev visible
        onPageChanged: (index, reason) {
          widget.onPageChanged(index);
        },
      ),
    );
  }
}

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final audiohandler = audioHandler;
    final queue = audioHandler.queue.value;
    final currentMedia = audioHandler.mediaItem.value;
    final currentIndex = queue.indexWhere((m) => m.id == currentMedia?.id);
    final extractedId = currentMedia!.id.split('/').last;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            NowPlayingCarousel(
              queue: queue,
              currentIndex: currentIndex >= 0 ? currentIndex : 0,
              onPageChanged: (index) {
                final item = queue[index];
                audioHandler.skipToQueueItem(index);
                audioHandler.play();
              },
            ),
            const SizedBox(height: 30),
            Text(
              currentMedia?.title ?? '',
              style: const TextStyle(color: Colors.white, fontSize: 22),
              textAlign: TextAlign.center,
            ),
            Text(
              currentMedia?.artist ?? '',
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const Spacer(),
            // PlaybackControls(), // Your custom widget for play/pause, next, prev
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
