import 'package:flutter/material.dart';

class PlaylistTexView extends StatelessWidget {
  final String name;
  final String count;
  const PlaylistTexView({super.key, required this.name, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
      height: 30,
      width: double.infinity,
      child: Column(
        children: [
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          Text(
            "$count songs",
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}
