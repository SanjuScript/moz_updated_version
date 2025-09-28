import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:moz_updated_version/core/animations/custom_paint_animations/audio_scan_animation.dart';
import 'package:moz_updated_version/core/helper/cubit/player_settings_cubit.dart';
import 'package:moz_updated_version/core/themes/cubit/theme_cubit.dart';
import 'package:moz_updated_version/main.dart';
import 'package:moz_updated_version/screens/removed_screen/presentation/ui/removed_songs_screen.dart';
import 'package:moz_updated_version/screens/settings/screens/contact_support/contact_support_screen.dart';
import 'package:moz_updated_version/screens/settings/screens/faq/faq_screen.dart';
import 'package:moz_updated_version/screens/settings/screens/privacy_policy/privacy_policy_screen.dart';
import 'package:moz_updated_version/screens/settings/screens/setting_screen/Widgets/color_picker.dart';
import 'package:moz_updated_version/screens/settings/screens/setting_screen/Widgets/custom_switch.dart';
import 'package:moz_updated_version/screens/settings/screens/setting_screen/Widgets/seting_selection.dart';
import 'package:moz_updated_version/screens/settings/screens/setting_screen/Widgets/setting_item.dart';
import 'package:moz_updated_version/screens/settings/screens/setting_screen/dialogues/reset_confirmation.dart';
import 'package:moz_updated_version/screens/settings/screens/sleep_timer_screen/presentation/cubit/sleeptimer_cubit.dart';
import 'package:moz_updated_version/screens/settings/screens/sleep_timer_screen/presentation/ui/sleep_timer.dart';
import 'package:moz_updated_version/screens/settings/screens/storage_location_screen/ui/storage_location.dart';
import 'package:moz_updated_version/services/core/app_services.dart';
import 'package:moz_updated_version/services/reset_service.dart';
import 'package:moz_updated_version/services/service_locator.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  final Map<double, String> speedMap = {
    0.5: "0.5x",
    0.8: "0.8x",
    1.0: "Normal",
    1.5: "1.5x",
    2.0: "2.0x",
  };

  final Map<RepeatMode, String> repeatModeMap = {
    RepeatMode.off: "Off",
    RepeatMode.one: "Repeat One",
    RepeatMode.all: "Repeat All",
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            expandedHeight: 100.0,
            elevation: 10,
            shadowColor: Colors.grey[700],
            flexibleSpace: FlexibleSpaceBar(
              title: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  children: [
                    const SizedBox(width: 5),
                    Text(
                      'Settings',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            pinned: true,
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SettingsSection(
                      title: 'Playback Settings',
                      items: [
                        SettingsItem(
                          title: 'Repeat',
                          trailing:
                              BlocBuilder<
                                PlayerSettingsCubit,
                                PlayerSettingsState
                              >(
                                builder: (context, state) {
                                  return DropdownButton<RepeatMode>(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                    value: state.repeatMode,
                                    items: repeatModeMap.entries.map((data) {
                                      final isSelected =
                                          data.key == state.repeatMode;
                                      return DropdownMenuItem(
                                        value: data.key,
                                        child: Text(
                                          data.value,
                                          style: TextStyle(
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            color: isSelected
                                                ? Theme.of(context).primaryColor
                                                : null,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (mode) {
                                      if (mode != null) {
                                        context
                                            .read<PlayerSettingsCubit>()
                                            .setRepeatMode(mode);
                                      }
                                    },
                                  );
                                },
                              ),
                        ),
                        SettingsItem(
                          title: 'Shuffle',
                          trailing:
                              BlocBuilder<
                                PlayerSettingsCubit,
                                PlayerSettingsState
                              >(
                                builder: (context, state) {
                                  return CustomSwitch(
                                    value: state.shuffle,
                                    onChanged: (_) {
                                      context
                                          .read<PlayerSettingsCubit>()
                                          .toggleShuffle();
                                    },
                                  );
                                },
                              ),
                        ),

                        SettingsItem(
                          title: 'Playback Speed',
                          trailing:
                              BlocBuilder<
                                PlayerSettingsCubit,
                                PlayerSettingsState
                              >(
                                builder: (context, state) {
                                  return DropdownButton<double>(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                    value: state.speed,
                                    items: speedMap.entries.map((data) {
                                      final isSelected =
                                          data.key == state.speed;
                                      return DropdownMenuItem(
                                        value: data.key,
                                        child: Text(
                                          data.value,
                                          style: TextStyle(
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            color: isSelected
                                                ? Theme.of(context).primaryColor
                                                : null,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      if (value != null) {
                                        context
                                            .read<PlayerSettingsCubit>()
                                            .setSpeed(value);
                                      }
                                    },
                                  );
                                },
                              ),
                        ),

                        SettingsItem(
                          title: 'Volume',
                          trailing: SizedBox(
                            width: 200.0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                  child:
                                      BlocBuilder<
                                        PlayerSettingsCubit,
                                        PlayerSettingsState
                                      >(
                                        builder: (context, state) {
                                          return Slider.adaptive(
                                            activeColor: Theme.of(
                                              context,
                                            ).primaryColor,
                                            value: state.volume,
                                            min: 0.0,
                                            max: 1.0,
                                            onChanged: (value) {
                                              final cubit =
                                                  BlocProvider.of<
                                                    PlayerSettingsCubit
                                                  >(context, listen: false);
                                              cubit.setVolume(value);
                                            },
                                          );
                                        },
                                      ),
                                ),
                                const SizedBox(width: 8.0),
                                SizedBox(
                                  width: MediaQuery.sizeOf(context).width * .1,
                                  child:
                                      BlocBuilder<
                                        PlayerSettingsCubit,
                                        PlayerSettingsState
                                      >(
                                        builder: (context, state) {
                                          final percentage =
                                              (state.volume * 100)
                                                  .toStringAsFixed(0);
                                          return Text(
                                            '$percentage%',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          );
                                        },
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SettingsSection(
                      title: 'Theme & Appearance',
                      items: [
                        SettingsItem(
                          title: 'Theme',
                          trailing: BlocBuilder<ThemeCubit, ThemeState>(
                            builder: (context, state) {
                              return DropdownButton<String>(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                value: state.themeMode,
                                items:
                                    const [
                                      DropdownMenuItem(
                                        value: 'light',
                                        child: Text('Light'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'dark',
                                        child: Text('Dark'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'system',
                                        child: Text('System Default'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'timeBased',
                                        child: Text('Time-Based'),
                                      ),
                                    ].map((item) {
                                      final isSelected =
                                          item.value == state.themeMode;
                                      return DropdownMenuItem<String>(
                                        value: item.value,
                                        child: Text(
                                          (item.child as Text).data ?? '',
                                          style: TextStyle(
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            color: isSelected
                                                ? Theme.of(context).primaryColor
                                                : null,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                onChanged: (value) {
                                  if (value == null) return;
                                  final cubit = context.read<ThemeCubit>();
                                  switch (value) {
                                    case 'light':
                                      cubit.setLightMode();
                                      break;
                                    case 'dark':
                                      cubit.setDarkMode();
                                      break;
                                    case 'system':
                                      cubit.setSystemMode();
                                      break;
                                    case 'timeBased':
                                      cubit.setTimeBasedMode(true);
                                      break;
                                  }
                                },
                              );
                            },
                          ),
                        ),

                        SettingsItem(
                          title: 'Enable Time-Based Mode',
                          trailing: BlocBuilder<ThemeCubit, ThemeState>(
                            builder: (context, state) {
                              return CustomSwitch(
                                value: state.isTimeBased,
                                onChanged: (enabled) {
                                  context.read<ThemeCubit>().setTimeBasedMode(
                                    enabled,
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        SettingsItem(
                          title: 'Use iOS Style',
                          trailing: BlocBuilder<ThemeCubit, ThemeState>(
                            builder: (context, state) {
                              final isIOS =
                                  state.platform == TargetPlatform.iOS;

                              return CustomSwitch(
                                value: isIOS,
                                onChanged: (enabled) {
                                  context.read<ThemeCubit>().setPlatform(
                                    enabled
                                        ? TargetPlatform.iOS
                                        : TargetPlatform.android,
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        SettingsItem(
                          title: "Palette",
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                              ),
                              builder: (context) => ColorPickerSheet(
                                onColorSelected: (color) {
                                  context.read<ThemeCubit>().setPrimaryColor(
                                    color,
                                  );
                                  Navigator.pop(context);
                                },
                              ),
                            );
                          },
                          trailing: BlocBuilder<ThemeCubit, ThemeState>(
                            builder: (context, state) {
                              return CircleAvatar(
                                radius: 18,
                                backgroundColor: state.primaryColor,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    SettingsSection(
                      title: 'Sleep Timer',
                      items: [
                        SettingsItem(
                          title: 'Sleep Timer',
                          trailing:
                              BlocBuilder<SleepTimerCubit, SleepTimerState>(
                                builder: (context, state) {
                                  return CustomSwitch(
                                    value: state.isRunning,
                                    onChanged: (value) {
                                      if (value) {
                                        sl<NavigationService>().navigateTo(
                                          animation: NavigationAnimation.fade,
                                          SleepTimerScreen(),
                                        );
                                      } else {
                                        context
                                            .read<SleepTimerCubit>()
                                            .stopTimer();
                                      }
                                    },
                                  );
                                },
                              ),
                        ),
                        SettingsItem(
                          title: 'Timer Status',
                          trailing: BlocBuilder<SleepTimerCubit, SleepTimerState>(
                            builder: (context, state) {
                              String subtitle;
                              if (!state.isRunning) {
                                subtitle = "OFF";
                              } else if (state.isTrackMode) {
                                subtitle =
                                    "Moz Will stop after ${state.tracksLeft} track${state.tracksLeft > 1 ? 's' : ''}";
                              } else {
                                final minutes = (state.remainingSeconds ~/ 60);
                                final seconds = (state.remainingSeconds % 60)
                                    .toString()
                                    .padLeft(2, '0');
                                subtitle =
                                    "Moz will stop in $minutes:$seconds minutes";
                              }

                              return Text(
                                subtitle,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: state.isRunning
                                          ? Colors.pinkAccent
                                          : Colors.grey[400],
                                    ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    SettingsSection(
                      title: 'Music Library',
                      items: [
                        SettingsItem(
                          title: 'Scan Audio',
                          trailing: const Icon(Icons.search),
                          onTap: () {
                            sl<NavigationService>().navigateTo(
                              animation: NavigationAnimation.fade,
                              AudioScanScreen(),
                            );
                          },
                        ),
                        SettingsItem(
                          title: 'Storage Location',
                          trailing: const Icon(Icons.storage),
                          onTap: () {
                            sl<NavigationService>().navigateTo(
                              animation: NavigationAnimation.fade,
                              StorageLocationScreen(),
                            );
                          },
                        ),
                        SettingsItem(
                          title: 'Removed Songs',
                          trailing: const Icon(Icons.music_off),
                          onTap: () {
                            sl<NavigationService>().navigateTo(
                              animation: NavigationAnimation.fade,
                              RemovedSongsScreen(),
                            );
                          },
                        ),
                      ],
                    ),
                    SettingsSection(
                      title: 'Account',
                      items: [
                        SettingsItem(
                          title: 'Full Reset',
                          trailing: const Icon(Icons.cleaning_services),
                          onTap: () {
                            showResetDialog(context);
                          },
                        ),
                      ],
                    ),

                    SettingsSection(
                      title: 'Data Management',
                      items: [
                        SettingsItem(
                          title: 'Clear Playlists',
                          trailing: const Icon(Icons.playlist_remove),
                          onTap: () => AppResetService.clearPlaylists(context),
                        ),
                        SettingsItem(
                          title: 'Clear Favorites',
                          trailing: const Icon(Icons.favorite_border),
                          onTap: () => AppResetService.clearFavorites(context),
                        ),
                        SettingsItem(
                          title: 'Clear Recently Played',
                          trailing: const Icon(Icons.history),
                          onTap: () =>
                              AppResetService.clearRecentlyPlayed(context),
                        ),
                        SettingsItem(
                          title: 'Clear Mostly Played',
                          trailing: const Icon(Icons.leaderboard),
                          onTap: () =>
                              AppResetService.clearMostlyPlayed(context),
                        ),

                        SettingsItem(
                          title: 'Clear Settings',
                          trailing: const Icon(Icons.settings_backup_restore),
                          onTap: () => AppResetService.clearSettings(context),
                        ),
                      ],
                    ),

                    SettingsSection(
                      title: 'Help & Support',
                      items: [
                        SettingsItem(
                          title: 'FAQ',
                          trailing: const Icon(Icons.help_outline),
                          onTap: () {
                            sl<NavigationService>().navigateTo(FaqScreen());
                          },
                        ),
                        SettingsItem(
                          title: 'Contact Support',
                          trailing: const Icon(Icons.contact_support),
                          onTap: () {
                            sl<NavigationService>().navigateTo(
                              ContactSupportScreen(),
                            );
                          },
                        ),
                        SettingsItem(
                          title: 'Privacy Policy',
                          trailing: const Icon(Icons.privacy_tip),
                          onTap: () {
                            sl<NavigationService>().navigateTo(
                              PrivacyPolicyScreen(),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
