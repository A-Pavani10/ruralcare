import 'package:flutter/material.dart';
import 'app_data.dart';
import 'translations.dart';

class AdminStaffScreen extends StatefulWidget {
  @override
  _AdminStaffScreenState createState() => _AdminStaffScreenState();
}

class _AdminStaffScreenState extends State<AdminStaffScreen> {
  void _showAddStaffDialog({Map<String, String>? existing, int? index}) {
    String lang = AppData.selectedLanguage;
    final nameCtrl = TextEditingController(text: existing?['name'] ?? '');
    final roleCtrl = TextEditingController(text: existing?['role'] ?? '');
    final mobileCtrl = TextEditingController(text: existing?['mobile'] ?? '');
    final userCtrl = TextEditingController(text: existing?['username'] ?? '');
    final passCtrl = TextEditingController(text: existing?['password'] ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(existing == null
            ? (translations[lang]!['add_new_staff']!)
            : translations[lang]!['edit']! + ' Staff'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogField('Staff Name', nameCtrl),
              _dialogField('Role', roleCtrl),
              _dialogField('Mobile', mobileCtrl, keyboard: TextInputType.phone),
              _dialogField('Username', userCtrl),
              _dialogField('Password', passCtrl),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(translations[lang]!['cancel']!)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1A7A55),
                foregroundColor: Colors.white),
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty || roleCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Name and Role are required')),
                );
                return;
              }
              setState(() {
                final entry = {
                  'name': nameCtrl.text.trim(),
                  'role': roleCtrl.text.trim(),
                  'mobile': mobileCtrl.text.trim(),
                  'username': userCtrl.text.trim(),
                  'password': passCtrl.text.trim(),
                };
                if (index != null) {
                  AppData.staffList[index] = entry;
                } else {
                  AppData.staffList.add(entry);
                }
              });
              Navigator.pop(context);
            },
            child: Text(translations[lang]!['save']!),
          ),
        ],
      ),
    );
  }

  void _removeStaff(int index) {
    String lang = AppData.selectedLanguage;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Remove Staff?'),
        content: Text('Remove ${AppData.staffList[index]['name']} from the system?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(translations[lang]!['cancel']!)),
          TextButton(
            onPressed: () {
              setState(() => AppData.staffList.removeAt(index));
              Navigator.pop(context);
            },
            child: Text(translations[lang]!['remove']!,
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _dialogField(String label, TextEditingController ctrl,
      {TextInputType keyboard = TextInputType.text}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          SizedBox(height: 6),
          TextField(
            controller: ctrl,
            keyboardType: keyboard,
            decoration: InputDecoration(
              isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String lang = AppData.selectedLanguage;
    final staff = AppData.staffList;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Color(0xFF1A7A55),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text(translations[lang]!['staff_management']!),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              border:
                  Border(left: BorderSide(color: Colors.orange, width: 4)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('⚠️', style: TextStyle(fontSize: 16)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    translations[lang]!['staff_info'] ??
                        'No doctor accounts. Staff informs doctors verbally after claiming a request.',
                    style: TextStyle(fontSize: 13, color: Colors.green[900]),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1A7A55),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  textStyle:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () => _showAddStaffDialog(),
                child: Text(translations[lang]!['add_new_staff']!),
              ),
            ),
          ),
          Expanded(
            child: staff.isEmpty
                ? _emptyState(translations[lang]!['no_staff']!)
                : SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 4)
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(16, 14, 16, 8),
                            child: Text(
                              'Current Staff (${staff.length})',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                          Divider(height: 1),
                          ...staff.asMap().entries.map((entry) {
                            int idx = entry.key;
                            final Map<String, String> s = entry.value;
                            final initials =
                                AppData.initialsFrom(s['name'] ?? '');
                            final color =
                                Color(AppData.avatarColor(s['name'] ?? ''));
                            return Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 24,
                                        backgroundColor:
                                            color.withOpacity(0.2),
                                        child: Text(initials,
                                            style: TextStyle(
                                                color: color,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15)),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(s['name'] ?? '—',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 15)),
                                            Text(s['role'] ?? '—',
                                                style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 13)),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      ElevatedButton(
                                        onPressed: () => _showAddStaffDialog(
                                            existing: s, index: idx),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          textStyle: TextStyle(fontSize: 13),
                                        ),
                                        child:
                                            Text(translations[lang]!['edit']!),
                                      ),
                                      SizedBox(width: 6),
                                      ElevatedButton(
                                        onPressed: () => _removeStaff(idx),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          textStyle: TextStyle(fontSize: 13),
                                        ),
                                        child: Text(
                                            translations[lang]!['remove']!),
                                      ),
                                    ],
                                  ),
                                ),
                                if (idx < staff.length - 1)
                                  Divider(height: 1, indent: 72, endIndent: 16),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 56, color: Colors.grey[400]),
          SizedBox(height: 12),
          Text(msg, style: TextStyle(color: Colors.grey[500], fontSize: 15)),
        ],
      ),
    );
  }
}