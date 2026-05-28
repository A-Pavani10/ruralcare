part of '../../main.dart';

class PatientRegister extends StatefulWidget {
  const PatientRegister({super.key});
  @override
  State<PatientRegister> createState() => _PatientRegisterState();
}

class _PatientRegisterState extends State<PatientRegister> {
  final full = TextEditingController(),
      mob = TextEditingController(),
      aad = TextEditingController(),
      addr = TextEditingController(),
      email = TextEditingController(),
      dob = TextEditingController(),
      pin = TextEditingController(),
      confirmPin = TextEditingController();
  String gender = 'Male', blood = 'O+';
  String get mobileDigits => mob.text.trim().replaceAll(RegExp(r'\D'), '');
  String get e164 => '+91$mobileDigits';
  @override
  void dispose() {
    for (final c in [full, mob, aad, addr, email, dob, pin, confirmPin]) {
      c.dispose();
    }
    super.dispose();
  }

  String? validateRegistration() {
    if (full.text.trim().isEmpty) return 'Full name is required.';
    if (!RegExp(r'^\d{10}$').hasMatch(mobileDigits)) {
      return 'Mobile number must be 10 digits.';
    }
    if (dob.text.trim().isEmpty) return 'Date of birth is required.';
    if (!RegExp(r'^\d{12}$').hasMatch(aad.text.trim())) {
      return 'Aadhaar number must be 12 digits.';
    }
    if (addr.text.trim().isEmpty) return 'Address is required.';
    if (gender.trim().isEmpty) return 'Gender is required.';
    if (blood.trim().isEmpty) return 'Blood group is required.';
    if (!RegExp(r'^\d{4}$').hasMatch(pin.text.trim())) {
      return 'PIN must be exactly 4 digits.';
    }
    if (confirmPin.text.trim() != pin.text.trim()) {
      return 'Confirm PIN must match.';
    }
    return null;
  }

  Future<void> register() async {
    final validationError = validateRegistration();
    if (validationError != null) return toast(context, validationError);
    await ensureFirebaseAuthSession();
    if (!mounted) return;
    final dup = await db
        .collection('patients')
        .where('mobile', isEqualTo: e164)
        .limit(1)
        .get();
    if (!mounted) return;
    if (dup.docs.isNotEmpty)
      return toast(context, 'Mobile already registered. Please login.');
    final user = auth.currentUser;
    if (user == null) return;
    final data = {
      'uid': user.uid,
      'fullName': full.text.trim(),
      'mobile': e164,
      'gender': gender,
      'dob': dob.text,
      'aadhaarMasked': '********${aad.text.trim().substring(8)}',
      'aadhaarCipherText': aad.text.trim(),
      'address': addr.text.trim(),
      'bloodGroup': blood,
      'email': email.text.trim(),
      'pin': pin.text.trim(),
      'fcmToken': await FirebaseMessaging.instance.getToken(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await db.collection('patients').doc(user.uid).set(data);
    if (!mounted) return;
    AppSession.set(
      newRole: 'patient',
      newUid: user.uid,
      newName: full.text.trim(),
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
  Widget build(BuildContext c) => form(c, 'Patient Registration', [
    TextField(controller: full, decoration: dec('Full name')),
    TextField(
      controller: mob,
      keyboardType: TextInputType.phone,
      decoration: dec('Mobile'),
    ),
    dropdown('Gender', gender, ['Male', 'Female', 'Other'], (v) {
      if (!mounted) return;
      setState(() => gender = v!);
    }),
    TextField(
      controller: dob,
      readOnly: true,
      decoration: dec('DOB'),
      onTap: () async {
        final d = await showDatePicker(
          context: c,
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          initialDate: DateTime(1990),
        );
        if (!mounted) return;
        if (d != null) dob.text = DateFormat('dd/MM/yyyy').format(d);
      },
    ),
    TextField(
      controller: aad,
      keyboardType: TextInputType.number,
      decoration: dec('Aadhaar'),
    ),
    TextField(controller: addr, maxLines: 3, decoration: dec('Full address')),
    dropdown(
      'Blood group',
      blood,
      ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'],
      (v) {
        if (!mounted) return;
        setState(() => blood = v!);
      },
    ),
    TextField(controller: email, decoration: dec('Email optional')),
    TextField(
      controller: pin,
      keyboardType: TextInputType.number,
      obscureText: true,
      maxLength: 4,
      decoration: dec('Create 4-digit PIN'),
    ),
    TextField(
      controller: confirmPin,
      keyboardType: TextInputType.number,
      obscureText: true,
      maxLength: 4,
      decoration: dec('Confirm PIN'),
    ),
    FilledButton(onPressed: register, child: const Text('Register')),
  ]);
}
