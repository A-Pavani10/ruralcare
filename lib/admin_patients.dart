import 'package:flutter/material.dart';
import 'translations.dart';
import 'app_data.dart';
import 'firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPatientsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String lang = AppData.selectedLanguage;

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
                left: BorderSide(color: Color(0xFF1A7A55), width: 4),
              ),
            ),
            child: Row(
              children: [
                Text('📋'),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Live patient data from database",
                    style: TextStyle(color: Colors.green[900]),
                  ),
                ),
              ],
            ),
          ),

          // 🔥 FIRESTORE DATA
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirestoreService().getPatients(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No patients found"));
                }

                final patients = snapshot.data!.docs;

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: patients.length,
                  itemBuilder: (context, index) {
                    final p = patients[index].data()
                        as Map<String, dynamic>;

                    final name =
                        "${p['firstName'] ?? ''} ${p['lastName'] ?? ''}";
                    final mobile = p['mobile'] ?? '';
                    final location = p['location'] ?? '';

                    return Container(
                      margin: EdgeInsets.only(bottom: 10),
                      padding: EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black12, blurRadius: 4)
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Color(0xFF1A7A55),
                            child: Text(
                              name.isNotEmpty
                                  ? name[0].toUpperCase()
                                  : 'P',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(name,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold)),
                                SizedBox(height: 4),
                                Text(
                                  "$mobile • $location",
                                  style: TextStyle(
                                      color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}