import 'package:flutter/material.dart';
import 'package:moz_updated_version/screens/ONLINE/bottom_nav/presentation/ui/bottom_nav.dart';

class ShimmerGoOnlineButton extends StatefulWidget {
  const ShimmerGoOnlineButton({super.key});

  @override
  State<ShimmerGoOnlineButton> createState() => _ShimmerGoOnlineButtonState();
}

class _ShimmerGoOnlineButtonState extends State<ShimmerGoOnlineButton>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _scaleController;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _shimmerAnimation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: InkWell(
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            onTap: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OnlineBottomNavScreen(),
                ),
              );
            },
            child: AnimatedBuilder(
              animation: _shimmerAnimation,
              builder: (context, child) {
                return Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      children: [
                        Text(
                          "Go online",
                          style: TextStyle(
                            color: theme.scaffoldBackgroundColor,
                          ),
                        ),
                        Positioned.fill(
                          child: Transform.translate(
                            offset: Offset(_shimmerAnimation.value * 100, 0),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Colors.transparent,
                                    Colors.white.withValues(alpha: 0.4),
                                    Colors.transparent,
                                  ],
                                  stops: const [0.0, 0.5, 1.0],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
