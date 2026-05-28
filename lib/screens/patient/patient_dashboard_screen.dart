part of '../../main.dart';

class PatientHome extends StatefulWidget {
  const PatientHome({super.key});
  @override
  State<PatientHome> createState() => _PatientHomeState();
}

class _PatientHomeState extends State<PatientHome> {
  int i = 0;
  @override
  Widget build(BuildContext c) => shell(
    'Patient Dashboard',
    i,
    (v) {
      if (!mounted) return;
      setState(() => i = v);
    },
    const [BookService(), PatientRequests(), PatientProfile(), Notifications()],
    const [
      NavigationDestination(icon: Icon(Icons.add_box), label: 'Book'),
      NavigationDestination(icon: Icon(Icons.history), label: 'Requests'),
      NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
      NavigationDestination(icon: Icon(Icons.notifications), label: 'Alerts'),
    ],
  );
}
