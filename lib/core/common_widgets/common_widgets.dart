part of '../../main.dart';

class DocList extends StatelessWidget {
  final Stream<QuerySnapshot> stream;
  final String empty;
  final bool Function(QueryDocumentSnapshot)? include;
  final Widget Function(QueryDocumentSnapshot) item;
  const DocList({
    super.key,
    required this.stream,
    required this.empty,
    this.include,
    required this.item,
  });
  @override
  Widget build(BuildContext c) => StreamBuilder<QuerySnapshot>(
    stream: stream,
    builder: (_, s) {
      if (s.hasError) return Center(child: Text(empty));
      if (!s.hasData) return const Center(child: CircularProgressIndicator());
      final docs = include == null
          ? s.data!.docs
          : s.data!.docs.where(include!).toList();
      if (docs.isEmpty) return Center(child: Text(empty));
      return ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: docs.length,
        itemBuilder: (_, i) => item(docs[i]),
      );
    },
  );
}

Widget line(Map<String, dynamic> x, String label, String key) => ListTile(
  dense: true,
  title: Text(label),
  subtitle: Text('${x[key] ?? '-'}'),
);
Widget dropdown(
  String label,
  String value,
  List<String> options,
  ValueChanged<String?> onChanged,
) => DropdownButtonFormField<String>(
  decoration: dec(label),
  value: value,
  items: options
      .map((v) => DropdownMenuItem(value: v, child: Text(v)))
      .toList(),
  onChanged: onChanged,
);
Widget form(BuildContext c, String title, List<Widget> kids) => Scaffold(
  appBar: AppBar(title: Text(title)),
  body: Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: ListView(
        padding: const EdgeInsets.all(20),
        shrinkWrap: true,
        children: kids.expand((w) => [w, const SizedBox(height: 12)]).toList(),
      ),
    ),
  ),
);
