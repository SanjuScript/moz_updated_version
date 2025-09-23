// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:moz_updated_version/screens/song_list_screen/presentation/cubit/allsongs_cubit.dart';

// class SortMenu extends StatelessWidget {
//   const SortMenu({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final cubit = context.read<AllSongsCubit>();

//     return DropdownButton<SongSortOption>(
//       value: cubit.currentSort,
//       focusColor: Colors.transparent,
//       dropdownColor: Theme.of(context).colorScheme.surface,
//       underline: const SizedBox.shrink(),
//       borderRadius: BorderRadius.circular(12),
//       style: Theme.of(context).textTheme.bodyMedium,
//       onChanged: (value) {
//         if (value != null) {
//           cubit.toggleSort(value);
//         }
//       },
//       selectedItemBuilder: (_) {
//         // Display current selection with arrow icon
//         return SongSortOption.values.map((option) {
//           final isSelected = cubit.currentSort == option;
//           final ascending = cubit.isAscending;

//           String label;
//           switch (option) {
//             case SongSortOption.dateAdded:
//               label = "Date Added";
//               break;
//             case SongSortOption.name:
//               label = "Name";
//               break;
//             case SongSortOption.duration:
//               label = "Duration";
//               break;
//             case SongSortOption.fileSize:
//               label = "File";
//               break;
//           }

//           return Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(label),
//               if (isSelected)
//                 Icon(
//                   ascending ? Icons.arrow_upward : Icons.arrow_downward,
//                   size: 16,
//                 ),
//             ],
//           );
//         }).toList();
//       },
//       items: SongSortOption.values.map((option) {
//         String label;
//         switch (option) {
//           case SongSortOption.dateAdded:
//             label = "Date Added";
//             break;
//           case SongSortOption.name:
//             label = "Name";
//             break;
//           case SongSortOption.duration:
//             label = "Duration";
//             break;
//           case SongSortOption.fileSize:
//             label = "File";
//             break;
//         }

//         return DropdownMenuItem(
//           value: option,
//           child: Row(
//             children: [
//               Text(label),
//               if (cubit.currentSort == option)
//                 Icon(
//                   cubit.isAscending ? Icons.arrow_upward : Icons.arrow_downward,
//                   size: 16,
//                 ),
//             ],
//           ),
//         );
//       }).toList(),
//     );
//   }
// }
