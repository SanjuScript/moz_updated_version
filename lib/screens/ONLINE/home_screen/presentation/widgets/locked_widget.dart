import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LockedHomeSection extends StatefulWidget {
  final String title;
  final String lockMessage;

  const LockedHomeSection({
    super.key,
    required this.title,
    this.lockMessage = "Available in next update",
  });

  @override
  State<LockedHomeSection> createState() => _LockedHomeSectionState();
}

class _LockedHomeSectionState extends State<LockedHomeSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _dismissController;
  late Animation<double> _dismissAnimation;

  static const String _hiveBoxName = 'app_settings';
  static const String _hideMozSectionKey = 'hide_moz_section_permanently';

  bool? _isVisible;
  Box? _settingsBox;

  List<Map<String, String>> get _dummyItems => List.generate(
    8,
    (index) => {
      'title': 'Premium Content ${index + 1}',
      'image': 'https://via.placeholder.com/300x200',
    },
  );

  @override
  void initState() {
    super.initState();
    _initializeBox();

    _dismissController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _dismissAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _dismissController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initializeBox() async {
    try {
      _settingsBox = await Hive.openBox(_hiveBoxName);
      final hidePermanently = _settingsBox!.get(
        _hideMozSectionKey,
        defaultValue: false,
      );

      if (mounted) {
        setState(() {
          _isVisible = !hidePermanently;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isVisible = true;
        });
      }
    }
  }

  Future<void> _handleClose() async {
    if (_settingsBox == null) return;

    await _settingsBox!.put(_hideMozSectionKey, true);
    await _dismissController.forward();

    if (mounted) {
      setState(() {
        _isVisible = false;
      });
    }
  }

  @override
  void dispose() {
    _dismissController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isVisible == null) {
      return const SizedBox.shrink();
    }

    if (!_isVisible!) {
      return const SizedBox.shrink();
    }

    final size = MediaQuery.sizeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _dismissAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _dismissAnimation.value == 0.0 ? 0.0 : _dismissAnimation.value,
          child: Opacity(
            opacity: _dismissAnimation.value == 0.0
                ? 0.0
                : _dismissAnimation.value,
            child: child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                GestureDetector(
                  onTap: _handleClose,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.2)
                            : Colors.black.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: size.height * .32,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.3)
                      : Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? [
                                  const Color(0xFF1a1a2e),
                                  const Color(0xFF16213e),
                                  const Color(0xFF0f3460),
                                ]
                              : [
                                  const Color(0xFFf8f9fa),
                                  const Color(0xFFe9ecef),
                                  const Color(0xFFdee2e6),
                                ],
                        ),
                      ),
                    ),
                  ),
                  // Blurred content grid
                  Positioned.fill(
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Opacity(
                        opacity: 0.25,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: GridView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                  childAspectRatio: 0.9,
                                ),
                            itemCount: _dummyItems.length,
                            itemBuilder: (context, index) {
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: isDark
                                        ? [
                                            Colors.white.withValues(
                                              alpha: 0.15,
                                            ),
                                            Colors.white.withValues(
                                              alpha: 0.05,
                                            ),
                                          ]
                                        : [
                                            Colors.black.withValues(
                                              alpha: 0.08,
                                            ),
                                            Colors.black.withValues(
                                              alpha: 0.03,
                                            ),
                                          ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Glassmorphic overlay
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: isDark
                                ? [
                                    Colors.black.withValues(alpha: 0.2),
                                    Colors.black.withValues(alpha: 0.4),
                                  ]
                                : [
                                    Colors.white.withValues(alpha: 0.3),
                                    Colors.white.withValues(alpha: 0.5),
                                  ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Central lock content
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Animated lock icon
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Theme.of(context).primaryColor,
                                Theme.of(
                                  context,
                                ).primaryColor.withValues(alpha: 0.6),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).primaryColor.withValues(alpha: 0.4),
                                blurRadius: 20,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.lock_rounded,
                            size: 36,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Unlocking Soon',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            widget.lockMessage,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.grey[600],
                                  height: 1.5,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Moz badge with shimmer effect
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDark
                                  ? [
                                      Colors.amber.withValues(alpha: 0.2),
                                      Colors.orange.withValues(alpha: 0.2),
                                    ]
                                  : [
                                      Colors.amber.withValues(alpha: 0.15),
                                      Colors.orange.withValues(alpha: 0.15),
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.amber.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.workspace_premium_rounded,
                                size: 18,
                                color: isDark
                                    ? Colors.amber
                                    : Colors.orange[700],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Moz Recommended',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.amber
                                      : Colors.orange[700],
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Decorative corner accents
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.3),
                            Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.2),
                            Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
