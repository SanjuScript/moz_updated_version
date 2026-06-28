import 'dart:io';
import 'dart:ui';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SongDetailScreen extends StatelessWidget {
  final MediaItem song;

  const SongDetailScreen({super.key, required this.song});

  String _formatDuration(Duration duration) {
    return "${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final extras = song.extras ?? {};
    final bool isOnline = extras['isOnline'] == true || int.tryParse(song.id) == null;
    final bool isFileUri = song.artUri != null && song.artUri!.isScheme('file');
    final bool isNetworkUri = song.artUri != null &&
        (song.artUri!.isScheme('http') || song.artUri!.isScheme('https'));

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Song Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: isFileUri
                ? Image.file(File(song.artUri!.toFilePath()), fit: BoxFit.cover)
                : isNetworkUri
                    ? Image.network(song.artUri!.toString(), fit: BoxFit.cover)
                    : Container(color: Colors.black),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 35, sigmaY: 35),
              child: Container(color: Colors.black.withValues(alpha: 0.65)),
            ),
          ),
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.only(
                top: 100,
                left: 20,
                right: 20,
                bottom: 30,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: isFileUri
                          ? Image.file(
                              File(song.artUri!.toFilePath()),
                              height: 260,
                              width: 260,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _fallbackCover(),
                            )
                          : isNetworkUri
                              ? Image.network(
                                  song.artUri!.toString(),
                                  height: 260,
                                  width: 260,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _fallbackCover(),
                                )
                              : _fallbackCover(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    song.title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),

                  Text(
                    song.artist ?? "Unknown Artist",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white70,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 32),

                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.55,
                    children: isOnline
                        ? [
                            _buildAppleTile(
                              context,
                              icon: Icons.album_rounded,
                              iconBg: Colors.blueAccent.withAlpha(40),
                              iconColor: Colors.blue,
                              label: "ALBUM",
                              value: song.album ?? "Unknown",
                            ),
                            _buildAppleTile(
                              context,
                              icon: Icons.access_time_rounded,
                              iconBg: Colors.greenAccent.withAlpha(40),
                              iconColor: Colors.green,
                              label: "DURATION",
                              value: _formatDuration(song.duration ?? Duration.zero),
                            ),
                            if (extras['year'] != null && extras['year'].toString().isNotEmpty)
                              _buildAppleTile(
                                context,
                                icon: Icons.calendar_today_rounded,
                                iconBg: Colors.orangeAccent.withAlpha(40),
                                iconColor: Colors.orange,
                                label: "RELEASED",
                                value: extras['year'].toString(),
                              ),
                            if (extras['language'] != null && extras['language'].toString().isNotEmpty)
                              _buildAppleTile(
                                context,
                                icon: Icons.language_rounded,
                                iconBg: Colors.purpleAccent.withAlpha(40),
                                iconColor: Colors.purpleAccent,
                                label: "LANGUAGE",
                                value: extras['language'].toString().toUpperCase(),
                              ),
                            _buildAppleTile(
                              context,
                              icon: Icons.high_quality_rounded,
                              iconBg: Colors.pinkAccent.withAlpha(40),
                              iconColor: Colors.pinkAccent,
                              label: "QUALITY",
                              value: "320kbps HD",
                            ),
                            _buildAppleTile(
                              context,
                              icon: Icons.cloud_queue_rounded,
                              iconBg: Colors.tealAccent.withAlpha(40),
                              iconColor: Colors.teal,
                              label: "SOURCE",
                              value: "JioSaavn",
                            ),
                          ]
                        : [
                            _buildAppleTile(
                              context,
                              icon: Icons.album_rounded,
                              iconBg: Colors.blueAccent.withAlpha(40),
                              iconColor: Colors.blue,
                              label: "ALBUM",
                              value: song.album ?? "Unknown",
                            ),
                            _buildAppleTile(
                              context,
                              icon: Icons.access_time_rounded,
                              iconBg: Colors.greenAccent.withAlpha(40),
                              iconColor: Colors.green,
                              label: "DURATION",
                              value: _formatDuration(song.duration ?? Duration.zero),
                            ),
                            _buildAppleTile(
                              context,
                              icon: Icons.sd_storage_rounded,
                              iconBg: Colors.orangeAccent.withAlpha(40),
                              iconColor: Colors.orange,
                              label: "FILE SIZE",
                              value: "${((extras['size'] ?? 0) / (1024 * 1024)).toStringAsFixed(2)} MB",
                            ),
                            _buildAppleTile(
                              context,
                              icon: Icons.audiotrack_rounded,
                              iconBg: Colors.purpleAccent.withAlpha(40),
                              iconColor: Colors.purpleAccent,
                              label: "FILE TYPE",
                              value: (extras['fileExtension'] ?? "mp3").toString().toUpperCase(),
                            ),
                            _buildAppleTile(
                              context,
                              icon: Icons.calendar_today_rounded,
                              iconBg: Colors.pinkAccent.withAlpha(40),
                              iconColor: Colors.pink,
                              label: "ADDED ON",
                              value: (extras['dateAdded'] != null)
                                  ? DateFormat.yMMMd().format(
                                      DateTime.fromMillisecondsSinceEpoch(
                                        (extras['dateAdded'] ?? 0) * 1000,
                                      ),
                                    )
                                  : "Unknown",
                            ),
                            _buildAppleTile(
                              context,
                              icon: Icons.folder_rounded,
                              iconBg: Colors.tealAccent.withAlpha(40),
                              iconColor: Colors.teal,
                              label: "PATH",
                              value: (extras['data'] != null)
                                  ? extras['data'].toString().split('/').last
                                  : "Local Storage",
                            ),
                          ],
                  ),
                  if (!isOnline && extras['data'] != null) ...[
                    const SizedBox(height: 16),
                    _buildWidePathCard(context, path: extras['data'].toString()),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppleTile(
    BuildContext context, {
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(isDark ? 15 : 20),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withAlpha(isDark ? 20 : 30),
              width: 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white60,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWidePathCard(BuildContext context, {required String path}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(isDark ? 15 : 20),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withAlpha(isDark ? 20 : 30),
              width: 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.folder_open_rounded, color: Colors.tealAccent.shade400, size: 18),
                  const SizedBox(width: 8),
                  const Text(
                    "FILE LOCATION",
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: Colors.white60,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                path,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: Colors.white70,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fallbackCover() {
    return Container(
      height: 260,
      width: 260,
      color: Colors.grey.shade800,
      child: const Icon(
        Icons.music_note,
        size: 100,
        color: Colors.white70,
      ),
    );
  }
}
