part of '../../main.dart';

class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});
  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  final u = TextEditingController(), p = TextEditingController();
  @override
  void dispose() {
    u.dispose();
    p.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final profile = await runBusy(
      context,
      () => adminLoginDirect(u.text, p.text),
    );
    if (!mounted) return;
    if (profile == null) return;
    AppSession.set(
      newRole: 'admin',
      newUid: profile['uid'] ?? 'admin',
      newName: profile['username'] ?? 'admin',
      newProfile: profile,
    );
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      page(const AdminHome()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext c) => form(c, 'Admin Login', [
    TextField(controller: u, decoration: dec('Username')),
    TextField(controller: p, obscureText: true, decoration: dec('Password')),
    FilledButton(onPressed: login, child: Text(t(c, 'login'))),
    TextButton(
      onPressed: () => resetAdminDialog(c, u.text),
      child: const Text('Forgot / reset password'),
    ),
    TextButton(
      onPressed: () => forgotAdminPasswordDialog(c, u.text),
      child: const Text('Forgot Password?'),
    ),
  ]);
}

Future<void> resetAdminDialog(BuildContext c, String username) async {
  if (!c.mounted) return;
  final current = TextEditingController(),
      pass = TextEditingController(),
      confirm = TextEditingController();
  await showDialog(
    context: c,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Reset admin password'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: current,
            obscureText: true,
            decoration: dec('Current password'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: pass,
            obscureText: true,
            decoration: dec('New password'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: confirm,
            obscureText: true,
            decoration: dec('Confirm password'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            if (!c.mounted) return;
            final ok = await runBusy(c, () async {
              await resetAdminPasswordDirect(
                username,
                current.text,
                pass.text,
                confirm.text,
              );
              return true;
            });
            if (ok != null && dialogContext.mounted) {
              Navigator.pop(dialogContext);
              if (c.mounted) {
                toast(c, 'Admin password updated successfully.');
              }
            }
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
  current.dispose();
  pass.dispose();
  confirm.dispose();
}

Future<void> forgotAdminPasswordDialog(BuildContext c, String username) async {
  if (!c.mounted) return;
  final secret = TextEditingController(),
      pass = TextEditingController(),
      confirm = TextEditingController();
  await showDialog(
    context: c,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Forgot Password?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: secret, decoration: dec('Secret word')),
          const SizedBox(height: 10),
          TextField(
            controller: pass,
            obscureText: true,
            decoration: dec('New password'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: confirm,
            obscureText: true,
            decoration: dec('Confirm password'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            if (!c.mounted) return;
            final ok = await runBusy(c, () async {
              await forgotAdminPasswordDirect(
                username,
                secret.text,
                pass.text,
                confirm.text,
              );
              return true;
            });
            if (ok == null || !dialogContext.mounted) return;
            secret.clear();
            pass.clear();
            confirm.clear();
            Navigator.pop(dialogContext);
            if (c.mounted) {
              toast(c, 'Password reset successful. Login with new password.');
            }
          },
          child: const Text('Reset'),
        ),
      ],
    ),
  );
  secret.dispose();
  pass.dispose();
  confirm.dispose();
}
