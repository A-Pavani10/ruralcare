part of '../../main.dart';

class StaffLogin extends StatefulWidget {
  const StaffLogin({super.key});
  @override
  State<StaffLogin> createState() => _StaffLoginState();
}

class _StaffLoginState extends State<StaffLogin> {
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
      () => staffLoginDirect(u.text, p.text),
    );
    if (!mounted) return;
    if (profile == null) return;
    AppSession.set(
      newRole: 'staff',
      newUid: profile['uid'],
      newName: profile['fullName'] ?? profile['username'] ?? 'Staff',
      newProfile: profile,
    );
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      page(StaffHome(profile: profile)),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext c) => form(c, 'Staff Login', [
    TextField(controller: u, decoration: dec('Username')),
    TextField(controller: p, obscureText: true, decoration: dec('Password')),
    FilledButton(onPressed: login, child: Text(t(c, 'login'))),
    const Text('Staff cannot self-register. Contact Admin for credentials.'),
  ]);
}
