import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'app_data.dart';
import 'translations.dart';
import 'firestore_service.dart';

String t(String key) {
  return translations[AppData.selectedLanguage]![key] ?? key;
}

class PatientServicesScreen extends StatefulWidget {
  @override
  _PatientServicesScreenState createState() =>
      _PatientServicesScreenState();
}

class _PatientServicesScreenState extends State<PatientServicesScreen> {
  Map<String, String> selectedSeverity = {};

  // 🔥 BOOK SERVICE (USING FIRESTORE SERVICE)
  Future<void> _book(String serviceName, String severity) async {
    final firestore = FirestoreService();

    await firestore.addRequest(
      patientName: AppData.patientFullName.isEmpty
          ? 'Patient'
          : AppData.patientFullName,
      mobile: AppData.patientMobile,
      service: serviceName,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Request submitted for $serviceName')),
    );
  }

  void _cancel(String serviceName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cancel feature will be added later')),
    );
  }

  @override
  Widget build(BuildContext context) {
    String lang = AppData.selectedLanguage;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Color(0xFF1A7A55),
        foregroundColor: Colors.white,
        title: Text(translations[lang]!['services']!),
      ),

      // 🔥 FIRESTORE SERVICES
      body: StreamBuilder<QuerySnapshot>(
  stream: FirestoreService().getServices(),
  builder: (context, snapshot) {

    // 🔥 ADD THIS (VERY IMPORTANT)
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
      return Center(child: Text("Error loading services"));
    }

    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return Center(child: Text("No services available"));
    }

    final services = snapshot.data!.docs;

    return ListView.builder(
      padding: EdgeInsets.all(12),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final svc =
            services[index].data() as Map<String, dynamic>;

        final String svcName = svc['name'] ?? '';

        return Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                svcName,
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),

              SizedBox(height: 10),

              DropdownButtonFormField<String>(
                value: selectedSeverity[svcName],
                hint: Text(t('select')),
                items: ["low", "medium", "high"].map((level) {
                  return DropdownMenuItem(
                    value: level,
                    child: Text(t(level)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSeverity[svcName] = value!;
                  });
                },
              ),

              SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF1A7A55),
                      ),
                      onPressed: () {
                        if (selectedSeverity[svcName] == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text(t('select_severity_first'))),
                          );
                          return;
                        }

                        _book(
                          svcName,
                          selectedSeverity[svcName]!,
                        );
                      },
                      child: Text(translations[lang]!['book']!),
                    ),
                  ),

                  SizedBox(width: 10),

                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _cancel(svcName),
                      child: Text(translations[lang]!['cancel']!),
                    ),
                  ),
                ],
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