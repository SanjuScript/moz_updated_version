// import 'package:flutter/material.dart';

// /// Custom page route with artwork expansion animation
// class LyricsPageRoute extends PageRouteBuilder {
//   final Widget page;
//   final Offset artworkPosition;
//   final Size artworkSize;

//   LyricsPageRoute({
//     required this.page,
//     required this.artworkPosition,
//     required this.artworkSize,
//   }) : super(
//          pageBuilder: (context, animation, secondaryAnimation) => page,
//          transitionDuration: const Duration(milliseconds: 800),
//          reverseTransitionDuration: const Duration(milliseconds: 600),
//          transitionsBuilder: (context, animation, secondaryAnimation, child) {
//            return FadeTransition(
//              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
//                CurvedAnimation(
//                  parent: animation,
//                  curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
//                ),
//              ),
//              child: child,
//            );
//          },
//        );
// }

// /// Widget wrapper for the now playing screen with animated elements
// class AnimatedNowPlayingContent extends StatefulWidget {
//   final Widget child;
//   final VoidCallback onArtworkTap;
//   final bool isTransitioning;

//   const AnimatedNowPlayingContent({
//     super.key,
//     required this.child,
//     required this.onArtworkTap,
//     this.isTransitioning = false,
//   });

//   @override
//   State<AnimatedNowPlayingContent> createState() =>
//       _AnimatedNowPlayingContentState();
// }

// class _AnimatedNowPlayingContentState extends State<AnimatedNowPlayingContent>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideUpAnimation;
//   late Animation<Offset> _slideDownAnimation;
//   late Animation<double> _scaleAnimation;

//   bool _isAnimating = false;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 600),
//       vsync: this,
//     );

//     // Fade animation for artwork and background
//     _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
//       ),
//     );

//     // Slide up animation for elements above artwork
//     _slideUpAnimation = Tween<Offset>(
//       begin: Offset.zero,
//       end: const Offset(0, -1.5),
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInCubic));

//     // Slide down animation for elements below artwork
//     _slideDownAnimation = Tween<Offset>(
//       begin: Offset.zero,
//       end: const Offset(0, 1.5),
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInCubic));

//     // Scale animation for artwork
//     _scaleAnimation = Tween<double>(
//       begin: 1.0,
//       end: 1.1,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   Future<void> _handleArtworkTap() async {
//     if (_isAnimating) return;

//     setState(() => _isAnimating = true);
//     await _controller.forward();
//     widget.onArtworkTap();

//     // Reset after navigation
//     await Future.delayed(const Duration(milliseconds: 100));
//     _controller.reset();
//     if (mounted) {
//       setState(() => _isAnimating = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _controller,
//       builder: (context, child) {
//         return Stack(
//           children: [
//             // Background fade
//             Opacity(opacity: _fadeAnimation.value, child: widget.child),

//             // Wrap specific sections with slide animations
//             // This is handled in the main widget
//           ],
//         );
//       },
//     );
//   }

//   // Expose these methods to wrap sections
//   Widget wrapAboveArtwork(Widget child) {
//     return SlideTransition(
//       position: _slideUpAnimation,
//       child: FadeTransition(opacity: _fadeAnimation, child: child),
//     );
//   }

//   Widget wrapArtwork(Widget child) {
//     return GestureDetector(
//       onTap: _handleArtworkTap,
//       child: ScaleTransition(
//         scale: _scaleAnimation,
//         child: FadeTransition(opacity: _fadeAnimation, child: child),
//       ),
//     );
//   }

//   Widget wrapBelowArtwork(Widget child) {
//     return SlideTransition(
//       position: _slideDownAnimation,
//       child: FadeTransition(opacity: _fadeAnimation, child: child),
//     );
//   }
// }

// /// Updated Now Playing Screen with custom animations
// class AnimatedNowPlayingWrapper extends StatefulWidget {
//   final Widget appBar;
//   final Widget artwork;
//   final Widget belowArtwork;
//   final VoidCallback onNavigateToLyrics;

//   const AnimatedNowPlayingWrapper({
//     super.key,
//     required this.appBar,
//     required this.artwork,
//     required this.belowArtwork,
//     required this.onNavigateToLyrics,
//   });

//   @override
//   State<AnimatedNowPlayingWrapper> createState() =>
//       _AnimatedNowPlayingWrapperState();
// }

// class _AnimatedNowPlayingWrapperState extends State<AnimatedNowPlayingWrapper>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideUpAnimation;
//   late Animation<Offset> _slideDownAnimation;
//   late Animation<double> _scaleAnimation;

//   bool _isAnimating = false;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 650),
//       vsync: this,
//     );

//     _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
//       ),
//     );

//     _slideUpAnimation =
//         Tween<Offset>(begin: Offset.zero, end: const Offset(0, -1.2)).animate(
//           CurvedAnimation(
//             parent: _controller,
//             curve: const Interval(0.0, 0.7, curve: Curves.easeInCubic),
//           ),
//         );

//     _slideDownAnimation =
//         Tween<Offset>(begin: Offset.zero, end: const Offset(0, 1.2)).animate(
//           CurvedAnimation(
//             parent: _controller,
//             curve: const Interval(0.0, 0.7, curve: Curves.easeInCubic),
//           ),
//         );

//     _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   Future<void> _handleArtworkTap() async {
//     if (_isAnimating) return;

//     setState(() => _isAnimating = true);
//     await _controller.forward();

//     widget.onNavigateToLyrics();

//     await Future.delayed(const Duration(milliseconds: 100));
//     if (mounted) {
//       _controller.reset();
//       setState(() => _isAnimating = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         Column(
//           children: [
//             // AppBar - slides up
//             SlideTransition(
//               position: _slideUpAnimation,
//               child: FadeTransition(
//                 opacity: _fadeAnimation,
//                 child: widget.appBar,
//               ),
//             ),

//             const SizedBox(height: 100),

//             // Artwork - scales and fades
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10),
//               child: GestureDetector(
//                 onTap: _handleArtworkTap,
//                 child: ScaleTransition(
//                   scale: _scaleAnimation,
//                   child: FadeTransition(
//                     opacity: Tween<double>(begin: 1.0, end: 0.3).animate(
//                       CurvedAnimation(
//                         parent: _controller,
//                         curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
//                       ),
//                     ),
//                     child: widget.artwork,
//                   ),
//                 ),
//               ),
//             ),

//             // Content below artwork - slides down
//             SlideTransition(
//               position: _slideDownAnimation,
//               child: FadeTransition(
//                 opacity: _fadeAnimation,
//                 child: widget.belowArtwork,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }
