import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:moz_updated_version/screens/favorite_screen/presentation/widgets/fav_button.dart';
import 'package:moz_updated_version/widgets/audio_artwork_widget.dart';
import 'package:moz_updated_version/widgets/song_detail_sheet.dart';
import 'package:on_audio_query/on_audio_query.dart';

class CustomSongTile extends StatelessWidget {
  final bool isTrailingChange;
  final Widget? trailing;
  final SongModel song;
  final void Function()? remove;
  final void Function()? onTap;
  final bool isSelecting;
  final bool isPlaying;
  final bool showSheet;
  final EdgeInsets? padding;
  const CustomSongTile({
    super.key,
    required this.song,
    this.isSelecting = false,
    this.isTrailingChange = false,
    this.isPlaying = false,
    this.showSheet = true,
    this.trailing,
    this.padding,
    this.onTap,
    this.remove,
  });

  @override
  Widget build(BuildContext context) {
    final extras = song.getMap;
    final isOnline = extras["isOnline"] == true;
    final url = isOnline ? (extras["image"] as String?) : null;

    log(name: "URL", url.toString());

    return ListTile(
      contentPadding: padding,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
      tileColor: isPlaying
          ? Theme.of(context).primaryColor.withValues(alpha: .9)
          : Colors.transparent,
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
        child: isTrailingChange
            ? (trailing ?? const SizedBox())
            : FavoriteButton(
                key: ValueKey("fav_${song.id}"),
                songFavorite: song,
              ),
      ),
    );
  }
}
