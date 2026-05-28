part of '../../main.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext c) => Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                color: green,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.local_hospital,
                color: Colors.white,
                size: 64,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'RuralCare Hospital',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Healthcare at home for rural families\nVillage Health Road | +91 90000 00000',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: () => Navigator.push(c, page(const LanguageScreen())),
              icon: const Icon(Icons.arrow_forward),
              label: Text(t(c, 'start')),
            ),
          ],
        ),
      ),
    ),
  );
}
