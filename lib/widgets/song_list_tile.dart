import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:moz_updated_version/core/constants/beta_info.dart';
import 'package:moz_updated_version/screens/favorite_screen/presentation/widgets/fav_button.dart';
import 'package:moz_updated_version/services/audio_handler.dart';
import 'package:moz_updated_version/services/service_locator.dart';
import 'package:moz_updated_version/widgets/audio_artwork_widget.dart';
import 'package:moz_updated_version/widgets/custom_lottie.dart';
import 'package:moz_updated_version/widgets/song_detail_sheet.dart';
import 'package:on_audio_query/on_audio_query.dart';

class CustomSongTile extends StatelessWidget {
  final bool isTrailingChange;
  final Widget? trailing;
  final SongModel song;
  final void Function()? remove;
  final void Function()? onTap;
  final bool isSelecting;
  final bool showSheet;
  final EdgeInsets? padding;
  final bool keepFavbtn;
  const CustomSongTile({
    super.key,
    required this.song,
    this.isSelecting = false,
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
    final extras = song.getMap;
    final isOnline = extras["isOnline"] == true;
    final url = isOnline ? (extras["image"] as String?) : null;

    log(name: "URL", url.toString());

    return StreamBuilder<MediaItem?>(
      stream: sl<MozAudioHandler>().mediaItem,
      builder: (context, snapshot) {
        final currentMedia = snapshot.data;
        final currentId = currentMedia?.id;

        final bool isPlaying =
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
              iconSize: 30,
              isOnline: isOnline,
              imageUrl: url,
            ),
          ),
          title: Text(
            song.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 16,
              overflow: TextOverflow.ellipsis,
            ),
            maxLines: 1,
          ),
          selectedTileColor: Colors.transparent,
          selectedColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          splashColor: Colors.transparent,
          onLongPress: showSheet
              ? () {
                  showSongDetailsSheet(context, song);
                }
              : null,

          subtitle: Text(
            song.artist!,
            maxLines: 1,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(letterSpacing: .3),
          ),
          onTap: onTap,
          trailing: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: CurvedAnimation(parent: animation, curve: Curves.linear),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: isPlaying
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isPlaying)
                        StreamBuilder<bool?>(
                          stream: sl<MozAudioHandler>().isPlaying,
                          builder: (context, asyncSnapshot) {
                            if (asyncSnapshot.hasData &&
                                asyncSnapshot.data != null) {
                              return CustomLottie(
                                asset: "assets/lotties/audio_playing.json",
                                width: 50,
                                height: 50,
                                animate: asyncSnapshot.data!,
                              );
                            }
                            return SizedBox();
                          },
                        ),
                      if (keepFavbtn) ...{
                        FavoriteButton(songFavorite: song),
                      } else ...{
                        IconButton(
                          onPressed: () {
                            betaInfo(context);
                          },
                          icon: const Icon(Icons.more_vert),
                          padding: EdgeInsets.zero,
                        ),
                      },
                    ],
                  )
                : isTrailingChange
                ? (trailing ?? const SizedBox())
                : FavoriteButton(
                    key: ValueKey("fav_${song.id}"),
                    songFavorite: song,
                  ),
          ),
        );
      },
    );
  }
}
