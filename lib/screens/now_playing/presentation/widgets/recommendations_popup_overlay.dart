import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audio_service/audio_service.dart';
import 'package:moz_updated_version/data/repository/saavn_repository.dart';
import 'package:moz_updated_version/services/service_locator.dart';
import 'package:moz_updated_version/screens/ONLINE/album_screen/presentation/cubit/collection_cubit.dart';
import 'package:moz_updated_version/screens/ONLINE/album_screen/presentation/ui/collection_screen.dart';
import 'package:moz_updated_version/screens/now_playing/presentation/widgets/text_boxes.dart';
import 'package:moz_updated_version/widgets/custom_cached_image.dart';

class RecommendationsOverlayWrapper extends StatelessWidget {
  final MediaItem song;
  const RecommendationsOverlayWrapper({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        TextBoxesWidgets(song: song),
        Positioned(
          left: 20,
          right: 20,
          bottom: 75,
          child: RecommendationsPopupOverlay(song: song),
        ),
      ],
    );
  }
}

class RecommendationsPopupOverlay extends StatefulWidget {
  final MediaItem song;
  const RecommendationsPopupOverlay({super.key, required this.song});

  @override
  State<RecommendationsPopupOverlay> createState() =>
      _RecommendationsPopupOverlayState();
}

class _RecommendationsPopupOverlayState
    extends State<RecommendationsPopupOverlay> {
  final SaavnRepository _saavnRepo = sl<SaavnRepository>();

  Map<String, dynamic>? _similarAlbum;
  Map<String, dynamic>? _similarArtist;

  bool _showAlbumPopup = false;
  bool _showArtistPopup = false;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  @override
  void didUpdateWidget(RecommendationsPopupOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.song.id != widget.song.id) {
      _loadRecommendations();
    }
  }

  Future<void> _loadRecommendations() async {
    if (mounted) {
      setState(() {
        _showAlbumPopup = false;
        _showArtistPopup = false;
        _similarAlbum = null;
        _similarArtist = null;
      });
    }

    final isOnline = int.tryParse(widget.song.id) == null;
    if (!isOnline) return;

    try {
      final songDetails = await _saavnRepo.songDetails(widget.song.id);
      final albumId = songDetails['albumid']?.toString();
      final primaryArtistsIdStr = songDetails['primary_artists_id']?.toString();
      final artistId =
          (primaryArtistsIdStr != null && primaryArtistsIdStr.isNotEmpty)
          ? primaryArtistsIdStr.split(',').first.trim()
          : null;

      if (albumId != null && albumId.isNotEmpty) {
        final albumReco = await _saavnRepo.recoAlbum(albumId);
        if (albumReco.isNotEmpty) {
          _similarAlbum = Map<String, dynamic>.from(albumReco.first);
        }
      }

      if (artistId != null && artistId.isNotEmpty) {
        final artistInfo = await _saavnRepo.artistDetails(artistId);
        final artistReco = artistInfo['similarArtists'] as List?;
        if (artistReco != null && artistReco.isNotEmpty) {
          _similarArtist = Map<String, dynamic>.from(artistReco.first);
        }
      }

      if (mounted) {
        _startSequence();
      }
    } catch (e) {
      debugPrint("Error loading overlay recommendations: $e");
    }
  }

  Future<void> _startSequence() async {
    if (!mounted) return;

    if (_similarAlbum != null) {
      await Future.delayed(const Duration(milliseconds: 1000));
      if (!mounted) return;
      setState(() {
        _showAlbumPopup = true;
      });
    }

    if (_similarArtist != null) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      setState(() {
        _showArtistPopup = true;
      });
    }
  }

  void _navigateToAlbum(String albumId) {
    context.read<CollectionCubitForOnline>().loadAlbum(albumId, "album");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const OnlineAlbumScreen()),
    );
  }

  void _navigateToArtist(String artistId) {
    context.read<CollectionCubitForOnline>().loadArtist(artistId);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const OnlineAlbumScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_showAlbumPopup && !_showArtistPopup) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AnimatedCard(
          visible: _showArtistPopup && _similarArtist != null,
          child: _similarArtist != null
              ? _buildPopupCard(
                  title: "Similar Artist: ${_similarArtist!['name']}",
                  imageUrl: _similarArtist!['image'] ?? '',
                  icon: Icons.person_rounded,
                  iconColor: Colors.orangeAccent,
                  hasTail: !_showAlbumPopup,
                  onTap: () => _navigateToArtist(_similarArtist!['id']),
                  onClose: () {
                    setState(() {
                      _showArtistPopup = false;
                    });
                  },
                )
              : const SizedBox.shrink(),
        ),
        if (_showAlbumPopup && _showArtistPopup) const SizedBox(height: 6),
        _AnimatedCard(
          visible: _showAlbumPopup && _similarAlbum != null,
          child: _similarAlbum != null
              ? _buildPopupCard(
                  title: "Similar Album: ${_similarAlbum!['title']}",
                  imageUrl: _similarAlbum!['image'] ?? '',
                  icon: Icons.album_rounded,
                  iconColor: Theme.of(context).primaryColor,
                  hasTail: true,
                  onTap: () => _navigateToAlbum(_similarAlbum!['id']),
                  onClose: () {
                    setState(() {
                      _showAlbumPopup = false;
                    });
                  },
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildPopupCard({
    required String title,
    required String imageUrl,
    required IconData icon,
    required Color iconColor,
    required bool hasTail,
    required VoidCallback onTap,
    required VoidCallback onClose,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const double tailHeight = 5.0;

    final cardContent = ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          color: isDark
              ? Colors.black.withAlpha(130)
              : Colors.white.withAlpha(160),
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (imageUrl.isNotEmpty)
                    CustomCachedImage(
                      imageUrl: imageUrl,
                      width: 24,
                      height: 24,
                      radius: 12,
                    )
                  else
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: iconColor, size: 14),
                    ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: isDark ? Colors.white30 : Colors.black38,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Container(
                    height: 12,
                    width: 1,
                    color: isDark ? Colors.white10 : Colors.black12,
                  ),
                  const SizedBox(width: 2),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      Icons.close_rounded,
                      color: isDark ? Colors.white38 : Colors.black38,
                      size: 14,
                    ),
                    onPressed: onClose,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return CustomPaint(
      painter: hasTail
          ? LeftTailBubblePainter(
              color: isDark
                  ? Colors.black.withAlpha(130)
                  : Colors.white.withAlpha(160),
              borderColor: isDark ? Colors.white10 : Colors.black.withAlpha(25),
            )
          : null,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 260),
        decoration: !hasTail
            ? BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.black.withAlpha(25),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(isDark ? 30 : 15),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              )
            : null,
        padding: EdgeInsets.only(bottom: hasTail ? tailHeight : 0),
        child: cardContent,
      ),
    );
  }
}

class LeftTailBubblePainter extends CustomPainter {
  final Color color;
  final Color borderColor;

  LeftTailBubblePainter({required this.color, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final path = Path();
    const double radius = 20.0;
    const double tailWidth = 10.0;
    const double tailHeight = 5.0;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height - tailHeight),
      const Radius.circular(radius),
    );
    path.addRRect(rrect);

    const double centerX = 20.0;
    final tailPath = Path()
      ..moveTo(centerX - tailWidth / 2, size.height - tailHeight)
      ..lineTo(centerX, size.height)
      ..lineTo(centerX + tailWidth / 2, size.height - tailHeight)
      ..close();
    path.addPath(tailPath, Offset.zero);

    canvas.drawShadow(path, Colors.black.withAlpha(25), 6.0, true);
    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PopWaveCurve extends Curve {
  const PopWaveCurve();

  @override
  double transformInternal(double t) {
    // Apple-style overshooting spring oscillation simulation
    return 1.0 - math.exp(-5.0 * t) * math.cos(9.0 * t);
  }
}

class _AnimatedCard extends StatelessWidget {
  final bool visible;
  final Widget child;

  const _AnimatedCard({required this.visible, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: visible ? 1.0 : 0.0,
      curve: Curves.easeOut,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 700),
        scale: visible ? 1.0 : 0.0,
        curve: visible ? const PopWaveCurve() : Curves.easeIn,
        child: child,
      ),
    );
  }
}
