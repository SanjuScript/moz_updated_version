extension StringExtension on String {
  String capitalize() {
    if (isEmpty) {
      return this;
    }
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}

extension NameFormatting on String {
  String get formattedFirstName {
    final trimmed = trim();
    if (trimmed.isEmpty) return '';

    final first = trimmed.split(RegExp(r'\s+')).first;
    if (first.isEmpty) return '';

    return first[0].toUpperCase() + first.substring(1).toLowerCase();
  }

  String get formattedFirstNamePossessive {
    final name = formattedFirstName;
    if (name.isEmpty) return '';

    if (name.toLowerCase().endsWith('s')) {
      return "$name'";
    }

    return "$name's";
  }
}
