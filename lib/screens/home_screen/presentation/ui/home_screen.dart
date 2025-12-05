import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/core/utils/bloc/audio_bloc.dart';
import 'package:moz_updated_version/data/db/playlist/playlist_model.dart';
import 'package:moz_updated_version/data/db/playlist/repository/playlist_ab_repo.dart';

import 'package:moz_updated_version/screens/favorite_screen/presentation/cubit/favotite_cubit.dart';
import 'package:moz_updated_version/screens/home_screen/presentation/widgets/catagory_bar.dart';
import 'package:moz_updated_version/screens/home_screen/presentation/widgets/section_title.dart';
import 'package:moz_updated_version/screens/home_screen/presentation/widgets/sections/current_playlist_section.dart';
import 'package:moz_updated_version/screens/home_screen/presentation/widgets/sections/last_songs_section.dart';
import 'package:moz_updated_version/screens/home_screen/presentation/widgets/sections/mostly_played_section.dart';
import 'package:moz_updated_version/screens/home_screen/presentation/widgets/sections/recently_played_section.dart';
import 'package:moz_updated_version/screens/mostly_played/presentation/cubit/mostlyplayed_cubit.dart';
import 'package:moz_updated_version/screens/playlist_screen/presentation/cubit/playlist_cubit.dart';
import 'package:moz_updated_version/screens/playlist_screen/presentation/widgets/artwork_displaying.dart';
import 'package:moz_updated_version/screens/recently_played/presentation/cubit/recently_played_cubit.dart';
import 'package:moz_updated_version/screens/song_list_screen/presentation/cubit/allsongs_cubit.dart';
import 'package:moz_updated_version/widgets/audio_artwork_widget.dart';

import '../../../../services/core/app_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _refreshContent() async {
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    context.read<AllSongsCubit>().loadSongs();
  }

  @override
  void initState() {
    super.initState();
    loadDatas();
  }

  void loadDatas() {
    context.read<PlaylistCubit>().loadPlaylists();
    context.read<FavoritesCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: RefreshIndicator(
        color: Theme.of(context).textTheme.titleLarge!.color,
        backgroundColor: Theme.of(context).primaryColor,
        onRefresh: _refreshContent,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              const CategoryBar(),

              CurrentPlaylistWidget(),
              BlocBuilder<RecentlyPlayedCubit, RecentlyPlayedState>(
                builder: (context, state) {
                  if (state is RecentlyPlayedLoaded) {
                    if (state.items.isNotEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          SectionTitle(index: 1, title: "Recently Played"),
                          RecentlyPlayedSection(),
                        ],
                      );
                    }
                  }
                  return const SizedBox.shrink();
                },
              ),

              BlocBuilder<MostlyPlayedCubit, MostlyplayedState>(
                builder: (context, state) {
                  if (state is MostlyPlayedLoaded && state.items.isNotEmpty) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        SectionTitle(index: 5, title: "Mostly Played"),
                        MostlyPlayedSection(),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              BlocBuilder<AllSongsCubit, AllsongsState>(
                builder: (context, state) {
                  if (state is AllSongsLoaded && state.songs.isNotEmpty) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        SectionTitle(index: 1, title: "Last Added"),
                        LastAddedSection(),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              SizedBox(height: size.height * .10),
            ],
          ),
        ),
      ),
    );
  }
}
