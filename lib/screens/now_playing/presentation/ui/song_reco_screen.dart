import 'package:flutter/material.dart';

class ComingSoonScreen extends StatefulWidget {
  const ComingSoonScreen({super.key});

  @override
  State<ComingSoonScreen> createState() => _ComingSoonScreenState();
}

class _ComingSoonScreenState extends State<ComingSoonScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: NeverScrollableScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        'Coming Soon!',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                          letterSpacing: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Subtitle
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.amber.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.rocket_launch,
                              color: Colors.amber.shade700,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Available in Next Beta Version',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.amber.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Features List
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildFeaturesList(isDark),
                    ),

                    const Spacer(),

                    // Beta Message
                    Column(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue.shade400,
                          size: 28,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Thank you for testing our beta!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'We\'re working hard to bring you amazing features. Stay tuned for updates!',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesList(bool isDark) {
    final upcomingFeatures = [
      {
        'icon': Icons.recommend,
        'title': 'Recommended Songs',
        'description': 'Personalized song recommendations based on your taste',
      },
      {
        'icon': Icons.album,
        'title': 'Album Collections',
        'description':
            'Browse and explore complete albums from your favorite artists',
      },
      {
        'icon': Icons.playlist_play,
        'title': 'Smart Playlists',
        'description': 'AI-curated playlists matching your mood and activity',
      },
      {
        'icon': Icons.person_search,
        'title': 'Artist Discovery',
        'description': 'Find new artists similar to the ones you love',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Text(
            'Upcoming Features',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...upcomingFeatures.asMap().entries.map((entry) {
          final index = entry.key;
          final feature = entry.value;
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 400 + (index * 100)),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(50 * (1 - value), 0),
                child: Opacity(opacity: value, child: child),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.purple.shade400, Colors.pink.shade400],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      feature['icon'] as IconData,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          feature['title'] as String,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          feature['description'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.lock_clock, color: Colors.grey.shade400, size: 20),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
