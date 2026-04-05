import 'package:flutter/material.dart';
import 'app_data.dart';
import 'translations.dart';
import 'patient_dashboard.dart';
import 'patient_register.dart';

class PatientLoginScreen extends StatefulWidget {
  @override
  _PatientLoginScreenState createState() => _PatientLoginScreenState();
}

class _PatientLoginScreenState extends State<PatientLoginScreen> {
  final _mobileCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();

  @override
  void dispose() {
    _mobileCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  void _login() {
    if (_mobileCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your mobile number')),
      );
      return;
    }
    AppData.patientMobile = _mobileCtrl.text.trim();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => PatientDashboard()),
    );
  }

  @override
  Widget build(BuildContext context) {
    String lang = AppData.selectedLanguage;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1A7A55),
        foregroundColor: Colors.white,
        title: Text(translations[lang]!['login']!),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text('📱', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Enter your registered mobile number. OTP will only be sent if you are on a new device.',
                      style: TextStyle(fontSize: 13, color: Colors.blue[800]),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 28),
            Text(translations[lang]!['mobile_number']!,
                style: TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            TextField(
              controller: _mobileCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: '+91 XXXXX XXXXX',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            SizedBox(height: 20),
            Text(translations[lang]!['otp']!,
                style: TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            TextField(
              controller: _otpCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'XXXXXX',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Same device? No OTP needed after first login.',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
            SizedBox(height: 32),
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
                onPressed: _login,
                child: Text(translations[lang]!['verify_login']!,
                    style: TextStyle(fontSize: 16)),
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => PatientRegisterScreen()),
                ),
                child: Text(
                  translations[lang]!['new_user_register']!,
                  style: TextStyle(color: Color(0xFF1A7A55)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}