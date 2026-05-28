part of '../../main.dart';

class AdminStaff extends StatelessWidget {
  const AdminStaff({super.key});
  @override
  Widget build(BuildContext c) => Scaffold(
    floatingActionButton: FloatingActionButton(
      onPressed: () => staffDialog(c),
      child: const Icon(Icons.add),
    ),
    body: DocList(
      stream: db
          .collection('staff')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      empty: 'No staff.',
      item: (d) {
        final x = d.data() as Map<String, dynamic>;
        return Card(
          child: ListTile(
            title: Text(x['fullName'] ?? ''),
            subtitle: Text(
              '${x['designation']} | ID ${x['staffId']} | ${x['mobile']}',
            ),
            leading: Icon(
              x['active'] == true ? Icons.badge : Icons.block,
              color: x['active'] == true ? green : Colors.red,
            ),
            trailing: Wrap(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => staffDialog(c, id: d.id, data: x),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => runBusy(c, () => deleteStaffDirect(d.id)),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

Future<void> staffDialog(
  BuildContext c, {
  String? id,
  Map<String, dynamic>? data,
}) async {
  if (!c.mounted) return;
  final keys = [
    'fullName',
    'designation',
    'staffId',
    'username',
    'password',
    'mobile',
    'age',
    'department',
  ];
  final ctrls = {
    for (final k in keys)
      k: TextEditingController(
        text: k == 'password' ? '' : data?[k]?.toString() ?? '',
      ),
  };
  await showDialog(
    context: c,
    builder: (dialogContext) => AlertDialog(
      title: Text(id == null ? 'Add staff' : 'Edit staff'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: keys
              .map(
                (k) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TextField(
                    controller: ctrls[k],
                    obscureText: k == 'password',
                    decoration: dec(
                      k == 'password' && id != null
                          ? 'new password optional'
                          : k,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            final data = {for (final k in keys) k: ctrls[k]!.text};
            if (id != null) data['uid'] = id;
            final ok = await runBusy(c, () async {
              await saveStaffDirect(data, id: id);
              return true;
            });
            if (ok != null && dialogContext.mounted) {
              Navigator.pop(dialogContext);
            }
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
  for (final v in ctrls.values) {
    v.dispose();
  }
}
