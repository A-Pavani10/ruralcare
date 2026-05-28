part of '../../main.dart';

class PatientEntry extends StatelessWidget {
  const PatientEntry({super.key});
  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: Text(t(c, 'patient'))),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FilledButton.icon(
            onPressed: () => Navigator.push(c, page(const PatientLogin())),
            icon: const Icon(Icons.pin),
            label: const Text('Login with PIN'),
          ),
          OutlinedButton.icon(
            onPressed: () => Navigator.push(c, page(const PatientRegister())),
            icon: const Icon(Icons.person_add),
            label: Text(t(c, 'register')),
          ),
        ],
      ),
    ),
  );
}
