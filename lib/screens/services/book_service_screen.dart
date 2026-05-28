part of '../../main.dart';

class BookService extends StatefulWidget {
  const BookService({super.key});
  @override
  State<BookService> createState() => _BookServiceState();
}

class _BookServiceState extends State<BookService> {
  String forWhom = 'Self';
  final rn = TextEditingController(), age = TextEditingController();
  String? serviceId;
  Map<String, dynamic>? service;
  DateTime? at;
  @override
  void dispose() {
    rn.dispose();
    age.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    final patientUid = activePatientUid();
    final p = (await db.collection('patients').doc(patientUid).get()).data();
    if (!mounted) return;
    if (p == null || service == null || at == null)
      return toast(context, 'Complete booking details.');
    if (forWhom != 'Self' &&
        (rn.text.trim().isEmpty || age.text.trim().isEmpty))
      return toast(context, 'Enter recipient details.');
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm request'),
        content: Text(
          'Recipient: ${forWhom == 'Self' ? p['fullName'] : rn.text}\nService: ${service!['name']}\nCharge: Rs ${service!['charge']}\nPreferred: ${fmt.format(at!)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (ok != true) return;
    await runBusy(
      context,
      () => createRequestDirect({
        'patientUid': patientUid,
        'patientName': p['fullName'],
        'patientMobile': p['mobile'],
        'patientAddress': p['address'],
        'recipientType': forWhom,
        'recipientName': forWhom == 'Self' ? p['fullName'] : rn.text.trim(),
        'recipientAge': forWhom == 'Self' ? '' : age.text.trim(),
        'serviceId': serviceId,
        'serviceName': service!['name'],
        'serviceCharge': service!['charge'],
        'preferredAt': Timestamp.fromDate(at!.toUtc()),
        'status': 'Pending',
        'claimed': false,
        'assignedStaffUid': '',
        'assignedStaffName': '',
        'assignedStaffMobile': '',
        'rejectionReason': '',
        'proposedAt': null,
        'proposedMessage': '',
        'completedAt': null,
        'completedByUid': '',
        'completedByName': '',
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
        'actionLog': [],
      }),
    );
    if (!mounted) return;
    toast(context, 'Request submitted successfully.');
  }

  @override
  Widget build(BuildContext c) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      SegmentedButton<String>(
        segments: const [
          ButtonSegment(value: 'Self', label: Text('Self')),
          ButtonSegment(value: 'Household', label: Text('Household member')),
        ],
        selected: {forWhom},
        onSelectionChanged: (s) {
          if (!mounted) return;
          setState(() => forWhom = s.first);
        },
      ),
      if (forWhom != 'Self') ...[
        const SizedBox(height: 10),
        TextField(controller: rn, decoration: dec('Recipient name')),
        const SizedBox(height: 10),
        TextField(
          controller: age,
          keyboardType: TextInputType.number,
          decoration: dec('Recipient age'),
        ),
      ],
      const SizedBox(height: 10),
      StreamBuilder<QuerySnapshot>(
        stream: db
            .collection('services')
            .where('active', isEqualTo: true)
            .snapshots(),
        builder: (_, s) => DropdownButtonFormField<String>(
          decoration: dec('Service'),
          value: serviceId,
          items: (s.data?.docs ?? []).map((d) {
            final x = d.data() as Map<String, dynamic>;
            return DropdownMenuItem(
              value: d.id,
              child: Text('${x['name']} - Rs ${x['charge']}'),
            );
          }).toList(),
          onChanged: (v) {
            if (!mounted || v == null || s.data == null) return;
            final d = s.data!.docs.firstWhere((e) => e.id == v);
            if (!mounted) return;
            setState(() {
              serviceId = v;
              service = d.data() as Map<String, dynamic>;
            });
          },
        ),
      ),
      ListTile(
        title: Text(at == null ? 'Preferred date/time' : fmt.format(at!)),
        trailing: const Icon(Icons.calendar_month),
        onTap: () async {
          if (!context.mounted) return;
          final d = await showDatePicker(
            context: c,
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 60)),
            initialDate: DateTime.now(),
          );
          if (!mounted) return;
          if (d == null) return;
          if (!context.mounted) return;
          final time = await showTimePicker(
            context: c,
            initialTime: TimeOfDay.now(),
          );
          if (!mounted) return;
          if (time != null)
            setState(
              () =>
                  at = DateTime(d.year, d.month, d.day, time.hour, time.minute),
            );
        },
      ),
      FilledButton(onPressed: submit, child: const Text('Review and submit')),
    ],
  );
}
