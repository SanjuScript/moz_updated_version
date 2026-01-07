import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class MozShimmer extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const MozShimmer({
    super.key,
    required this.width,
    required this.height,
    this.radius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade800.withValues(alpha: 0.3),
      highlightColor: Colors.grey.shade500.withValues(alpha: 0.3),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
