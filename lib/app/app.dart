part of '../main.dart';

class RuralCareApp extends StatefulWidget {
  const RuralCareApp({super.key});
  @override
  State<RuralCareApp> createState() => _RuralCareAppState();
}

class _RuralCareAppState extends State<RuralCareApp> {
  var lang = 'en';
  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => lang = p.getString('lang') ?? 'en');
  }

  Future<void> setLang(String code) async {
    final p = await SharedPreferences.getInstance();
    await p.setString('lang', code);
    if (!mounted) return;
    setState(() => lang = code);
  }

  @override
  Widget build(BuildContext context) {
    AppScope.configure(language: lang, setLanguage: setLang);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RuralCare',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: green),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class AppScope {
  static String lang = 'en';
  static Future<void> Function(String)? _setLang;

  static void configure({
    required String language,
    required Future<void> Function(String) setLanguage,
  }) {
    lang = language;
    _setLang = setLanguage;
  }

  static Future<void> setLanguage(String code) async {
    final updateLanguage = _setLang;
    if (updateLanguage != null) {
      await updateLanguage(code);
    }
  }
}

const labels = {
  'en': {
    'start': 'Get Started',
    'language': 'Choose Language',
    'role': 'Who are you?',
    'patient': 'Patient',
    'staff': 'Staff',
    'admin': 'Admin',
    'login': 'Login',
    'register': 'Register',
    'save': 'Save',
  },
  'te': {
    'start': 'ప్రారంభించండి',
    'language': 'భాష ఎంచుకోండి',
    'role': 'మీ పాత్ర?',
    'patient': 'రోగి',
    'staff': 'సిబ్బంది',
    'admin': 'అడ్మిన్',
    'login': 'లాగిన్',
    'register': 'నమోదు',
    'save': 'సేవ్',
  },
  'hi': {
    'start': 'शुरू करें',
    'language': 'भाषा चुनें',
    'role': 'आप कौन हैं?',
    'patient': 'मरीज',
    'staff': 'स्टाफ',
    'admin': 'एडमिन',
    'login': 'लॉगिन',
    'register': 'रजिस्टर',
    'save': 'सेव करें',
  },
};
