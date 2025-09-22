import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/screens/home_screen/presentation/cubit/library_counts_cubit.dart';
import 'package:moz_updated_version/screens/home_screen/presentation/widgets/buttons/home_screen_count_button.dart';
import 'package:moz_updated_version/screens/home_screen/presentation/widgets/catagory_bar.dart';
import 'package:moz_updated_version/screens/home_screen/presentation/widgets/section_title.dart';
import 'package:moz_updated_version/screens/home_screen/presentation/widgets/sections/all_songs_section.dart';
import 'package:moz_updated_version/screens/home_screen/presentation/widgets/sections/mostly_played_section.dart';
import 'package:moz_updated_version/screens/recently_played/presentation/ui/recently_palyed.dart';
import 'package:moz_updated_version/screens/home_screen/presentation/widgets/sections/recently_played_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            CategoryBar(),
            SectionTitle(index: 1, title: "Recently Played"),
            RecentlyPlayedSection(),
            SectionTitle(index: 5, title: "Mostly Played"),
            MostlyPlayedSection(),
            SectionTitle(index: 1, title: "Last Added"),
            LastAddedSection(),
            SizedBox(height: size.height * .10),
          ],
        ),
      ),
    );
  }
}
