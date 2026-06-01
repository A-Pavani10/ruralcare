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
  bool consentAccepted = false;
  String get mobileDigits => normalizeMobileDigits(mob.text);
  String get e164 => '+91$mobileDigits';
  String get mobileKey => mobileKeyFromDigits(mobileDigits);
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
    if (!consentAccepted) {
      return 'Please accept the privacy and medical disclaimer.';
    }
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
    final user = auth.currentUser;
    if (user == null) return;
    String? fcmToken;
    try {
      fcmToken = await FirebaseMessaging.instance.getToken();
    } catch (_) {
      fcmToken = null;
    }
    final data = {
      'uid': user.uid,
      'fullName': full.text.trim(),
      'mobile': e164,
      'mobileKey': mobileKey,
      'gender': gender,
      'dob': dob.text,
      'aadhaarMasked': '********${aad.text.trim().substring(8)}',
      'aadhaarLast4': aad.text.trim().substring(8),
      'address': addr.text.trim(),
      'bloodGroup': blood,
      'email': email.text.trim(),
      'pinHash': hashSecret(pin.text.trim(), mobileKey),
      'consentAccepted': true,
      'consentText':
          'Accepted RuralCare/APV Hospital privacy and non-emergency medical disclaimer.',
      'fcmToken': fcmToken,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    try {
      await db
          .runTransaction((tx) async {
            final mobileRef = db.collection('patientMobiles').doc(mobileKey);
            final existing = await tx.get(mobileRef);
            if (existing.exists) {
              throw Exception('Mobile already registered. Please login.');
            }
            tx.set(db.collection('patients').doc(user.uid), data);
            tx.set(mobileRef, {
              'patientUid': user.uid,
              'mobile': e164,
              'createdAt': FieldValue.serverTimestamp(),
            });
          })
          .timeout(const Duration(seconds: 15));
    } on TimeoutException {
      if (!mounted) return;
      return toast(context, 'Request timed out. Check internet and try again.');
    } catch (e) {
      if (!mounted) return;
      return toast(context, friendlyError(e));
    }
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
    CheckboxListTile(
      value: consentAccepted,
      onChanged: (v) {
        if (!mounted) return;
        setState(() => consentAccepted = v ?? false);
      },
      title: const Text('I agree to privacy and medical disclaimer'),
      subtitle: const Text(
        'APV Hospital stores my health details for service delivery only. This app is not for emergencies.',
      ),
      controlAffinity: ListTileControlAffinity.leading,
    ),
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
