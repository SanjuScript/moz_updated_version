import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:moz_updated_version/data/model/user_model/repository/user_repo.dart';
import 'package:moz_updated_version/services/core/analytics_service.dart';
import 'package:moz_updated_version/services/core/app_services.dart';

class DummyProfileScreen extends StatelessWidget {
  const DummyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text('Profile'),
            SizedBox(width: 8),
            Chip(
              label: Text(
                'BETA',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              backgroundColor: Colors.deepOrange,
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 0),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            // Avatar with beta badge
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange.shade300,
                        Colors.deepOrange.shade400,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.transparent,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Icon(
                      Icons.science,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Name placeholder
            const Text(
              'User',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            // Email placeholder
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.email_outlined, size: 16, color: Colors.grey),
                  SizedBox(width: 6),
                  Text(
                    'user@example.com',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Info Card with gradient
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.orange.withOpacity(0.1),
                    Colors.deepOrange.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.info_outline,
                      color: Colors.orange.shade700,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Beta Testing Mode',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'This profile information is not exact.\n'
                    'The app is currently in beta, so some details may be '
                    'missing or incorrect.\n\n'
                    'We\'re working on syncing accurate data.\n'
                    'Your correct profile will appear soon.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Feedback Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        color: Colors.blue.shade600,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Help Us Improve',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Your feedback is valuable to us!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  // Feedback Buttons
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FeedbackScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.rate_review),
                    label: const Text('Submit Feedback'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      // Handle bug report
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BugReportScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.bug_report_outlined),
                    label: const Text('Report a Bug'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade600,
                      side: BorderSide(color: Colors.red.shade300),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'Thanks for testing the beta version',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                SizedBox(width: 4),
                Text('🙏', style: TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Version 1.0.0-beta',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

// ==================== FEEDBACK SCREEN ====================
class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _feedbackController = TextEditingController();
  String _selectedCategory = 'General';
  bool _isSubmitting = false;

  final List<String> _categories = [
    'General',
    'UI/UX',
    'Performance',
    'Features',
    'Audio Quality',
    'Other',
  ];

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final userName = sl<UserStorageAbRepo>().userName ?? "Anonymous";

      // Log feedback to Firebase Analytics
      await FirebaseAnalytics.instance.logEvent(
        name: 'feedback_submitted',
        parameters: {
          'user_name': userName,
          'category': _selectedCategory,
          'feedback': _feedbackController.text,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you for your feedback! 🙏'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting feedback: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Submit Feedback'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade600, Colors.blue.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(Icons.feedback, color: Colors.white, size: 40),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'We value your opinion!\nHelp us make the app better.',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Category Dropdown
              const Text(
                'Category',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,

                  fillColor: Colors.grey[100]!,
                  hintStyle: TextStyle(color: Colors.black),
                  labelStyle: TextStyle(color: Colors.black),
                  // sty: TextStyle(color: Colors.black),
                  // hintStyle: TextStyle(color: Colors.black),
                  prefixIcon: const Icon(Icons.category),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(
                      category,
                      style: TextStyle(color: Colors.black),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedCategory = value!);
                },
              ),
              const SizedBox(height: 24),

              // Feedback Text Field
              const Text(
                'Your Feedback',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _feedbackController,
                maxLines: 6,

                style: TextStyle(color: Colors.black),
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: 'Tell us what you think...',
                  hintStyle: TextStyle(color: Colors.black),
                  labelStyle: TextStyle(color: Colors.black),
                  errorStyle: TextStyle(color: Colors.black),
                  helperStyle: TextStyle(color: Colors.black),
                  // labelStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100]!,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your feedback';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 30),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitFeedback,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.grey[100]!,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isSubmitting
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.grey[100]!,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Submit Feedback',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== BUG REPORT SCREEN ====================
class BugReportScreen extends StatefulWidget {
  const BugReportScreen({super.key});

  @override
  State<BugReportScreen> createState() => _BugReportScreenState();
}

class _BugReportScreenState extends State<BugReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _stepsController = TextEditingController();
  String _selectedSeverity = 'Medium';
  bool _isSubmitting = false;

  final List<String> _severityLevels = ['Low', 'Medium', 'High', 'Critical'];

  final Map<String, Color> _severityColors = {
    'Low': Colors.green,
    'Medium': Colors.orange,
    'High': Colors.red,
    'Critical': Colors.purple,
  };

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _stepsController.dispose();
    super.dispose();
  }

  Future<void> _submitBugReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final userName = sl<UserStorageAbRepo>().userName ?? "Anonymous";

      // Log bug report to Firebase Analytics
      await FirebaseAnalytics.instance.logEvent(
        name: 'bug_reported',
        parameters: {
          'user_name': userName,
          'title': _titleController.text,
          'severity': _selectedSeverity,
          'description': _descriptionController.text,
          'steps': _stepsController.text,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bug report submitted successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting bug report: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Report a Bug'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.red.shade600,
        foregroundColor: Colors.grey[100]!,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red.shade600, Colors.red.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(Icons.bug_report, color: Colors.grey[100]!, size: 40),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Help us squash bugs!\nDescribe the issue you encountered.',
                        style: TextStyle(
                          color: Colors.grey[100]!,
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Bug Title
              const Text(
                'Bug Title *',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                style: TextStyle(color: Colors.black),
                controller: _titleController,
                decoration: InputDecoration(
                  hintStyle: TextStyle(color: Colors.black),
                  hintText: 'Brief description of the bug',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100]!,
                  prefixIcon: const Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a bug title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Severity Level
              const Text(
                'Severity Level',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedSeverity,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100]!,
                  prefixIcon: Icon(
                    Icons.warning,
                    color: _severityColors[_selectedSeverity],
                  ),
                ),
                items: _severityLevels.map((severity) {
                  return DropdownMenuItem(
                    value: severity,
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _severityColors[severity],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(severity, style: TextStyle(color: Colors.black)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedSeverity = value!);
                },
              ),
              const SizedBox(height: 24),

              // Bug Description
              const Text(
                'Description *',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                style: TextStyle(color: Colors.black),
                controller: _descriptionController,
                maxLines: 5,
                maxLength: 500,
                decoration: InputDecoration(
                  hintStyle: TextStyle(color: Colors.black),
                  hintText: 'What happened? What did you expect to happen?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100]!,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please describe the bug';
                  }
                  if (value.trim().length < 10) {
                    return 'Please provide at least 20 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Steps to Reproduce
              const Text(
                'Steps to Reproduce (Optional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                style: TextStyle(color: Colors.black),
                controller: _stepsController,
                maxLines: 4,
                maxLength: 300,
                decoration: InputDecoration(
                  hintStyle: TextStyle(color: Colors.black),
                  hintText: '1. Open the app\n2. Tap on...\n3. See error',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100]!,
                ),
              ),
              const SizedBox(height: 30),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitBugReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.grey[100]!,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  icon: _isSubmitting
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.grey[100]!,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.send),
                  label: Text(
                    _isSubmitting ? 'Submitting...' : 'Submit Bug Report',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
