import 'package:flutter/material.dart';
import 'app_data.dart';
import 'translations.dart';
import 'patient_login.dart';
import 'patient_register.dart';

class PatientEntryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String lang = AppData.selectedLanguage;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1A7A55),
        foregroundColor: Colors.white,
        title: Text(translations[lang]!['patient']!),
        // Flutter auto-shows back arrow to role_screen
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🏥', style: TextStyle(fontSize: 56)),
            SizedBox(height: 20),
            Text(
              translations[lang]!['welcome']!,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              translations[lang]!['already_registered']!,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.grey[600], fontSize: 14, height: 1.5),
            ),
            SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1A7A55),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PatientLoginScreen()),
                ),
                child: Text(translations[lang]!['login']!,
                    style: TextStyle(fontSize: 16)),
              ),
            ),
            SizedBox(height: 14),
            Text(translations[lang]!['or']!,
                style: TextStyle(color: Colors.grey)),
            SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Color(0xFF1A7A55)),
                  foregroundColor: Color(0xFF1A7A55),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PatientRegisterScreen()),
                ),
                child: Text(translations[lang]!['register']!,
                    style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}