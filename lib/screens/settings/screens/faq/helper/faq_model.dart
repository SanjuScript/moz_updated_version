class FAQ {
  final String question;
  final String answer;

  const FAQ({required this.question, required this.answer});
}

class FAQData {
  static const List<FAQ> faqs = [
    FAQ(
      question: "What is Moz Music?",
      answer:
          "Moz Music is a powerful hybrid music player that lets you enjoy both offline and online music. Play songs stored on your device or stream millions of tracks online with a feature-rich interface, smooth animations, synchronized lyrics, and intelligent recommendations powered by Moz.",
    ),
    FAQ(
      question: "Can I use Moz Music without an internet connection?",
      answer:
          "Absolutely! Moz Music works perfectly offline for playing your local music files. You can enjoy all your downloaded songs without any internet connection. Online features like streaming, lyrics sync, and recommendations require an internet connection.",
    ),
    FAQ(
      question: "Do I need to create an account?",
      answer:
          "An account is optional! You can use Moz Music offline without creating an account. However, creating a free account unlocks online streaming, personalized recommendations, cloud playlists, cross-device sync, and more premium features.",
    ),
    FAQ(
      question: "What online features does Moz Music offer?",
      answer:
          "With online mode, you get access to millions of songs, real-time synchronized lyrics, personalized recommendations by Moz AI, curated playlists, new releases, trending charts, artist radio, and the ability to sync your library across all your devices.",
    ),
    FAQ(
      question: "Can I choose music quality for streaming?",
      answer:
          "Yes! Moz Music lets you select your preferred streaming quality: Low (64 kbps) for data saving, Normal (128 kbps) for balanced performance, High (320 kbps) for premium quality, and Lossless for audiophile-grade listening. You can set different qualities for WiFi and mobile data.",
    ),
    FAQ(
      question: "Does Moz Music show lyrics?",
      answer:
          "Yes! Moz Music features real-time synchronized lyrics that highlight line-by-line as the song plays. For online tracks, lyrics are automatically fetched. You can also view, scroll, and tap on any line to jump to that part of the song instantly.",
    ),
    FAQ(
      question: "How do Moz recommendations work?",
      answer:
          "Moz uses advanced AI to analyze your listening habits, favorite genres, and mood preferences to create personalized recommendations just for you. The more you listen, the smarter Moz gets at understanding your taste and suggesting new music you'll love.",
    ),
    FAQ(
      question: "Can I create and sync playlists?",
      answer:
          "Definitely! Create unlimited playlists with both local and online tracks. With a Moz account, your playlists automatically sync across all your devices. You can also make playlists public to share with friends or keep them private.",
    ),
    FAQ(
      question: "Does it support custom theming?",
      answer:
          "Yes! Moz Music adapts beautifully to system themes and supports Dark and Light modes. It also features a smart Time-based theme that automatically switches according to the time of day. Plus, the player extracts colors from album artwork for a dynamic, immersive visual experience.",
    ),
    FAQ(
      question: "Can I download songs for offline listening?",
      answer:
          "Yes! Premium subscribers can download any song from our online catalog for offline playback. Downloaded songs are available even without internet and don't count toward your data usage. You can download entire playlists or albums with one tap.",
    ),
    FAQ(
      question: "What are favorites and how do they work?",
      answer:
          "Tap the heart icon on any song (local or online) to add it to your Favorites. Your favorites sync across devices with your Moz account and help our AI understand your preferences better for more accurate recommendations.",
    ),
    FAQ(
      question: "Does Moz Music track my listening history?",
      answer:
          "Yes, Moz Music automatically tracks your Recently Played songs and Mostly Played tracks to help you rediscover your favorites. This data is also used to improve your personalized recommendations. You can clear your history anytime from settings.",
    ),
    FAQ(
      question: "Can I manage my local music library?",
      answer:
          "Absolutely! You can include or exclude specific folders, set minimum audio duration filters to skip ringtones and notifications, and organize your local collection exactly the way you want. Changes are reflected instantly in your library.",
    ),
    FAQ(
      question: "What audio formats are supported?",
      answer:
          "Moz Music supports all major audio formats including MP3, AAC, FLAC, WAV, OGG, M4A, and more. For online streaming, we provide multiple quality options from standard MP3 to high-fidelity lossless formats.",
    ),
    FAQ(
      question: "Does the app support a sleep timer?",
      answer:
          "Yes! Set a sleep timer to automatically stop playback after a specific duration (5, 10, 15, 30 minutes, or custom) or after a certain number of songs. You can also set it to stop at the end of the current track. Perfect for bedtime listening!",
    ),
    FAQ(
      question: "Can I search for songs, artists, or albums?",
      answer:
          "Absolutely! Moz Music features powerful search across both your local library and our entire online catalog. Search by song title, artist name, album, genre, or even lyrics. Results appear instantly as you type with smart suggestions.",
    ),
    FAQ(
      question: "Are there curated playlists and radio stations?",
      answer:
          "Yes! Discover expertly curated playlists for every mood, genre, and occasion. Create personalized radio stations based on any artist, song, or genre. Moz Radio learns your preferences and plays similar tracks you'll enjoy.",
    ),
    FAQ(
      question: "Can I see what's trending?",
      answer:
          "Definitely! Check out trending charts updated daily, new releases from your favorite artists, top songs in your region, and viral tracks gaining popularity. Stay up-to-date with what's hot in the music world.",
    ),
    FAQ(
      question: "Does it have playback notifications?",
      answer:
          "Yes! Rich notification controls let you play, pause, skip tracks, view lyrics, add to favorites, or stop playback directly from the notification panel. You can control everything without opening the app.",
    ),
    FAQ(
      question: "What kind of animations are included?",
      answer:
          "Moz Music features elegant transitions, smooth motion effects, playful micro-animations, and beautiful visualizers that react to your music. The entire UI feels premium, fluid, and incredibly responsive for an immersive listening experience.",
    ),
    FAQ(
      question: "Can I change the UI style?",
      answer:
          "Yes! Switch between Android Material Design and iOS-inspired styles in settings. Choose what feels most comfortable for you. The app maintains its beautiful aesthetics regardless of which style you prefer.",
    ),
    FAQ(
      question: "Is my data safe and private?",
      answer:
          "Absolutely! We use industry-standard encryption for all data transmission. Your listening data is used only to improve recommendations and is never sold to third parties. You can delete your account and all associated data anytime. Read our Privacy Policy for complete details.",
    ),
    FAQ(
      question: "Does Moz Music support Android Auto or CarPlay?",
      answer:
          "Yes! Moz Music is fully compatible with Android Auto and Apple CarPlay, giving you a safe and seamless way to enjoy your music while driving. Control playback with voice commands or steering wheel buttons.",
    ),
    FAQ(
      question: "Can I share songs with friends?",
      answer:
          "Definitely! Share any song, album, playlist, or artist with friends through social media, messaging apps, or a direct link. Friends can listen even if they don't have Moz Music installed (web player available).",
    ),
    FAQ(
      question: "Why are short audio files excluded?",
      answer:
          "Short audios like WhatsApp tones, ringtones, and notification sounds can clutter your library. You can set a minimum duration filter (default 30 seconds) to automatically skip them and keep your music collection clean.",
    ),
    FAQ(
      question: "Do I need to restart the app after making changes?",
      answer:
          "Usually no! Most changes like adding/excluding folders, changing quality settings, or updating preferences apply instantly. However, a quick restart might be needed after major library scans to ensure everything is properly refreshed.",
    ),
    FAQ(
      question: "How do I exclude a folder from my library?",
      answer:
          "Go to Settings → Storage Location → Select the folder you want to exclude → Toggle the switch. Excluded folders won't appear in your library. This is useful for hiding audiobooks, podcasts, or other non-music content.",
    ),
    FAQ(
      question: "Can I edit metadata or rename files?",
      answer:
          "Moz Music focuses on delivering the best playback and streaming experience. While you can't edit file metadata directly in the app, you can add songs to playlists, mark favorites, and organize your collection through our library management features.",
    ),
    // FAQ(
    //   question: "What is Moz Premium?",
    //   answer:
    //       "Moz Premium unlocks ad-free listening, unlimited downloads for offline playback, highest quality audio (lossless), advanced equalizer settings, exclusive early access to new features, and priority customer support. Try it free for 30 days!",
    // ),
    FAQ(
      question: "How much mobile data does streaming use?",
      answer:
          "It depends on your quality settings. Low quality uses about 30 MB/hour, Normal uses 60 MB/hour, High uses 150 MB/hour, and Lossless uses up to 400 MB/hour. Enable 'Download on WiFi only' in settings to save mobile data.",
    ),
    FAQ(
      question: "Can I use Moz Music on multiple devices?",
      answer:
          "Yes! Sign in with your Moz account on any device (phone, tablet, desktop) and your library, playlists, favorites, and listening history sync automatically. Play on one device and continue seamlessly on another.",
    ),
  ];
}
