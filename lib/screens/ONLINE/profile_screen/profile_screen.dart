import 'package:flutter/material.dart';

class DummyProfileScreen extends StatelessWidget {
  const DummyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile (Beta)'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // Avatar
            const CircleAvatar(radius: 45, child: Icon(Icons.person, size: 45)),

            const SizedBox(height: 16),

            // Name placeholder
            const Text(
              'User',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 4),

            // Email placeholder
            const Text(
              'user@example.com',
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 30),

            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: const [
                  Icon(Icons.info_outline, color: Colors.orange),
                  SizedBox(height: 10),
                  Text(
                    'This profile information is not exact.\n'
                    'The app is currently in beta, so some details may be '
                    'missing or incorrect.\n\n'
                    'We’re working on syncing accurate data.\n'
                    'Your correct profile will appear soon.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Footer
            const Text(
              'Thanks for testing the beta version 🙏',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
