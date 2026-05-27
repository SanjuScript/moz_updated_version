import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/core/extensions/capitalize.dart';
import 'package:moz_updated_version/screens/favorite_screen/presentation/widgets/fav_button.dart';
import 'package:moz_updated_version/services/audio_handler.dart';
import 'package:moz_updated_version/services/device_type_detector/cubit/device_type_cubit.dart';
import 'package:moz_updated_version/services/device_type_detector/device_type_detector.dart';
import 'package:moz_updated_version/services/service_locator.dart';
import 'package:moz_updated_version/widgets/audio_artwork_widget.dart';
import 'package:moz_updated_version/widgets/custom_lottie.dart';
import 'package:moz_updated_version/widgets/custom_menu/custom_dynamic_popmenu.dart';
import 'package:moz_updated_version/widgets/song_detail_sheet.dart';
import 'package:on_audio_query/on_audio_query.dart';

class CustomSongTile extends StatelessWidget {
  final bool isTrailingChange;
  final Widget? trailing;
  final SongModel song;
  final bool showMoreTrailing;
  final SongMenuContext menuContext;
  final void Function()? remove;
  final void Function()? onTap;
  final bool isSelecting;
  final bool showSheet;
  final EdgeInsets? padding;
  final bool keepFavbtn;
  final String? playlistId;

  const CustomSongTile({
    super.key,
    required this.song,
    this.isSelecting = false,
    this.showMoreTrailing = false,
    this.menuContext = SongMenuContext.search,
    this.playlistId,
    this.isTrailingChange = false,
    this.showSheet = true,
    this.trailing,
    this.padding,
    this.keepFavbtn = false,
    this.onTap,
    this.remove,
  });

  @override
  Widget build(BuildContext context) {
    final isTv =
        context.read<DeviceTypeCubit>().state is DeviceTypeReady &&
        (context.read<DeviceTypeCubit>().state as DeviceTypeReady).device ==
            DeviceType.tv;
    if (isTv) return _buildTv(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return _buildMobile(context);
        }
        return _buildDesktop(context);
      },
    );
  }

  Widget _buildMobile(BuildContext context) {
    // log(song.toString(), name: "BUILD FROM CUSTOM TILE");
    final extras = song.getMap;
    final isOnline = extras["isOnline"] == true;
    final isDownloaded = extras["is_downloaded"] == true;
    final localArtwork = extras["artworkPath"];
    final url = isOnline
        ? (extras["image"] as String?)!.replaceArtworkSize("150x150")
        : null;

    return StreamBuilder<MediaItem?>(
      stream: sl<MozAudioHandler>().mediaItem,
      builder: (context, snapshot) {
        final currentMedia = snapshot.data;
        final currentId = currentMedia?.id;

        final isPlaying =
            currentId != null && currentId == song.getMap["pid"].toString();

        return ListTile(
          // contentPadding: padding ?? EdgeInsets.symmetric(horizontal: 10),
          contentPadding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          leading: SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.25,
            width: MediaQuery.sizeOf(context).width * 0.16,
            child: AudioArtWorkWidget(
              id: song.id ?? 0,
              radius: 8,
              artworkPath: localArtwork,
              isDownloaded: isDownloaded,
              iconSize: 30,
              isOnline: isOnline,
              imageUrl: url,
            ),
          ),
          title: Text(
            song.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          subtitle: Text(
            song.artist ?? "",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          onTap: onTap,
          onLongPress: showSheet
              ? () => showSongDetailsSheet(context, song)
              : null,
          trailing: _buildTrailing(context, isPlaying),
        );
      },
    );
  }

  Widget _buildTv(BuildContext context) {
    final extras = song.getMap;
    final isOnline = extras["isOnline"] == true;
    final isDownloaded = extras["is_downloaded"] == true;
    final localArtwork = extras["artworkPath"];
    final url = isOnline ? (extras["image"] as String?) : null;

    return StreamBuilder<MediaItem?>(
      stream: sl<MozAudioHandler>().mediaItem,
      builder: (context, snapshot) {
        final currentId = snapshot.data?.id;
        final isPlaying =
            currentId != null && currentId == song.getMap["pid"].toString();

        return Focus(
          onKeyEvent: (node, event) {
            if (event is KeyDownEvent) {
              if (event.logicalKey == LogicalKeyboardKey.select ||
                  event.logicalKey == LogicalKeyboardKey.enter) {
                if (node.hasFocus) {
                  onTap?.call();
                  return KeyEventResult.handled;
                }
              }
              if (event.logicalKey == LogicalKeyboardKey.contextMenu ||
                  event.logicalKey == LogicalKeyboardKey.f1) {
                if (showMoreTrailing) {
                  return KeyEventResult.handled;
                }
              }
            }
            return KeyEventResult.ignored;
          },
          child: Builder(
            builder: (context) {
              final isFocused = Focus.of(context).hasFocus;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: isFocused
                      ? Theme.of(context).primaryColor.withOpacity(0.15)
                      : Colors.transparent,
                  border: isFocused
                      ? Border.all(
                          color: Theme.of(context).primaryColor,
                          width: 3,
                        )
                      : null,
                ),
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // Artwork
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: isFocused ? 72 : 64,
                          width: isFocused ? 72 : 64,
                          child: AudioArtWorkWidget(
                            id: song.id ?? 0,
                            radius: 10,
                            artworkPath: localArtwork,
                            isDownloaded: isDownloaded,
                            iconSize: 28,
                            isOnline: isOnline,
                            imageUrl: url,
                          ),
                        ),

                        const SizedBox(width: 20),

                        // Song details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                song.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontSize: isFocused ? 20 : 18,
                                      fontWeight: isFocused
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                song.artist ?? "",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      fontSize: isFocused ? 15 : 14,
                                      color: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.color
                                          ?.withOpacity(0.8),
                                    ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Trailing section
                        _buildTrailing(context, isPlaying),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDesktop(BuildContext context) {
    final extras = song.getMap;
    final isOnline = extras["isOnline"] == true;
    final isDownloaded = extras["is_downloaded"] == true;
    final localArtwork = extras["artworkPath"];
    final url = isOnline ? (extras["image"] as String?) : null;

    return StreamBuilder<MediaItem?>(
      stream: sl<MozAudioHandler>().mediaItem,
      builder: (context, snapshot) {
        final currentId = snapshot.data?.id;
        final isPlaying =
            currentId != null && currentId == song.getMap["pid"].toString();

        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                SizedBox(
                  height: 56,
                  width: 56,
                  child: AudioArtWorkWidget(
                    id: song.id ?? 0,
                    radius: 8,
                    artworkPath: localArtwork,
                    isDownloaded: isDownloaded,
                    iconSize: 22,
                    isOnline: isOnline,
                    imageUrl: url,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(fontSize: 15),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        song.artist ?? "",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        ).textTheme.titleSmall?.copyWith(letterSpacing: .3),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                _buildTrailing(context, isPlaying),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrailing(BuildContext context, bool isPlaying) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: isPlaying
          ? _PlayingRow(context, song)
          : showMoreTrailing
          ? SongMenuBuilder.buildMenu(
              context: context,
              song: song,
              menuContext: menuContext,
              playlistId: playlistId,
            )
          : isTrailingChange
          ? (trailing ?? const SizedBox())
          : FavoriteButton(key: ValueKey("fav_${song.id}"), songFavorite: song),
    );
  }

  Widget _PlayingRow(BuildContext context, SongModel song) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StreamBuilder<bool>(
          stream: sl<MozAudioHandler>().isPlaying,
          builder: (context, snapshot) {
            final playing = snapshot.data ?? false;
            return CustomLottie(
              asset: "assets/lotties/audio_playing.json",
              width: 44,
              height: 44,
              animate: playing,
            );
          },
        ),
        if (keepFavbtn)
          FavoriteButton(songFavorite: song)
        else if (isTrailingChange && trailing != null)
          trailing!
        else
          SongMenuBuilder.buildMenu(
            context: context,
            song: song,
            menuContext: menuContext,
            playlistId: playlistId,
          ),
      ],
    );
  }
}
