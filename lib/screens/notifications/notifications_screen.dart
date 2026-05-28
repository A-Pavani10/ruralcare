part of '../../main.dart';

class Notifications extends StatelessWidget {
  const Notifications({super.key});
  @override
  Widget build(BuildContext c) {
    final userUid = AppSession.uid.isNotEmpty
        ? AppSession.uid
        : auth.currentUser?.uid ?? '';
    if (userUid.isEmpty) {
      return const Center(child: Text('No notifications.'));
    }
    return DocList(
      stream: db
          .collection('notifications')
          .where('userUid', isEqualTo: userUid)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      empty: 'No notifications.',
      item: (d) {
        final x = d.data() as Map<String, dynamic>;
        return Card(
          child: ListTile(
            leading: Icon(
              x['read'] == true
                  ? Icons.notifications_none
                  : Icons.notifications_active,
              color: green,
            ),
            title: Text(x['title'] ?? ''),
            subtitle: Text('${x['body'] ?? ''}\n${when(x['createdAt'])}'),
            onTap: () async {
              try {
                await d.reference.update({'read': true});
              } catch (_) {
                if (c.mounted) toast(c, 'Please login again to continue.');
              }
            },
          ),
        );
      },
    );
  }
}
