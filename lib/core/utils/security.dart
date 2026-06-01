part of '../../main.dart';

const _secretPepper = 'ruralcare-v1-local-secret-pepper';
const _recoverySecret = String.fromEnvironment(
  'RURALCARE_ADMIN_RECOVERY_SECRET',
);

String normalizeMobileDigits(String input) =>
    input.trim().replaceAll(RegExp(r'\D'), '');

String mobileKeyFromDigits(String digits) => '91$digits';

String hashSecret(String value, String salt) {
  final bytes = utf8.encode('$salt|$_secretPepper|$value');
  return sha256.convert(bytes).toString();
}

bool verifySecret({
  required String value,
  required String salt,
  required Map<String, dynamic> data,
  required String hashField,
  String? legacyField,
}) {
  final storedHash = data[hashField]?.toString();
  if (storedHash != null && storedHash.isNotEmpty) {
    return storedHash == hashSecret(value.trim(), salt);
  }
  if (legacyField == null) return false;
  return data[legacyField]?.toString() == value.trim();
}

Map<String, dynamic> stripSecretFields(Map<String, dynamic> data) {
  final clean = Map<String, dynamic>.from(data);
  clean.remove('password');
  clean.remove('passwordHash');
  clean.remove('pin');
  clean.remove('pinHash');
  clean.remove('securityAnswer');
  clean.remove('securityAnswerHash');
  clean.remove('aadhaarCipherText');
  return clean;
}
