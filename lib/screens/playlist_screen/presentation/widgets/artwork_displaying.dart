import 'package:flutter/material.dart';
import 'package:moz_updated_version/widgets/audio_artwork_widget.dart';

class PlaylistGridItem extends StatelessWidget {
  final dynamic playlist;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PlaylistGridItem({
    super.key,
    required this.playlist,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final songCount = playlist.songIds?.length ?? 0;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).hintColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.18,
                      width: double.infinity,
                      child: songCount < 3
                          ? _singleArtwork(context)
                          : _stackedArtwork(),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      playlist.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      "$songCount songs",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: PopupMenuButton<String>(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    onSelected: (value) {
                      if (value == 'edit') onEdit();
                      if (value == 'delete') onDelete();
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                    icon: const Icon(Icons.more_vert),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _singleArtwork(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: playlist.songIds != null && playlist.songIds!.isNotEmpty
          ? AudioArtWorkWidget(id: playlist.artwork, size: 500)
          : Container(
              height: 120,
              width: 120,
              color: Colors.grey.shade300,
              child: const Icon(
                Icons.music_note,
                size: 50,
                color: Colors.white,
              ),
            ),
    );
  }

  Widget _stackedArtwork() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (playlist.songIds != null && playlist.songIds!.length > 2)
          Positioned(
            left: 24,
            top: 12,
            child: Transform.rotate(
              angle: -0.15,
              child: _artworkContainer(playlist.songIds[2]),
            ),
          ),
        if (playlist.songIds != null && playlist.songIds!.length > 1)
          Positioned(
            left: 12,
            top: 6,
            child: Transform.rotate(
              angle: 0.1,
              child: _artworkContainer(playlist.songIds[1]),
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AudioArtWorkWidget(id: playlist.artwork, size: 120),
        ),
      ],
    );
  }

  Widget _artworkContainer(int songId) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(2, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: AudioArtWorkWidget(id: songId, size: 120),
    );
  }
}
