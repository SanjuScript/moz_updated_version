import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/data/model/online_models/trending_search_model.dart';
import 'package:moz_updated_version/screens/ONLINE/search_screen/presentation/cubit/jio_saavn_cubit.dart';
import 'package:moz_updated_version/widgets/custom_cached_image.dart';

class TrendingSearchesView extends StatefulWidget {
  final void Function(TrendingItemModel item) onTap;

  const TrendingSearchesView({super.key, required this.onTap});

  @override
  State<TrendingSearchesView> createState() => _TrendingSearchesViewState();
}

class _TrendingSearchesViewState extends State<TrendingSearchesView> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      context.read<JioSaavnCubit>().fetchTrendingSearches();
      _loaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<JioSaavnCubit, JioSaavnState>(
      builder: (context, state) {
        if (state is JioSaavnTrendingLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is JioSaavnTrendingError) {
          return Center(
            child: Text(state.message, style: theme.textTheme.bodySmall),
          );
        }

        if (state is JioSaavnTrendingSuccess) {
          final items = state.items;

          if (items.isEmpty) {
            return const SizedBox();
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];

              return ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 5),
                onTap: () => widget.onTap(item),
                leading: CustomCachedImage(
                  imageUrl: item.image!,
                  height: 50,
                  width: 50,
                  radius: 10,
                ),
                title: Text(
                  item.title ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  item.subtitle ?? item.type ?? '',
                  style: theme.textTheme.bodySmall,
                ),
              );
            },
          );
        }

        return const SizedBox();
      },
    );
  }
}
