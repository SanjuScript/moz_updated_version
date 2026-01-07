import 'package:flutter/material.dart';
import 'package:moz_updated_version/data/db/language_db/respository/language_repo.dart';
import 'package:moz_updated_version/screens/ONLINE/bottom_nav/presentation/ui/bottom_nav.dart';
import 'package:moz_updated_version/screens/ONLINE/search_screen/presentation/ui/search_screen_on.dart';
import 'package:moz_updated_version/services/service_locator.dart';

// Language Selection Screen
class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Set<String> _selectedLanguages = {};
  final _repository = sl<LanguageRepository>();

  final List<LanguageItem> _languages = [
    LanguageItem(
      code: 'ml',
      name: 'Malayalam',
      flag: '🇮🇳',
      color: Color(0xFF00BCD4),
    ),
    LanguageItem(
      code: 'en',
      name: 'English',
      flag: '🇬🇧',
      color: Color(0xFF1DB954),
    ),
    LanguageItem(
      code: 'hi',
      name: 'Hindi',
      flag: '🇮🇳',
      color: Color(0xFFFF9800),
    ),
    LanguageItem(
      code: 'ta',
      name: 'Tamil',
      flag: '🇮🇳',
      color: Color(0xFFE91E63),
    ),
    LanguageItem(
      code: 'te',
      name: 'Telugu',
      flag: '🇮🇳',
      color: Color(0xFF9C27B0),
    ),
    LanguageItem(
      code: 'kn',
      name: 'Kannada',
      flag: '🇮🇳',
      color: Color(0xFFF44336),
    ),
    LanguageItem(
      code: 'pa',
      name: 'Punjabi',
      flag: '🇮🇳',
      color: Color(0xFFFF5722),
    ),
    LanguageItem(
      code: 'bn',
      name: 'Bengali',
      flag: '🇮🇳',
      color: Color(0xFF4CAF50),
    ),
    LanguageItem(
      code: 'mr',
      name: 'Marathi',
      flag: '🇮🇳',
      color: Color(0xFF673AB7),
    ),
    LanguageItem(
      code: 'gu',
      name: 'Gujarati',
      flag: '🇮🇳',
      color: Color(0xFF2196F3),
    ),
    LanguageItem(
      code: 'es',
      name: 'Spanish',
      flag: '🇪🇸',
      color: Color(0xFFFFC107),
    ),
    LanguageItem(
      code: 'fr',
      name: 'French',
      flag: '🇫🇷',
      color: Color(0xFF3F51B5),
    ),
    LanguageItem(
      code: 'ar',
      name: 'Arabic',
      flag: '🇸🇦',
      color: Color(0xFF009688),
    ),
    LanguageItem(
      code: 'ko',
      name: 'Korean',
      flag: '🇰🇷',
      color: Color(0xFFE91E63),
    ),
    LanguageItem(
      code: 'ja',
      name: 'Japanese',
      flag: '🇯🇵',
      color: Color(0xFFF44336),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _controller.forward();
    _loadSavedLanguages();
  }

  Future<void> _loadSavedLanguages() async {
    final saved = await _repository.getSelectedLanguages();
    setState(() {
      _selectedLanguages.addAll(saved);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleLanguage(String code) {
    setState(() {
      if (_selectedLanguages.contains(code)) {
        _selectedLanguages.remove(code);
      } else {
        _selectedLanguages.add(code);
      }
    });
  }

  Future<void> _saveAndContinue() async {
    if (_selectedLanguages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select at least one language'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    await _repository.saveSelectedLanguages(_selectedLanguages.toList());

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Language preferences saved!'),
          backgroundColor: Colors.green.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnlineBottomNavScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: FadeTransition(
                  opacity: _controller,
                  child: _buildLanguageGrid(),
                ),
              ),
              _buildBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back_ios, color: Colors.white),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  '${_selectedLanguages.length} selected',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          Text(
            'Choose Your\nMusic Languages',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Select languages to personalize your feed',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageGrid() {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1,
      ),
      itemCount: _languages.length,
      itemBuilder: (context, index) {
        final lang = _languages[index];
        final isSelected = _selectedLanguages.contains(lang.name);

        return GestureDetector(
          onTap: () => _toggleLanguage(lang.name),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: const Color(0xFF16161D),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF1DB954)
                    : Colors.white.withValues(alpha: 0.08),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                lang.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.7),
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _saveAndContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1DB954),
              padding: EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
            ),
            child: Text(
              'Save & Continue',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LanguageItem {
  final String code;
  final String name;
  final String flag;
  final Color color;

  LanguageItem({
    required this.code,
    required this.name,
    required this.flag,
    required this.color,
  });
}
