import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:moz_updated_version/core/extensions/song_model_ext.dart';
import 'package:moz_updated_version/screens/favorite_screen/presentation/widgets/fav_button.dart';
import 'package:on_audio_query/on_audio_query.dart';

class TextBoxesWidgets extends StatelessWidget {
  final MediaItem song;
  const TextBoxesWidgets({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: MediaQuery.sizeOf(context).width * .70,
              child: Text(
                song.title ?? "Unknown",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(
              width: MediaQuery.sizeOf(context).width * .70,
              child: Text(
                song.artist ?? "Unknown Artist",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ),
          ],
        ),

        FavoriteButton(songFavorite: song.toSongModel(), showShadow: false),
      ],
    );
  }
}
