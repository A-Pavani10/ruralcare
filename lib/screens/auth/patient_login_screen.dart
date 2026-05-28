part of '../../main.dart';

class PatientLogin extends StatefulWidget {
  const PatientLogin({super.key});
  @override
  State<PatientLogin> createState() => _PatientLoginState();
}

class _PatientLoginState extends State<PatientLogin> {
  final phone = TextEditingController(), pin = TextEditingController();
  String get mobileDigits => phone.text.trim().replaceAll(RegExp(r'\D'), '');
  String get e164 => '+91$mobileDigits';
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
    final existing = await db
        .collection('patients')
        .where('mobile', isEqualTo: e164)
        .limit(1)
        .get();
    if (!mounted) return;
    if (existing.docs.isEmpty)
      return toast(context, 'No account found. Please register.');
    final data = existing.docs.first.data();
    if ((data['pin'] ?? '') != pin.text.trim()) {
      toast(context, 'Invalid mobile number or PIN.');
      return;
    }
    AppSession.set(
      newRole: 'patient',
      newUid: existing.docs.first.id,
      newName: data['fullName'] ?? 'Patient',
      newProfile: data,
    );
    if (!context.mounted) return;
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
