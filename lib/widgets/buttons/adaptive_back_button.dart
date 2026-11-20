import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A compact back control with an iOS chevron and Navigator.maybePop behavior.
class AdaptiveBackButton extends StatelessWidget {
  const AdaptiveBackButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;
    return IconButton(
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      onPressed: onPressed ?? () => Navigator.of(context).maybePop(),
      icon: Icon(isIOS ? CupertinoIcons.back : Icons.arrow_back_rounded),
    );
  }
}
