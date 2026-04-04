import 'package:flutter/material.dart';
import 'app_data.dart';
import 'translations.dart';

class StaffMyTasksScreen extends StatefulWidget {
  @override
  _StaffMyTasksScreenState createState() => _StaffMyTasksScreenState();
}

class _StaffMyTasksScreenState extends State<StaffMyTasksScreen> {
  Color _priorityColor(String priority) {
    switch (priority) {
      case 'High': return Colors.red;
      case 'Medium': return Colors.orange;
      case 'Low': return Colors.green;
      default: return Colors.grey;
    }
  }

  void _updateTask(int index, String newStatus) {
    setState(() {
      AppData.myTasks[index]['status'] = newStatus;
      // Update corresponding patient request status
      String service = AppData.myTasks[index]['service'];
      for (var req in AppData.patientRequests) {
        if (req['service'] == service) {
          req['status'] = newStatus == 'Done' ? 'Completed' : newStatus;
          break;
        }
      }
      // Update allRequests for admin monitor
      for (var req in AppData.allRequests) {
        if (req['service'] == service) {
          req['status'] = newStatus == 'Done' ? 'Completed' : newStatus;
          req['claimedBy'] = AppData.staffName;
          break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String lang = AppData.selectedLanguage;
    final active = AppData.myTasks
        .asMap()
        .entries
        .where((e) => e.value['status'] != 'Done')
        .toList();
    final past = AppData.myTasks
        .asMap()
        .entries
        .where((e) => e.value['status'] == 'Done')
        .toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Color(0xFF1A7A55),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text(translations[lang]!['my_tasks']!),
      ),
      body: AppData.myTasks.isEmpty
          ? _emptyState(translations[lang]!['no_tasks']!)
          : SingleChildScrollView(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (active.isNotEmpty) ...[
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      child: Text(translations[lang]!['active_tasks']!,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                    ...active.map((entry) {
                      int idx = entry.key;
                      Map<String, dynamic> task = entry.value;
                      bool isClaimed = task['status'] == 'Claimed';
                      bool isAccepted = task['status'] == 'Accepted';

                      return Container(
                        margin: EdgeInsets.only(bottom: 12),
                        padding: EdgeInsets.all(14),
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
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          '${task["patient"]} — ${task["service"]}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      SizedBox(height: 4),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: _priorityColor(
                                                  task['priority'])
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          task['priority'],
                                          style: TextStyle(
                                              color: _priorityColor(
                                                  task['priority']),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.teal[50],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(task['status'],
                                      style: TextStyle(
                                          color: Colors.teal,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12)),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            if (isClaimed)
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                      ),
                                      onPressed: () =>
                                          _updateTask(idx, 'Accepted'),
                                      child: Text(
                                          translations[lang]!['accept']!),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red[100],
                                        foregroundColor: Colors.red,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                      ),
                                      onPressed: () =>
                                          _updateTask(idx, 'Rejected'),
                                      child: Text(
                                          translations[lang]!['reject']!),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange[100],
                                        foregroundColor: Colors.orange[800],
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                      ),
                                      onPressed: () {},
                                      child: Text(translations[lang]!
                                          ['reschedule']!),
                                    ),
                                  ),
                                ],
                              ),
                            if (isAccepted)
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8)),
                                  ),
                                  onPressed: () =>
                                      _updateTask(idx, 'Done'),
                                  child: Text(
                                      translations[lang]!['mark_done']!),
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                  ],
                  if (past.isNotEmpty) ...[
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      child: Text(translations[lang]!['past_tasks']!,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                    ...past.map((entry) {
                      Map<String, dynamic> task = entry.value;
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
                              child: Text(
                                  '${task["patient"]} — ${task["service"]}',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(translations[lang]!['done']!,
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12)),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _emptyState(String msg) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline,
                size: 56, color: Colors.grey[400]),
            SizedBox(height: 12),
            Text(msg, style: TextStyle(color: Colors.grey[500], fontSize: 15)),
            SizedBox(height: 6),
            Text('Claim requests from Incoming tab.',
                style: TextStyle(color: Colors.grey[400], fontSize: 13)),
          ],
        ),
      );
}