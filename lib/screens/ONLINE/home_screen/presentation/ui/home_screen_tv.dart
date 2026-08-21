import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/data/model/online_models/home_item_model.dart';
import 'package:moz_updated_version/screens/ONLINE/album_screen/presentation/cubit/collection_cubit.dart';
import 'package:moz_updated_version/screens/ONLINE/album_screen/presentation/ui/collection_screen.dart';
import 'package:moz_updated_version/screens/ONLINE/home_screen/presentation/cubit/jio_saavn_home_cubit.dart';
import 'package:moz_updated_version/widgets/custom_cached_image.dart';

class HomeScreenTV extends StatelessWidget {
  const HomeScreenTV({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<JioSaavnHomeCubit, JioSaavnHomeState>(
          builder: (context, state) {
            if (state is JioSaavnHomeLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is JioSaavnHomeError) {
              return const Center(child: Text("Network Error"));
            }

            final home = (state as JioSaavnHomeSuccess).data;

            return ListView(
              children: [
                // _TvHeader(),
                TvSection("Recommended", home.cityMod ?? []),
                TvSection("Trending", home.newTrending ?? []),
                TvSection("Top Charts", home.charts ?? []),
                TvSection("Artists", home.artistRecos ?? []),
                TvSection("Albums", home.newAlbums ?? []),
                TvSection("Top Playlists", home.topPlaylists ?? []),
                TvSection("Radio Stations", home.radio ?? []),
                TvSection("Discover", home.browseDiscover ?? []),
              ],
            );
          },
        ),
      ),
    );
  }
}

class TvSection extends StatelessWidget {
  final String title;
  final List<HomeItem> items;

  const TvSection(this.title, this.items, {super.key});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 40),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return TvCard(items[index]);
            },
          ),
        ),
      ],
    );
  }
}

class TvCard extends StatefulWidget {
  final HomeItem item;
  const TvCard(this.item, {super.key});

  @override
  State<TvCard> createState() => _TvCardState();
}

class _TvCardState extends State<TvCard> {
  bool focused = false;

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      onShowFocusHighlight: (v) => setState(() => focused = v),
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (intent) {
            _open(context);
            return null;
          },
        ),
      },

      child: GestureDetector(
        onTap: () => _open(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(right: 20),
          width: focused ? 190 : 170,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: focused
                ? Border.all(color: Colors.blueAccent, width: 3)
                : null,
            boxShadow: focused
                ? [const BoxShadow(color: Colors.blueAccent, blurRadius: 20)]
                : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CustomCachedImage(
              imageUrl: widget.item.image!,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  void _open(BuildContext context) {
    final item = widget.item;
    context.read<CollectionCubitForOnline>().loadAlbum(item.id!, item.type!);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OnlineAlbumScreen()),
    );
  }
}
