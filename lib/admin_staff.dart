import 'package:flutter/material.dart';
import 'app_data.dart';
import 'translations.dart';
import 'firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminStaffScreen extends StatefulWidget {
  @override
  _AdminStaffScreenState createState() => _AdminStaffScreenState();
}

class _AdminStaffScreenState extends State<AdminStaffScreen> {

  // =========================
  // ➕ ADD STAFF
  // =========================
  void _showAddStaffDialog() {
    String lang = AppData.selectedLanguage;

    final nameCtrl = TextEditingController();
    final roleCtrl = TextEditingController();
    final mobileCtrl = TextEditingController();
    final userCtrl = TextEditingController();
    final passCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(translations[lang]!['add_new_staff']!),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _field('Name', nameCtrl),
              _field('Role', roleCtrl),
              _field('Mobile', mobileCtrl),
              _field('Username', userCtrl),
              _field('Password', passCtrl),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirestoreService().addStaff(
                name: nameCtrl.text,
                username: userCtrl.text,
                password: passCtrl.text,
                role: roleCtrl.text,
                mobile: mobileCtrl.text,
              );
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  // =========================
  // ✏️ EDIT STAFF
  // =========================
  void _showEditDialog(String docId, Map<String, dynamic> data) {

    final nameCtrl = TextEditingController(text: data['name']);
    final roleCtrl = TextEditingController(text: data['role']);
    final mobileCtrl = TextEditingController(text: data['mobile']);
    final userCtrl = TextEditingController(text: data['username']);
    final passCtrl = TextEditingController(text: data['password']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Edit Staff"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _field('Name', nameCtrl),
              _field('Role', roleCtrl),
              _field('Mobile', mobileCtrl),
              _field('Username', userCtrl),
              _field('Password', passCtrl),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirestoreService().updateStaff(
                docId: docId,
                name: nameCtrl.text,
                username: userCtrl.text,
                password: passCtrl.text,
                role: roleCtrl.text,
                mobile: mobileCtrl.text,
              );

              Navigator.pop(context);
            },
            child: Text("Update"),
          ),
        ],
      ),
    );
  }

  // =========================
  // 🗑 DELETE CONFIRM
  // =========================
  void _confirmDelete(String docId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Delete Staff"),
        content: Text("Are you sure you want to delete this staff?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              await FirestoreService().deleteStaff(docId);
              Navigator.pop(context);
            },
            child: Text("Delete"),
          ),
        ],
      ),
    );
  }

  // =========================
  // FIELD UI
  // =========================
  Widget _field(String label, TextEditingController ctrl) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          SizedBox(height: 6),
          TextField(
            controller: ctrl,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text("Staff Management")),

      body: Column(
        children: [

          ElevatedButton(
            onPressed: _showAddStaffDialog,
            child: Text("Add Staff"),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirestoreService().getStaff(),
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

                    return Card(
                      child: ListTile(
                        title: Text(data['name']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Role: ${data['role']}"),
                            Text("Mobile: ${data['mobile']}"),
                            Text("Username: ${data['username']}"),
                          ],
                        ),

                        // ✅ EDIT + DELETE
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                _showEditDialog(doc.id, data);
                              },
                            ),

                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _confirmDelete(doc.id);
                              },
                            ),
                          ],
                        ),
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