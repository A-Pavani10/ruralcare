import 'package:flutter/material.dart';
import 'app_data.dart';
import 'translations.dart';
import 'main.dart';

class PatientProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String lang = AppData.selectedLanguage;
    String initials = AppData.patientInitials.isEmpty ? 'P' : AppData.patientInitials;
    String name = AppData.patientFullName.isEmpty
        ? translations[lang]!['patient']!
        : AppData.patientFullName;

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
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            Text('Primary User',
                style: TextStyle(color: Colors.grey[600])),
            SizedBox(height: 24),
            _infoCard([
              {
                'label': 'Mobile',
                'value': AppData.patientMobile.isEmpty
                    ? '—'
                    : AppData.patientMobile,
                'icon': Icons.phone
              },
              {
                'label': 'Aadhaar',
                'value': AppData.patientAadhaar.isEmpty
                    ? '—'
                    : _maskAadhaar(AppData.patientAadhaar),
                'icon': Icons.credit_card
              },
              {
                'label': 'Location',
                'value': AppData.patientLocation.isEmpty
                    ? '—'
                    : AppData.patientLocation,
                'icon': Icons.location_on
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
                  AppData.clearPatient();
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

  String _maskAadhaar(String aadhaar) {
    final digits = aadhaar.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 4) {
      return 'XXXX XXXX ${digits.substring(digits.length - 4)}';
    }
    return 'XXXX XXXX XXXX';
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
                leading:
                    Icon(item['icon'] as IconData, color: Color(0xFF1A7A55)),
                title: Text(item['label'] as String,
                    style:
                        TextStyle(color: Colors.grey[600], fontSize: 12)),
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