part of '../main.dart';

Future<void> logAttempt(
  String role,
  String username,
  bool success,
  String reason,
) async {
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
    final ref = db.collection('adminAccounts').doc('admin');
    final snap = await ref.get();
    if (snap.exists) return;
    await ref.set({
      'uid': 'admin',
      'username': 'admin',
      'usernameLower': 'admin',
      'password': 'Admin@12345',
      'securityQuestion': 'Your favourite place?',
      'securityAnswer': 'hospital',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  } catch (_) {
    // If rules are not deployed yet, login also has a guarded seed path.
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
    // Demo seeding should never block app launch or login.
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

  final admins = db.collection('adminAccounts');
  final existing = await admins
      .where('usernameLower', isEqualTo: user)
      .limit(1)
      .get();

  if (existing.docs.isEmpty && user == 'admin' && pass == 'Admin@12345') {
    await ensureFirebaseAuthSession();
    await admins.doc('admin').set({
      'uid': 'admin',
      'username': 'admin',
      'usernameLower': 'admin',
      'password': 'Admin@12345',
      'securityQuestion': 'Your favourite place?',
      'securityAnswer': 'hospital',
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

  final data = existing.docs.first.data();
  if ((data['password'] ?? '') != pass) {
    await logAttempt('admin', user, false, 'bad_password');
    throw Exception('Invalid username or password. Please try again.');
  }

  await ensureFirebaseAuthSession();
  await seedDefaultServicesIfMissing();
  await logAttempt('admin', user, true, '');
  return {...data, 'uid': existing.docs.first.id, 'role': 'admin'};
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

  debugPrint('Admin password change started for "$user".');

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
    final snap = await db
        .collection('adminAccounts')
        .where('usernameLower', isEqualTo: user)
        .limit(1)
        .get()
        .timeout(const Duration(seconds: 12));
    if (snap.docs.isEmpty) throw Exception('Admin account not found.');

    final doc = snap.docs.first;
    final data = doc.data();
    if ((data['password'] ?? '').toString() != current) {
      debugPrint('Admin password change failed: wrong current password.');
      throw Exception('Current password is incorrect.');
    }

    await ensureFirebaseAuthSession();
    await doc.reference
        .update({'password': next, 'updatedAt': FieldValue.serverTimestamp()})
        .timeout(const Duration(seconds: 12));

    if (AppSession.role == 'admin' &&
        (AppSession.uid == doc.id ||
            AppSession.name.trim().toLowerCase() == user)) {
      AppSession.profile = {...AppSession.profile, 'password': next};
    }
    debugPrint('Admin password change completed for "$user".');
  } on TimeoutException {
    debugPrint('Admin password change failed: timeout.');
    throw Exception('Request timed out. Check internet and try again.');
  } on FirebaseException catch (e) {
    debugPrint('Admin password change failed: ${e.code}.');
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

  debugPrint('Admin forgot password reset started for "$user".');

  if (secret.isEmpty) throw Exception('Secret word is required.');
  if (secret != 'hospital') {
    debugPrint('Admin forgot password reset failed: wrong secret word.');
    throw Exception('Secret word is incorrect.');
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
    final admins = db.collection('adminAccounts');
    final snap = await admins
        .where('usernameLower', isEqualTo: user)
        .limit(1)
        .get()
        .timeout(const Duration(seconds: 12));

    final data = {
      'uid': user,
      'username': user,
      'usernameLower': user,
      'password': next,
      'securityQuestion': 'Your favourite place?',
      'securityAnswer': 'hospital',
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (snap.docs.isEmpty) {
      await admins
          .doc(user)
          .set({...data, 'createdAt': FieldValue.serverTimestamp()})
          .timeout(const Duration(seconds: 12));
    } else {
      await snap.docs.first.reference
          .update(data)
          .timeout(const Duration(seconds: 12));
    }

    debugPrint('Admin forgot password reset completed for "$user".');
  } on TimeoutException {
    debugPrint('Admin forgot password reset failed: timeout.');
    throw Exception('Request timed out. Check internet and try again.');
  } on FirebaseException catch (e) {
    debugPrint('Admin forgot password reset failed: ${e.code}.');
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
  final snap = await db
      .collection('staff')
      .where('usernameLower', isEqualTo: user)
      .where('active', isEqualTo: true)
      .limit(1)
      .get();
  if (snap.docs.isEmpty) {
    await logAttempt('staff', user, false, 'not_found_or_disabled');
    throw Exception('Invalid username or password.');
  }
  final data = snap.docs.first.data();
  if ((data['password'] ?? '') != password.trim()) {
    await logAttempt('staff', user, false, 'bad_password');
    throw Exception('Invalid username or password.');
  }
  await ensureFirebaseAuthSession();
  await logAttempt('staff', user, true, '');
  return {...data, 'uid': snap.docs.first.id, 'role': 'staff'};
}
