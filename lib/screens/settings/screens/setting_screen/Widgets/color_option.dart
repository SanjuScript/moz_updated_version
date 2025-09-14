import 'package:flutter/material.dart';

Widget buildColorOption(BuildContext context, Color color) {
  return ListTile(
    leading: CircleAvatar(backgroundColor: color),
    title: Text(
      color.toString(),
      style: TextStyle(color: Theme.of(context).cardColor),
    ),
    onTap: () {
      Navigator.pop(context);
    },
  );
}

