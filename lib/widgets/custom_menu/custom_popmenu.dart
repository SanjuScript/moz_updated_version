import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:moz_updated_version/widgets/custom_menu/menu_layout.dart';

class GlassPopMenuButton<T> extends StatefulWidget {
  final List<GlassPopMenuEntry<T>> items;
  final Widget icon;
  final void Function(T)? onSelected;
  final EdgeInsetsGeometry padding;
  final bool showBarrier;
  const GlassPopMenuButton({
    super.key,
    required this.items,
    required this.icon,
    this.onSelected,
    this.showBarrier = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
  });

  @override
  State<GlassPopMenuButton<T>> createState() => _GlassPopMenuButtonState<T>();
}

class _GlassPopMenuButtonState<T> extends State<GlassPopMenuButton<T>>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _offset = Tween<Offset>(
      begin: const Offset(0, -0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  void _showMenu() {
    final renderBox = context.findRenderObject() as RenderBox;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    final buttonSize = renderBox.size;
    final buttonPosition = renderBox.localToGlobal(
      Offset.zero,
      ancestor: overlay,
    );

    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        buttonPosition,
        buttonPosition + Offset(buttonSize.width, buttonSize.height),
      ),
      Offset.zero & overlay.size,
    );

    _overlayEntry = OverlayEntry(
      builder: (oVcontext) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: _hideMenu,
                behavior: HitTestBehavior.translucent,
                child: FadeTransition(
                  opacity: _fade,
                  child: Container(
                    color: widget.showBarrier
                        ? Colors.black.withValues(alpha: 0.25)
                        : null,
                  ),
                ),
              ),
            ),

            CustomSingleChildLayout(
              delegate: GlassMenuLayout(
                position,
                Directionality.of(oVcontext),
                MediaQuery.of(oVcontext).padding,
              ),
              child: Material(
                color: Colors.transparent,
                child: FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _offset,
                    child: IntrinsicWidth(
                      stepWidth: 56.0,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: 112.0,
                          maxWidth: 280.0,
                        ),
                        child: _buildGlassMenu(oVcontext),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
    if (!mounted) return;
    Overlay.of(context).insert(_overlayEntry!);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.dispose();
  }

  void _hideMenu() async {
    if (_overlayEntry == null) return;
    if (!mounted) return;
    await _controller.reverse();
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _buildGlassMenu(BuildContext overlayContext) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).disabledColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Theme.of(context).scaffoldBackgroundColor,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widget.items.map((item) {
              return InkWell(
                onTap: () {
                  widget.onSelected?.call(item.value);
                  _hideMenu();
                },
                borderRadius: BorderRadius.circular(18),
                child: Padding(padding: widget.padding, child: item.child),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showMenu,
      behavior: HitTestBehavior.translucent,
      child: Padding(padding: const EdgeInsets.all(8.0), child: widget.icon),
    );
  }
}

class GlassPopMenuEntry<T> {
  final T value;
  final Widget child;
  GlassPopMenuEntry({required this.child, required this.value});
}
