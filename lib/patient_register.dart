import 'package:flutter/material.dart';
import 'app_data.dart';
import 'translations.dart';
import 'patient_dashboard.dart';

class PatientRegisterScreen extends StatefulWidget {
  @override
  _PatientRegisterScreenState createState() => _PatientRegisterScreenState();
}

class _PatientRegisterScreenState extends State<PatientRegisterScreen> {
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _aadhaarCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _mobileCtrl.dispose();
    _aadhaarCtrl.dispose();
    _locationCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  void _register() {
    if (_firstNameCtrl.text.trim().isEmpty ||
        _mobileCtrl.text.trim().isEmpty ||
        _aadhaarCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Please fill First Name, Mobile and Aadhaar fields')),
      );
      return;
    }
    AppData.patientFirstName = _firstNameCtrl.text.trim();
    AppData.patientLastName = _lastNameCtrl.text.trim();
    AppData.patientMobile = _mobileCtrl.text.trim();
    AppData.patientAadhaar = _aadhaarCtrl.text.trim();
    AppData.patientLocation = _locationCtrl.text.trim();

    AppData.patients.add({
      'name': AppData.patientFullName,
      'mobile': AppData.patientMobile,
      'location': AppData.patientLocation,
      'requests': '0',
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => PatientDashboard()),
    );
  }

  Widget _field(String label, TextEditingController ctrl,
      {TextInputType keyboard = TextInputType.text, String hint = ''}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
        SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: keyboard,
          decoration: InputDecoration(
            hintText: hint,
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    String lang = AppData.selectedLanguage;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1A7A55),
        foregroundColor: Colors.white,
        title: Text(translations[lang]!['register']!),
        // Flutter auto-shows back arrow to patient_entry
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text('📋', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Register once with your Aadhaar. Name, mobile & Aadhaar are linked to create your account.',
                      style: TextStyle(fontSize: 13, color: Colors.green[800]),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            _field(translations[lang]!['first_name']!, _firstNameCtrl),
            _field(translations[lang]!['last_name']!, _lastNameCtrl),
            _field(translations[lang]!['mobile_number']!, _mobileCtrl,
                keyboard: TextInputType.phone, hint: '+91 XXXXX XXXXX'),
            _field(translations[lang]!['aadhaar_number']!, _aadhaarCtrl,
                keyboard: TextInputType.number, hint: 'XXXX XXXX XXXX'),
            _field(translations[lang]!['location_village']!, _locationCtrl),
            Divider(height: 8),
            SizedBox(height: 16),
            Text(translations[lang]!['aadhaar_otp']!,
                style: TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(height: 4),
            Text('OTP sent to Aadhaar-linked mobile. One-time only.',
                style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            SizedBox(height: 8),
            TextField(
              controller: _otpCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'XXXXXX',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            SizedBox(height: 28),
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
                onPressed: _register,
                child: Text(translations[lang]!['verify_register']!,
                    style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}