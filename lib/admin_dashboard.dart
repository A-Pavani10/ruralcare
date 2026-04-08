import 'package:flutter/material.dart';
import 'app_data.dart';
import 'translations.dart';
import 'admin_patients.dart';
import 'admin_staff.dart';
import 'admin_services.dart';
import 'admin_monitor.dart';
import 'role_screen.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;
 
  @override
  Widget build(BuildContext context) {
    String lang = AppData.selectedLanguage;

    final List<Widget> _pages = [
      _AdminHomeTab(onTabSwitch: (i) => setState(() => _currentIndex = i)),
      AdminPatientsScreen(),
      AdminStaffScreen(),
      AdminServicesScreen(),
    ];

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Color(0xFF1A7A55),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => _currentIndex = i),
        items: [
          BottomNavigationBarItem(
              icon: Text('🏠', style: TextStyle(fontSize: 22)),
              label: translations[lang]!['home']!),
          BottomNavigationBarItem(
              icon: Text('👥', style: TextStyle(fontSize: 22)),
              label: translations[lang]!['patients']!),
          BottomNavigationBarItem(
              icon: Text('👨‍⚕️', style: TextStyle(fontSize: 22)),
              label: translations[lang]!['staff_label']!),
          BottomNavigationBarItem(
              icon: Text('🏥', style: TextStyle(fontSize: 22)),
              label: translations[lang]!['services']!),
        ],
      ),
    );
  }
}

class _AdminHomeTab extends StatelessWidget {
  final Function(int) onTabSwitch;
  const _AdminHomeTab({required this.onTabSwitch});

  @override
  Widget build(BuildContext context) {
    String lang = AppData.selectedLanguage;
    int patientCount = AppData.patients.length;
    int todayReqs = AppData.allRequests.length;
    int staffActive = AppData.staffList.length;

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
                content: Text('Are you sure you want to logout as Admin?'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel')),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF1A7A55),
                        foregroundColor: Colors.white),
                    onPressed: () {
                      AppData.adminName = 'Admin';
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
        title: Row(
          children: [
            Text('🛡️', style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Text(translations[lang]!['admin_login']!
                .replaceAll(' Login', ' Dashboard')),
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                AppData.adminName,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _statCard('$patientCount', translations[lang]!['patients']!,
                    Colors.indigo),
                SizedBox(width: 10),
                _statCard('$todayReqs',
                    translations[lang]!['today_requests']!, Colors.teal),
                SizedBox(width: 10),
                _statCard('$staffActive',
                    translations[lang]!['staff_active']!, Colors.orange),
              ],
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                border:
                    Border(left: BorderSide(color: Colors.orange, width: 4)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('⚠️', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      translations[lang]!['admin_note'] ??
                          'Admin monitors only. Doctors not in app — staff informs verbally.',
                      style: TextStyle(fontSize: 13, color: Colors.green[900]),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            _menuCard(
              emoji: '👥',
              title: translations[lang]!['patient_details']!,
              action: translations[lang]!['view_all']!,
              actionColor: Colors.indigo,
              onTap: () => onTabSwitch(1),
            ),
            _menuCard(
              emoji: '👨‍⚕️',
              title: translations[lang]!['staff_management']!,
              action: translations[lang]!['crud']!,
              actionColor: Colors.teal,
              onTap: () => onTabSwitch(2),
            ),
            _menuCard(
              emoji: '🏥',
              title: translations[lang]!['service_management']!,
              action: translations[lang]!['add_remove']!,
              actionColor: Colors.orange,
              onTap: () => onTabSwitch(3),
            ),
            _menuCard(
              emoji: '📊',
              title: translations[lang]!['monitor_requests']!,
              action: translations[lang]!['view_arrow']!,
              actionColor: Colors.green,
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => AdminMonitorScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: color)),
            SizedBox(height: 4),
            Text(label,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _menuCard({
    required String emoji,
    required String title,
    required String action,
    required Color actionColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Row(
          children: [
            Text(emoji, style: TextStyle(fontSize: 22)),
            SizedBox(width: 14),
            Expanded(
              child: Text(title,
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            Text(action,
                style: TextStyle(
                    color: actionColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
          ],
        ),
      ),
    );
  }
}