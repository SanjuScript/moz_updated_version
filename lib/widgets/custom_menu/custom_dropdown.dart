// premium_blur_dropdown.dart
// Simplified premium-looking dropdown with frosted glass (backdrop blur)
// and smooth open/close animations. No search, just a clean dropdown.

import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

typedef PremiumDropdownItemBuilder<T> =
    Widget Function(BuildContext context, T item, bool selected);

class PremiumDropdown<T> extends StatefulWidget {
  const PremiumDropdown({
    super.key,
    required this.items,
    this.initialValue,
    required this.onChanged,
    this.hint,
    this.width,
    this.maxHeight = 300,
    this.borderRadius = const BorderRadius.all(Radius.circular(18)),
    this.elevation = 12,
    this.itemBuilder,
    this.leading,
    this.labelBuilder,
    this.showDivider = false,
  });

  final List<T> items;
  final bool showDivider;
  final T? initialValue;
  final String Function(T item)? labelBuilder;
  final ValueChanged<T?> onChanged;
  final Widget? hint;
  final double? width;
  final double maxHeight;
  final BorderRadius borderRadius;
  final int elevation;
  final PremiumDropdownItemBuilder<T>? itemBuilder;
  final Widget? leading;

  @override
  State<PremiumDropdown<T>> createState() => _PremiumDropdownState<T>();
}

class _PremiumDropdownState<T> extends State<PremiumDropdown<T>>
    with SingleTickerProviderStateMixin {
  late LayerLink _layerLink;
  OverlayEntry? _overlayEntry;
  bool _open = false;
  T? _value;
  late AnimationController _ctrl;
  late Animation<double> _opacity;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _layerLink = LayerLink();
    _value = widget.initialValue;
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _scale = Tween<double>(
      begin: 0.98,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
  }

  void _toggleDropdown() {
    if (_open) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  @override
  void didUpdateWidget(covariant PremiumDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialValue != widget.initialValue) {
      setState(() {
        _value = widget.initialValue;
      });
    }
  }

  void _showOverlay() {
    _overlayEntry = _buildOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _open = true);
    _ctrl.forward();
  }

  void _removeOverlay() async {
    await _ctrl.reverse();
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() => _open = false);
  }

  OverlayEntry _buildOverlayEntry() {
    final RenderBox box = context.findRenderObject()! as RenderBox;
    final Offset target = box.localToGlobal(Offset.zero);
    final Size size = box.size;
    final double menuWidth = widget.width ?? size.width;

    return OverlayEntry(
      builder: (context) {
        return GestureDetector(
          onTap: _removeOverlay,
          behavior: HitTestBehavior.translucent,
          child: Material(
            type: MaterialType.transparency,
            child: Stack(
              children: [
                Positioned.fill(
                  child: FadeTransition(
                    opacity: _opacity,
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.12),
                    ),
                  ),
                ),
                Positioned(
                  left: target.dx,
                  top: target.dy + size.height + 8,
                  width: menuWidth,
                  child: CompositedTransformFollower(
                    link: _layerLink,
                    showWhenUnlinked: false,
                    offset: Offset(0, size.height + 8),
                    child: Material(
                      type: MaterialType.transparency,
                      child: FadeTransition(
                        opacity: _opacity,
                        child: ScaleTransition(
                          scale: _scale,
                          alignment: Alignment.topCenter,
                          child: _buildMenu(menuWidth),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenu(double width) {
    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: width,
          constraints: BoxConstraints(maxHeight: widget.maxHeight),
          decoration: BoxDecoration(
            color: Theme.of(context).disabledColor,
            borderRadius: widget.borderRadius,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.22),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: Theme.of(context).scaffoldBackgroundColor,
              width: 1,
            ),
          ),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            itemCount: widget.items.length,
            separatorBuilder: (c, i) => const SizedBox(height: 4),
            itemBuilder: (context, index) {
              final T item = widget.items[index];
              final bool selected = _value != null && _value == item;
              return _buildItem(context, item, selected);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, T item, bool selected) {
    final label = widget.labelBuilder?.call(item) ?? item.toString();
    final child = widget.itemBuilder != null
        ? widget.itemBuilder!(context, item, selected)
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Expanded(child: Text(label)),
                if (selected) const Icon(Icons.check, size: 18),
              ],
            ),
          );

    return InkWell(
      onTap: () {
        setState(() => _value = item);
        widget.onChanged(item);
        _removeOverlay();
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final display =
        _value?.toString() ?? (widget.hint != null ? null : 'Select');
    return CompositedTransformTarget(
      link: _layerLink,
      child: SizedBox(
        width: widget.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _toggleDropdown,
              child: Container(
                width: widget.width,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.04)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.leading != null) ...[
                      widget.leading!,
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: DefaultTextStyle(
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium!.copyWith(fontSize: 15),
                        child: _value == null
                            ? (widget.hint ?? Text('Select'))
                            : Text(
                                widget.labelBuilder?.call(_value as T) ??
                                    _value.toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: _open ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 220),
                      child: const Icon(Icons.keyboard_arrow_down),
                    ),
                  ],
                ),
              ),
            ),
            if (widget.showDivider)
              SizedBox(
                width: widget.width! - 30,
                child: Divider(
                  height: 1,
                  color: const Color.fromARGB(206, 238, 238, 238)!,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }
}
