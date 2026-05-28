part of '../../main.dart';

class StaffHome extends StatefulWidget {
  final Map<String, dynamic> profile;
  const StaffHome({super.key, required this.profile});
  @override
  State<StaffHome> createState() => _StaffHomeState();
}

class _StaffHomeState extends State<StaffHome> {
  int i = 0;
  @override
  Widget build(BuildContext c) => shell(
    widget.profile['fullName'] ?? 'Staff',
    i,
    (v) {
      if (!mounted) return;
      setState(() => i = v);
    },
    [
      const StaffIncoming(),
      const StaffTasks(),
      StaffProfile(profile: widget.profile),
      const Notifications(),
    ],
    const [
      NavigationDestination(icon: Icon(Icons.inbox), label: 'Incoming'),
      NavigationDestination(icon: Icon(Icons.task), label: 'Tasks'),
      NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
      NavigationDestination(icon: Icon(Icons.notifications), label: 'Alerts'),
    ],
  );
}
