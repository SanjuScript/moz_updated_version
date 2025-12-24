import 'package:hive/hive.dart';
import 'package:moz_updated_version/data/db/language_db/model/language_preference_model.dart';

class LanguageRepository {
  static const String _boxName = 'languagePreferences';
  static const String _preferenceKey = 'userLanguagePreference';

  Box<LanguagePreference>? _box;

  Future<void> init() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<LanguagePreference>(_boxName);
    }
  }

  Future<Box<LanguagePreference>> _getBox() async {
    if (_box == null || !_box!.isOpen) {
      await init();
    }
    return _box!;
  }

  Future<void> saveSelectedLanguages(List<String> languages) async {
    final box = await _getBox();

    final existing = box.get(_preferenceKey);

    final preference = LanguagePreference(
      selectedLanguages: languages,
      lastUpdated: DateTime.now(),
      isOnboardingComplete: existing?.isOnboardingComplete ?? true,
    );

    await box.put(_preferenceKey, preference);
  }

  Future<List<String>> getSelectedLanguages() async {
    final box = await _getBox();
    final preference = box.get(_preferenceKey);

    if (preference == null) {
      return [];
    }

    return preference.selectedLanguages;
  }

  Future<LanguagePreference?> getPreference() async {
    final box = await _getBox();
    return box.get(_preferenceKey);
  }

  Future<void> addLanguage(String languageCode) async {
    final languages = await getSelectedLanguages();

    if (!languages.contains(languageCode)) {
      languages.add(languageCode);
      await saveSelectedLanguages(languages);
    }
  }

  Future<void> removeLanguage(String languageCode) async {
    final languages = await getSelectedLanguages();

    if (languages.contains(languageCode)) {
      languages.remove(languageCode);
      await saveSelectedLanguages(languages);
    }
  }

  Future<bool> isLanguageSelected(String languageCode) async {
    final languages = await getSelectedLanguages();
    return languages.contains(languageCode);
  }

  Future<void> setOnboardingComplete(bool complete) async {
    final box = await _getBox();
    final existing = box.get(_preferenceKey);

    final preference = LanguagePreference(
      selectedLanguages: existing?.selectedLanguages ?? [],
      lastUpdated: DateTime.now(),
      isOnboardingComplete: complete,
    );

    await box.put(_preferenceKey, preference);
  }

  Future<bool> isOnboardingComplete() async {
    final preference = await getPreference();
    return preference?.isOnboardingComplete ?? false;
  }

  Future<void> clearPreferences() async {
    final box = await _getBox();
    await box.delete(_preferenceKey);
  }

  Future<DateTime?> getLastUpdated() async {
    final preference = await getPreference();
    return preference?.lastUpdated;
  }

  Future<Map<String, dynamic>?> exportAsJson() async {
    final preference = await getPreference();
    return preference?.toJson();
  }

  Future<void> importFromJson(Map<String, dynamic> json) async {
    final preference = LanguagePreference.fromJson(json);
    final box = await _getBox();
    await box.put(_preferenceKey, preference);
  }

  Future<void> close() async {
    if (_box != null && _box!.isOpen) {
      await _box!.close();
      _box = null;
    }
  }

  Future<void> deleteBox() async {
    await close();
    await Hive.deleteBoxFromDisk(_boxName);
  }
}
