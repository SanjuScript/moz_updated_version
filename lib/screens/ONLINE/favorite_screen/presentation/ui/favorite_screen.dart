import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/core/extensions/capitalize.dart';
import 'package:moz_updated_version/core/extensions/song_model_ext.dart';
import 'package:moz_updated_version/core/utils/online_playback_repo/audio_playback_repository.dart';
import 'package:moz_updated_version/data/firebase/logic/favorites/favorites_cubit.dart';
import 'package:moz_updated_version/data/model/user_model/repository/user_repo.dart';
import 'package:moz_updated_version/main.dart';
import 'package:moz_updated_version/screens/ONLINE/auth/presentation/cubit/auth_cubit.dart';
import 'package:moz_updated_version/screens/ONLINE/auth/presentation/ui/google_sign_in_screen.dart';
import 'package:moz_updated_version/screens/ONLINE/favorite_screen/presentation/widgets/empty_view.dart';
import 'package:moz_updated_version/screens/ONLINE/favorite_screen/presentation/widgets/error_view.dart';
import 'package:moz_updated_version/screens/ONLINE/favorite_screen/presentation/widgets/playlist_tile.dart';
import 'package:moz_updated_version/screens/favorite_screen/presentation/cubit/favotite_cubit.dart';
import 'package:moz_updated_version/services/service_locator.dart';
import 'package:moz_updated_version/widgets/song_list_tile.dart';

class OnlineFavoriteSongsScreen extends StatefulWidget {
  const OnlineFavoriteSongsScreen({super.key});

  @override
  State<OnlineFavoriteSongsScreen> createState() =>
      _OnlineFavoriteSongsScreenState();
}

class _OnlineFavoriteSongsScreenState extends State<OnlineFavoriteSongsScreen>
    with RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }

    final userRepo = sl<UserStorageAbRepo>().isLoggedIn();
    if (userRepo) {
      context.read<OnlineFavoritesCubit>().loadFavoriteSongs();
    }
  }

  @override
  void didPopNext() {
    context.read<OnlineFavoritesCubit>().loadFavoriteSongs();
    log("Returned to Favorites screen – refreshed");
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final username = sl<UserStorageAbRepo>().userName;
    final isLoggedIn = context.watch<AuthCubit>().state;

    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${username!.isNotEmpty ? username.formattedFirstNamePossessive : "Your"} Favorites",
        ),
        centerTitle: false,
      ),
      body: BlocListener<AuthCubit, bool>(
        listenWhen: (prev, curr) => prev != curr,
        listener: (context, state) {
          if (state) {
            Future.delayed(Duration(milliseconds: 500), () {
              if (mounted) {
                context.read<OnlineFavoritesCubit>().init();
                context.read<OnlineFavoritesCubit>().loadFavoriteSongs();
              }
            });
          }
        },
        child: !isLoggedIn
            ? _buildLoginPrompt(context)
            : RefreshIndicator.adaptive(
                onRefresh: () async {
                  await context
                      .read<OnlineFavoritesCubit>()
                      .loadFavoriteSongs();
                  log("REFRESHED");
                },
                child: BlocBuilder<OnlineFavoritesCubit, OnlineFavoritesState>(
                  builder: (context, state) {
                    if (state is OnlineFavoriteLoading) {
                      return Center(child: CircularProgressIndicator());
                    }

                    return CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(child: PlaylistsTile()),

                        if (state is OnlineFavoriteSongsLoaded)
                          SliverToBoxAdapter(
                            child: FavoritesCountHeader(
                              count: state.songs.length,
                            ),
                          ),

                        if (state is OnlineFavoritesInitial)
                          const SliverFillRemaining(
                            child: Center(child: CircularProgressIndicator()),
                          ),

                        if (state is OnlineFavoritesError)
                          SliverFillRemaining(
                            child: ErrorView(
                              message: state.message,
                              onRetry: () => context
                                  .read<OnlineFavoritesCubit>()
                                  .loadFavoriteSongs(),
                            ),
                          ),

                        if (state is OnlineFavoriteSongsLoaded &&
                            state.songs.isEmpty)
                          const SliverFillRemaining(
                            child: EmptyView(
                              title: "No favorites yet",
                              desc:
                                  "Songs you favorite will appear here.\nStart building your collection!",
                              icon: Icons.favorite_border,
                            ),
                          ),

                        if (state is OnlineFavoriteSongsLoaded)
                          SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final song = state.songs[index].toSongModel();
                              return CustomSongTile(
                                keepFavbtn: true,
                                song: song,
                                onTap: () {
                                  sl<AudioPlaybackRepository>().playOnlineSong(
                                    state.songs,
                                    startIndex: index,
                                  );
                                },
                              );
                            }, childCount: state.songs.length),
                          ),
                        SliverToBoxAdapter(
                          child: SizedBox(height: size.height * .20),
                        ),
                      ],
                    );
                  },
                ),
              ),
      ),
    );
  }
}

class FavoritesCountHeader extends StatelessWidget {
  final int count;

  const FavoritesCountHeader({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Text("Liked Songs", style: theme.textTheme.titleMedium),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "$count",
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildLoginPrompt(BuildContext context) {
  final theme = Theme.of(context);

  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            "Login Required",
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Sign in to save your favorite songs and access them across all your devices.",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () {
              // Navigate to login screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => GoogleSignInScreen()),
              );
            },
            icon: const Icon(Icons.login),
            label: const Text("Login"),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
          ),
        ],
      ),
    ),
  );
}
