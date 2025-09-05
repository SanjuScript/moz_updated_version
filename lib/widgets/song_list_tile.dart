import 'package:flutter/material.dart';
import 'package:moz_updated_version/widgets/audio_artwork_widget.dart';
import 'package:on_audio_query/on_audio_query.dart';

class CustomSongTile extends StatelessWidget {
  final bool isTrailingChange;
  final bool disableOnTap;
  final Widget? trailing;
  final SongModel song;
  final void Function()? remove;
  final void Function()? onTap;
  final bool isSelecting;

  const CustomSongTile({
    super.key,
    required this.song,
    this.isSelecting = false,
    this.isTrailingChange = false,
    this.disableOnTap = false,
    this.trailing,
    this.onTap,
    this.remove,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.25,
        width: MediaQuery.sizeOf(context).width * 0.16,
        child: AudioArtWorkWidget(
          id: song.id,
          imgRadius: 8,
          iconSize: 30,
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
      onLongPress: () async {},

      subtitle: Text(
        song.artist!,
        maxLines: 1,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(letterSpacing: .3),
      ),
      onTap: disableOnTap ? onTap : () async {},
      trailing: isTrailingChange ? trailing : null,
    );
  }
}
