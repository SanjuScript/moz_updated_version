import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/screens/ONLINE/home_screen/presentation/widgets/home_section.dart';
import 'package:moz_updated_version/screens/ONLINE/home_screen/presentation/widgets/silver_app_bar.dart';
import 'package:moz_updated_version/screens/mini_player/presentation/ui/mini_player.dart';
import 'package:moz_updated_version/widgets/shimmers/moz_shimmer.dart';

import '../cubit/jio_saavn_home_cubit.dart';

class HomeScreenOn extends StatefulWidget {
  const HomeScreenOn({super.key});

  @override
  State<HomeScreenOn> createState() => _HomeScreenOnState();
}

class _HomeScreenOnState extends State<HomeScreenOn> {
  @override
  void initState() {
    super.initState();
    context.read<JioSaavnHomeCubit>().loadHomeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: RefreshIndicator.adaptive(
        onRefresh: () async {
          context.read<JioSaavnHomeCubit>().loadHomeData(forceRefresh: true);
        },
        child: SafeArea(
          top: false,
          bottom: false,
          child: BlocBuilder<JioSaavnHomeCubit, JioSaavnHomeState>(
            builder: (context, state) {
              if (state is JioSaavnHomeLoading) {
                return HomePageShimmer();
              }

              if (state is JioSaavnHomeError) {
                return Center(child: Text(state.message));
              }

              final home = (state as JioSaavnHomeSuccess).data;

              return CustomScrollView(
                slivers: [
                  CustomSilverAppBar(),

                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HomeSection(
                          title: "Trending Now",
                          items: home.newTrending ?? [],
                        ),
                        HomeSection(
                          title: "Popular Artists",
                          items: home.artistRecos ?? [],
                        ),
                        HomeSection(
                          title: "New Albums",
                          items: home.newAlbums ?? [],
                        ),
                        HomeSection(
                          title: "Discover",
                          items: home.browseDiscover ?? [],
                        ),
                        HomeSection(
                          title: "Top Charts",
                          items: home.charts ?? [],
                        ),
                        HomeSection(
                          title: "Recommended for You",
                          items: home.cityMod ?? [],
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),

      bottomNavigationBar: MiniPlayer(),
    );
  }
}
