part of '../../main.dart';

class StaffIncoming extends StatelessWidget {
  const StaffIncoming({super.key});
  @override
  Widget build(BuildContext c) => DocList(
    stream: db
        .collection('requests')
        .orderBy('createdAt', descending: true)
        .snapshots(),
    empty: 'No open requests.',
    include: (d) {
      final x = d.data() as Map<String, dynamic>;
      final status = (x['status'] ?? 'Pending').toString();
      return x['claimed'] != true &&
          (status == 'Pending' || status == 'Alternate Proposed');
    },
    item: (d) => requestCard(c, d, incoming: true),
  );
}
