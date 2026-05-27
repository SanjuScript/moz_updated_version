import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moz_updated_version/core/helper/snackbar_helper.dart';
import 'package:moz_updated_version/data/db/language_db/respository/language_repo.dart';
import 'package:moz_updated_version/screens/ONLINE/bottom_nav/presentation/ui/bottom_nav.dart';
import 'package:moz_updated_version/services/service_locator.dart';

class LanguageSelectionScreenForTv extends StatefulWidget {
  const LanguageSelectionScreenForTv({super.key});

  @override
  State<LanguageSelectionScreenForTv> createState() =>
      _LanguageSelectionScreenForTvState();
}

class _LanguageSelectionScreenForTvState
    extends State<LanguageSelectionScreenForTv>
    with SingleTickerProviderStateMixin {
  final _repository = sl<LanguageRepository>();
  final Set<String> _selectedLanguages = {};
  late final List<FocusNode> _focusNodes;
  late AnimationController _animController;
  bool _isLoading = true;

  final List<String> _languages = [
    'Malayalam',
    'English',
    'Hindi',
    'Tamil',
    'Telugu',
    'Kannada',
    'Punjabi',
    'Bengali',
    'Marathi',
    'Gujarati',
    'Spanish',
    'French',
    'Arabic',
    'Korean',
    'Japanese',
  ];

  @override
  void initState() {
    super.initState();
    _focusNodes = List.generate(_languages.length, (_) => FocusNode());
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadSavedLanguages();
  }

  Future<void> _loadSavedLanguages() async {
    final saved = await _repository.getSelectedLanguages();
    setState(() {
      _selectedLanguages.addAll(saved);
      _isLoading = false;
    });
    _animController.forward();
  }

  void _toggleLanguage(String lang) {
    setState(() {
      if (_selectedLanguages.contains(lang)) {
        _selectedLanguages.remove(lang);
      } else {
        _selectedLanguages.add(lang);
      }
    });
  }

  Future<void> _saveAndContinue() async {
    if (_selectedLanguages.isEmpty) {
      AppSnackBar.error(context, "Please select at least one language");
      return;
    }

    await _repository.saveSelectedLanguages(_selectedLanguages.toList());

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnlineBottomNavScreen()),
      );
    }
  }

  @override
  void dispose() {
    for (final node in _focusNodes) {
      node.dispose();
    }
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E14),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 16),
                    _buildSubtitle(),
                    const SizedBox(height: 40),
                    Expanded(child: _buildGrid()),
                    const SizedBox(height: 32),
                    _buildFooter(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _animController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Your Music Languages',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitle() {
    return FadeTransition(
      opacity: _animController,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _selectedLanguages.isNotEmpty
                  ? Theme.of(context).primaryColor.withOpacity(0.2)
                  : const Color(0xFF1B1B25),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _selectedLanguages.isNotEmpty
                    ? Theme.of(context).primaryColor
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Text(
              '${_selectedLanguages.length} selected',
              style: TextStyle(
                fontSize: 16,
                color: _selectedLanguages.isNotEmpty
                    ? Theme.of(context).primaryColor
                    : Colors.white60,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Choose languages for personalized music recommendations',
            style: TextStyle(fontSize: 16, color: Colors.white60),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return FadeTransition(
      opacity: _animController,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 2.5,
        ),
        itemCount: _languages.length,
        itemBuilder: (context, index) => _buildLanguageCard(index),
      ),
    );
  }

  Widget _buildLanguageCard(int index) {
    final lang = _languages[index];
    final selected = _selectedLanguages.contains(lang);

    return Focus(
      focusNode: _focusNodes[index],
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            (event.logicalKey.keyLabel == 'Select' ||
                event.logicalKey.keyLabel == ' ')) {
          _toggleLanguage(lang);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Builder(
        builder: (context) {
          final focused = Focus.of(context).hasFocus;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            transform: Matrix4.identity()..scale(focused ? 1.05 : 1.0),
            decoration: BoxDecoration(
              gradient: selected
                  ? LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: selected ? null : const Color(0xFF1B1B25),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: focused
                    ? Colors.white
                    : selected
                    ? Theme.of(context).primaryColor.withOpacity(0.5)
                    : Colors.transparent,
                width: focused ? 3 : 2,
              ),
              boxShadow: focused
                  ? [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ]
                  : selected
                  ? [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.4),
                        blurRadius: 15,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _toggleLanguage(lang),
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        lang,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    if (selected)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check,
                            size: 16,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFooter() {
    return FadeTransition(
      opacity: _animController,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_selectedLanguages.isNotEmpty)
            TextButton.icon(
              onPressed: () {
                setState(() => _selectedLanguages.clear());
              },
              icon: const Icon(Icons.clear_all, color: Colors.white60),
              label: const Text(
                'Clear All',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white60,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          else
            const SizedBox.shrink(),
          ElevatedButton(
            onPressed: _selectedLanguages.isEmpty ? null : _saveAndContinue,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 24),
              backgroundColor: Theme.of(context).primaryColor,
              disabledBackgroundColor: const Color(0xFF1B1B25),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: _selectedLanguages.isEmpty ? 0 : 8,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white60,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.arrow_forward_rounded, size: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
