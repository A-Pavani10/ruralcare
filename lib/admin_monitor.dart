import 'package:flutter/material.dart';
import 'app_data.dart';
import 'translations.dart';

class AdminMonitorScreen extends StatelessWidget {
  Color _statusColor(String status) {
    switch (status) {
      case 'Accepted':
        return Colors.green;
      case 'Claimed':
        return Colors.blue;
      case 'Pending':
        return Colors.orange;
      case 'Completed':
        return Colors.teal;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    String lang = AppData.selectedLanguage;
    final all = AppData.allRequests;
    int total = all.length;
    int accepted =
        all.where((r) => r['status'] == 'Accepted').length;
    int pending =
        all.where((r) => r['status'] == 'Pending').length;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Color(0xFF1A7A55),
        foregroundColor: Colors.white,
        title: Text(translations[lang]!['monitor_requests']!),
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
                  left: BorderSide(color: Color(0xFF1A7A55), width: 4)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('👁️', style: TextStyle(fontSize: 16)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    translations[lang]!['monitor_info'] ??
                        'Admin monitors only. Cannot accept or reject — that is staff\'s job.',
                    style: TextStyle(
                        fontSize: 13, color: Colors.green[900]),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: all.isEmpty
                ? _emptyState(translations[lang]!['no_requests']!)
                : SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Stats row
                        Row(
                          children: [
                            _statCard('$total',
                                translations[lang]!['today_requests']!,
                                Colors.teal),
                            SizedBox(width: 10),
                            _statCard('$accepted',
                                translations[lang]!['accepted']!,
                                Colors.green),
                            SizedBox(width: 10),
                            _statCard('$pending',
                                translations[lang]!['pending']!,
                                Colors.orange),
                          ],
                        ),
                        SizedBox(height: 16),
                        // Request list
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black12, blurRadius: 4)
                            ],
                          ),
                          child: Column(
                            children: all.asMap().entries.map((entry) {
                              int idx = entry.key;
                              final r = entry.value;
                              final status =
                                  r['status'] as String? ?? 'Pending';
                              final claimedBy =
                                  r['claimedBy'] as String? ?? '';
                              final Color sc = _statusColor(status);

                              return Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 14),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${r['patient'] ?? '—'} — ${r['service'] ?? '—'}',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.w600,
                                                    fontSize: 14),
                                              ),
                                              SizedBox(height: 3),
                                              Text(
                                                claimedBy.isEmpty
                                                    ? (translations[lang]!['not_yet_claimed'] ??
                                                        'Not yet claimed')
                                                    : '${translations[lang]!['claimed_by'] ?? 'Claimed by'} $claimedBy',
                                                style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Status badge
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 5),
                                          decoration: BoxDecoration(
                                            color:
                                                sc.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            _localizedStatus(
                                                status, lang),
                                            style: TextStyle(
                                                color: sc,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (idx < all.length - 1)
                                    Divider(
                                        height: 1,
                                        indent: 16,
                                        endIndent: 16),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  String _localizedStatus(String status, String lang) {
    switch (status) {
      case 'Accepted':
        return translations[lang]!['accepted'] ?? status;
      case 'Pending':
        return translations[lang]!['pending'] ?? status;
      case 'Completed':
        return translations[lang]!['completed'] ?? status;
      case 'Rejected':
        return translations[lang]!['rejected'] ?? status;
      case 'Claimed':
        return translations[lang]!['claimed'] ?? status;
      default:
        return status;
    }
  }

  Widget _statCard(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: color)),
            SizedBox(height: 4),
            Text(label,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart_outlined, size: 56, color: Colors.grey[400]),
          SizedBox(height: 12),
          Text(msg, style: TextStyle(color: Colors.grey[500], fontSize: 15)),
          SizedBox(height: 6),
          Text('Requests will appear here once patients book services.',
              style: TextStyle(color: Colors.grey[400], fontSize: 13),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}