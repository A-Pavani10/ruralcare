import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_service.dart';
import 'app_data.dart';
class StaffIncomingScreen extends StatelessWidget {

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
      appBar: AppBar(title: Text("Incoming Requests")),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService().getRequests(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {

              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              return Container(
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text("${data['patientName']} - ${data['service']}"),
                    Text("Status: ${data['status']}"),

                    SizedBox(height: 10),

                    // CLAIM
                    if (data['claimed'] == false)
                      ElevatedButton(
                        onPressed: () async {
                          await FirestoreService()
                              .claimRequest(doc.id, AppData.staffName);
                        },
                        child: Text("Claim"),
                      ),

                    // AFTER CLAIM
                    if (data['claimed'] == true) ...[

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

                      SizedBox(height: 8),

                      ElevatedButton(
                        onPressed: () async {
                          await FirestoreService()
                              .updateRequestStatus(doc.id, "Completed");
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue),
                        child: Text("Mark Done"),
                      ),
                    ],
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