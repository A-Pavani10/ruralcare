import 'package:flutter/material.dart';
import 'app_data.dart';
import 'translations.dart';
import 'staff_dashboard.dart';
import 'firestore_service.dart'; // ✅ NEW IMPORT
class StaffLoginScreen extends StatefulWidget {
  @override
  _StaffLoginScreenState createState() => _StaffLoginScreenState();
}

class _StaffLoginScreenState extends State<StaffLoginScreen> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _login() async {
  final username = _usernameCtrl.text.trim();
  final password = _passwordCtrl.text.trim();

  if (username.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please enter username and password')),
    );
    return;
  }

  // ✅ CLEAR OLD SESSION (VERY IMPORTANT)
  AppData.clearStaff();

  // 🔥 FIRESTORE LOGIN
  final user = await FirestoreService()
      .checkStaffLogin(username, password);

  if (user != null) {

    // ✅ SAVE DATA
    AppData.staffName = user['name'] ?? '';
    AppData.staffRole = user['role'] ?? '';
    AppData.staffMobile = user['mobile'] ?? '';

    // ✅ SUCCESS MESSAGE (for testing)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Login Successful')),
    );

    // ✅ NAVIGATION (SAFE)
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => StaffDashboard()),
      (route) => false,
    );

  } else {

    // ❌ BLOCK ACCESS
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Invalid username or password')),
    );

    // ❌ DO NOT NAVIGATE
    return;
  }
}

  @override
  Widget build(BuildContext context) {
    String lang = AppData.selectedLanguage;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1A7A55),
        foregroundColor: Colors.white,
        title: Text(translations[lang]!['staff_login']!),
        // Flutter auto-shows back arrow to role_screen
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Center(child: Text('👤', style: TextStyle(fontSize: 52))),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Your account is created by Admin. Use the credentials provided to you.',
                style: TextStyle(fontSize: 13, color: Colors.blue[800]),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 28),
            Text(translations[lang]!['username']!,
                style: TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            TextField(
              controller: _usernameCtrl,
              decoration: InputDecoration(
                hintText: 'Enter username',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            SizedBox(height: 20),
            Text(translations[lang]!['password']!,
                style: TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            TextField(
              controller: _passwordCtrl,
              obscureText: _obscure,
              decoration: InputDecoration(
                hintText: 'Enter password',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
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
                child: Text(translations[lang]!['login']!,
                    style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}