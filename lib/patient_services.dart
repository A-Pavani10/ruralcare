import 'package:flutter/material.dart';
import 'app_data.dart';
import 'translations.dart';

class PatientServicesScreen extends StatefulWidget {
  @override
  _PatientServicesScreenState createState() => _PatientServicesScreenState();
}

class _PatientServicesScreenState extends State<PatientServicesScreen> {
  Color _statusColor(String? status) {
    if (status == null) return Colors.grey;
    if (status == 'Active') return Colors.green;
    if (status == 'Pending') return Colors.orange;
    return Colors.grey;
  }

  void _book(String serviceName) {
    setState(() {
      AppData.serviceStatuses[serviceName] = 'Pending';
      // Add to requests list
      AppData.patientRequests.add({
        'service': serviceName,
        'time': _now(),
        'status': 'Pending',
      });
      // Also push to shared incoming pool for staff
      AppData.incomingRequests.add({
        'patient': AppData.patientFullName.isEmpty
            ? 'Patient'
            : AppData.patientFullName,
        'service': serviceName,
        'time': _now(),
        'priority': 'Medium',
        'claimed': false,
        'claimedBy': '',
        'status': 'Pending',
      });
      AppData.allRequests.add({
        'patient': AppData.patientFullName.isEmpty
            ? 'Patient'
            : AppData.patientFullName,
        'service': serviceName,
        'time': _now(),
        'status': 'Pending',
        'claimedBy': '',
      });
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Request submitted for $serviceName')),
    );
  }

  void _cancel(String serviceName) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Cancel $serviceName?'),
        content: Text('Are you sure you want to cancel this request?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('No')),
          TextButton(
            onPressed: () {
              setState(() {
                AppData.serviceStatuses[serviceName] = null;
                AppData.patientRequests.removeWhere(
                    (r) => r['service'] == serviceName && r['status'] == 'Pending');
              });
              Navigator.pop(context);
            },
            child: Text('Yes', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _now() {
    final now = DateTime.now();
    return '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    String lang = AppData.selectedLanguage;
    final services = AppData.services;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Color(0xFF1A7A55),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text(translations[lang]!['services']!),
      ),
      body: services.isEmpty
          ? _emptyState(translations[lang]!['no_services']!)
          : Column(
              children: [
                Container(
                  margin: EdgeInsets.all(12),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.yellow[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.yellow[700]!),
                  ),
                  child: Row(
                    children: [
                      Text('💡', style: TextStyle(fontSize: 16)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Cancel button is disabled until you make a request for that service.',
                          style: TextStyle(
                              fontSize: 12, color: Colors.yellow[900]),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Table(
                      border: TableBorder.all(
                          color: Colors.grey[300]!,
                          borderRadius: BorderRadius.circular(8)),
                      columnWidths: {
                        0: FlexColumnWidth(3),
                        1: FlexColumnWidth(2),
                        2: FlexColumnWidth(1.5),
                        3: FlexColumnWidth(1.5),
                      },
                      children: [
                        TableRow(
                          decoration: BoxDecoration(color: Colors.grey[200]),
                          children: [
                            _th(translations[lang]!['service']!),
                            _th(translations[lang]!['status']!),
                            _th(translations[lang]!['book']!),
                            _th(translations[lang]!['cancel']!),
                          ],
                        ),
                        ...services.map((svcName) {
                          String? status = AppData.serviceStatuses[svcName];
                          bool hasStatus = status != null;
                          return TableRow(
                            decoration: BoxDecoration(color: Colors.white),
                            children: [
                              Padding(
                                padding: EdgeInsets.all(10),
                                child: Text(svcName,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13)),
                              ),
                              Padding(
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  status ?? '—',
                                  style: TextStyle(
                                      color: _statusColor(status),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 4),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF1A7A55),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 6),
                                    textStyle: TextStyle(fontSize: 12),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(6)),
                                  ),
                                  onPressed: () => _book(svcName),
                                  child: Text(translations[lang]!['book']!),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 4),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: hasStatus
                                        ? Colors.red[100]
                                        : Colors.grey[200],
                                    foregroundColor: hasStatus
                                        ? Colors.red
                                        : Colors.grey,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 6),
                                    textStyle: TextStyle(fontSize: 12),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(6)),
                                  ),
                                  onPressed:
                                      hasStatus ? () => _cancel(svcName) : null,
                                  child:
                                      Text(translations[lang]!['cancel']!),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _th(String text) => Padding(
        padding: EdgeInsets.all(10),
        child: Text(text,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      );

  Widget _emptyState(String msg) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.medical_services_outlined,
                size: 56, color: Colors.grey[400]),
            SizedBox(height: 12),
            Text(msg, style: TextStyle(color: Colors.grey[500], fontSize: 15)),
            SizedBox(height: 6),
            Text('Admin will add services soon.',
                style: TextStyle(color: Colors.grey[400], fontSize: 13)),
          ],
        ),
      );
}