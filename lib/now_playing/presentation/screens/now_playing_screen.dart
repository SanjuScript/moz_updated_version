
import 'package:audio_service/audio_service.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:moz_updated_version/home/presentation/widgets/audio_artwork_sep.dart';
import 'package:moz_updated_version/main.dart';

class NowPlayingCarousel extends StatefulWidget {
  final List<MediaItem> queue;
  final int currentIndex;
  final void Function(int index) onPageChanged;

  const NowPlayingCarousel({
    super.key,
    required this.queue,
    required this.currentIndex,
    required this.onPageChanged,
  });

  @override
  State<NowPlayingCarousel> createState() => _NowPlayingCarouselState();
}

class _NowPlayingCarouselState extends State<NowPlayingCarousel> {
  late CarouselSliderController _carouselController;

  @override
  void initState() {
    super.initState();
    _carouselController = CarouselSliderController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carouselController.jumpToPage(widget.currentIndex);
    });
  }

  @override
  void didUpdateWidget(covariant NowPlayingCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _carouselController.animateToPage(
        widget.currentIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      carouselController: _carouselController,
      itemCount: widget.queue.length,
      itemBuilder: (context, index, realIdx) {
        final mediaItem = widget.queue[index];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Hero(
            tag: 'artwork_${mediaItem.id}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: mediaItem.artUri != null
                  ? AudioArtworkDefiner(
                      id: int.tryParse(mediaItem.id.split('/').last) ?? 0,
                    )
                  : Image.asset(
                      'assets/images/placeholder.jpg',
                      fit: BoxFit.cover,
                    ),
            ),
          ),
        );
      },
      options: CarouselOptions(
        height: 350,
        enlargeCenterPage: true,
        viewportFraction: 0.8, // 10–15% of next/prev visible
        onPageChanged: (index, reason) {
          widget.onPageChanged(index);
        },
      ),
    );
  }
}

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final audiohandler = audioHandler;
    final queue = audioHandler.queue.value;
    final currentMedia = audioHandler.mediaItem.value;
    final currentIndex = queue.indexWhere((m) => m.id == currentMedia?.id);
    final extractedId = currentMedia!.id.split('/').last;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            NowPlayingCarousel(
              queue: queue,
              currentIndex: currentIndex >= 0 ? currentIndex : 0,
              onPageChanged: (index) {
                final item = queue[index];
                audioHandler.skipToQueueItem(index);
                audioHandler.play();
              },
            ),
            const SizedBox(height: 30),
            Text(
              currentMedia?.title ?? '',
              style: const TextStyle(color: Colors.white, fontSize: 22),
              textAlign: TextAlign.center,
            ),
            Text(
              currentMedia?.artist ?? '',
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const Spacer(),
            // PlaybackControls(), // Your custom widget for play/pause, next, prev
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
