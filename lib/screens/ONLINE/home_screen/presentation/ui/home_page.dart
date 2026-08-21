import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/data/db/app_settings/app_settings_db.dart';
import 'package:moz_updated_version/screens/ONLINE/home_screen/presentation/services/drawer_service.dart';
import 'package:moz_updated_version/screens/ONLINE/home_screen/presentation/ui/home_screen_tv.dart';
import 'package:moz_updated_version/screens/ONLINE/home_screen/presentation/widgets/home_section.dart';
import 'package:moz_updated_version/screens/ONLINE/home_screen/presentation/widgets/locked_widget.dart';
import 'package:moz_updated_version/screens/ONLINE/home_screen/presentation/widgets/silver_app_bar.dart';
import 'package:moz_updated_version/screens/song_list_screen/presentation/widgets/custom_drawer.dart';
import 'package:moz_updated_version/services/core/remote_update/app_version_service.dart';
import 'package:moz_updated_version/services/core/remote_update/dialog/force_update_dialog.dart';
import 'package:moz_updated_version/services/core/remote_update/remote_config_service.dart';
import 'package:moz_updated_version/services/device_type_detector/cubit/device_type_cubit.dart';
import 'package:moz_updated_version/services/device_type_detector/device_type_detector.dart';
import 'package:moz_updated_version/services/one_time_dialogue_service.dart';
import 'package:moz_updated_version/widgets/error_widget.dart';
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
    await rcService.init();

    final currentVersion = await AppVersionService.getBuildNumber();
    final userSkippedVersion = SettingsManager.skippedVersion;
    final updateAvailable = currentVersion < rcService.minAppVersion;

    log('BUILD NUMBER = $currentVersion');
    log(userSkippedVersion.toString(), name: "SKIPPED VERSION");

    if (updateAvailable && rcService.forceUpdateEnabled) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ForceUpdateScreen(
            canClose: rcService.forceUpdateEnabled,
            title: rcService.updateTitle,
            description: rcService.updateDescription,
            buttonText: rcService.updateButtonText,
            url: rcService.updateUrl,
          ),
        ),
      );
      return;
    }
    if (updateAvailable) {
      if (SettingsManager.skippedVersion == rcService.minAppVersion) {
        await SettingsManager.setUpdateIconVisible(true);
        return;
      }
      await SettingsManager.setUpdateIconVisible(false);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ForceUpdateScreen(
            canClose: rcService.forceUpdateEnabled,
            title: rcService.updateTitle,
            description: rcService.updateDescription,
            buttonText: rcService.updateButtonText,
            url: rcService.updateUrl,
          ),
        ),
      );
    } else {
      await SettingsManager.clearSkip();
      if (!mounted) return;
      OneTimeDialog.show(
        context: context,
        dialogId: DialogIds.homeNewFeature,
        content: DialogContents.homeWelcome,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTv =
        (context.read<DeviceTypeCubit>().state as DeviceTypeReady).device ==
        DeviceType.tv;
    if (isTv) {
      return HomeScreenTV();
    }
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
                return AppErrorView(
                  onRetry: () {
                    context.read<JioSaavnHomeCubit>().loadHomeData(
                      forceRefresh: true,
                    );
                  },
                );
              }

              final home = (state as JioSaavnHomeSuccess).data;

              return CustomScrollView(
                slivers: [
                  CustomSilverAppBar(),

                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LockedHomeSection(
                          title: "Recommended by Moz",
                          lockMessage:
                              "This will be available in the next update. Stay tuned!",
                        ),
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

                        HomeSection(
                          title: "Top Playlists",
                          items: home.topPlaylists ?? [],
                        ),
                        HomeSection(
                          title: "Radio Stations",
                          items: home.radio ?? [],
                        ),
                        HomeSection(
                          title: "Discover",
                          items: home.browseDiscover ?? [],
                        ),
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
