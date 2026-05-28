part of '../../main.dart';

String t(BuildContext c, String k) =>
    labels[AppScope.lang]?[k] ?? labels['en']![k] ?? k;
String when(dynamic v) {
  DateTime? d;
  if (v is Timestamp) d = v.toDate();
  if (v is DateTime) d = v;
  return d == null ? '-' : fmt.format(d.toLocal());
}

String activePatientUid() =>
    AppSession.role == 'patient' && AppSession.uid.isNotEmpty
    ? AppSession.uid
    : auth.currentUser?.uid ?? '';

InputDecoration dec(String label) => InputDecoration(
  labelText: label,
  border: const OutlineInputBorder(),
  filled: true,
  fillColor: Colors.white,
);
Route page(Widget w) => MaterialPageRoute(builder: (_) => w);
void toast(BuildContext c, String s) {
  if (!c.mounted) return;
  ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(s)));
}

String friendlyError(Object error) {
  final text = error.toString();
  if (text.contains('permission-denied') ||
      text.contains('cloud_firestore/permission-denied')) {
    return 'Please login again to continue.';
  }
  return text.replaceFirst('Exception: ', '');
}

Future<T?> runBusy<T>(BuildContext c, Future<T> Function() task) async {
  if (!c.mounted) return null;
  showDialog(
    context: c,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );
  try {
    return await task();
  } on FirebaseAuthException catch (e) {
    toast(c, e.message ?? e.code);
  } catch (e) {
    toast(c, friendlyError(e));
  } finally {
    if (c.mounted) {
      await Navigator.of(c, rootNavigator: true).maybePop();
    }
  }
  return null;
}
