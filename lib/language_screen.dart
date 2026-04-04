import 'package:flutter/material.dart';
import 'app_data.dart';
import 'role_screen.dart';
import 'translations.dart';

class LanguageScreen extends StatelessWidget {
  final List<Map<String, String>> languages = [
    {'name': 'English', 'code': 'en'},
    {'name': 'తెలుగు', 'code': 'te'},
    {'name': 'हिन्दी', 'code': 'hi'},
    {'name': 'தமிழ்', 'code': 'ta'},
    {'name': 'ಕನ್ನಡ', 'code': 'kn'},
  ];

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        String lang = AppData.selectedLanguage;
        return Scaffold(
          appBar: AppBar(
            title: Text(translations[lang]!['choose_language']!),
            backgroundColor: Color(0xFF1A7A55),
            foregroundColor: Colors.white,
          ),
          body: Padding(
            padding: EdgeInsets.all(20),
            child: GridView.builder(
              itemCount: languages.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                bool selected =
                    AppData.selectedLanguage == languages[index]['code'];
                return GestureDetector(
                  onTap: () {
                    AppData.selectedLanguage = languages[index]['code']!;
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => RoleScreen()),
                    );
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? Color(0xFF1A7A55).withOpacity(0.1)
                          : Colors.white,
                      border: Border.all(
                        color: selected
                            ? Color(0xFF1A7A55)
                            : Colors.grey.shade300,
                        width: selected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      languages[index]['name']!,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: selected ? Color(0xFF1A7A55) : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}