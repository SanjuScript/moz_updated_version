import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/screens/all_screens/presentation/cubit/tab_confiq_cubit.dart';
import 'package:moz_updated_version/screens/all_screens/presentation/model/tab_model.dart';

class TabCustomizationScreen extends StatelessWidget {
  const TabCustomizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Customize Tabs")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              "Enable/disable tabs, reorder them by long pressing.\n"
              "At least 2 tabs must remain enabled.",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<TabConfigCubit, List<TabModel>>(
              builder: (context, tabs) {
                final tabCubit = context.read<TabConfigCubit>();
                final defaultTabTitle = tabCubit.getDefaultTab(tabs);

                return Column(
                  children: [
                    Expanded(
                      child: ReorderableListView(
                        onReorder: (oldIndex, newIndex) {
                          tabCubit.reorderTab(oldIndex, newIndex);
                        },
                        children: [
                          for (int i = 0; i < tabs.length; i++)
                            SwitchListTile.adaptive(
                              activeTrackColor: Theme.of(context).primaryColor,
                              inactiveTrackColor: Colors.grey.withValues(
                                alpha: 0.6,
                              ),

                              key: ValueKey(tabs[i].title),
                              value: tabs[i].enabled,
                              title: Text(
                                tabs[i].title,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      fontSize: 17,
                                      fontWeight: FontWeight.normal,
                                    ),
                              ),
                              onChanged: (val) {
                                final enabledCount = tabs
                                    .where((t) => t.enabled)
                                    .length;
                                if (!val && enabledCount <= 2) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "At least 2 tabs must remain enabled",
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                tabCubit.toggleTab(i, val);
                              },
                            ),
                        ],
                      ),
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Select your default starting tab below",
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                           color:  Colors.grey
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,

                          runSpacing: 8,
                          children: tabs.where((t) => t.enabled).map((tab) {
                            final isSelected = tab.title == defaultTabTitle;
                            return GestureDetector(
                              onTap: () {
                                tabCubit.setDefaultTab(tab.title);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.grey.shade400,
                                  ),
                                ),
                                child: Text(
                                  tab.title,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : null,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
