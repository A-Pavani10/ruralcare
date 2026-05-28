part of '../../main.dart';

class StaffProfile extends StatelessWidget {
  final Map<String, dynamic> profile;
  const StaffProfile({super.key, required this.profile});
  @override
  Widget build(BuildContext c) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Card(
        child: Column(
          children: profile.entries
              .map(
                (e) =>
                    ListTile(title: Text(e.key), subtitle: Text('${e.value}')),
              )
              .toList(),
        ),
      ),
      const Text('Profile is read-only. Only Admin can edit staff details.'),
    ],
  );
}
