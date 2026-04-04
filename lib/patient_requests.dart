import 'package:flutter/material.dart';
import 'app_data.dart';
import 'translations.dart';

class PatientRequestsScreen extends StatelessWidget {
  Color _statusColor(String status) {
    switch (status) {
      case 'Accepted': return Colors.green;
      case 'Pending': return Colors.orange;
      case 'Completed': return Colors.blue;
      case 'Rejected': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    String lang = AppData.selectedLanguage;
    final current = AppData.patientRequests
        .where((r) => r['status'] == 'Pending' || r['status'] == 'Accepted')
        .toList();
    final past = AppData.patientRequests
        .where((r) => r['status'] == 'Completed' || r['status'] == 'Rejected')
        .toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Color(0xFF1A7A55),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text(translations[lang]!['my_requests']!),
      ),
      body: AppData.patientRequests.isEmpty
          ? _emptyState(translations[lang]!['no_requests']!)
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (current.isNotEmpty) ...[
                    Text(translations[lang]!['current_requests']!,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 10),
                    ...current.map((item) => _requestCard(item)),
                    SizedBox(height: 16),
                  ],
                  if (past.isNotEmpty) ...[
                    Text(translations[lang]!['past_requests']!,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 10),
                    ...past.map((item) => _requestCard(item)),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _requestCard(Map<String, String> item) {
    Color statusColor = _statusColor(item['status']!);
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['service']!,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                if (item['time'] != null && item['time']!.isNotEmpty)
                  Text(item['time']!,
                      style:
                          TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(item['status']!,
                style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(String msg) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.list_alt_outlined, size: 56, color: Colors.grey[400]),
            SizedBox(height: 12),
            Text(msg, style: TextStyle(color: Colors.grey[500], fontSize: 15)),
            SizedBox(height: 6),
            Text('Book a service to create a request.',
                style: TextStyle(color: Colors.grey[400], fontSize: 13)),
          ],
        ),
      );
}