part of '../../main.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});
  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: Text(t(c, 'language'))),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        lang(c, 'English', 'en'),
        lang(c, 'తెలుగు', 'te'),
        lang(c, 'हिन्दी', 'hi'),
      ],
    ),
  );
  Widget lang(BuildContext c, String label, String code) => Card(
    child: ListTile(
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        await AppScope.setLanguage(code);
        if (c.mounted) Navigator.pushReplacement(c, page(const RoleScreen()));
      },
    ),
  );
}
