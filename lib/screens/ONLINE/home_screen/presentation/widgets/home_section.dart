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
    final size = MediaQuery.sizeOf(context);
    if (items.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        SizedBox(
          height: size.height * .50,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GridView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.2,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];

                  return GestureDetector(
                    onTap: () => _onTapItem(context, item),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: CustomCachedImage(
                            imageUrl: item.image!,
                            height: MediaQuery.sizeOf(context).height * .10,
                            width: MediaQuery.sizeOf(context).width * .40,
                          ),
                        ),

                        const SizedBox(height: 8),

                        SizedBox(
                          height: size.height * .047,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              item.title ?? "",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
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
        // AppSnackBar.error(
        //   context,
        //   "Artist page has an issue right now. Check out other songs instead.",
        // );
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
