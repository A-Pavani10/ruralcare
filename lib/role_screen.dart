import 'package:flutter/material.dart';
import 'app_data.dart';
import 'translations.dart';
import 'patient_entry.dart';
import 'staff_login.dart';
import 'admin_login.dart';

class RoleScreen extends StatelessWidget {
  const RoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String lang = AppData.selectedLanguage;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A7A55),
        foregroundColor: Colors.white,
        title: Text(translations[lang]!['who_are_you']!),

        // ✅ SMART BACK ARROW CONTROL
        automaticallyImplyLeading: Navigator.canPop(context),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 8),

            _roleCard(
              emoji: '🧑',
              title: translations[lang]!['patient']!,
              subtitle: translations[lang]!['patient_desc']!,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PatientEntryScreen()),
              ),
            ),

            _roleCard(
              emoji: '👨‍⚕️',
              title: translations[lang]!['staff']!,
              subtitle: translations[lang]!['staff_desc']!,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => StaffLoginScreen()),
              ),
            ),

            _roleCard(
              emoji: '🛡️',
              title: translations[lang]!['admin']!,
              subtitle: translations[lang]!['admin_desc']!,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AdminLoginScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roleCard({
    required String emoji,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 3))
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFF1A7A55).withOpacity(0.1),
              child: Text(emoji, style: const TextStyle(fontSize: 26)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}