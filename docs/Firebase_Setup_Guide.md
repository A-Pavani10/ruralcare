# RuralCare Firebase Setup and Database Guide

## Firebase project names
Use a Firebase project name like `RuralCare Demo` and a project id like `ruralcare-demo`. The app uses these Firestore collection names exactly:

- `adminAccounts`
- `staff`
- `patients`
- `services`
- `requests`
- `notifications`
- `auditLogs`
- `loginAttempts`

## Required Firebase products on Spark plan
Enable only:

- Firebase Authentication
- Cloud Firestore
- Firebase Cloud Messaging, optional for later device push work

Cloud Functions are not required and were removed.

## Authentication setup
Enable these Firebase Auth providers:

- Phone provider for Patient OTP login and registration.
- Anonymous provider for Admin and Staff demo sessions after Firestore credential verification.

Admin and Staff credentials are stored directly in Firestore for demo purpose only.

## Default admin for demo
The app creates the first admin automatically the first time you login with:

```text
username: admin
password: Admin@12345
security answer: hospital
```

After login, you can create staff users from the Admin Staff screen.

## First-time setup commands
Run these from `D:\ruralcare`:

```powershell
flutter pub get
firebase login
firebase use --add
flutterfire configure
firebase deploy --only firestore:rules,firestore:indexes
flutter run
```

## Database fields
`adminAccounts`: uid, username, usernameLower, password, securityQuestion, securityAnswer, createdAt, updatedAt.

`patients`: uid, fullName, mobile, gender, dob, aadhaarMasked, aadhaarCipherText, address, bloodGroup, email, fcmToken, createdAt, updatedAt.

`staff`: uid, fullName, designation, staffId, username, usernameLower, password, mobile, age, department, active, deleted, createdAt, updatedAt.

`services`: name, charge, active, createdAt, updatedAt.

`requests`: patientUid, patientName, patientMobile, patientAddress, recipientType, recipientName, recipientAge, serviceId, serviceName, serviceCharge, preferredAt, status, claimed, assignedStaffUid, assignedStaffName, assignedStaffMobile, rejectionReason, proposedAt, proposedMessage, completedAt, createdAt, updatedAt.

`notifications`: userUid, role, title, body, requestId, read, createdAt.

`loginAttempts`: role, username, success, reason, createdAt.

## Demo security note
This Spark-plan version intentionally stores Admin and Staff passwords in Firestore so the app can run without Cloud Functions. Use this only for project/demo submission. For real production, move password verification and Aadhaar encryption to a trusted backend.
