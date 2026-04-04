import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Color(0xFF1A7A55),
      ),
      body: const Center(
        child: Text('Welcome to Admin Dashboard'),
      ),
    );
  }
}