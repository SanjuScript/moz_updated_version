import 'package:flutter/material.dart';
import 'package:moz_updated_version/widgets/shimmers/shimmer_widget.dart';

class HomePageShimmer extends StatelessWidget {
  const HomePageShimmer({super.key});

  Widget _section(BuildContext context, {bool showTitle = true}) {
    final size = MediaQuery.sizeOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (showTitle)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: MozShimmer(
              width: size.width * .60,
              height: size.height * .05,
              radius: 10,
            ),
          ),
        SizedBox(
          height: 140,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: 6,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (_, __) =>
                MozShimmer(width: 120, height: 140, radius: 16),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        spacing: 20,
        children: [
          _section(context),
          // const SizedBox(height: 20),
          _section(context),
          // const SizedBox(height: 20),
          _section(context),
          _section(context, showTitle: false),
        ],
      ),
    );
  }
}
