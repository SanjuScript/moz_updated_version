
import 'package:flutter/material.dart';

class GlassMenuLayout extends SingleChildLayoutDelegate {
  GlassMenuLayout(this.position, this.textDirection, this.padding);

  final RelativeRect position;
  final TextDirection textDirection;
  final EdgeInsets padding;

  static const double _kMenuScreenPadding = 8.0;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints.loose(
      constraints.biggest,
    ).deflate(const EdgeInsets.all(_kMenuScreenPadding) + padding);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    double y = position.top;

    // If menu goes off bottom, show above the button
    if (y + childSize.height >
        size.height - _kMenuScreenPadding - padding.bottom) {
      y = position.top - childSize.height;
    }

    // Horizontal placement
    double x;
    if (position.left > position.right) {
      x = size.width - position.right - childSize.width;
    } else if (position.left < position.right) {
      x = position.left;
    } else {
      x = textDirection == TextDirection.rtl
          ? size.width - position.right - childSize.width
          : position.left;
    }

    // Clamp inside screen
    if (x < _kMenuScreenPadding + padding.left) {
      x = _kMenuScreenPadding + padding.left;
    } else if (x + childSize.width >
        size.width - _kMenuScreenPadding - padding.right) {
      x = size.width - childSize.width - _kMenuScreenPadding - padding.right;
    }

    return Offset(x, y);
  }

  @override
  bool shouldRelayout(GlassMenuLayout oldDelegate) {
    return position != oldDelegate.position ||
        textDirection != oldDelegate.textDirection ||
        padding != oldDelegate.padding;
  }
}
