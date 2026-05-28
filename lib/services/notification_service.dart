part of '../main.dart';

Future<void> notifyUser(
  String uid,
  String role,
  String title,
  String body,
  String requestId,
) async {
  await db.collection('notifications').add({
    'userUid': uid,
    'role': role,
    'title': title,
    'body': body,
    'requestId': requestId,
    'read': false,
    'createdAt': FieldValue.serverTimestamp(),
  });
}
