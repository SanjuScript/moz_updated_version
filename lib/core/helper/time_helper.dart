class TimeHelper {
  static String timeAgo(int playedAtMillis) {
    final playedDate = DateTime.fromMillisecondsSinceEpoch(playedAtMillis);
    final now = DateTime.now();
    final difference = now.difference(playedDate);

    String time;

    if (difference.inSeconds < 60) {
      time = "${difference.inSeconds}s";
    } else if (difference.inMinutes < 60) {
      time = "${difference.inMinutes}m";
    } else if (difference.inHours < 24) {
      time = "${difference.inHours}h";
    } else if (difference.inDays < 7) {
      time = "${difference.inDays}d";
    } else if (difference.inDays < 30) {
      time = "${(difference.inDays / 7).floor()}w";
    } else if (difference.inDays < 365) {
      time = "${(difference.inDays / 30).floor()}mo";
    } else {
      time = "${(difference.inDays / 365).floor()}y";
    }

    return "$time\nago";
  }
}
