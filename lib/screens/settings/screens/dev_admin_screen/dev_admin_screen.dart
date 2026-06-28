import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class DevAdminScreen extends StatefulWidget {
  const DevAdminScreen({super.key});

  @override
  State<DevAdminScreen> createState() => _DevAdminScreenState();
}

class _DevAdminScreenState extends State<DevAdminScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final Color bg = isDark
        ? Color.lerp(primaryColor, const Color(0xFF0B0B11), 0.95) ?? const Color(0xFF0B0B11)
        : Color.lerp(primaryColor, const Color(0xFFF2F1F7), 0.95) ?? const Color(0xFFF2F1F7);
    final Color surface = isDark ? const Color(0xFF161520) : const Color(0xFFFFFFFF);
    final Color cardBorder = isDark ? const Color(0xFF252235) : const Color(0xFFE5E2F0);
    final Color textPrimary = isDark ? const Color(0xFFF0EEF8) : const Color(0xFF1A1625);
    final Color textMuted = isDark ? const Color(0xFF6E6887) : const Color(0xFF9B97AC);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(
          "Developer Console",
          style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Search & Filters bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Container(
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cardBorder),
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: "Search user by name or email...",
                  hintStyle: TextStyle(color: textMuted),
                  prefixIcon: Icon(Icons.search_rounded, color: textMuted),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear_rounded, color: textMuted),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase().trim();
                  });
                },
              ),
            ),
          ),

          // Users list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        "Error loading users:\n${snapshot.error}",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: textMuted),
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allDocs = snapshot.data?.docs ?? [];
                
                // Filter docs client side based on query
                final docs = allDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>? ?? {};
                  final name = (data['name'] ?? '').toString().toLowerCase();
                  final email = (data['email'] ?? '').toString().toLowerCase();
                  return name.contains(_searchQuery) || email.contains(_searchQuery);
                }).toList();

                if (docs.isEmpty) {
                  return Center(
                    child: Text(
                      _searchQuery.isEmpty ? "No registered users found" : "No matching users found",
                      style: TextStyle(color: textMuted, fontSize: 14),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>? ?? {};
                    final userId = docs[index].id;
                    final name = data['name'] ?? 'Unknown User';
                    final email = data['email'] ?? 'No Email';
                    final photoUrl = data['photoUrl'] ?? '';
                    final rawCreated = data['createdAt'];
                    DateTime? createdTimestamp;
                    if (rawCreated is Timestamp) {
                      createdTimestamp = rawCreated.toDate();
                    } else if (rawCreated is String) {
                      createdTimestamp = DateTime.tryParse(rawCreated);
                    }
                    final dateStr = createdTimestamp != null
                        ? DateFormat('MMM dd, yyyy hh:mm a').format(createdTimestamp)
                        : 'Unknown signup date';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: cardBorder),
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            leading: CircleAvatar(
                              radius: 20,
                              backgroundColor: primaryColor.withAlpha(30),
                              backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                              child: photoUrl.isEmpty
                                  ? Text(
                                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                                      style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                                    )
                                  : null,
                            ),
                            title: Text(
                              name,
                              style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            subtitle: Text(
                              email,
                              style: TextStyle(color: textMuted, fontSize: 12),
                            ),
                            childrenPadding: const EdgeInsets.all(16),
                            children: [
                              Divider(color: cardBorder, height: 1),
                              const SizedBox(height: 12),
                              
                              // User Fields Details Grid
                              _buildDetailRow("Firestore UID", userId, canCopy: true, textMuted: textMuted, textPrimary: textPrimary),
                              const SizedBox(height: 8),
                              _buildDetailRow("Signup Date", dateStr, textMuted: textMuted, textPrimary: textPrimary),
                              
                              const SizedBox(height: 16),
                              
                              // Device info subheader
                              Row(
                                children: [
                                  Icon(Icons.phone_android_rounded, size: 14, color: primaryColor),
                                  const SizedBox(width: 6),
                                  Text(
                                    "DEVICE TELEMETRY",
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Fetch device sub-document
                              FutureBuilder<DocumentSnapshot>(
                                future: FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(userId)
                                    .collection('device_info')
                                    .doc('main')
                                    .get(),
                                builder: (context, deviceSnap) {
                                  if (deviceSnap.connectionState == ConnectionState.waiting) {
                                    return const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 8.0),
                                      child: Center(
                                        child: SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        ),
                                      ),
                                    );
                                  }

                                  final devData = deviceSnap.data?.data() as Map<String, dynamic>?;
                                  if (devData == null || !deviceSnap.data!.exists) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                                      child: Text(
                                        "No device telemetry registered for this user.",
                                        style: TextStyle(color: textMuted, fontSize: 11, fontStyle: FontStyle.italic),
                                      ),
                                    );
                                  }

                                  final platform = (devData['platform'] ?? 'unknown').toString().toUpperCase();
                                  final brand = devData['brand'] ?? devData['manufacturer'] ?? '';
                                  final model = devData['model'] ?? '';
                                  final osVersion = devData['androidVersion'] ?? devData['systemVersion'] ?? 'Unknown';
                                  final appVersion = devData['appVersion'] ?? 'Unknown';
                                  final buildNum = devData['buildNumber'] ?? '';
                                  final timezone = devData['timezone'] ?? 'Unknown';
                                  
                                  return Column(
                                    children: [
                                      _buildDetailRow("Device Model", "$brand $model ($platform)".trim(), textMuted: textMuted, textPrimary: textPrimary),
                                      const SizedBox(height: 6),
                                      _buildDetailRow("Operating System", "$platform $osVersion", textMuted: textMuted, textPrimary: textPrimary),
                                      const SizedBox(height: 6),
                                      _buildDetailRow("App Version", "$appVersion ($buildNum)", textMuted: textMuted, textPrimary: textPrimary),
                                      const SizedBox(height: 6),
                                      _buildDetailRow("Timezone", timezone, textMuted: textMuted, textPrimary: textPrimary),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool canCopy = false,
    required Color textMuted,
    required Color textPrimary,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(color: textMuted, fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onLongPress: canCopy
                ? () {
                    Clipboard.setData(ClipboardData(text: value));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("UID copied to clipboard"),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                : null,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      fontFamily: canCopy ? 'Courier' : null,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                if (canCopy) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.copy_rounded, size: 10, color: textMuted),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
