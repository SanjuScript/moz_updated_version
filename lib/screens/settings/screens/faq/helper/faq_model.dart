class FAQ {
  final String question;
  final String answer;

  const FAQ({
    required this.question,
    required this.answer,
  });
}



class FAQData {
  static const List<FAQ> faqs = [
    FAQ(
      question: "What is this app about?",
      answer:
          "This is a modern music player designed to play all your songs stored on your device. It comes with a feature-rich interface, smooth animations, and dynamic theming for a delightful listening experience.",
    ),
    FAQ(
      question: "Does it support custom theming?",
      answer:
          "Yes! The player adapts beautifully to system themes and also supports Dark and Light modes. In addition, it comes with a smart Time-based theme that automatically switches between light and dark according to the time of day, giving you a personalized and dynamic music experience.",
    ),
    FAQ(
      question: "Can I manage my library?",
      answer:
          "Absolutely. You can include or exclude specific folders, set minimum audio duration filters, and keep your music collection organized exactly the way you want.",
    ),
    FAQ(
      question: "What kind of animations are used?",
      answer:
          "The app makes use of elegant transitions, smooth motion effects, and micro-animations across the UI, giving you a premium, fluid, and immersive music experience.",
    ),
    FAQ(
      question: "Does the app support playlists and favorites?",
      answer:
          "Yes! You can create your own playlists, mark tracks as favorites, and quickly access them anytime from the beautifully designed UI. In addition, the app automatically keeps track of your Recently Played songs and highlights your Mostly Played tracks, making it easier to rediscover your favorite music.",
    ),
    FAQ(
      question: "Will it work offline?",
      answer:
          "Definitely! The music player is built to play audio files directly from your device storage, so no internet connection is required.",
    ),
    FAQ(
      question: "Do I need to restart the app after making changes?",
      answer:
          "In most cases, changes like adding or excluding folders are applied instantly. However, sometimes a quick restart ensures that your library is fully refreshed.",
    ),
    FAQ(
      question: "How do I exclude a folder?",
      answer:
          "Go to Settings → Storage Location → Tap on a folder to toggle exclusion. Excluded folders won’t appear in your library.",
    ),
    FAQ(
      question: "Does the app support a sleep timer?",
      answer:
          "Yes! You can set a sleep timer to stop playback automatically. It supports both track-count based timers (stop after a certain number of songs) and time-based timers (stop after a specific duration). Perfect for late-night listening!",
    ),
    FAQ(
      question: "Can I get playback notifications?",
      answer:
          "Of course! The app provides rich notification controls so you can play, pause, skip tracks, or stop playback directly from the notification panel—making it quick and convenient without opening the app.",
    ),
    FAQ(
      question: "Can I change the UI style?",
      answer:
          "Yes, you can! The app includes a toggle in settings that lets you switch the interface to an iOS-inspired style for those who prefer a different look and feel.",
    ),
    FAQ(
      question: "Can I edit or rename audio files with this app?",
      answer:
          "No, the app focuses purely on delivering the best playback and library management experience. It does not support editing or renaming audio files, ensuring your original files remain safe and untouched.",
    ),
    FAQ(
      question: "Why are short audios excluded?",
      answer:
          "Short audios (like WhatsApp tones or ringtones) can clutter your library. You can set a minimum duration filter to skip them.",
    ),
    FAQ(
      question: "Do I need to restart the app?",
      answer:
          "In some cases, yes. After making changes to excluded folders or duration filters, restarting the app ensures updates take effect.",
    ),
    FAQ(
      question: "Can I remove default folders?",
      answer:
          "No, default system folders are protected. However, you can always add and remove your own custom folders.",
    ),
  ];
}