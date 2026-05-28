part of '../../main.dart';

class AdminPatients extends StatelessWidget {
  const AdminPatients({super.key});
  @override
  Widget build(BuildContext c) => DocList(
    stream: db
        .collection('patients')
        .orderBy('createdAt', descending: true)
        .snapshots(),
    empty: 'No patients.',
    item: (d) {
      final x = d.data() as Map<String, dynamic>;
      return Card(
        child: ExpansionTile(
          title: Text(x['fullName'] ?? ''),
          subtitle: Text('${x['mobile'] ?? ''}\n${x['address'] ?? ''}'),
          children: [
            line(x, 'Gender', 'gender'),
            line(x, 'DOB', 'dob'),
            line(x, 'Blood', 'bloodGroup'),
            line(x, 'Aadhaar', 'aadhaarMasked'),
            RequestHistory(patientUid: d.id),
          ],
        ),
      );
    },
  );
}

class RequestHistory extends StatelessWidget {
  final String patientUid;
  const RequestHistory({super.key, required this.patientUid});
  @override
  Widget build(BuildContext c) => StreamBuilder<QuerySnapshot>(
    stream: db
        .collection('requests')
        .where('patientUid', isEqualTo: patientUid)
        .orderBy('createdAt', descending: true)
        .snapshots(),
    builder: (_, s) => Column(
      children: (s.data?.docs ?? [])
          .map((d) => requestTile(d.data() as Map<String, dynamic>))
          .toList(),
    ),
  );
}
