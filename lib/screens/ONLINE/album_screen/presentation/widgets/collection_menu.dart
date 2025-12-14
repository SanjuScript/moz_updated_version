import 'package:flutter/material.dart';
import 'package:moz_updated_version/data/model/online_models/album_model.dart';
import 'package:moz_updated_version/widgets/custom_menu/custom_popmenu.dart';

class AlbumOptionsMenu extends StatelessWidget {
  final AlbumResponse album;

  const AlbumOptionsMenu({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    return GlassPopMenuButton(
      padding: EdgeInsetsGeometry.only(left: 10, right: 5),
      icon: const Icon(Icons.more_vert_rounded),
      items: [
        GlassPopMenuEntry(
          value: 'play_album',
          child: const ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.play_arrow),
            title: Text('Play album now'),
          ),
        ),
        GlassPopMenuEntry(
          value: 'share',
          child: const ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.share),
            title: Text('Share'),
          ),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'play_album':
            // onPlayAlbum();
            break;
          case 'share':
            // onShare();
            break;
        }
      },
    );
  }
}
