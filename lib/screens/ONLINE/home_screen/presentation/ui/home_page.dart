import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/data/firebase/logic/favorites/favorites_cubit.dart';
import 'package:moz_updated_version/screens/ONLINE/home_screen/presentation/services/drawer_service.dart';
import 'package:moz_updated_version/screens/ONLINE/home_screen/presentation/widgets/home_section.dart';
import 'package:moz_updated_version/screens/ONLINE/home_screen/presentation/widgets/silver_app_bar.dart';
import 'package:moz_updated_version/screens/mini_player/presentation/ui/mini_player.dart';
import 'package:moz_updated_version/screens/song_list_screen/presentation/widgets/custom_drawer.dart';
import 'package:moz_updated_version/services/core/remote_update/app_version_service.dart';
import 'package:moz_updated_version/services/core/remote_update/dialog/force_update_dialog.dart';
import 'package:moz_updated_version/services/core/remote_update/remote_config_service.dart';
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
    _checkUpdateStatus();
  }

  void _checkUpdateStatus() async {
    final rcService = RemoteConfigService.instance;

    await rcService.init(debug: true);

    final currentVersion = await AppVersionService.getBuildNumber();
    log('BUILD NUMBER = $currentVersion');

    if (currentVersion < rcService.minAppVersion) {
      ForceUpdateDialog.show(
        context: context,
        canClose: rcService.forceUpdateEnabled,
        title: rcService.updateTitle,
        description: rcService.updateDescription,
        buttonText: rcService.updateButtonText,
        url: rcService.updateUrl,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      key: DrawerService.scaffoldKey,
      drawer: AppDrawer(scaffoldKey: DrawerService.scaffoldKey),
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
                          title: "Recommended for You",
                          items: home.cityMod ?? [],
                        ),
                        HomeSection(
                          title: "Trending Now",
                          items: home.newTrending ?? [],
                        ),
                        HomeSection(
                          title: "Top Charts",
                          items: home.charts ?? [],
                        ),
                        HomeSection(
                          title: "Popular Artists",
                          items: home.artistRecos ?? [],
                        ),
                        HomeSection(
                          title: "New Albums",
                          items: home.newAlbums ?? [],
                        ),

                        // HomeSection(
                        //   title: "Discover",
                        //   items: home.browseDiscover ?? [],
                        // ),
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * .25,
                        ),
                      ],
                    ),
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
