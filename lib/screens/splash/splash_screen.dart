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
              'Anantapuram Praja Vaidyasala',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const Text(
              'RuralCare powered by Anantapuram Praja Vaidyasala\nKamalanagar, Anantapur, Andhra Pradesh',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Healthcare services managed by APV Hospital. Not for emergencies.',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w600),
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
