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

extension NumberFormatX on num {
  String toKMBB() {
    if (this >= 1000000000) {
      return '${(this / 1000000000).toStringAsFixed(1)}B';
    }
    if (this >= 1000000) {
      return '${(this / 1000000).toStringAsFixed(1)}M';
    }
    if (this >= 1000) {
      return '${(this / 1000).toStringAsFixed(1)}K';
    }
    return toString();
  }
}

extension SongTitleCleaner on String {
  String get cleanTitle {
    return replaceAll(RegExp(r'\s*[\(\[].*?[\)\]]'), '')
        .replaceAll(RegExp(r'\s*[-–—|].*'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}

extension ArtworkSize on String {
  String replaceArtworkSize(String target) {
    return replaceAll(RegExp(r'\d{2,4}x\d{2,4}'), target);
  }
}
