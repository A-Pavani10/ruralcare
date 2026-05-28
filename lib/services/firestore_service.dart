part of '../main.dart';

Future<void> saveStaffDirect(Map<String, String> data, {String? id}) async {
  final username = (data['username'] ?? '').trim();
  final usernameLower = username.toLowerCase();
  final staffId = (data['staffId'] ?? '').trim();
  if (username.isEmpty ||
      staffId.isEmpty ||
      (data['fullName'] ?? '').trim().isEmpty) {
    throw Exception('Full name, staff ID and username are required.');
  }
  if (id == null && (data['password'] ?? '').trim().isEmpty) {
    throw Exception('Password is required for new staff.');
  }
  final duplicate = await db
      .collection('staff')
      .where('usernameLower', isEqualTo: usernameLower)
      .limit(2)
      .get();
  if (duplicate.docs.any((d) => d.id != id)) {
    throw Exception('Username already exists.');
  }
  final docId =
      id ??
      'staff_${staffId.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_')}';
  final payload = {
    'uid': docId,
    'fullName': (data['fullName'] ?? '').trim(),
    'designation': (data['designation'] ?? '').trim(),
    'staffId': staffId,
    'username': username,
    'usernameLower': usernameLower,
    'mobile': (data['mobile'] ?? '').trim(),
    'age': (data['age'] ?? '').trim(),
    'department': (data['department'] ?? '').trim(),
    'active': true,
    'deleted': false,
    'updatedAt': FieldValue.serverTimestamp(),
  };
  final password = (data['password'] ?? '').trim();
  if (password.isNotEmpty) payload['password'] = password;
  if (id == null) payload['createdAt'] = FieldValue.serverTimestamp();
  await db.collection('staff').doc(docId).set(payload, SetOptions(merge: true));
}

Future<void> deleteStaffDirect(String uid) async {
  await db.collection('staff').doc(uid).update({
    'active': false,
    'deleted': true,
    'deletedAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  });
}

Future<void> saveServiceDirect({
  String? id,
  required String name,
  required String chargeText,
  required bool active,
}) async {
  final charge = num.tryParse(chargeText.trim());
  if (name.trim().isEmpty || charge == null || charge < 0) {
    throw Exception('Enter a valid service name and charge.');
  }
  final payload = {
    'name': name.trim(),
    'charge': charge,
    'active': active,
    'updatedAt': FieldValue.serverTimestamp(),
  };
  if (id == null) {
    payload['createdAt'] = FieldValue.serverTimestamp();
    await db.collection('services').add(payload);
  } else {
    await db
        .collection('services')
        .doc(id)
        .set(payload, SetOptions(merge: true));
  }
}
