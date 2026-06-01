import 'package:flutter_test/flutter_test.dart';
import 'package:ruralcare/main.dart';

void main() {
  group('security helpers', () {
    test('hashSecret is deterministic and does not expose raw secret', () {
      final hash = hashSecret('Admin@12345', 'admin');

      expect(hash, hashSecret('Admin@12345', 'admin'));
      expect(hash, isNot(contains('Admin@12345')));
      expect(hash.length, 64);
    });

    test('verifySecret accepts hashed value and rejects wrong value', () {
      final data = {'passwordHash': hashSecret('StrongPass1', 'staff_1')};

      expect(
        verifySecret(
          value: 'StrongPass1',
          salt: 'staff_1',
          data: data,
          hashField: 'passwordHash',
        ),
        isTrue,
      );
      expect(
        verifySecret(
          value: 'WrongPass1',
          salt: 'staff_1',
          data: data,
          hashField: 'passwordHash',
        ),
        isFalse,
      );
    });

    test('stripSecretFields removes sensitive keys', () {
      final cleaned = stripSecretFields({
        'password': 'plain',
        'passwordHash': 'hash',
        'pin': '1234',
        'pinHash': 'hash',
        'aadhaarCipherText': '123456789012',
        'fullName': 'Patient',
      });

      expect(cleaned.keys, isNot(contains('password')));
      expect(cleaned.keys, isNot(contains('passwordHash')));
      expect(cleaned.keys, isNot(contains('pin')));
      expect(cleaned.keys, isNot(contains('pinHash')));
      expect(cleaned.keys, isNot(contains('aadhaarCipherText')));
      expect(cleaned['fullName'], 'Patient');
    });
  });

  group('patient validation helpers', () {
    test('mobile normalization keeps only digits', () {
      expect(normalizeMobileDigits('+91 98765-43210'), '919876543210');
    });

    test('mobile key is stable for Firestore lookup', () {
      expect(mobileKeyFromDigits('9876543210'), '919876543210');
    });
  });
}
