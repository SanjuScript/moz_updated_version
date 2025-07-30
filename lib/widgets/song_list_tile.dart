import 'package:flutter/material.dart';
import 'package:moz_updated_version/home/presentation/widgets/audio_artwork.dart';
import 'package:on_audio_query/on_audio_query.dart';


class CustomSongTile extends StatelessWidget {
  final bool isTrailingChange;
  final bool disableOnTap;
  final Widget? trailing;
  final SongModel song;
  final void Function()? remove;
  final void Function()? onTap;
  final bool isSelecting;
  final int index;

  const CustomSongTile({
    super.key,
    required this.song,
    this.isSelecting = false,
    this.isTrailingChange = false,
    this.disableOnTap = false,
    this.trailing,
    this.onTap,
    this.remove,

    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Theme.of(context).scaffoldBackgroundColor,
      leading: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.25,
        width: MediaQuery.sizeOf(context).width * 0.16,
        child: AudioArtworkDefinerForOthers(
          id: song.id,
          imgRadius: 8,
          iconSize: 30,
        ),
      ),
      title: Text(
        song.title,
        maxLines: 1,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: Theme.of(context).disabledColor,
          letterSpacing: .1,
          fontFamily: 'rounder',
          overflow: TextOverflow.ellipsis,
        ),
      ),
      onLongPress: () async {
        // bottomDetailsSheet(
        //   context: context,
        //   enableRemoveButton: true,
        //   remove: remove,
        //   song: songs,
        //   index: index,
        //   onTap: () {
        //     //MozController.addToNext(song);
        //   },
        // );
        // await DataController.deleteImageFile(File(song.data));
      },
      selectedTileColor: Theme.of(context).scaffoldBackgroundColor,
      selectedColor: Theme.of(context).scaffoldBackgroundColor,
      focusColor: Theme.of(context).scaffoldBackgroundColor,
      hoverColor: Theme.of(context).scaffoldBackgroundColor,
      subtitle: Text(
        // artistHelper(song.artist.toString(), song.fileExtension),
        song.artist!,
        maxLines: 1,
        style: TextStyle(
          fontSize: 13,
          fontFamily: 'rounder',
          overflow: TextOverflow.ellipsis,
          fontWeight: FontWeight.normal,
          color: Theme.of(context).cardColor.withOpacity(.4),
        ),
      ),
      onTap: disableOnTap
          ? onTap
          : () async {
              // if (songs.isNotEmpty && songs != null) {
              //   await MozController.createSongList(songs);
              //   await MozController.player.seek(Duration.zero, index: index);
              //   // MozController.player.setAudioSource(
              //   //     await MozController.createSongList(songs),
              //   //     initialIndex: index);
              //   if (MozController.player.playing != true) {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => NowPlaying(songModelList: songs),
              //       ),
              //     );
              //   }
              //   MozController.play();
              // }
            },
      trailing: isTrailingChange
          ? trailing
          :null,
    );
  }
}

