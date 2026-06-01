part of '../main.dart';

Future<void> createRequestDirect(Map<String, dynamic> payload) async {
  final now = Timestamp.now();
  final request = {
    'patientUid': '',
    'patientName': '',
    'patientMobile': '',
    'patientAddress': '',
    'recipientType': 'Self',
    'recipientName': '',
    'recipientAge': '',
    'serviceId': '',
    'serviceName': '',
    'serviceCharge': 0,
    'preferredAt': now,
    'status': 'Pending',
    'claimed': false,
    'assignedStaffUid': '',
    'assignedStaffName': '',
    'assignedStaffMobile': '',
    'rejectionReason': '',
    'proposedAt': null,
    'proposedMessage': '',
    'completedAt': null,
    'completedByUid': '',
    'completedByName': '',
    'createdAt': now,
    'updatedAt': now,
    'actionLog': [],
    ...payload,
  };
  final ref = await db.collection('requests').add(request);
  final staff = await db
      .collection('staff')
      .where('active', isEqualTo: true)
      .get();
  final batch = db.batch();
  for (final doc in staff.docs) {
    batch.set(db.collection('notifications').doc(), {
      'userUid': doc.id,
      'role': 'staff',
      'title': 'New APV Hospital service request',
      'body':
          '${request['patientName']} requested ${request['serviceName']} via APV Hospital',
      'requestId': ref.id,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
  await batch.commit();
}

Future<void> acceptRequestDirect(String requestId) async {
  final staff = AppSession.profile;
  await db.runTransaction((tx) async {
    final ref = db.collection('requests').doc(requestId);
    final snap = await tx.get(ref);
    final data = snap.data();
    if (data == null) throw Exception('Request not found.');
    if (data['claimed'] == true ||
        !['Pending', 'Alternate Proposed'].contains(data['status'])) {
      throw Exception('This request is no longer open.');
    }
    tx.update(ref, {
      'claimed': true,
      'status': 'Accepted',
      'assignedStaffUid': AppSession.uid,
      'assignedStaffName': staff['fullName'] ?? AppSession.name,
      'assignedStaffMobile': staff['mobile'] ?? '',
      'acceptedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  });
  final req = (await db.collection('requests').doc(requestId).get()).data();
  if (req != null) {
    await notifyUser(
      req['patientUid'],
      'patient',
      'Request Accepted',
      '${req['serviceName']} accepted by ${AppSession.name} from APV Hospital',
      requestId,
    );
  }
}

Future<void> rejectRequestDirect(String requestId, String reason) async {
  final ref = db.collection('requests').doc(requestId);
  final req = (await ref.get()).data();
  await ref.update({
    'status': 'Rejected',
    'claimed': false,
    'assignedStaffUid': AppSession.uid,
    'assignedStaffName': AppSession.name,
    'rejectionReason': reason.trim(),
    'rejectedAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  });
  if (req != null) {
    await notifyUser(
      req['patientUid'],
      'patient',
      'Request Rejected',
      '${req['serviceName']} rejected by APV Hospital: $reason',
      requestId,
    );
  }
}

Future<void> proposeTimeDirect(
  String requestId,
  DateTime at,
  String message,
) async {
  final ref = db.collection('requests').doc(requestId);
  final req = (await ref.get()).data();
  await ref.update({
    'status': 'Alternate Proposed',
    'proposedAt': Timestamp.fromDate(at.toUtc()),
    'proposedMessage': message.trim(),
    'assignedStaffUid': AppSession.uid,
    'assignedStaffName': AppSession.name,
    'updatedAt': FieldValue.serverTimestamp(),
  });
  if (req != null) {
    await notifyUser(
      req['patientUid'],
      'patient',
      'Alternate Time Proposed',
      '${req['serviceName']}: APV Hospital proposed an alternate time',
      requestId,
    );
  }
}

Future<void> completeRequestDirect(String requestId) async {
  final ref = db.collection('requests').doc(requestId);
  final req = (await ref.get()).data();
  await ref.update({
    'status': 'Completed',
    'completedAt': FieldValue.serverTimestamp(),
    'completedByUid': AppSession.uid,
    'completedByName': AppSession.name,
    'updatedAt': FieldValue.serverTimestamp(),
  });
  if (req != null) {
    await notifyUser(
      req['patientUid'],
      'patient',
      'Request Completed',
      '${req['serviceName']} completed by APV Hospital',
      requestId,
    );
  }
}

Future<void> cancelRequestDirect(String requestId) async {
  final ref = db.collection('requests').doc(requestId);
  await db.runTransaction((tx) async {
    final snap = await tx.get(ref);
    final data = snap.data();
    if (data == null) throw Exception('Request not found.');
    if ((data['patientUid'] ?? '') != activePatientUid()) {
      throw Exception('You can cancel only your own request.');
    }
    if (!['Pending', 'Alternate Proposed'].contains(data['status'])) {
      throw Exception('Only open requests can be cancelled.');
    }
    tx.update(ref, {
      'status': 'Cancelled',
      'claimed': false,
      'cancelledAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  });
}

Future<void> rebookRequestDirect(String requestId) async {
  final ref = db.collection('requests').doc(requestId);
  final snap = await ref.get();
  final data = snap.data();
  if (data == null) throw Exception('Request not found.');
  if ((data['patientUid'] ?? '') != activePatientUid()) {
    throw Exception('You can rebook only your own request.');
  }
  final copy = Map<String, dynamic>.from(data);
  copy.remove('acceptedAt');
  copy.remove('rejectedAt');
  copy.remove('cancelledAt');
  copy.remove('completedAt');
  copy.addAll({
    'status': 'Pending',
    'claimed': false,
    'assignedStaffUid': '',
    'assignedStaffName': '',
    'assignedStaffMobile': '',
    'rejectionReason': '',
    'proposedAt': null,
    'proposedMessage': '',
    'completedByUid': '',
    'completedByName': '',
    'rebookedFrom': requestId,
    'createdAt': Timestamp.now(),
    'updatedAt': Timestamp.now(),
  });
  await createRequestDirect(copy);
}
