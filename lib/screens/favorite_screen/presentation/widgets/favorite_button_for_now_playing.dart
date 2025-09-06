import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/screens/favorite_screen/presentation/cubit/favotite_cubit.dart';
import 'package:on_audio_query/on_audio_query.dart';

class FavButMusicPlaying extends StatefulWidget {
  const FavButMusicPlaying({
    super.key,
    required this.songFavoriteMusicPlaying,
  });

  final SongModel songFavoriteMusicPlaying;

  @override
  State<FavButMusicPlaying> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavButMusicPlaying>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _animation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesCubit, FavotiteState>(
      builder: (context, state) {
        final cubit = context.read<FavoritesCubit>();
        final isFav = cubit.isFavorite(widget.songFavoriteMusicPlaying.id.toString());

        return GestureDetector(
          onTap: () async {
            await cubit.toggleFavorite(widget.songFavoriteMusicPlaying);

            // play animation
            _animationController.forward();
          },
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (BuildContext context, Widget? child) {
              return ScaleTransition(
                scale: _animation,
                child: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  size: 23.0,
                  color: isFav
                      ? Colors.deepPurple[400]
                      : const Color(0xff9CADC0),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
