import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moz_updated_version/screens/home_screen/presentation/widgets/catagory_bar.dart';
import 'package:moz_updated_version/screens/home_screen/presentation/widgets/section_title.dart';
import 'package:moz_updated_version/screens/home_screen/presentation/widgets/sections/last_songs_section.dart';
import 'package:moz_updated_version/screens/home_screen/presentation/widgets/sections/mostly_played_section.dart';
import 'package:moz_updated_version/screens/home_screen/presentation/widgets/sections/recently_played_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _refreshContent() async {
    await Future.delayed(const Duration(seconds: 1));

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: RefreshIndicator(
        color: Colors.pinkAccent,
        backgroundColor: Colors.pink[50],
        onRefresh: _refreshContent,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
      ),
    );
  }
}
