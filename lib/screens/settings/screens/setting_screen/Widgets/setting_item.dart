import 'package:flutter/material.dart';

class SettingsItem extends StatelessWidget {
  final String title;
  final Widget trailing;
  final void Function()? onTap;
  final String? subTitle;

  const SettingsItem({
    super.key,
    required this.title,
    required this.trailing,
    this.subTitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      subtitle: subTitle != null && subTitle!.isNotEmpty
          ? Text(
              subTitle ?? '',
              maxLines: 1,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(letterSpacing: .3),
            )
          : null,
      trailing: trailing,
      onTap: onTap,
    );
  }
}
