part of '../../main.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});
  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int i = 0;
  @override
  Widget build(BuildContext c) => shell(
    'Admin Dashboard',
    i,
    (v) {
      if (!mounted) return;
      setState(() => i = v);
    },
    const [
      AdminSummary(),
      AdminPatients(),
      AdminStaff(),
      AdminServices(),
      RequestMonitor(),
      Notifications(),
    ],
    const [
      NavigationDestination(icon: Icon(Icons.dashboard), label: 'Home'),
      NavigationDestination(icon: Icon(Icons.people), label: 'Patients'),
      NavigationDestination(icon: Icon(Icons.badge), label: 'Staff'),
      NavigationDestination(
        icon: Icon(Icons.medical_services),
        label: 'Services',
      ),
      NavigationDestination(icon: Icon(Icons.monitor_heart), label: 'Monitor'),
      NavigationDestination(icon: Icon(Icons.notifications), label: 'Alerts'),
    ],
  );
}
