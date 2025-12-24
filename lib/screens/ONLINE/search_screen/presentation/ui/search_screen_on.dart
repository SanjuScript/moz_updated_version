import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/core/constants/api.dart';
import 'package:moz_updated_version/core/extensions/song_model_ext.dart';
import 'package:moz_updated_version/core/helper/color_extractor.dart/cubit/artworkcolorextractor_cubit.dart';
import 'package:moz_updated_version/data/model/online_models/oline_album_search_model.dart';
import 'package:moz_updated_version/data/model/online_models/online_song_model.dart';
import 'package:moz_updated_version/screens/ONLINE/album_screen/presentation/cubit/collection_cubit.dart';
import 'package:moz_updated_version/screens/ONLINE/album_screen/presentation/ui/collection_screen.dart';
import 'package:moz_updated_version/screens/ONLINE/favorite_screen/presentation/widgets/empty_view.dart';
import 'package:moz_updated_version/screens/ONLINE/favorite_screen/presentation/widgets/error_view.dart';
import 'package:moz_updated_version/screens/ONLINE/search_screen/presentation/auto_complete_cubit/auto_complete_cubit.dart';
import 'package:moz_updated_version/screens/ONLINE/search_screen/presentation/cubit/jio_saavn_cubit.dart';
import 'package:moz_updated_version/screens/ONLINE/search_screen/presentation/search_history_cubit/search_history_cubit.dart';
import 'package:moz_updated_version/screens/ONLINE/search_screen/presentation/widgets/search_chips.dart';
import 'package:moz_updated_version/screens/ONLINE/search_screen/presentation/widgets/search_history_widget.dart';
import 'package:moz_updated_version/screens/ONLINE/search_screen/presentation/widgets/trending_search_widget.dart';
import 'package:moz_updated_version/services/audio_handler.dart';
import 'package:moz_updated_version/services/core/analytics_service.dart';
import 'package:moz_updated_version/services/core/app_services.dart';
import 'package:moz_updated_version/widgets/custom_cached_image.dart';
import 'package:moz_updated_version/widgets/song_list_tile.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

class OnlineSearchScreen extends StatefulWidget {
  const OnlineSearchScreen({super.key});

  @override
  State<OnlineSearchScreen> createState() => _OnlineSearchScreenState();
}

class _OnlineSearchScreenState extends State<OnlineSearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounce;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late final ScrollController _scrollController;
  bool _showSuggestions = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // _searchFocusNode.addListener(() {
    //   setState(() {
    //     _showSuggestions =
    //         _searchFocusNode.hasFocus &&
    //         _searchController.text.isNotEmpty &&
    //         !_hasSearched;
    //   });
    // });

    context.read<JioSaavnCubit>().fetchTrendingSearches();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 200) {
      context.read<JioSaavnCubit>().loadMore();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounce?.cancel();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (query.trim().isEmpty) {
      setState(() {
        _showSuggestions = false;
        _hasSearched = false;
      });
      context.read<AutocompleteCubit>().clearSuggestions();
      return;
    }

    setState(() {
      _showSuggestions = true;
      _hasSearched = false;
    });

    _debounce = Timer(const Duration(milliseconds: 180), () {
      context.read<AutocompleteCubit>().fetchSuggestions(query);
    });
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) return;

    _searchFocusNode.unfocus();

    setState(() {
      _showSuggestions = false;
      _hasSearched = true;
    });

    context.read<AutocompleteCubit>().clearSuggestions();
    context.read<JioSaavnCubit>().searchSongs(query);
    context.read<SearchHistoryCubit>().add(query);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    Theme.of(context).primaryColor.withValues(alpha: .8),
                    theme.scaffoldBackgroundColor,
                    theme.scaffoldBackgroundColor,
                  ]
                : [
                    Theme.of(context).primaryColor.withValues(alpha: .1),
                    Theme.of(context).primaryColor.withValues(alpha: .1),
                    theme.scaffoldBackgroundColor,
                  ],
            stops: const [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(isDark),
              _buildSearchBar(isDark),
              _buildContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    // Show autocomplete ONLY when actively typing (not after search is done)
    if (_showSuggestions &&
        _searchController.text.isNotEmpty &&
        !_hasSearched) {
      return _buildAutocompleteSuggestions(
        Theme.of(context).brightness == Brightness.dark,
      );
    }

    // Show initial suggestions when search is empty
    if (_searchController.text.isEmpty) {
      setState(() {
        _hasSearched = false; // Reset when search is cleared
      });
      return _buildInitialSuggestions();
    }

    // Show search results (even when text field is focused after search)
    return Expanded(
      child: BlocBuilder<JioSaavnCubit, JioSaavnState>(
        builder: (context, state) {
          if (state is JioSaavnSearchLoading ||
              state is JioSaavnAlbumSearchLoading) {
            return _buildLoadingState();
          }

          if (state is JioSaavnSearchError) {
            return ErrorView(
              message: state.message,
              onRetry: () {
                if (_searchController.text.isNotEmpty) {
                  _performSearch(_searchController.text);
                }
              },
            );
          }

          if (state is JioSaavnAlbumSearchError) {
            return ErrorView(
              message: state.message,
              onRetry: () {
                if (_searchController.text.isNotEmpty) {
                  context.read<JioSaavnCubit>().searchAlbums(
                    _searchController.text,
                  );
                }
              },
            );
          }

          if (state is JioSaavnSearchSuccess) {
            if (state.songs.isEmpty) {
              return const EmptyView(
                title: "No songs found",
                desc: "Try different keywords",
                icon: Icons.search_off,
              );
            }
            return _buildResults(state.songs);
          }

          if (state is JioSaavnAlbumSearchSuccess) {
            if (state.albums.isEmpty) {
              return const EmptyView(
                title: "No albums found",
                desc: "Try different keywords",
                icon: Icons.album_outlined,
              );
            }
            return _buildResults(state.albums);
          }

          // Keep showing results even during loading more
          if (state is JioSaavnSearchLoadingMore) {
            return _buildResults(state.currentSongs);
          }

          if (state is JioSaavnAlbumSearchLoadingMore) {
            return _buildResults(state.currentAlbums);
          }

          return EmptyView(
            title: "Discover Music",
            desc: 'Search for your favorite songs',
            icon: Icons.music_note,
            showButton: false,
          );
        },
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple, Colors.pink.shade400],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withValues(alpha: .3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.search, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Search Music',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text(
                'Find your favorite songs',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: isDark
              ? const Color.fromARGB(255, 23, 23, 23).withValues(alpha: .7)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          style: Theme.of(context).textTheme.bodyMedium,
          cursorColor: Theme.of(context).primaryColor,
          decoration: InputDecoration(
            hintText: 'Search songs, artists, albums',
            hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: Colors.purple.shade300,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    splashRadius: 18,
                    icon: const Icon(Icons.close_rounded, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                      context.read<JioSaavnCubit>().reset();
                      context.read<AutocompleteCubit>().clearSuggestions();
                      setState(() {
                        _hasSearched = false;
                      });
                    },
                  )
                : null,
            border: InputBorder.none,
            errorBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            fillColor: Colors.transparent,
          ),
          onSubmitted: _performSearch,
          onChanged: (value) {
            setState(() {});
            _onSearchChanged(value);
          },
        ),
      ),
    );
  }

  Widget _buildAutocompleteSuggestions(bool isDark) {
    return Expanded(
      child: BlocBuilder<AutocompleteCubit, AutocompleteState>(
        builder: (context, state) {
          if (state is AutocompleteLoading) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          if (state is AutocompleteSuccess && state.suggestions.isNotEmpty) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color.fromARGB(
                        255,
                        23,
                        23,
                        23,
                      ).withValues(alpha: .7)
                    : Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: isDark
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .06),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: state.suggestions.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: Colors.grey.withValues(alpha: .2),
                ),
                itemBuilder: (context, index) {
                  final suggestion = state.suggestions[index];
                  return ListTile(
                    dense: true,
                    leading: Icon(
                      Icons.search,
                      size: 20,
                      color: Colors.grey.shade600,
                    ),
                    title: Text(
                      suggestion,
                      style: const TextStyle(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Icon(
                      Icons.north_west,
                      size: 16,
                      color: Colors.grey.shade400,
                    ),
                    onTap: () {
                      _searchController.text = suggestion;
                      _performSearch(suggestion);
                    },
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildInitialSuggestions() {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SearchHistoryWidget(
              onTap: (val) {
                _searchController.text = val;
                _performSearch(val);
              },
            ),
            _buildSectionHeader('Trending Searches', Icons.whatshot),
            TrendingSearchesView(
              onTap: (val) {
                _searchController.text = val.title.toString();
                _performSearch(val.title!);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple.withValues(alpha: .3),
                      Colors.pink.withValues(alpha: .3),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Searching...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.purple),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(dynamic results) {
    final isAlbumSearch = results is List<OnlineAlbumSearchModel>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SearchFilterChips(),
        Expanded(
          child: isAlbumSearch
              ? _buildAlbumsList(results as List<OnlineAlbumSearchModel>)
              : _buildSongsList(
                  results as List<OnlineSongModel>,
                  _scrollController,
                ),
        ),
      ],
    );
  }
}

Widget _buildAlbumsList(List<OnlineAlbumSearchModel> albums) {
  return ListView.builder(
    physics: const BouncingScrollPhysics(),
    itemCount: albums.length + 1,
    itemBuilder: (context, index) {
      if (index == albums.length) {
        return _buildBottomLoader(context);
      }
      final album = albums[index];

      return TweenAnimationBuilder<double>(
        duration: Duration(milliseconds: 200 + (index * 30)),
        tween: Tween(begin: 0.0, end: 1.0),
        curve: Curves.easeOut,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Opacity(opacity: value, child: child),
          );
        },
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CustomCachedImage(
              imageUrl: album.image,
              height: MediaQuery.sizeOf(context).height * 0.25,
              width: MediaQuery.sizeOf(context).width * 0.16,
            ),
          ),
          title: Text(
            album.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${album.artist} • ${album.songCount} songs',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            context.read<ArtworkColorCubit>().extractAlbumArtworkColors(
              album.image,
            );
            context.read<CollectionCubitForOnline>().loadAlbum(
              album.id,
              "album",
            );
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => OnlineAlbumScreen()),
            );
          },
        ),
      );
    },
  );
}

Widget _buildSongsList(
  List<OnlineSongModel> songs,
  ScrollController scrollController,
) {
  return ListView.builder(
    controller: scrollController,
    physics: const BouncingScrollPhysics(),
    itemCount: songs.length + 1,
    itemBuilder: (context, index) {
      if (index == songs.length) {
        return _buildBottomLoader(context);
      }
      final song = songs[index];
      final songModel = song.toSongModel();

      return TweenAnimationBuilder<double>(
        duration: Duration(milliseconds: 200 + (index * 30)),
        tween: Tween(begin: 0.0, end: 1.0),
        curve: Curves.easeOut,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Opacity(opacity: value, child: child),
          );
        },
        child: CustomSongTile(
          song: songModel,
          showMoreTrailing: true,
          isTrailingChange: true,
          trailing: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert_rounded),
          ),
          onTap: () async {
            await sl<MozAudioHandler>().setOnlinePlaylist(songs, index: index);
            await sl<MozAudioHandler>().play();
          },
        ),
      );
    },
  );
}

Widget _buildBottomLoader(BuildContext context) {
  final state = context.watch<JioSaavnCubit>().state;

  if (state is JioSaavnSearchLoadingMore ||
      state is JioSaavnAlbumSearchLoadingMore) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }

  return const SizedBox.shrink();
}
