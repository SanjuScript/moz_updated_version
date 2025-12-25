import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/core/helper/color_extractor.dart/cubit/artworkcolorextractor_cubit.dart';
import 'package:moz_updated_version/core/helper/snackbar_helper.dart';
import 'package:moz_updated_version/data/model/online_models/home_item_model.dart';
import 'package:moz_updated_version/screens/ONLINE/album_screen/presentation/cubit/collection_cubit.dart';
import 'package:moz_updated_version/screens/ONLINE/album_screen/presentation/ui/collection_screen.dart';
import 'package:moz_updated_version/widgets/custom_cached_image.dart';

class HomeSection extends StatelessWidget {
  final String title;
  final List<HomeItem> items;

  const HomeSection({super.key, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              return GestureDetector(
                onTap: () => _onTapItem(context, item),
                child: Column(
                  children: [
                    CustomCachedImage(
                      height: 110,
                      width: 110,
                      imageUrl: item.image!.replaceAll("150x150", "500x500"),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: 110,
                      child: Text(
                        item.title ?? "",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _onTapItem(BuildContext context, HomeItem item) {
    log(item.type.toString(), name: "ITEM TYPE GLOBAL");
    log(item.id.toString());
    log(item.toString());

    if (item.id == null || item.image == null) return;

    final collectionCubit = context.read<CollectionCubitForOnline>();
    final artworkCubit = context.read<ArtworkColorCubit>();

    artworkCubit.extractAlbumArtworkColors(item.image!);

    switch (item.type) {
      case "artist":
      case "radio_station":
        log("Open Artist Page: ${item.title}");
        collectionCubit.loadArtist(item.id!, limit: 30);
        AppSnackBar.error(
          context,
          "Artist page has an issue right now. Check out other songs instead.",
        );
        break;

      case "album":
      case "playlist":
      case "song":
        collectionCubit.loadAlbum(item.id!, item.type!);
        break;

      default:
        log("Unhandled item type: ${item.type}");
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OnlineAlbumScreen()),
    );
  }
}
