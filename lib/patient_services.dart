import 'package:flutter/material.dart';
import 'app_data.dart';
import 'translations.dart';

String t(String key) {
  return translations[AppData.selectedLanguage]![key] ?? key;
}

class PatientServicesScreen extends StatefulWidget {
  @override
  _PatientServicesScreenState createState() => _PatientServicesScreenState();
}

class _PatientServicesScreenState extends State<PatientServicesScreen> {
  Map<String, String> selectedSeverity = {};

  Color _statusColor(String? status) {
    if (status == null) return Colors.grey;
    if (status == 'Active') return Colors.green[700]!;
    if (status == 'Pending') return Colors.orange[700]!;
    return Colors.grey;
  }

  Color _statusBgColor(String? status) {
    if (status == 'Active') return Colors.green[50]!;
    if (status == 'Pending') return Colors.orange[50]!;
    return Colors.grey[100]!;
  }

  void _book(String serviceName, String severity) {
    setState(() {
      AppData.serviceStatuses[serviceName] = 'Pending';
      AppData.patientRequests.add({
        'service': serviceName,
        'time': _now(),
        'status': 'Pending',
      });
      AppData.incomingRequests.add({
        'patient': AppData.patientFullName.isEmpty
            ? 'Patient'
            : AppData.patientFullName,
        'service': serviceName,
        'time': _now(),
        'priority': severity,
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
        'priority': severity,
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
            child: Text('No'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                AppData.serviceStatuses[serviceName] = null;
                AppData.patientRequests.removeWhere(
                  (r) =>
                      r['service'] == serviceName && r['status'] == 'Pending',
                );
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
    final List<Map<String, String>> services = AppData.services;

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
                // Tip banner
                Container(
                  margin: EdgeInsets.fromLTRB(12, 12, 12, 4),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.yellow[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.yellow[700]!),
                  ),
                  child: Row(
                    children: [
                      Text('💡', style: TextStyle(fontSize: 14)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Cancel button is disabled until you make a request for that service.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.yellow[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Service cards
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      final svc = services[index];
                      final String svcName = svc['name'] ?? '';
                      final String? status = AppData.serviceStatuses[svcName];
                      final bool hasStatus = status != null;

                      return Container(
                        margin: EdgeInsets.only(bottom: 10),
                        padding: EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Service name + status badge
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    svcName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                if (status != null)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _statusBgColor(status),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      status,
                                      style: TextStyle(
                                        color: _statusColor(status),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: 12),

                            // Priority label
                            Text(
                              t('priority'),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 5),

                            // Priority dropdown (full width)
                            DropdownButtonFormField<String>(
                              value: selectedSeverity[svcName],
                              hint: Text(
                                t('select'),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[500],
                                ),
                              ),
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: Colors.grey[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Color(0xFF1A7A55),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              items: ["low", "medium", "high"].map((level) {
                                return DropdownMenuItem(
                                  value: level,
                                  child: Text(
                                    t(level),
                                    style: TextStyle(fontSize: 13),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedSeverity[svcName] = value!;
                                });
                              },
                            ),
                            SizedBox(height: 12),

                            // Book + Cancel buttons
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF1A7A55),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding:
                                          EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    onPressed: () {
                                      if (selectedSeverity[svcName] == null) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              t('select_severity_first'),
                                            ),
                                          ),
                                        );
                                        return;
                                      }
                                      _book(
                                        svcName,
                                        selectedSeverity[svcName]!,
                                      );
                                    },
                                    child: Text(
                                      translations[lang]!['book']!,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: hasStatus
                                          ? Colors.red[50]
                                          : Colors.grey[100],
                                      foregroundColor: hasStatus
                                          ? Colors.red[700]
                                          : Colors.grey[400],
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: BorderSide(
                                          color: hasStatus
                                              ? Colors.red[200]!
                                              : Colors.grey[300]!,
                                        ),
                                      ),
                                      padding:
                                          EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    onPressed:
                                        hasStatus ? () => _cancel(svcName) : null,
                                    child: Text(
                                      translations[lang]!['cancel']!,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _emptyState(String msg) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medical_services_outlined,
              size: 56,
              color: Colors.grey[400],
            ),
            SizedBox(height: 12),
            Text(
              msg,
              style: TextStyle(color: Colors.grey[500], fontSize: 15),
            ),
            SizedBox(height: 6),
            Text(
              'Admin will add services soon.',
              style: TextStyle(color: Colors.grey[400], fontSize: 13),
            ),
          ],
        ),
      );
}