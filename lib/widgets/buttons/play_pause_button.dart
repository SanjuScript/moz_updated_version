import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:moz_updated_version/main.dart';

class PlayPauseButton extends StatelessWidget {
  const PlayPauseButton({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlaybackState>(
      stream: audioHandler.playbackState,
      builder: (context, snapshot) {
        final playbackState = snapshot.data;
        final playing = playbackState?.playing ?? false;

        return InkWell(
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          onTap: () async {
            if (playing) {
              await audioHandler.pause();
            } else {
              await audioHandler.play();
            }
          },
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFFF4081), Color(0xFFFF80AB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.pink.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              playing ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: size * 0.5,
            ),
          ),
        );
      },
    );
  }
}
