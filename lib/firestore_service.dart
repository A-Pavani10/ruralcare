
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // =========================
  // 👤 PATIENTS
  // =========================

  Future<void> addPatient({
    required String firstName,
    required String lastName,
    required String mobile,
    required String aadhaar,
    required String location,
  }) async {
    await _db.collection('patients').add({
      'firstName': firstName,
      'lastName': lastName,
      'mobile': mobile,
      'aadhaar': aadhaar,
      'location': location,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getPatients() {
    return _db.collection('patients').snapshots();
  }

  // =========================
  // 🏥 SERVICES
  // =========================

  Future<void> addService(String name) async {
    await _db.collection('services').add({
      'name': name,
      'status': 'Active',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getServices() {
    return _db.collection('services').snapshots();
  }

  // =========================
  // 👨‍⚕️ STAFF
  // =========================

  Future<void> addStaff({
    required String name,
    required String username,
    required String password,
    required String role,
    required String mobile,
  }) async {
    await _db.collection('staff').add({
      'name': name,
      'username': username,
      'password': password,
      'role': role,
      'mobile': mobile,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // 🔐 STAFF LOGIN (OPTIMIZED)
  Future<Map<String, dynamic>?> checkStaffLogin(
      String username, String password) async {

    final snapshot = await _db
        .collection('staff')
        .where('username', isEqualTo: username)
        .where('password', isEqualTo: password)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.data();
    }

    return null;
  }

  // 📋 GET STAFF LIST
  Stream<QuerySnapshot> getStaff() {
    return _db
        .collection('staff')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // =========================
  // 📋 REQUESTS
  // =========================

  Future<void> addRequest({
    required String patientName,
    required String mobile,
    required String service,
  }) async {
    await _db.collection('requests').add({
      'patientName': patientName,
      'mobile': mobile,
      'service': service,
      'status': 'Pending',
      'claimed': false,
      'claimedBy': '',
      'reason': '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getRequests() {
    return _db
        .collection('requests')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // 🙋 CLAIM REQUEST
  Future<void> claimRequest(String docId, String staffName) async {
    await _db.collection('requests').doc(docId).update({
      'claimed': true,
      'claimedBy': staffName,
      'status': 'Claimed',
    });
  }

  // 👨‍⚕️ MY TASKS
  Stream<QuerySnapshot> getMyTasks(String staffName) {
    return _db
        .collection('requests')
        .where('claimedBy', isEqualTo: staffName)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // 🔄 UPDATE STATUS
  Future<void> updateRequestStatus(String docId, String status) async {
    await _db.collection('requests').doc(docId).update({
      'status': status,
    });
  }

  // ❌ REJECT
  Future<void> rejectRequest(String docId, String reason) async {
    await _db.collection('requests').doc(docId).update({
      'status': 'Rejected',
      'reason': reason,
    });
  }

  // =========================
  // 🔐 ADMIN LOGIN
  // =========================

  Future<bool> checkAdminLogin(String username, String password) async {
    final snapshot = await _db
        .collection('admin')
        .where('username', isEqualTo: username)
        .where('password', isEqualTo: password)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }
  // ✏️ UPDATE STAFF
Future<void> updateStaff({
  required String docId,
  required String name,
  required String username,
  required String password,
  required String role,
  required String mobile,
}) async {
  await _db.collection('staff').doc(docId).update({
    'name': name,
    'username': username,
    'password': password,
    'role': role,
    'mobile': mobile,
  });
}
// 🗑 DELETE STAFF
Future<void> deleteStaff(String docId) async {
  await _db.collection('staff').doc(docId).delete();
}
}