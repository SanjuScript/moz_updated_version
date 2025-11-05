import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'dart:typed_data';

Future<Uint8List?> getSongArtwork(
  int songId, {
  ArtworkType type = ArtworkType.AUDIO,
  int size = 250,
  int quality = 100,
}) async {
  final OnAudioQuery audioQuery = OnAudioQuery();

  try {
    final Uint8List? artwork = await audioQuery.queryArtwork(
      songId,
      type,
      format: ArtworkFormat.JPEG,
      size: size,
      quality: quality,
    );

    if (artwork == null || artwork.isEmpty) return null;

    return artwork;
  } catch (e) {
    log("Error fetching artwork for songId $songId: $e");
    return null;
  }
}

class AudioArtWorkWidget extends StatefulWidget {
  final int? id;
  final int size;
  final double radius;
  final ArtworkType type;
  final double iconSize;
  final bool isNowplaying;
  const AudioArtWorkWidget({
    super.key,
    required this.id,
    this.size = 250,
    this.iconSize = 70,
    this.radius = 8,
    this.isNowplaying = false,
    this.type = ArtworkType.AUDIO,
  });
  @override
  _AudioArtWorkWidgetState createState() => _AudioArtWorkWidgetState();
}

class _AudioArtWorkWidgetState extends State<AudioArtWorkWidget>
    with AutomaticKeepAliveClientMixin {
  late Future<Uint8List?> _artworkFuture;
  late int? _currentId;
  @override
  void initState() {
    super.initState();
    _currentId = widget.id;
    if (_currentId != null) {
      _loadArtwork();
    } else {
      _artworkFuture = Future.value(null);
    }
  }

  @override
  void didUpdateWidget(covariant AudioArtWorkWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.id != _currentId) {
      _currentId = widget.id;
      _loadArtwork();
    }
  }

  void _loadArtwork() {
    if (widget.id == null) {
      _artworkFuture = Future.value(null);
      return;
    }
    _artworkFuture = OnAudioQuery().queryArtwork(
      widget.id!,
      widget.type,
      format: ArtworkFormat.JPEG,
      size: widget.size,
      quality: 100,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (widget.id == null) {
      return _fallbackIcon(context);
    }
    return FutureBuilder<Uint8List?>(
      future: _artworkFuture,
      builder: (context, snapshot) {
        return _buildArtworkWidget(snapshot, context);
      },
    );
  }

  Widget _buildArtworkWidget(
    AsyncSnapshot<Uint8List?> snapshot,
    BuildContext context,
  ) {
    final size = MediaQuery.sizeOf(context);
    if (snapshot.data != null && snapshot.data!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(widget.radius),
        clipBehavior: Clip.antiAlias,
        child: Image.memory(
          height: size.height * .48,
          width: size.width * .92,
          snapshot.data!,
          gaplessPlayback: true,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
          errorBuilder: (context, exception, stackTrace) {
            return const Icon(Icons.image_not_supported, size: 50);
          },
        ),
      );
    } else {
      return _fallbackIcon(context);
    }
  }

  Widget _fallbackIcon(BuildContext contex) {
    final size = MediaQuery.sizeOf(context);
    return Container(
      height: size.height * .48,
      width: size.width * .92,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).hintColor,

        borderRadius: BorderRadius.circular(widget.radius),
      ),
      child: Icon(
        Icons.music_note_rounded,
        size: widget.iconSize,
        color: Theme.of(context).textTheme.titleSmall!.color,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
