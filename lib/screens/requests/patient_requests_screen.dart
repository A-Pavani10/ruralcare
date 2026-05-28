part of '../../main.dart';

class PatientRequests extends StatelessWidget {
  const PatientRequests({super.key});
  @override
  Widget build(BuildContext c) => DocList(
    stream: db
        .collection('requests')
        .orderBy('createdAt', descending: true)
        .snapshots(),
    empty: 'No requests.',
    include: (d) {
      final x = d.data() as Map<String, dynamic>;
      return (x['patientUid'] ?? '') == activePatientUid() ||
          (AppSession.profile['mobile'] != null &&
              x['patientMobile'] == AppSession.profile['mobile']);
    },
    item: (d) => requestCard(c, d),
  );
}
