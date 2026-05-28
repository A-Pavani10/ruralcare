part of '../../main.dart';

class AdminServices extends StatelessWidget {
  const AdminServices({super.key});
  @override
  Widget build(BuildContext c) => Scaffold(
    floatingActionButton: FloatingActionButton(
      onPressed: () => serviceDialog(c),
      child: const Icon(Icons.add),
    ),
    body: DocList(
      stream: db
          .collection('services')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      empty: 'No services.',
      item: (d) {
        final x = d.data() as Map<String, dynamic>;
        return Card(
          child: ListTile(
            title: Text(x['name'] ?? ''),
            subtitle: Text('Charge: Rs ${x['charge'] ?? 0}'),
            leading: Icon(
              x['active'] == true
                  ? Icons.medical_services
                  : Icons.visibility_off,
              color: green,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => serviceDialog(c, id: d.id, data: x),
            ),
          ),
        );
      },
    ),
  );
}

Future<void> serviceDialog(
  BuildContext c, {
  String? id,
  Map<String, dynamic>? data,
}) async {
  if (!c.mounted) return;
  final name = TextEditingController(text: data?['name'] ?? ''),
      charge = TextEditingController(text: '${data?['charge'] ?? ''}');
  var active = data?['active'] ?? true;
  await showDialog(
    context: c,
    builder: (_) => StatefulBuilder(
      builder: (dialogContext, set) => AlertDialog(
        title: Text(id == null ? 'Add service' : 'Edit service'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name, decoration: dec('Service name')),
            const SizedBox(height: 10),
            TextField(
              controller: charge,
              keyboardType: TextInputType.number,
              decoration: dec('Charge'),
            ),
            SwitchListTile(
              value: active,
              onChanged: (v) => set(() => active = v),
              title: const Text('Active'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final ok = await runBusy(c, () async {
                await saveServiceDirect(
                  id: id,
                  name: name.text,
                  chargeText: charge.text,
                  active: active,
                );
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
    ),
  );
  name.dispose();
  charge.dispose();
}
