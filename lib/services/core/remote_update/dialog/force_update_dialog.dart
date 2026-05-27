import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:moz_updated_version/core/helper/snackbar_helper.dart';
import 'package:moz_updated_version/data/db/app_settings/app_settings_db.dart';
import 'package:moz_updated_version/services/core/remote_update/remote_config_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ForceUpdateScreen extends StatefulWidget {
  final String title;
  final String description;
  final String buttonText;
  final String url;
  final bool canClose;

  const ForceUpdateScreen({
    super.key,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.url,
    this.canClose = false,
  });

  @override
  State<ForceUpdateScreen> createState() => _ForceUpdateScreenState();
}

class _ForceUpdateScreenState extends State<ForceUpdateScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lines = widget.description.split('\n');

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (widget.canClose) {
          AppSnackBar.info(
            context,
            duration: Duration(seconds: 6),
            "This update is mandatory and cannot be skipped. Please update the app to continue using all features securely.",
          );
        }
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).scaffoldBackgroundColor,
                Colors.purple.shade500,
                Theme.of(context).primaryColor,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // Animated Icon
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 40,
                            offset: const Offset(0, 20),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.system_update_alt_rounded,
                            size: 50,
                            color: Colors.purple.shade600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (lines.isNotEmpty)
                        Text(
                          lines.first,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),

                      const SizedBox(height: 16),

                      ...lines.skip(1).where((l) => l.trim().isNotEmpty).map((
                        line,
                      ) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "•",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  line.replaceFirst("•", "").trim(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    height: 1.6,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Spacer(flex: 3),

                  // Update Button
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          launchUrl(
                            Uri.parse(widget.url),
                            mode: LaunchMode.externalApplication,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.purple.shade600,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.buttonText,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple.shade600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.purple.shade600,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  if (!widget.canClose) ...[
                    const SizedBox(height: 16),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: TextButton(
                        onPressed: () async {
                          await SettingsManager.skipVersion(
                            RemoteConfigService.instance.minAppVersion,
                          );
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Maybe Later',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
