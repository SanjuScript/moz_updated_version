import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:moz_updated_version/screens/settings/screens/faq/helper/faq_model.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<FAQ> get _filteredFaqs {
    if (_searchQuery.isEmpty) return FAQData.faqs;
    return FAQData.faqs.where((faq) {
      return faq.question.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          faq.answer.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Premium App Bar
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withOpacity(0.8),
                      theme.colorScheme.secondary,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Animated circles background
                    Positioned(
                      top: -50,
                      right: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -30,
                      left: -30,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                    ),
                    // Content
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.help_outline_rounded,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Help Center",
                                        style: theme.textTheme.headlineSmall
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Find answers to common questions",
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: Colors.white.withOpacity(
                                                0.9,
                                              ),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade900 : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search FAQs...',
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // FAQ Count Badge
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _searchQuery.isEmpty
                          ? '${FAQData.faqs.length} Questions'
                          : '${_filteredFaqs.length} Results',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // FAQ List
          _filteredFaqs.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No results found',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try different keywords',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  sliver: AnimationLimiter(
                    child: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final faq = _filteredFaqs[index];
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: _PremiumFaqTile(
                                question: faq.question,
                                answer: faq.answer,
                                index: index,
                                searchQuery: _searchQuery,
                              ),
                            ),
                          ),
                        );
                      }, childCount: _filteredFaqs.length),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class _PremiumFaqTile extends StatefulWidget {
  final String question;
  final String answer;
  final int index;
  final String searchQuery;

  const _PremiumFaqTile({
    required this.question,
    required this.answer,
    required this.index,
    required this.searchQuery,
  });

  @override
  State<_PremiumFaqTile> createState() => _PremiumFaqTileState();
}

class _PremiumFaqTileState extends State<_PremiumFaqTile>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _animationController;
  late Animation<double> _iconRotation;
  late Animation<double> _expansionAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _iconRotation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _expansionAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  TextSpan _highlightSearchText(String text, TextStyle? style) {
    if (widget.searchQuery.isEmpty) {
      return TextSpan(text: text, style: style);
    }

    final matches = <TextSpan>[];
    final lowerText = text.toLowerCase();
    final lowerQuery = widget.searchQuery.toLowerCase();
    int lastMatchEnd = 0;

    for (int i = 0; i < lowerText.length; i++) {
      if (lowerText.substring(i).startsWith(lowerQuery)) {
        if (i > lastMatchEnd) {
          matches.add(
            TextSpan(text: text.substring(lastMatchEnd, i), style: style),
          );
        }
        matches.add(
          TextSpan(
            text: text.substring(i, i + lowerQuery.length),
            style: style?.copyWith(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withOpacity(0.3),
              fontWeight: FontWeight.bold,
            ),
          ),
        );
        lastMatchEnd = i + lowerQuery.length;
      }
    }

    if (lastMatchEnd < text.length) {
      matches.add(TextSpan(text: text.substring(lastMatchEnd), style: style));
    }

    return TextSpan(children: matches);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Category colors based on index
    final List<Color> categoryColors = [
      Colors.blue,
      Colors.purple,
      Colors.green,
      Colors.orange,
      Colors.pink,
      Colors.teal,
    ];
    final accentColor = categoryColors[widget.index % categoryColors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: _expanded
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accentColor.withOpacity(0.05),
                  accentColor.withOpacity(0.02),
                ],
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: _expanded
                ? accentColor.withOpacity(0.2)
                : Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: _expanded ? 16 : 8,
            offset: Offset(0, _expanded ? 6 : 2),
          ),
        ],
      ),
      child: Material(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: _toggleExpanded,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Number Badge
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [accentColor, accentColor.withOpacity(0.7)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '${widget.index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Question
                    Expanded(
                      child: RichText(
                        text: _highlightSearchText(
                          widget.question,
                          theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Animated Icon
                    AnimatedBuilder(
                      animation: _iconRotation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _iconRotation.value * 3.14159,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: accentColor,
                              size: 24,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                // Animated Answer
                SizeTransition(
                  sizeFactor: _expansionAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Container(
                        height: 2,
                        width: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [accentColor, accentColor.withOpacity(0.3)],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 12),
                      RichText(
                        text: _highlightSearchText(
                          widget.answer,
                          theme.textTheme.bodyMedium?.copyWith(
                            height: 1.6,
                            color: theme.colorScheme.onSurface.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
