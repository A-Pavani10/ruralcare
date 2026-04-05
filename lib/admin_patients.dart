import 'package:flutter/material.dart';
import 'app_data.dart';
import 'translations.dart';

class AdminPatientsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String lang = AppData.selectedLanguage;
    final patients = AppData.patients;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Color(0xFF1A7A55),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text(translations[lang]!['patient_details']!),
      ),
      body: Column(
        children: [
          // Info banner
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              border: Border(
                  left: BorderSide(color: Color(0xFF1A7A55), width: 4)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('📋', style: TextStyle(fontSize: 16)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    translations[lang]!['patients_info'] ??
                        'View all patient details and request history. Read-only access.',
                    style:
                        TextStyle(fontSize: 13, color: Colors.green[900]),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: patients.isEmpty
                ? _emptyState(translations[lang]!['no_patients']!)
                : SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 4)
                        ],
                      ),
                      child: Column(
                        children: patients.asMap().entries.map((entry) {
                          int idx = entry.key;
                          final p = entry.value;
                          return Column(
                            children: [
                              _patientTile(context, p, lang),
                              if (idx < patients.length - 1)
                                Divider(height: 1, indent: 72, endIndent: 16),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _patientTile(
      BuildContext context, Map<String, String> p, String lang) {
    final initials = AppData.initialsFrom(p['name'] ?? '');
    final color = Color(AppData.avatarColor(p['name'] ?? ''));
    final reqCount = p['requests'] ?? '0';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 26,
            backgroundColor: color.withOpacity(0.2),
            child: Text(
              initials,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ),
          SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p['name'] ?? '—',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
                SizedBox(height: 3),
                Text(
                  '${p['mobile'] ?? '—'} · ${p['location'] ?? '—'} · $reqCount ${int.tryParse(reqCount) == 1 ? 'request' : 'requests'}',
                  style:
                      TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          // View button
          ElevatedButton(
            onPressed: () => _showPatientDetail(context, p, lang),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              textStyle:
                  TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            child: Text(translations[lang]!['view']!),
          ),
        ],
      ),
    );
  }

  void _showPatientDetail(
      BuildContext context, Map<String, String> p, String lang) {
    final initials = AppData.initialsFrom(p['name'] ?? '');
    final color = Color(AppData.avatarColor(p['name'] ?? ''));
    // Filter requests for this patient
    final reqs = AppData.allRequests
        .where((r) => r['patient'] == p['name'])
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (_, scrollCtrl) => SingleChildScrollView(
          controller: scrollCtrl,
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: color.withOpacity(0.2),
                    child: Text(initials,
                        style: TextStyle(
                            color: color,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p['name'] ?? '—',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('Patient',
                          style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              _detailRow(Icons.phone, 'Mobile', p['mobile'] ?? '—'),
              _detailRow(
                  Icons.location_on, 'Location', p['location'] ?? '—'),
              _detailRow(Icons.list_alt, 'Total Requests',
                  '${p['requests'] ?? '0'}'),
              SizedBox(height: 16),
              Text('Request History',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
              SizedBox(height: 10),
              if (reqs.isEmpty)
                Text('No requests yet.',
                    style: TextStyle(color: Colors.grey[500]))
              else
                ...reqs.map((r) => _reqRow(r)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF1A7A55), size: 20),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              Text(value,
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _reqRow(Map<String, dynamic> r) {
    final status = r['status'] ?? 'Pending';
    Color c = status == 'Accepted'
        ? Colors.green
        : status == 'Completed'
            ? Colors.blue
            : status == 'Rejected'
                ? Colors.red
                : Colors.orange;
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r['service'] ?? '—',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                if (r['time'] != null)
                  Text(r['time'],
                      style: TextStyle(
                          color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: c.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(status,
                style: TextStyle(
                    color: c,
                    fontWeight: FontWeight.w600,
                    fontSize: 12)),
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