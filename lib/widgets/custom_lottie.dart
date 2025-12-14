import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CustomLottie extends StatelessWidget {
  final String asset;
  final double? width;
  final double? height;
  final bool repeat;
  final bool animate;
  final BoxFit fit;

  const CustomLottie({
    super.key,
    required this.asset,
    this.width,
    this.height,
    this.repeat = true,
    this.animate = true,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      asset,
      width: width,
      height: height,
      repeat: repeat,
      animate: animate,
      fit: fit,
      delegates: LottieDelegates(
        values: [
          ValueDelegate.color(const [
            '**',
          ], value: Theme.of(context).primaryColor),
        ],
      ),
    );
  }
}
