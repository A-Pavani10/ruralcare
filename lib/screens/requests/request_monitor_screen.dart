part of '../../main.dart';

class RequestMonitor extends StatelessWidget {
  final bool compact;
  const RequestMonitor({super.key, this.compact = false});
  @override
  Widget build(BuildContext c) => DocList(
    stream: db
        .collection('requests')
        .orderBy('createdAt', descending: true)
        .limit(compact ? 8 : 100)
        .snapshots(),
    empty: 'No requests.',
    item: (d) => requestCard(c, d),
  );
}
