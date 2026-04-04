import 'package:flutter/material.dart';
import 'app_data.dart';
import 'translations.dart';

class StaffIncomingScreen extends StatefulWidget {
  @override
  _StaffIncomingScreenState createState() => _StaffIncomingScreenState();
}

class _StaffIncomingScreenState extends State<StaffIncomingScreen> {
  Color _priorityColor(String priority) {
    switch (priority) {
      case 'High': return Colors.red;
      case 'Medium': return Colors.orange;
      case 'Low': return Colors.green;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    String lang = AppData.selectedLanguage;
    final requests = AppData.incomingRequests
        .where((r) => r['claimed'] == false)
        .toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Color(0xFF1A7A55),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text(translations[lang]!['incoming']!),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: EdgeInsets.all(12),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '👥 All staff see these. Whoever is free can claim. Sorted High → Medium → Low.',
              style: TextStyle(fontSize: 12, color: Colors.blue[800]),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: requests.isEmpty
                ? _emptyState(translations[lang]!['no_incoming']!)
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final req = requests[index];
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${req["patient"]} — ${req["service"]}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(req['time'] ?? '',
                                          style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12)),
                                      SizedBox(width: 8),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: _priorityColor(
                                                  req['priority'])
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          req['priority'],
                                          style: TextStyle(
                                            color: _priorityColor(
                                                req['priority']),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF1A7A55),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () {
                                setState(() {
                                  // Mark as claimed in shared pool
                                  final globalIndex = AppData
                                      .incomingRequests
                                      .indexOf(req);
                                  if (globalIndex >= 0) {
                                    AppData.incomingRequests[globalIndex]
                                        ['claimed'] = true;
                                    AppData.incomingRequests[globalIndex]
                                        ['claimedBy'] = AppData.staffName;
                                  }
                                  // Add to my tasks
                                  AppData.myTasks.add({
                                    'patient': req['patient'],
                                    'service': req['service'],
                                    'priority': req['priority'],
                                    'status': 'Claimed',
                                  });
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'You claimed ${req["service"]} for ${req["patient"]}')),
                                );
                              },
                              child: Text(translations[lang]!['claim']!),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(String msg) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 56, color: Colors.grey[400]),
            SizedBox(height: 12),
            Text(msg, style: TextStyle(color: Colors.grey[500], fontSize: 15)),
            SizedBox(height: 6),
            Text('New patient requests will appear here.',
                style: TextStyle(color: Colors.grey[400], fontSize: 13)),
          ],
        ),
      );
}