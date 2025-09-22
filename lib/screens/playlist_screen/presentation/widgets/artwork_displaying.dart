import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lottie/lottie.dart';
import 'package:moz_updated_version/main.dart';
import 'package:moz_updated_version/widgets/audio_artwork_widget.dart';

class PlaylistGridItem extends StatelessWidget {
  final dynamic playlist;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isNowPlaying;

  const PlaylistGridItem({
    super.key,
    required this.playlist,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.isNowPlaying,
  });

  @override
  Widget build(BuildContext context) {
    final songCount = playlist.songIds?.length ?? 0;

    return InkWell(
      onTap: onTap,
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
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
                      height: MediaQuery.sizeOf(context).height * 0.19,
                      width: double.infinity,
                      child: songCount < 3
                          ? _singleArtwork(context)
                          : _stackedArtwork(context),
                    ),

                    const SizedBox(height: 8),
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width * .36,
                      child: Text(
                        playlist.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
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
                  right: -10,
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
      child: AudioArtWorkWidget(id: playlist.artwork, size: 500),
    );
  }

  Widget _stackedArtwork(BuildContext context) {
    final List<int> songIds = playlist.songIds ?? [];

    if (songIds.length >= 4) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          itemBuilder: (context, index) {
            if (index == 0 && isNowPlaying) {
              return _lottieNowPlaying();
            }
            return _artworkContainer(songIds[index]);
          },
        ),
      );
    }

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.18,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (songIds.length > 2)
            Positioned(
              left: 24,
              top: 12,
              child: Transform.rotate(
                angle: -0.12,
                child: _miniArtwork(songIds[2]),
              ),
            ),
          if (songIds.length > 1)
            Positioned(
              left: 12,
              top: 6,
              child: Transform.rotate(
                angle: 0.08,
                child: _miniArtwork(songIds[1]),
              ),
            ),
          isNowPlaying ? _lottieNowPlaying() : _artworkContainer(songIds.first),
        ],
      ),
    );
  }

  Widget _miniArtwork(int songId) {
    return SizedBox(width: 60, height: 60, child: _artworkContainer(songId));
  }

  Widget _lottieNowPlaying() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: StreamBuilder<bool>(
        stream: audioHandler.isPlaying,
        builder: (context, asyncSnapshot) {
          return Lottie.asset(
            "assets/lotties/playlist_anim.json",
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            repeat: true,
            animate: asyncSnapshot.data,
          );
        },
      ),
    );
  }

  Widget _artworkContainer(int songId) {
    return Container(
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AudioArtWorkWidget(id: songId, size: 500, iconSize: 30),
      ),
    );
  }
}
