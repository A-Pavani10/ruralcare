import 'package:flutter/material.dart';
import 'app_data.dart';
import 'translations.dart';
import 'main.dart';

class StaffProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String lang = AppData.selectedLanguage;
    String initials = AppData.staffInitials.isEmpty ? 'S' : AppData.staffInitials;
    String name = AppData.staffName.isEmpty ? translations[lang]!['staff']! : AppData.staffName;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Color(0xFF1A7A55),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text(translations[lang]!['profile']!),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(height: 16),
            CircleAvatar(
              radius: 40,
              backgroundColor: Color(0xFF1A7A55),
              child: Text(initials,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 12),
            Text(name,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(
              AppData.staffRole.isEmpty ? translations[lang]!['staff']! : AppData.staffRole,
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '🔒 Profile is read-only. Contact Admin to make changes.',
                style: TextStyle(color: Colors.grey[700], fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 24),
            _infoCard([
              {
                'label': 'Mobile',
                'value': AppData.staffMobile.isEmpty ? '—' : AppData.staffMobile,
                'icon': Icons.phone
              },
              {
                'label': 'Role',
                'value': AppData.staffRole.isEmpty ? '—' : AppData.staffRole,
                'icon': Icons.work
              },
              {
                'label': 'Created by',
                'value': AppData.staffCreatedBy,
                'icon': Icons.admin_panel_settings
              },
            ]),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[50],
                  foregroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                  side: BorderSide(color: Colors.red[200]!),
                ),
                icon: Icon(Icons.logout),
                label: Text(translations[lang]!['logout']!,
                    style: TextStyle(fontSize: 16)),
                onPressed: () {
                  AppData.clearStaff();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => SplashScreen()),
                    (route) => false,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(List<Map<String, dynamic>> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          int idx = entry.key;
          final item = entry.value;
          return Column(
            children: [
              ListTile(
                leading: Icon(item['icon'] as IconData,
                    color: Color(0xFF1A7A55)),
                title: Text(item['label'] as String,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                subtitle: Text(item['value'] as String,
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15)),
              ),
              if (idx < items.length - 1)
                Divider(height: 1, indent: 16, endIndent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }
}