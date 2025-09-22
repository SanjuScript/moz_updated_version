import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/screens/all_screens/presentation/cubit/tab_cubit.dart';
import 'package:moz_updated_version/screens/home_screen/presentation/cubit/library_counts_cubit.dart';
import 'package:moz_updated_version/screens/home_screen/presentation/helper/get_index.dart';
import 'buttons/home_screen_count_button.dart';

class CategoryBar extends StatefulWidget {
  const CategoryBar({super.key});

  @override
  State<CategoryBar> createState() => _CategoryBarState();
}

class _CategoryBarState extends State<CategoryBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                final animation = CurvedAnimation(
                  parent: _controller,
                  curve: Interval(
                    0.1 * index,
                    0.6 + 0.1 * index,
                    curve: Curves.easeOut,
                  ),
                );

                return AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: animation.value,
                      child: Transform.translate(
                        offset: Offset(0, 50 * (1 - animation.value)),
                        child: child,
                      ),
                    );
                  },
                  child: InkWell(
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                    onTap: () => context.read<TabCubit>().changeTab(
                          getTabIndexFromSection(index),
                        ),
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
