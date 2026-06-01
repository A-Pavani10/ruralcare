# RuralCare Firebase Setup and Database Guide

## Firebase Project

Use Firebase project id `ruralcare-production` or create your own production Firebase project. Register Android package:

```text
com.pavani.ruralcare
```

Download a fresh `google-services.json` from Firebase Console after registering this package.

## Required Firebase Products

- Firebase Authentication with Anonymous provider enabled for the current client-side session model.
- Cloud Firestore.
- Firebase Cloud Messaging is optional; Firestore notifications work without push delivery.

## Collection Names

- `adminAccounts`
- `staff`
- `patients`
- `patientMobiles`
- `hospitals`
- `services`
- `requests`
- `notifications`
- `loginAttempts`

## Credential Storage

The app no longer stores raw admin/staff passwords or patient PINs. It stores salted SHA-256 hashes:

- `adminAccounts.passwordHash`
- `staff.passwordHash`
- `patients.pinHash`

Existing legacy plaintext fields are migrated and deleted after successful login.

## Recovery

The old hardcoded recovery word was removed. Admin recovery is disabled unless a private phrase is supplied at build/run time:

```powershell
flutter run --dart-define=RURALCARE_ADMIN_RECOVERY_SECRET=your-private-phrase
flutter build appbundle --release --dart-define=RURALCARE_ADMIN_RECOVERY_SECRET=your-private-phrase
```

## Patient Data

New registrations store `aadhaarMasked` and `aadhaarLast4`, not plaintext Aadhaar. The registration screen records consent before saving health details.

## Default Hospital

The app seeds this hospital identity if it is missing:

```json
{
  "hospitalId": "APV001",
  "hospitalName": "Anantapuram Praja Vaidyasala",
  "shortName": "APV Hospital",
  "city": "Anantapur",
  "state": "Andhra Pradesh",
  "country": "India",
  "isActive": true
}
```

## Deployment

Run from `D:\ruralcare`:

```powershell
flutter pub get
firebase login
firebase use --add
firebase deploy --only firestore:rules,firestore:indexes
flutter run
```

## Production Note

For a stronger public launch, replace client-side credential verification with Firebase Auth users plus custom claims or a trusted backend. The current code is safer than the demo version, but true role isolation should be enforced by server-managed identities.
