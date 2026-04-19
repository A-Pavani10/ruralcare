import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_data.dart';
import 'firestore_service.dart';

class StaffMyTasksScreen extends StatelessWidget {

  Color _statusColor(String status) {
    switch (status) {
      case 'Accepted': return Colors.green;
      case 'Pending': return Colors.orange;
      case 'Completed': return Colors.blue;
      case 'Rejected': return Colors.red;
      case 'Claimed': return Colors.purple;
      default: return Colors.grey;
    }
  }

  void _showRejectDialog(BuildContext context, String docId) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Reject Request"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: "Enter reason"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isEmpty) return;

              await FirestoreService()
                  .rejectRequest(docId, controller.text);

              Navigator.pop(context);
            },
            child: Text("Submit"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("My Tasks"),
        backgroundColor: Color(0xFF1A7A55),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService().getMyTasks("Staff"),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(child: Text("No tasks"));
          }

          return ListView.builder(
            padding: EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {

              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final status = data['status'] ?? 'Pending';
              final color = _statusColor(status);

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

                    Text(
                      "${data['patientName']} — ${data['service']}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),

                    SizedBox(height: 6),

                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    SizedBox(height: 10),

                    // ACTIONS
                    if (status == 'Claimed') ...[
                      Row(
                        children: [

                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                await FirestoreService()
                                    .updateRequestStatus(doc.id, "Accepted");
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green),
                              child: Text("Accept"),
                            ),
                          ),

                          SizedBox(width: 8),

                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                _showRejectDialog(context, doc.id);
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red),
                              child: Text("Reject"),
                            ),
                          ),
                        ],
                      ),
                    ],

                    if (status == 'Accepted')
                      ElevatedButton(
                        onPressed: () async {
                          await FirestoreService()
                              .updateRequestStatus(doc.id, "Completed");
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue),
                        child: Text("Mark Done"),
                      ),

                    // SHOW REASON
                    if (data['reason'] != null &&
                        data['reason'].toString().isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Text(
                          "Reason: ${data['reason']}",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}