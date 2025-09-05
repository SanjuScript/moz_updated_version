import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'dart:typed_data';

class AudioArtWorkWidget extends StatefulWidget {
  final int id;
  final int size;
  final bool isRectangle;
  final double radius;
  final double imgRadius;
  final ArtworkType type;
  final bool visibleShadow;
  final double iconSize;

  const AudioArtWorkWidget({
    super.key,
    required this.id,
    this.size = 250,
    this.iconSize = 70,
    this.imgRadius = 30,
    this.isRectangle = false,
    this.radius = 0,
    this.visibleShadow = false,
    this.type = ArtworkType.AUDIO,
  });

  @override
  _AudioArtWorkWidgetState createState() => _AudioArtWorkWidgetState();
}

class _AudioArtWorkWidgetState extends State<AudioArtWorkWidget>
    with AutomaticKeepAliveClientMixin {
  late Future<Uint8List?> _artworkFuture;
  late int _currentId;

  @override
  void initState() {
    super.initState();
    _currentId = widget.id;
    _loadArtwork();
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
    _artworkFuture = OnAudioQuery().queryArtwork(
      widget.id,
      widget.type,
      format: ArtworkFormat.JPEG,
      size: widget.size,
      quality: 100,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<Uint8List?>(
      future: _artworkFuture,
      builder: (context, snapshot) {
        return _buildArtworkWidget(snapshot);
      },
    );
  }

  Widget _buildArtworkWidget(AsyncSnapshot<Uint8List?> snapshot) {
    if (snapshot.data != null && snapshot.data!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(widget.imgRadius),
        clipBehavior: Clip.antiAlias,
        child: Image.memory(
          snapshot.data!,
          gaplessPlayback: true,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
          errorBuilder: (context, exception, stackTrace) {
            return const Icon(
              Icons.image_not_supported,
              size: 50,
            );
          },
        ),
      );
    } else {
      return Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Theme.of(context).indicatorColor,
          borderRadius: BorderRadius.circular(widget.imgRadius),
        ),
        child: Icon(
          Icons.music_note_rounded,
          size: widget.iconSize,
          color: Theme.of(context).secondaryHeaderColor,
        ),
      );
    }
  }

  @override
  bool get wantKeepAlive => true;
}
