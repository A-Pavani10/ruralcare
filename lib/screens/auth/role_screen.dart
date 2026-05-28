part of '../../main.dart';

class RoleScreen extends StatelessWidget {
  const RoleScreen({super.key});
  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: Text(t(c, 'role'))),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        role(c, Icons.person, t(c, 'patient'), const PatientEntry()),
        role(c, Icons.medical_services, t(c, 'staff'), const StaffLogin()),
        role(c, Icons.admin_panel_settings, t(c, 'admin'), const AdminLogin()),
      ],
    ),
  );
  Widget role(BuildContext c, IconData icon, String text, Widget next) => Card(
    child: ListTile(
      leading: Icon(icon, color: green),
      title: Text(text),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.push(c, page(next)),
    ),
  );
}
