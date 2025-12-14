import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/core/themes/cubit/theme_cubit.dart';
import 'package:moz_updated_version/core/utils/repository/Authentication/auth_guard.dart';
import 'package:moz_updated_version/main.dart';
import 'package:moz_updated_version/services/service_locator.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:moz_updated_version/screens/favorite_screen/presentation/cubit/favotite_cubit.dart';

class FavoriteButton extends StatefulWidget {
  final bool showShadow;
  final SongModel songFavorite;

  const FavoriteButton({
    super.key,
    required this.songFavorite,
    this.showShadow = true,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _animation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      }
    });
  }

  void _playAnimation() {
    _animationController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isIos = sl<ThemeCubit>().isIos;

    return BlocBuilder<FavoritesCubit, FavotiteState>(
      builder: (context, state) {
        final cubit = context.read<FavoritesCubit>();
        final isFav = cubit.isFavorite(widget.songFavorite.id.toString());
        final themeCubit = context.watch<ThemeCubit>();
        final isLightMode =
            themeCubit.state.themeData.brightness == Brightness.light;

        return GestureDetector(
          onTap: () async {
            final songMap = widget.songFavorite.getMap;
            final bool isOnline = songMap["isOnline"] == true;

            log(songMap.toString());

            if (isOnline) {
              final canProceed = await AuthGuard.ensureLoggedIn(context);
              if (!canProceed) return;
            }

            await cubit.toggleFavorite(widget.songFavorite);
            _playAnimation();
          },
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (BuildContext context, Widget? child) {
              return ScaleTransition(
                scale: _animation,
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      colors: isFav
                          ? [
                              Theme.of(context).primaryColor,
                              Theme.of(
                                context,
                              ).primaryColor.withValues(alpha: .9),
                            ]
                          : isLightMode
                          ? [
                              Color.fromARGB(255, 232, 225, 244),
                              Color.fromARGB(255, 232, 225, 244),
                            ]
                          : [
                              Color.fromARGB(255, 57, 54, 62),
                              const Color.fromARGB(255, 59, 55, 64),
                            ],
                      tileMode: TileMode.clamp,
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.srcATop,
                  child: Icon(
                    isIos
                        ? (isFav
                              ? CupertinoIcons.heart_fill
                              : CupertinoIcons.heart)
                        : Icons.favorite,
                    shadows: widget.showShadow
                        ? [
                            const BoxShadow(
                              color: Color.fromARGB(80, 221, 140, 209),
                              offset: Offset(2, 2),
                              spreadRadius: 5,
                              blurRadius: 13,
                            ),
                            const BoxShadow(
                              color: Color.fromARGB(69, 201, 197, 197),
                              blurRadius: 13,
                              spreadRadius: 5,
                              offset: Offset(-2, -2),
                            ),
                          ]
                        : [],
                    color: Colors.white,
                    size: 41.0,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
