import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/core/helper/color_extractor.dart/cubit/artworkcolorextractor_cubit.dart';
import 'package:moz_updated_version/core/themes/cubit/theme_cubit.dart';
import 'package:moz_updated_version/data/model/online_models/album_model.dart';
import 'package:moz_updated_version/data/model/online_models/media_collection.dart';
import 'package:moz_updated_version/screens/ONLINE/album_screen/presentation/widgets/collection_menu.dart';
import 'package:moz_updated_version/screens/song_list_screen/presentation/widgets/buttons/theme_change_button.dart';
import 'package:moz_updated_version/widgets/custom_cached_image.dart';

class CollectionAppBar extends StatelessWidget {
  final MediaCollectionUI collection;

  const CollectionAppBar(this.collection, {super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return SliverAppBar(
      expandedHeight: size.height * .40,
      pinned: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),

      // actions: [AlbumOptionsMenu(album: collection.)],
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final top = constraints.biggest.height;
          final toolbarHeight =
              kToolbarHeight + MediaQuery.of(context).padding.top;

          final bool isCollapsed = top <= toolbarHeight;

          return BlocBuilder<ArtworkColorCubit, ArtworkColorState>(
            builder: (context, colorState) {
              final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
              final themeState = context.watch<ThemeCubit>();
              final albumColor = colorState.albumDominantColor;

              final colors = themeState.isDark
                  ? [
                      albumColor,
                      albumColor.withValues(alpha: 0.6),
                      albumColor.withValues(alpha: 0.3),
                      Colors.transparent,
                    ]
                  : [scaffoldBg, scaffoldBg, scaffoldBg, scaffoldBg];

              return FlexibleSpaceBar(
                centerTitle: true,

                title: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isCollapsed ? 1.0 : 0.0,
                  child: Text(
                    collection.title ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: colors,
                          stops: const [0.0, 0.5, 0.8, 1.0],
                        ),
                      ),
                    ),

                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 30,
                                spreadRadius: 1,
                                offset: const Offset(-5, -15),
                              ),
                            ],
                          ),
                          child: CustomCachedImage(
                            imageUrl: collection.image!,
                            useHD: true,
                          ),
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
    );
  }
}
