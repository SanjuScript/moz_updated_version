import 'dart:io';
import 'dart:ui';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moz_updated_version/widgets/audio_artwork_widget.dart';

class SongDetailScreen extends StatelessWidget {
  final MediaItem song;

  const SongDetailScreen({super.key, required this.song});

  String _formatDuration(Duration duration) {
    return "${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final extras = song.extras ?? {};

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Song Details"),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: song.artUri != null
                ? Image.file(
                    File(song.artUri!.toFilePath()),
                    fit: BoxFit.fill,
                    errorBuilder: (_, __, ___) => Container(
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: .5),
                    ),
                  )
                : Container(
                    color: Theme.of(context).primaryColor.withValues(alpha: .5),
                  ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Container(color: Colors.black.withValues(alpha: 0.4)),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 100, left: 16, right: 16),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.file(
                      gaplessPlayback: true,
                      File(song.artUri?.toFilePath() ?? ""),
                      height: 280,
                      filterQuality: FilterQuality.high,
                      width: 280,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 280,
                        width: 280,
                        color: Colors.grey.shade300,
                        child: const Icon(
                          Icons.music_note,
                          size: 100,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  // AudioArtWorkWidget(id: int.parse(song.id),size: 500,),
                  const SizedBox(height: 24),
                  Text(
                    song.title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    song.artist ?? "Unknown Artist",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: .5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32),
                  glassCard(
                    context,
                    children: [
                      buildDetailRow("Album", song.album ?? "Unknown", context),
                      buildDetailRow(
                        "Duration",
                        _formatDuration(song.duration ?? Duration.zero),
                        context,
                      ),
                      buildDetailRow(
                        "File Size",
                        "${((extras['size'] ?? 0) / (1024 * 1024)).toStringAsFixed(2)} MB",
                        context,
                      ),
                      buildDetailRow(
                        "File Type",
                        extras['fileExtension'] ?? "mp3",
                        context,
                      ),
                      buildDetailRow(
                        "Added On",
                        DateFormat.yMMMd().format(
                          DateTime.fromMillisecondsSinceEpoch(
                            (extras['dateAdded'] ?? 0) * 1000,
                          ),
                        ),
                        context,
                      ),
                      buildDetailRow(
                        "Path",
                        extras['data'] ?? "Unknown",
                        context,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget glassCard(BuildContext context, {required List<Widget> children}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(
                context,
              ).primaryColor.withValues(alpha: .5).withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    );
  }

  Widget buildDetailRow(String label, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor.withValues(alpha: .4).withRed(10),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
