import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/screens/all_screens/presentation/cubit/tab_cubit.dart';

class SectionTitle extends StatefulWidget {
  final int index;
  final String title;
  const SectionTitle({super.key, required this.index, required this.title});

  @override
  State<SectionTitle> createState() => _SectionTitleState();
}

class _SectionTitleState extends State<SectionTitle> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: FractionalTranslation(
            translation: _slideAnimation.value,
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: InkWell(
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          onTap: () {
            context.read<TabCubit>().changeTab(widget.index);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: const Color.fromARGB(255, 255, 73, 134),
                      fontWeight: FontWeight.w900,
                      shadows: [
                        Shadow(
                          offset: const Offset(2, 2),
                          blurRadius: 5,
                          color: Colors.pinkAccent.withOpacity(0.1),
                        ),
                        Shadow(
                          offset: const Offset(-1, -1),
                          blurRadius: 10,
                          color: Colors.pinkAccent.withOpacity(0.2),
                        ),
                      ],
                    ),
              ),
              const Icon(Icons.double_arrow_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
