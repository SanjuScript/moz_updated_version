import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:moz_updated_version/screens/favorite_screen/presentation/widgets/fav_button.dart';
import 'package:moz_updated_version/services/audio_handler.dart';
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
    log(song.toString(), name: "BUILD FROM CUSTOM TILE");
    final extras = song.getMap;
    final isOnline = extras["isOnline"] == true;
    final isDownloaded = extras["is_downloaded"] == true;
    final localArtwork = extras["artworkPath"];
    final url = isOnline ? (extras["image"] as String?) : null;

    return StreamBuilder<MediaItem?>(
      stream: sl<MozAudioHandler>().mediaItem,
      builder: (context, snapshot) {
        final currentMedia = snapshot.data;
        final currentId = currentMedia?.id;

        final isPlaying =
            currentId != null && currentId == song.getMap["pid"].toString();

        return ListTile(
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
