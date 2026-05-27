import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Privacy Policy",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple.shade400, Colors.purple.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Your Privacy Matters",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Last Updated: January 23, 2026",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "We've updated our privacy policy to reflect new online streaming features while keeping your data secure.",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // What's New Section
            _buildHighlightCard(
              icon: Icons.new_releases_outlined,
              title: "What's New in This Update",
              content:
                  "Moz Music now offers online streaming alongside offline playback. "
                  "We use minimal data to provide personalized recommendations and "
                  "improve your listening experience. Your privacy remains our top priority.",
              color: Colors.blue,
              isDark: isDark,
            ),
            const SizedBox(height: 24),

            // Section 1
            _buildSection(
              number: "1",
              title: "Introduction",
              content:
                  "Welcome to Moz Music, your hybrid music player that works both "
                  "online and offline. This Privacy Policy explains how we collect, use, "
                  "and protect your information. We believe in transparency and giving you "
                  "control over your data.",
              isDark: isDark,
            ),

            // Section 2
            _buildSection(
              number: "2",
              title: "Information We Collect",
              content: "",
              isDark: isDark,
              children: [
                _buildSubSection(
                  title: "2.1 Local Device Data (Offline Mode)",
                  content:
                      "When using offline features, we only access audio files stored "
                      "on your device. This data never leaves your device.",
                  isDark: isDark,
                ),
                _buildSubSection(
                  title: "2.2 Account Information (Online Mode)",
                  content:
                      "To provide streaming services, we collect your email address, "
                      "username, and password (encrypted). You can also optionally add a "
                      "profile picture and display name.",
                  isDark: isDark,
                ),
                _buildSubSection(
                  title: "2.3 Listening Activity",
                  content:
                      "We collect data about songs you play, skip, favorite, and add "
                      "to playlists. This helps us recommend music you'll love. We use "
                      "aggregated listening patterns, not your specific identity.",
                  isDark: isDark,
                ),
                _buildSubSection(
                  title: "2.4 Device Information",
                  content:
                      "We collect basic device info (OS version, app version, device "
                      "model) to ensure compatibility and improve performance. No unique "
                      "device identifiers are stored.",
                  isDark: isDark,
                ),
                _buildSubSection(
                  title: "2.5 What We Don't Collect",
                  content:
                      "We do NOT access your contacts, messages, call logs, location "
                      "data, or any files outside your music library. We never sell your "
                      "personal information to third parties.",
                  isDark: isDark,
                  highlight: true,
                ),
              ],
            ),

            // Section 3
            _buildSection(
              number: "3",
              title: "How We Use Your Data",
              content: "",
              isDark: isDark,
              children: [
                _buildBulletPoint(
                  "Personalized music recommendations based on your taste",
                  isDark,
                ),
                _buildBulletPoint(
                  "Creating custom playlists and radio stations for you",
                  isDark,
                ),
                _buildBulletPoint(
                  "Syncing your library across devices (if enabled)",
                  isDark,
                ),
                _buildBulletPoint(
                  "Improving app performance and fixing bugs",
                  isDark,
                ),
                _buildBulletPoint(
                  "Sending important updates about your account",
                  isDark,
                ),
                _buildBulletPoint(
                  "Analyzing aggregate trends to improve music discovery",
                  isDark,
                ),
              ],
            ),

            // Section 4
            _buildSection(
              number: "4",
              title: "Data Security & Encryption",
              content:
                  "Your security is paramount. All data transmitted between your device "
                  "and our servers uses industry-standard TLS/SSL encryption. Passwords are "
                  "hashed using bcrypt and never stored in plain text. We employ advanced "
                  "security measures including regular security audits, intrusion detection, "
                  "and secure data centers with 24/7 monitoring.",
              isDark: isDark,
            ),

            // Section 5
            _buildSection(
              number: "5",
              title: "Third-Party Services",
              content: "",
              isDark: isDark,
              children: [
                _buildSubSection(
                  title: "Analytics",
                  content:
                      "We use privacy-focused analytics to understand app usage patterns. "
                      "All data is anonymized and aggregated. We never track individual users.",
                  isDark: isDark,
                ),
                _buildSubSection(
                  title: "Music Licensing Partners",
                  content:
                      "To provide streaming content, we work with licensed music providers. "
                      "They receive anonymized playback data for royalty calculations only.",
                  isDark: isDark,
                ),
                _buildSubSection(
                  title: "Payment Processors",
                  content:
                      "For premium subscriptions, we use secure payment processors. We "
                      "never store your complete credit card information on our servers.",
                  isDark: isDark,
                ),
              ],
            ),

            // Section 6
            _buildSection(
              number: "6",
              title: "Your Privacy Rights & Controls",
              content: "",
              isDark: isDark,
              children: [
                _buildBulletPoint(
                  "Access and download all your data at any time",
                  isDark,
                ),
                _buildBulletPoint(
                  "Delete your account and all associated data permanently",
                  isDark,
                ),
                _buildBulletPoint(
                  "Opt out of personalized recommendations",
                  isDark,
                ),
                _buildBulletPoint(
                  "Control what data is synced across devices",
                  isDark,
                ),
                _buildBulletPoint(
                  "Manage email preferences and notifications",
                  isDark,
                ),
                _buildBulletPoint(
                  "Use the app in offline-only mode without creating an account",
                  isDark,
                ),
              ],
            ),

            // Section 7
            _buildSection(
              number: "7",
              title: "Data Retention",
              content:
                  "We keep your account data for as long as your account is active. "
                  "Listening history is retained for 2 years to improve recommendations. "
                  "When you delete your account, all personal data is permanently removed "
                  "within 30 days, except where required by law.",
              isDark: isDark,
            ),

            // Section 8
            _buildSection(
              number: "8",
              title: "Children's Privacy",
              content:
                  "Moz Music is not intended for children under 13. We do not knowingly "
                  "collect personal information from children. If you believe a child has "
                  "provided us with personal data, please contact us immediately.",
              isDark: isDark,
            ),

            // Section 9
            _buildSection(
              number: "9",
              title: "International Data Transfers",
              content:
                  "Your data may be processed in countries outside your residence. "
                  "We ensure appropriate safeguards are in place to protect your information "
                  "in compliance with GDPR, CCPA, and other privacy regulations.",
              isDark: isDark,
            ),

            // Section 10
            _buildSection(
              number: "10",
              title: "Changes to This Policy",
              content:
                  "We may update this Privacy Policy periodically. We'll notify you "
                  "of significant changes via email or in-app notification. Continued use "
                  "of the app after changes constitutes acceptance of the updated policy.",
              isDark: isDark,
            ),

            // Section 11
            _buildSection(
              number: "11",
              title: "Contact Us",
              content: "Questions about privacy? We're here to help.",
              isDark: isDark,
              children: [
                const SizedBox(height: 12),

                _buildContactCard(
                  icon: Icons.support_agent_outlined,
                  label: "Support",
                  value: "dev.sanju.codes@gmail.com",
                  isDark: isDark,
                ),
                const SizedBox(height: 8),
                _buildContactCard(
                  icon: Icons.language_outlined,
                  label: "Website",
                  value: "N/A",
                  isDark: isDark,
                ),
              ],
            ),

            // Footer
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    color: Colors.grey.shade400,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Committed to Your Privacy",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Moz Music © 2026",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "All rights reserved",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightCard({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String number,
    required String title,
    required String content,
    required bool isDark,
    List<Widget>? children,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepPurple.shade400,
                      Colors.purple.shade600,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    number,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          if (content.isNotEmpty) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 48),
              child: Text(
                content,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                ),
              ),
            ),
          ],
          if (children != null) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 48),
              child: Column(children: children),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubSection({
    required String title,
    required String content,
    required bool isDark,
    bool highlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: highlight ? const EdgeInsets.all(16) : null,
        decoration: highlight
            ? BoxDecoration(
                color: isDark
                    ? Colors.amber.shade900.withOpacity(0.2)
                    : Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.amber.shade700.withOpacity(0.3),
                  width: 1.5,
                ),
              )
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (highlight)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(
                      Icons.stars_rounded,
                      color: Colors.amber.shade700,
                      size: 20,
                    ),
                  ),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: highlight
                          ? Colors.amber.shade700
                          : (isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              content,
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade400,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple.shade400, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
