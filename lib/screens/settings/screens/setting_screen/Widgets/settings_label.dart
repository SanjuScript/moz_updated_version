final Map<String, String> imageQualityMap = {
  'low': 'Low',
  'medium': 'Medium',
  'high': 'High',
};

final Map<String, String> audioQualityMap = {
  'low': 'Low',
  'medium': 'Medium',
  'high': 'High',
};

String getImageQualityDescription(String quality) {
  switch (quality) {
    case 'low':
      return 'low-resolution - save data';
    case 'high':
      return 'high-resolution artwork';
    case 'medium':
    default:
      return 'Balanced image quality';
  }
}

String getAudioQualityDescription(String quality) {
  switch (quality) {
    case 'low':
      return '96 kbps - saves data';
    case 'high':
      return 'High quality (320 kbps)';
    case 'medium':
    default:
      return 'Medium quality - 160 kbps';
  }
}
