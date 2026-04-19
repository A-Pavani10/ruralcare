import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'translations.dart';
import 'app_data.dart';
import 'firestore_service.dart';

class AdminServicesScreen extends StatefulWidget {
  @override
  _AdminServicesScreenState createState() =>
      _AdminServicesScreenState();
}

class _AdminServicesScreenState extends State<AdminServicesScreen> {

  // 🔥 ADD SERVICE (Firestore)
  void _showAddServiceDialog() {
    String lang = AppData.selectedLanguage;
    final nameCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(translations[lang]!['add_new_service']!),
        content: TextField(
          controller: nameCtrl,
          decoration: InputDecoration(
            hintText: 'e.g. Ambulance',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;

              await FirestoreService().addService(name);

              Navigator.pop(context);
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  // 🔥 DELETE SERVICE
  Future<void> _deleteService(String docId) async {
    await FirebaseFirestore.instance
        .collection('services')
        .doc(docId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    String lang = AppData.selectedLanguage;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Color(0xFF1A7A55),
        foregroundColor: Colors.white,
        title: Text(translations[lang]!['service_management']!),
      ),

      // ➕ ADD BUTTON
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF1A7A55),
        onPressed: _showAddServiceDialog,
        child: Icon(Icons.add),
      ),

      // 🔥 FIRESTORE LIST
      body: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService().getServices(),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No services found"));
          }

          final services = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final doc = services[index];
              final data = doc.data() as Map<String, dynamic>;

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
                        data['name'] ?? '',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteService(doc.id),
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