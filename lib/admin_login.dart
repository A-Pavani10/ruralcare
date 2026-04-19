import 'package:flutter/material.dart';
import 'app_data.dart';
import 'translations.dart';
import 'admin_dashboard.dart';
import 'firestore_service.dart';

class AdminLoginScreen extends StatefulWidget {
  @override
  _AdminLoginScreenState createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // ✅ FIXED LOGIN
  void _login() async {
    String username = _usernameCtrl.text.trim();
    String password = _passwordCtrl.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter username and password')),
      );
      return;
    }

    bool isValid = await FirestoreService()
        .checkAdminLogin(username, password);

    if (isValid) {
      AppData.adminName = username;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AdminDashboard()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid admin credentials")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String lang = AppData.selectedLanguage;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Color(0xFF1A7A55),
        foregroundColor: Colors.white,
        title: Text(translations[lang]!['admin_login']!),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 12),

            // INFO BOX
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                border: Border(
                    left: BorderSide(color: Color(0xFF1A7A55), width: 4)),
              ),
              child: Row(
                children: [
                  Text('🛡️'),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      translations[lang]!['admin_info'] ??
                          'Admin access only',
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 28),

            // FORM
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // USERNAME
                  Text("USERNAME"),
                  SizedBox(height: 8),
                  TextField(controller: _usernameCtrl),

                  SizedBox(height: 20),

                  // PASSWORD
                  Text("PASSWORD"),
                  SizedBox(height: 8),
                  TextField(
                    controller: _passwordCtrl,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: Icon(_obscure
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () =>
                            setState(() => _obscure = !_obscure),
                      ),
                    ),
                  ),

                  SizedBox(height: 24),

                  // BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _login,
                      child: Text("Login as Admin"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}