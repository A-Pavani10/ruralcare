part of '../../main.dart';

class AdminSummary extends StatelessWidget {
  const AdminSummary({super.key});
  @override
  Widget build(BuildContext c) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          count('Patients', db.collection('patients').snapshots()),
          count(
            'Active staff',
            db.collection('staff').where('active', isEqualTo: true).snapshots(),
          ),
          count(
            'Pending',
            db
                .collection('requests')
                .where('status', isEqualTo: 'Pending')
                .snapshots(),
          ),
          count(
            'Services',
            db
                .collection('services')
                .where('active', isEqualTo: true)
                .snapshots(),
          ),
        ],
      ),
      const RequestMonitor(compact: true),
    ],
  );
}

Widget count(String label, Stream<QuerySnapshot> stream) =>
    StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (_, s) => SizedBox(
        width: 165,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${s.hasError ? 0 : s.data?.docs.length ?? 0}',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: green,
                  ),
                ),
                Text(label),
              ],
            ),
          ),
        ),
      ),
    );
