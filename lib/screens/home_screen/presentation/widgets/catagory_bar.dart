import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/screens/all_screens/presentation/cubit/tab_confiq_cubit.dart';
import 'package:moz_updated_version/screens/all_screens/presentation/cubit/tab_cubit.dart';
import 'package:moz_updated_version/screens/home_screen/presentation/cubit/library_counts_cubit.dart';
import 'buttons/home_screen_count_button.dart';

class CategoryBar extends StatelessWidget {
  const CategoryBar({super.key});

  @override
  Widget build(BuildContext context) {
    final enabledTabs = context
        .read<TabConfigCubit>()
        .state
        .where((t) => t.enabled)
        .toList();

    return BlocBuilder<LibraryCountsCubit, LibraryCountsState>(
      builder: (context, state) {
        final sections = [
          {"name": "All Songs", "count": state.allSongs},
          {"name": "Recently", "count": state.recentlyPlayed},
          {"name": "Favorites", "count": state.favorites},
          {"name": "Mostly", "count": state.mostlyPlayed},
          {"name": "Playlists", "count": state.playlists},
        ];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.11,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: sections.length,
              itemBuilder: (context, index) {
                final item = sections[index];

                final tabIndex = enabledTabs.indexWhere(
                  (tab) => tab.title.toLowerCase().contains(
                    item["name"].toString().toLowerCase(),
                  ),
                );

                return InkWell(
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  onTap: () {
                    if (tabIndex != -1) {
                      context.read<TabCubit>().changeTab(tabIndex);
                    }
                  },
                  child: HomePageButtons(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${item["count"]}",
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            item["name"].toString().toUpperCase(),
                            style: const TextStyle(
                              shadows: [
                                BoxShadow(
                                  color: Color.fromARGB(90, 63, 63, 63),
                                  blurRadius: 15,
                                  offset: Offset(-2, 2),
                                ),
                              ],
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
