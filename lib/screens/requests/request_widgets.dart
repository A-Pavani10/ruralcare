part of '../../main.dart';

Widget requestCard(
  BuildContext c,
  QueryDocumentSnapshot d, {
  bool incoming = false,
  bool task = false,
}) {
  final x = d.data() as Map<String, dynamic>;
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          requestTile(x),
          if (incoming)
            Wrap(
              spacing: 8,
              children: [
                FilledButton(
                  onPressed: () => runBusy(c, () => acceptRequestDirect(d.id)),
                  child: const Text('Accept'),
                ),
                OutlinedButton(
                  onPressed: () => rejectDialog(c, d.id),
                  child: const Text('Reject'),
                ),
                OutlinedButton(
                  onPressed: () => proposeDialog(c, d.id),
                  child: const Text('Propose time'),
                ),
              ],
            ),
          if (task && x['status'] != 'Completed' && x['status'] != 'Rejected')
            FilledButton.icon(
              onPressed: () => runBusy(c, () => completeRequestDirect(d.id)),
              icon: const Icon(Icons.check),
              label: const Text('Mark completed'),
            ),
          if (AppSession.role == 'patient' &&
              (x['patientUid'] ?? '') == activePatientUid())
            Wrap(
              spacing: 8,
              children: [
                if (['Pending', 'Alternate Proposed'].contains(x['status']))
                  OutlinedButton.icon(
                    onPressed: () =>
                        runBusy(c, () => cancelRequestDirect(d.id)),
                    icon: const Icon(Icons.cancel),
                    label: const Text('Cancel'),
                  ),
                if ([
                  'Rejected',
                  'Cancelled',
                  'Completed',
                ].contains(x['status']))
                  OutlinedButton.icon(
                    onPressed: () =>
                        runBusy(c, () => rebookRequestDirect(d.id)),
                    icon: const Icon(Icons.replay),
                    label: const Text('Rebook'),
                  ),
              ],
            ),
        ],
      ),
    ),
  );
}

Widget requestTile(Map<String, dynamic> x) => ListTile(
  title: Text('${x['serviceName']} - ${x['status']}'),
  subtitle: Text(
    'Patient: ${x['patientName']}\nRecipient: ${x['recipientName']} ${x['recipientAge'] ?? ''}\nAddress: ${x['patientAddress']}\nPreferred: ${when(x['preferredAt'])}\nCreated: ${when(x['createdAt'])}\nStaff: ${x['assignedStaffName'] ?? '-'}\nReason: ${x['rejectionReason'] ?? '-'}\nProposed: ${when(x['proposedAt'])} ${x['proposedMessage'] ?? ''}\nCompleted: ${when(x['completedAt'])}',
  ),
);
Future<void> rejectDialog(BuildContext c, String id) async {
  if (!c.mounted) return;
  final r = TextEditingController();
  await showDialog(
    context: c,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Reject request'),
      content: TextField(
        controller: r,
        maxLines: 3,
        decoration: dec('Mandatory reason'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            if (r.text.trim().isEmpty) return toast(c, 'Reason is required.');
            final ok = await runBusy(c, () async {
              await rejectRequestDirect(id, r.text);
              return true;
            });
            if (ok != null && dialogContext.mounted) {
              Navigator.pop(dialogContext);
            }
          },
          child: const Text('Reject'),
        ),
      ],
    ),
  );
  r.dispose();
}

Future<void> proposeDialog(BuildContext c, String id) async {
  if (!c.mounted) return;
  DateTime? at;
  final m = TextEditingController();
  await showDialog(
    context: c,
    builder: (_) => StatefulBuilder(
      builder: (dialogContext, set) => AlertDialog(
        title: const Text('Propose alternate time'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(at == null ? 'Choose date/time' : fmt.format(at!)),
              trailing: const Icon(Icons.calendar_month),
              onTap: () async {
                final d = await showDatePicker(
                  context: c,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 60)),
                  initialDate: DateTime.now(),
                );
                if (!c.mounted) return;
                if (d == null) return;
                final time = await showTimePicker(
                  context: c,
                  initialTime: TimeOfDay.now(),
                );
                if (!c.mounted) return;
                if (time != null)
                  set(
                    () => at = DateTime(
                      d.year,
                      d.month,
                      d.day,
                      time.hour,
                      time.minute,
                    ),
                  );
              },
            ),
            TextField(controller: m, decoration: dec('Optional message')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (at == null) return toast(c, 'Select time.');
              final ok = await runBusy(c, () async {
                await proposeTimeDirect(id, at!, m.text);
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
  m.dispose();
}
