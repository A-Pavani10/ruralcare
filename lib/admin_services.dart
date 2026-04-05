import 'package:flutter/material.dart';
import 'app_data.dart';
import 'translations.dart';

class AdminServicesScreen extends StatefulWidget {
  @override
  _AdminServicesScreenState createState() => _AdminServicesScreenState();
}

class _AdminServicesScreenState extends State<AdminServicesScreen> {
  void _showAddServiceDialog() {
    String lang = AppData.selectedLanguage;
    final nameCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(translations[lang]!['add_new_service']!),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(translations[lang]!['service_name']!,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            SizedBox(height: 8),
            TextField(
              controller: nameCtrl,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'e.g. Ambulance Van',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(translations[lang]!['cancel']!)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1A7A55),
                foregroundColor: Colors.white),
            onPressed: () {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;
              final alreadyExists = AppData.services
                  .any((s) => s['name']?.toLowerCase() == name.toLowerCase());
              if (alreadyExists) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Service "$name" already exists')),
                );
                return;
              }
              setState(() {
                AppData.services.add({'name': name, 'status': 'Active'});
                AppData.serviceStatuses.putIfAbsent(name, () => null);
              });
              Navigator.pop(context);
            },
            child: Text(translations[lang]!['save']!),
          ),
        ],
      ),
    );
  }

  void _removeService(int index) {
    String lang = AppData.selectedLanguage;
    final svcName = AppData.services[index]['name'] ?? '';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Remove Service?'),
        content: Text('Remove "$svcName" from the service list?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(translations[lang]!['cancel']!)),
          TextButton(
            onPressed: () {
              setState(() {
                AppData.services.removeAt(index);
                AppData.serviceStatuses.remove(svcName);
              });
              Navigator.pop(context);
            },
            child: Text(translations[lang]!['remove']!,
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String lang = AppData.selectedLanguage;
    final List<Map<String, String>> services = AppData.services;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Color(0xFF1A7A55),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text(translations[lang]!['service_management']!),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1A7A55),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  textStyle:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: _showAddServiceDialog,
                child: Text(translations[lang]!['add_new_service']!),
              ),
            ),
          ),
          Expanded(
            child: services.isEmpty
                ? _emptyState(translations[lang]!['no_services']!)
                : SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 4)
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(12)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    translations[lang]!['service_name']!,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: Colors.grey[700]),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    translations[lang]!['status']!,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: Colors.grey[700]),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    translations[lang]!['action']!,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: Colors.grey[700]),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(height: 1),
                          ...services.asMap().entries.map((entry) {
                            final int idx = entry.key;
                            final Map<String, String> svc = entry.value;
                            final String svcName = svc['name'] ?? '—';
                            final String svcStatus = svc['status'] ?? 'Active';
                            return Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Text(svcName,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14)),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.green[50],
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(svcStatus,
                                              style: TextStyle(
                                                  color: Colors.green[700],
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12)),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: ElevatedButton(
                                          onPressed: () => _removeService(idx),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 8),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                            textStyle: TextStyle(fontSize: 13),
                                          ),
                                          child: Text(
                                              translations[lang]!['remove']!),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (idx < services.length - 1)
                                  Divider(height: 1, indent: 16),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
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
          Icon(Icons.medical_services_outlined,
              size: 56, color: Colors.grey[400]),
          SizedBox(height: 12),
          Text(msg, style: TextStyle(color: Colors.grey[500], fontSize: 15)),
          SizedBox(height: 6),
          Text('Tap "+ Add New Service" to get started.',
              style: TextStyle(color: Colors.grey[400], fontSize: 13)),
        ],
      ),
    );
  }
}