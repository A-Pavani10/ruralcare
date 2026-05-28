part of '../../main.dart';

class StaffTasks extends StatelessWidget {
  const StaffTasks({super.key});
  @override
  Widget build(BuildContext c) => DocList(
    stream: db
        .collection('requests')
        .orderBy('createdAt', descending: true)
        .snapshots(),
    empty: 'No tasks.',
    include: (d) {
      final x = d.data() as Map<String, dynamic>;
      return (x['assignedStaffUid'] ?? '') == AppSession.uid;
    },
    item: (d) => requestCard(c, d, task: true),
  );
}
