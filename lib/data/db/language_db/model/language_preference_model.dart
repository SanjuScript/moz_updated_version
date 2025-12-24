import 'package:hive/hive.dart';

part 'language_preference_model.g.dart';

@HiveType(typeId: 4)
class LanguagePreference extends HiveObject {
  @HiveField(0)
  List<String> selectedLanguages;

  @HiveField(1)
  DateTime lastUpdated;

  @HiveField(2)
  bool isOnboardingComplete;

  LanguagePreference({
    required this.selectedLanguages,
    required this.lastUpdated,
    this.isOnboardingComplete = false,
  });

  LanguagePreference copyWith({
    List<String>? selectedLanguages,
    DateTime? lastUpdated,
    bool? isOnboardingComplete,
  }) {
    return LanguagePreference(
      selectedLanguages: selectedLanguages ?? this.selectedLanguages,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isOnboardingComplete: isOnboardingComplete ?? this.isOnboardingComplete,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'selectedLanguages': selectedLanguages,
      'lastUpdated': lastUpdated.toIso8601String(),
      'isOnboardingComplete': isOnboardingComplete,
    };
  }

  factory LanguagePreference.fromJson(Map<String, dynamic> json) {
    return LanguagePreference(
      selectedLanguages: List<String>.from(json['selectedLanguages']),
      lastUpdated: DateTime.parse(json['lastUpdated']),
      isOnboardingComplete: json['isOnboardingComplete'] ?? false,
    );
  }
}
