import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/core/themes/cubit/theme_cubit.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:moz_updated_version/screens/favorite_screen/presentation/cubit/favotite_cubit.dart';

class FavoriteButton extends StatefulWidget {
  const FavoriteButton({super.key, required this.songFavorite});
  final SongModel songFavorite;

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
    return BlocBuilder<FavoritesCubit, FavotiteState>(
      builder: (context, state) {
        final cubit = context.read<FavoritesCubit>();
        final isFav = cubit.isFavorite(widget.songFavorite.id.toString());
        final themeCubit = context.watch<ThemeCubit>();
        final isLightMode =
            themeCubit.state.themeData.brightness == Brightness.light;
        return GestureDetector(
          onTap: () async {
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
                          ? const [Color(0xfff55297), Color(0xffe04182)]
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
                  child: const Icon(
                    Icons.favorite,
                    shadows: [
                      BoxShadow(
                        color: Color.fromARGB(80, 221, 140, 209),
                        offset: Offset(2, 2),
                        spreadRadius: 5,
                        blurRadius: 13,
                      ),
                      BoxShadow(
                        color: Color.fromARGB(69, 201, 197, 197),
                        blurRadius: 13,
                        spreadRadius: 5,
                        offset: Offset(-2, -2),
                      ),
                    ],
                    color: Colors.white, // gets masked by ShaderMask
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
