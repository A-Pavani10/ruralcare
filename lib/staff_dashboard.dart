import 'package:flutter/material.dart';
import 'app_data.dart';
import 'translations.dart';
import 'staff_incoming.dart';
import 'staff_my_tasks.dart';
import 'staff_profile.dart';
import 'role_screen.dart';

class StaffDashboard extends StatefulWidget {
  @override
  _StaffDashboardState createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    String lang = AppData.selectedLanguage;
    final pages = [
      _StaffHomeTab(onTabSwitch: (i) => setState(() => _currentIndex = i)),
      StaffIncomingScreen(),
      StaffMyTasksScreen(),
      StaffProfileScreen(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Color(0xFF1A7A55),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => _currentIndex = i),
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: translations[lang]!['home']!),
          BottomNavigationBarItem(
              icon: Icon(Icons.inbox),
              label: translations[lang]!['incoming']!),
          BottomNavigationBarItem(
              icon: Icon(Icons.check_circle_outline),
              label: translations[lang]!['my_tasks']!),
          BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: translations[lang]!['profile']!),
        ],
      ),
    );
  }
}

class _StaffHomeTab extends StatelessWidget {
  final Function(int) onTabSwitch;
  const _StaffHomeTab({required this.onTabSwitch});

  @override
  Widget build(BuildContext context) {
    String lang = AppData.selectedLanguage;
    int allReqs = AppData.incomingRequests.length;
    int myTasksCount = AppData.myTasks.length;
    int pending = AppData.myTasks.where((t) => t['status'] == 'Pending').length;
    String name = AppData.staffName.isEmpty
        ? translations[lang]!['staff']!
        : AppData.staffName;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Color(0xFF1A7A55),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: Text('Logout'),
                content: Text('Are you sure you want to logout?'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel')),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF1A7A55),
                        foregroundColor: Colors.white),
                    onPressed: () {
                      AppData.clearStaff();
                      Navigator.pop(context);
                     Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (_) => RoleScreen()),
  (route) => route.isFirst,
);
                    },
                    child: Text('Logout'),
                  ),
                ],
              ),
            );
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('👋 ${translations[lang]!['hello']!}, $name',
                style: TextStyle(fontSize: 17)),
            Text(translations[lang]!['staff']!,
                style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _statCard('$allReqs', translations[lang]!['all_requests']!,
                    Colors.indigo),
                SizedBox(width: 10),
                _statCard('$myTasksCount',
                    translations[lang]!['my_tasks_count']!, Colors.teal),
                SizedBox(width: 10),
                _statCard('$pending', translations[lang]!['pending']!,
                    Colors.orange),
              ],
            ),
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber[300]!),
              ),
              child: Row(
                children: [
                  Text('📢', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Inform doctors verbally after claiming. No doctor login in the app.',
                      style: TextStyle(color: Colors.amber[900], fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _quickCard('📥', translations[lang]!['incoming']!,
                      () => onTabSwitch(1)),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _quickCard('✅', translations[lang]!['my_tasks']!,
                      () => onTabSwitch(2)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            SizedBox(height: 4),
            Text(label,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _quickCard(String emoji, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Column(
          children: [
            Text(emoji, style: TextStyle(fontSize: 28)),
            SizedBox(height: 6),
            Text(label,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}