import 'package:flutter/material.dart';
import 'app_data.dart';
import 'translations.dart';
import 'patient_services.dart';
import 'patient_requests.dart';
import 'patient_profile.dart';
import 'patient_entry.dart';
import 'role_screen.dart'; // ✅ ADDED

class PatientDashboard extends StatefulWidget {
  @override
  _PatientDashboardState createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _PatientHomeTab(onTabSwitch: (i) => setState(() => _currentIndex = i)),
      PatientServicesScreen(),
      PatientRequestsScreen(),
      PatientProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    String lang = AppData.selectedLanguage;
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
              icon: Icon(Icons.home), label: translations[lang]!['home']!),
          BottomNavigationBarItem(
              icon: Icon(Icons.local_hospital),
              label: translations[lang]!['services']!),
          BottomNavigationBarItem(
              icon: Icon(Icons.list_alt),
              label: translations[lang]!['my_requests']!),
          BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: translations[lang]!['profile']!),
        ],
      ),
    );
  }
}

class _PatientHomeTab extends StatelessWidget {
  final Function(int) onTabSwitch;
  const _PatientHomeTab({required this.onTabSwitch});

  Color _statusColor(String status) {
    switch (status) {
      case 'Accepted':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'Completed':
        return Colors.blue;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    String lang = AppData.selectedLanguage;
    final requests = AppData.patientRequests;
    int total = requests.length;
    int accepted =
        requests.where((r) => r['status'] == 'Accepted').length;
    int pending =
        requests.where((r) => r['status'] == 'Pending').length;
    final recent = requests.reversed.take(3).toList();

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
                    child: Text('Cancel'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1A7A55),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      AppData.clearPatient();

                      Navigator.pop(context); // close dialog

                      // ✅ UPDATED NAVIGATION
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
            Text(
              '👋 ${translations[lang]!['hello']!}, ${AppData.patientFirstName.isEmpty ? translations[lang]!['patient']! : AppData.patientFirstName}',
              style: TextStyle(fontSize: 17),
            ),
            Text(translations[lang]!['patient']!,
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
                _statCard('$total',
                    translations[lang]!['total_requests']!, Colors.indigo),
                SizedBox(width: 10),
                _statCard('$accepted',
                    translations[lang]!['accepted']!, Colors.green),
                SizedBox(width: 10),
                _statCard('$pending',
                    translations[lang]!['pending']!, Colors.orange),
              ],
            ),
            SizedBox(height: 20),
            Text(translations[lang]!['quick_actions']!,
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _quickActionCard(
                      '🏥',
                      translations[lang]!['services']!,
                      () => onTabSwitch(1)),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _quickActionCard(
                      '📋',
                      translations[lang]!['my_requests']!,
                      () => onTabSwitch(2)),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(translations[lang]!['recent_activity']!,
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 12),
            if (recent.isEmpty)
              _emptyState(translations[lang]!['no_requests']!)
            else
              ...recent.map((item) => _activityCard(item)),
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
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 4)
          ],
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color)),
            SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 11, color: Colors.grey[600]),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _quickActionCard(
      String emoji, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 4)
          ],
        ),
        child: Column(
          children: [
            Text(emoji, style: TextStyle(fontSize: 28)),
            SizedBox(height: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _activityCard(Map<String, String> item) {
    Color statusColor = _statusColor(item['status']!);
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4)
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(item['service']!,
                    style: TextStyle(
                        fontWeight: FontWeight.w600)),
                SizedBox(height: 4),
                Text(item['time'] ?? '',
                    style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius:
                  BorderRadius.circular(20),
            ),
            child: Text(
              item['status']!,
              style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(String message) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 32),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.inbox_outlined,
              size: 48, color: Colors.grey[400]),
          SizedBox(height: 8),
          Text(message,
              style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14)),
        ],
      ),
    );
  }
}