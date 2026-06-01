# RuralCare Release Checklist

1. Replace `android/key.properties` passwords before production upload.
2. Generate a private upload key and keep it outside public version control for real release use.
3. Register Android package `com.pavani.ruralcare` in Firebase Console.
4. Download a fresh `google-services.json` for `com.pavani.ruralcare`.
5. Configure Firestore rules from `firestore.rules`.
6. Set admin recovery phrase at build time:

   ```bash
   flutter build appbundle --release --dart-define=RURALCARE_ADMIN_RECOVERY_SECRET=your-private-phrase
   ```

7. Add the final privacy policy URL in Google Play Console.
8. Test on at least one physical Android device before production rollout.
