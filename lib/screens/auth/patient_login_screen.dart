part of '../../main.dart';

class PatientLogin extends StatefulWidget {
  const PatientLogin({super.key});
  @override
  State<PatientLogin> createState() => _PatientLoginState();
}

class _PatientLoginState extends State<PatientLogin> {
  final phone = TextEditingController(), pin = TextEditingController();
  String get mobileDigits => normalizeMobileDigits(phone.text);
  String get e164 => '+91$mobileDigits';
  String get mobileKey => mobileKeyFromDigits(mobileDigits);
  @override
  void dispose() {
    phone.dispose();
    pin.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (!RegExp(r'^\d{10}$').hasMatch(mobileDigits)) {
      return toast(context, 'Mobile number must be 10 digits.');
    }
    if (!RegExp(r'^\d{4}$').hasMatch(pin.text.trim())) {
      return toast(context, 'PIN must be exactly 4 digits.');
    }
    await ensureFirebaseAuthSession();
    if (!mounted) return;
    final lookup = await db.collection('patientMobiles').doc(mobileKey).get();
    if (!mounted) return;
    if (!lookup.exists)
      return toast(context, 'No account found. Please register.');
    final patientUid = lookup.data()?['patientUid']?.toString() ?? '';
    if (patientUid.isEmpty) {
      return toast(context, 'Account lookup failed. Please contact support.');
    }
    final doc = await db.collection('patients').doc(patientUid).get();
    if (!mounted) return;
    if (!doc.exists || doc.data() == null) {
      return toast(context, 'No account found. Please register.');
    }
    final data = doc.data()!;
    final ok = verifySecret(
      value: pin.text.trim(),
      salt: mobileKey,
      data: data,
      hashField: 'pinHash',
      legacyField: 'pin',
    );
    if (!ok) {
      toast(context, 'Invalid mobile number or PIN.');
      return;
    }
    if ((data['pinHash'] ?? '').toString().isEmpty) {
      await doc.reference.update({
        'pinHash': hashSecret(pin.text.trim(), mobileKey),
        'pin': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    AppSession.set(
      newRole: 'patient',
      newUid: doc.id,
      newName: data['fullName'] ?? 'Patient',
      newProfile: stripSecretFields(data),
    );
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      page(const PatientHome()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext c) => form(c, 'Patient Login', [
    TextField(
      controller: phone,
      keyboardType: TextInputType.phone,
      decoration: dec('Mobile'),
    ),
    TextField(
      controller: pin,
      keyboardType: TextInputType.number,
      obscureText: true,
      maxLength: 4,
      decoration: dec('4-digit PIN'),
    ),
    FilledButton(onPressed: login, child: const Text('Login')),
  ]);
}
