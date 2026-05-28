part of '../../main.dart';

class PatientProfile extends StatelessWidget {
  const PatientProfile({super.key});
  @override
  Widget build(BuildContext c) => StreamBuilder<DocumentSnapshot>(
    stream: db.collection('patients').doc(activePatientUid()).snapshots(),
    builder: (_, s) {
      if (s.hasError) {
        return const Center(child: Text('Profile is not available.'));
      }
      if (!s.hasData) return const Center(child: CircularProgressIndicator());
      if (!s.data!.exists || s.data!.data() == null) {
        return const Center(child: Text('Profile is not available.'));
      }
      final x = s.data!.data() as Map<String, dynamic>;
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                line(x, 'Name', 'fullName'),
                line(x, 'Mobile', 'mobile'),
                line(x, 'Gender', 'gender'),
                line(x, 'DOB', 'dob'),
                line(x, 'Aadhaar', 'aadhaarMasked'),
                line(x, 'Blood', 'bloodGroup'),
                line(x, 'Address', 'address'),
                line(x, 'Email', 'email'),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: () => patientEdit(c, x),
            icon: const Icon(Icons.edit),
            label: const Text('Edit profile'),
          ),
        ],
      );
    },
  );
}

Future<void> patientEdit(BuildContext c, Map<String, dynamic> x) async {
  if (!c.mounted) return;
  final name = TextEditingController(text: x['fullName']),
      addr = TextEditingController(text: x['address']),
      email = TextEditingController(text: x['email']),
      blood = TextEditingController(text: x['bloodGroup']);
  await showDialog(
    context: c,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Edit profile'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name, decoration: dec('Name')),
            TextField(
              controller: addr,
              maxLines: 3,
              decoration: dec('Address'),
            ),
            TextField(controller: email, decoration: dec('Email')),
            TextField(controller: blood, decoration: dec('Blood group')),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            await runBusy(
              c,
              () => db.collection('patients').doc(activePatientUid()).update({
                'fullName': name.text,
                'address': addr.text,
                'email': email.text,
                'bloodGroup': blood.text,
                'updatedAt': FieldValue.serverTimestamp(),
              }),
            );
            if (dialogContext.mounted) Navigator.pop(dialogContext);
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
  for (final v in [name, addr, email, blood]) {
    v.dispose();
  }
}
