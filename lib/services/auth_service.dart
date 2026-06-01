part of '../main.dart';

Future<void> seedDefaultHospitalIfMissing() async {
  try {
    await ensureFirebaseAuthSession();
    final ref = db.collection('hospitals').doc(hospitalId);
    final snap = await ref.get();
    if (snap.exists) return;
    await ref.set({
      'hospitalId': hospitalId,
      'hospitalName': hospitalName,
      'shortName': hospitalShortName,
      'city': 'Anantapur',
      'state': 'Andhra Pradesh',
      'country': 'India',
      'location': hospitalLocation,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  } catch (_) {
    // Hospital identity seeding should not block app startup.
  }
}

Future<void> logAttempt(
  String role,
  String username,
  bool success,
  String reason,
) async {
  await ensureFirebaseAuthSession();
  await db.collection('loginAttempts').add({
    'role': role,
    'username': username.trim().toLowerCase(),
    'success': success,
    'reason': reason,
    'createdAt': FieldValue.serverTimestamp(),
  });
}

Future<void> seedDefaultAdminIfMissing() async {
  try {
    await ensureFirebaseAuthSession();
    final ref = db.collection('adminAccounts').doc('admin');
    final snap = await ref.get();
    if (snap.exists) return;
    await ref.set({
      'uid': 'admin',
      'username': 'admin',
      'usernameLower': 'admin',
      'passwordHash': hashSecret('Admin@12345', 'admin'),
      'securityQuestion': 'Protected recovery phrase',
      'recoveryConfigured': _recoverySecret.isNotEmpty,
      if (_recoverySecret.isNotEmpty)
        'securityAnswerHash': hashSecret(_recoverySecret, 'admin-recovery'),
      'role': 'admin',
      'authUid': auth.currentUser?.uid ?? '',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  } catch (_) {
    // App startup should not be blocked by first-run seed permissions/network.
  }
}

Future<void> seedDefaultServicesIfMissing() async {
  try {
    final snap = await db.collection('services').limit(1).get();
    if (snap.docs.isNotEmpty) return;
    final batch = db.batch();
    final defaults = [
      {'name': 'Injection at Home', 'charge': 150},
      {'name': 'Wound Dressing', 'charge': 250},
      {'name': 'Ambulance Service', 'charge': 800},
      {'name': 'Basic Health Checkup', 'charge': 300},
    ];
    for (final item in defaults) {
      batch.set(db.collection('services').doc(), {
        ...item,
        'active': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  } catch (_) {
    // Service seeding is a convenience only.
  }
}

Future<Map<String, dynamic>> adminLoginDirect(
  String username,
  String password,
) async {
  final user = username.trim().toLowerCase();
  final pass = password.trim();
  if (user.isEmpty || pass.isEmpty) {
    throw Exception('Enter username and password.');
  }

  await ensureFirebaseAuthSession();
  final admins = db.collection('adminAccounts');
  final existing = await admins
      .where('usernameLower', isEqualTo: user)
      .limit(1)
      .get()
      .timeout(const Duration(seconds: 12));

  if (existing.docs.isEmpty && user == 'admin' && pass == 'Admin@12345') {
    await admins.doc('admin').set({
      'uid': 'admin',
      'username': 'admin',
      'usernameLower': 'admin',
      'passwordHash': hashSecret('Admin@12345', 'admin'),
      'securityQuestion': 'Protected recovery phrase',
      'recoveryConfigured': _recoverySecret.isNotEmpty,
      if (_recoverySecret.isNotEmpty)
        'securityAnswerHash': hashSecret(_recoverySecret, 'admin-recovery'),
      'role': 'admin',
      'authUid': auth.currentUser?.uid ?? '',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await logAttempt('admin', user, true, 'default_admin_created');
    return {'uid': 'admin', 'username': 'admin', 'role': 'admin'};
  }

  if (existing.docs.isEmpty) {
    await logAttempt('admin', user, false, 'not_found');
    throw Exception('Invalid username or password. Please try again.');
  }

  final doc = existing.docs.first;
  final data = doc.data();
  if (!verifySecret(
    value: pass,
    salt: doc.id,
    data: data,
    hashField: 'passwordHash',
    legacyField: 'password',
  )) {
    await logAttempt('admin', user, false, 'bad_password');
    throw Exception('Invalid username or password. Please try again.');
  }

  final updates = <String, dynamic>{
    'role': 'admin',
    'authUid': auth.currentUser?.uid ?? '',
    'lastLoginAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  };
  if ((data['passwordHash'] ?? '').toString().isEmpty) {
    updates['passwordHash'] = hashSecret(pass, doc.id);
    updates['password'] = FieldValue.delete();
  }
  await doc.reference.update(updates);
  await seedDefaultServicesIfMissing();
  await logAttempt('admin', user, true, '');
  return {...stripSecretFields(data), 'uid': doc.id, 'role': 'admin'};
}

Future<void> resetAdminPasswordDirect(
  String username,
  String currentPassword,
  String newPassword,
  String confirmPassword,
) async {
  final user = username.trim().toLowerCase();
  final current = currentPassword.trim();
  final next = newPassword.trim();
  final confirm = confirmPassword.trim();

  if (user.isEmpty) throw Exception('Enter admin username first.');
  if (current.isEmpty || next.isEmpty || confirm.isEmpty) {
    throw Exception('All password fields are required.');
  }
  if (next.length < 8) {
    throw Exception('New password must be at least 8 characters.');
  }
  if (next != confirm) {
    throw Exception('Confirm password must match new password.');
  }
  if (current == next) {
    throw Exception('New password cannot be the same as current password.');
  }

  try {
    await ensureFirebaseAuthSession();
    final snap = await db
        .collection('adminAccounts')
        .where('usernameLower', isEqualTo: user)
        .limit(1)
        .get()
        .timeout(const Duration(seconds: 12));
    if (snap.docs.isEmpty) throw Exception('Admin account not found.');

    final doc = snap.docs.first;
    final data = doc.data();
    if (!verifySecret(
      value: current,
      salt: doc.id,
      data: data,
      hashField: 'passwordHash',
      legacyField: 'password',
    )) {
      throw Exception('Current password is incorrect.');
    }

    await doc.reference
        .update({
          'passwordHash': hashSecret(next, doc.id),
          'password': FieldValue.delete(),
          'updatedAt': FieldValue.serverTimestamp(),
        })
        .timeout(const Duration(seconds: 12));

    if (AppSession.role == 'admin' &&
        (AppSession.uid == doc.id ||
            AppSession.name.trim().toLowerCase() == user)) {
      AppSession.profile = stripSecretFields(AppSession.profile);
    }
  } on TimeoutException {
    throw Exception('Request timed out. Check internet and try again.');
  } on FirebaseException catch (e) {
    if (e.code == 'unavailable' || e.code == 'deadline-exceeded') {
      throw Exception('No internet connection. Please try again.');
    }
    if (e.code == 'permission-denied') {
      throw Exception('Permission denied. Please login again and retry.');
    }
    throw Exception(e.message ?? 'Could not update password. Try again.');
  }
}

Future<void> forgotAdminPasswordDirect(
  String username,
  String secretWord,
  String newPassword,
  String confirmPassword,
) async {
  final user = username.trim().isEmpty
      ? 'admin'
      : username.trim().toLowerCase();
  final secret = secretWord.trim();
  final next = newPassword.trim();
  final confirm = confirmPassword.trim();

  if (secret.isEmpty) throw Exception('Recovery phrase is required.');
  if (_recoverySecret.isEmpty) {
    throw Exception('Admin recovery is not configured. Contact system owner.');
  }
  if (next.isEmpty || confirm.isEmpty) {
    throw Exception('New password and confirm password are required.');
  }
  if (next.length < 8) {
    throw Exception('New password must be at least 8 characters.');
  }
  if (next != confirm) {
    throw Exception('Confirm password must match new password.');
  }

  try {
    await ensureFirebaseAuthSession();
    final snap = await db
        .collection('adminAccounts')
        .where('usernameLower', isEqualTo: user)
        .limit(1)
        .get()
        .timeout(const Duration(seconds: 12));
    if (snap.docs.isEmpty) throw Exception('Admin account not found.');

    final doc = snap.docs.first;
    final data = doc.data();
    final storedRecovery = data['securityAnswerHash']?.toString() ?? '';
    final acceptedHashes = {
      if (storedRecovery.isNotEmpty) storedRecovery,
      hashSecret(_recoverySecret, '${doc.id}-recovery'),
      hashSecret(_recoverySecret, 'admin-recovery'),
    };
    final submittedHashes = {
      hashSecret(secret, '${doc.id}-recovery'),
      hashSecret(secret, 'admin-recovery'),
    };
    if (!submittedHashes.any(acceptedHashes.contains)) {
      throw Exception('Recovery phrase is incorrect.');
    }

    await doc.reference
        .update({
          'passwordHash': hashSecret(next, doc.id),
          'password': FieldValue.delete(),
          'securityAnswer': FieldValue.delete(),
          'recoveryConfigured': true,
          'updatedAt': FieldValue.serverTimestamp(),
        })
        .timeout(const Duration(seconds: 12));
  } on TimeoutException {
    throw Exception('Request timed out. Check internet and try again.');
  } on FirebaseException catch (e) {
    if (e.code == 'unavailable' || e.code == 'deadline-exceeded') {
      throw Exception('No internet connection. Please try again.');
    }
    if (e.code == 'permission-denied') {
      throw Exception('Permission denied. Please login again and retry.');
    }
    throw Exception(e.message ?? 'Could not reset password. Try again.');
  }
}

Future<Map<String, dynamic>> staffLoginDirect(
  String username,
  String password,
) async {
  final user = username.trim().toLowerCase();
  final pass = password.trim();
  if (user.isEmpty || pass.isEmpty) {
    throw Exception('Enter username and password.');
  }
  await ensureFirebaseAuthSession();
  final snap = await db
      .collection('staff')
      .where('usernameLower', isEqualTo: user)
      .where('active', isEqualTo: true)
      .limit(1)
      .get()
      .timeout(const Duration(seconds: 12));
  if (snap.docs.isEmpty) {
    await logAttempt('staff', user, false, 'not_found_or_disabled');
    throw Exception('Invalid username or password.');
  }
  final doc = snap.docs.first;
  final data = doc.data();
  if (!verifySecret(
    value: pass,
    salt: doc.id,
    data: data,
    hashField: 'passwordHash',
    legacyField: 'password',
  )) {
    await logAttempt('staff', user, false, 'bad_password');
    throw Exception('Invalid username or password.');
  }
  final updates = <String, dynamic>{
    'role': 'staff',
    'authUid': auth.currentUser?.uid ?? '',
    'lastLoginAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  };
  if ((data['passwordHash'] ?? '').toString().isEmpty) {
    updates['passwordHash'] = hashSecret(pass, doc.id);
    updates['password'] = FieldValue.delete();
  }
  await doc.reference.update(updates);
  await logAttempt('staff', user, true, '');
  return {...stripSecretFields(data), 'uid': doc.id, 'role': 'staff'};
}
