import 'package:flutter/material.dart';

Widget qualityDropdown({
  required String value,
  required Map<String, String> items,
  required ValueChanged<String?> onChanged,
}) {
  return SizedBox(
    width: 100,
    child: DropdownButton<String>(
      value: value,
      isExpanded: true,
      underline: const SizedBox(),
      borderRadius: BorderRadius.circular(10),
      items: items.entries.map((entry) {
        return DropdownMenuItem<String>(
          value: entry.key,
          child: Text(entry.value),
        );
      }).toList(),
      onChanged: onChanged,
    ),
  );
}
