part of '../../main.dart';

class AppSession {
  static String role = '';
  static String uid = '';
  static String name = '';
  static Map<String, dynamic> profile = {};

  static void set({
    required String newRole,
    required String newUid,
    required String newName,
    Map<String, dynamic>? newProfile,
  }) {
    role = newRole;
    uid = newUid;
    name = newName;
    profile = newProfile ?? {};
  }

  static void clear() {
    role = '';
    uid = '';
    name = '';
    profile = {};
  }
}

Future<void> ensureFirebaseAuthSession() async {
  if (auth.currentUser == null) {
    await auth.signInAnonymously();
  }
}
