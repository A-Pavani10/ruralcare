import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_data.dart';
import 'firestore_service.dart';

class PatientRequestsScreen extends StatelessWidget {

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("My Requests"),
        backgroundColor: Color(0xFF1A7A55),
        foregroundColor: Colors.white,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService().getRequests(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          final myRequests = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['mobile'] == AppData.patientMobile;
          }).toList();

          if (myRequests.isEmpty) {
            return _emptyState();
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: myRequests.length,
            itemBuilder: (context, index) {

              final data =
                  myRequests[index].data() as Map<String, dynamic>;

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

                    // 🔹 Service Name
                    Text(
                      data['service'] ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 8),

                    // 🔹 Status Badge
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

                    SizedBox(height: 8),

                    // 🔹 Reason (if rejected)
                    if (data['reason'] != null &&
                        data['reason'].toString().isNotEmpty)
                      Text(
                        "Reason: ${data['reason']}",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 13,
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

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.list_alt, size: 60, color: Colors.grey[400]),
          SizedBox(height: 10),
          Text(
            "No requests yet",
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}