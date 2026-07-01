import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  final String lang;
  const AboutScreen({super.key, required this.lang});

  final Map<String, Map<String, String>> _tr = const {
    'en': {'title': 'About', 'version': 'Version', 'dev': 'Developer', 'privacy': 'Privacy Policy', 'terms': 'Terms of Use'},
    'fa': {'title': 'درباره', 'version': 'نسخه', 'dev': 'توسعه‌دهنده', 'privacy': 'حریم خصوصی', 'terms': 'شرایط استفاده'},
    'ar': {'title': 'حول', 'version': 'الإصدار', 'dev': 'المطور', 'privacy': 'سياسة الخصوصية', 'terms': 'شروط الاستخدام'},
    'de': {'title': 'Über', 'version': 'Version', 'dev': 'Entwickler', 'privacy': 'Datenschutz', 'terms': 'Nutzungsbedingungen'},
    'fr': {'title': 'À propos', 'version': 'Version', 'dev': 'Développeur', 'privacy': 'Confidentialité', 'terms': 'Conditions d\'utilisation'},
    'pt': {'title': 'Sobre', 'version': 'Versão', 'dev': 'Desenvolvedor', 'privacy': 'Privacidade', 'terms': 'Termos de uso'},
    'ru': {'title': 'О приложении', 'version': 'Версия', 'dev': 'Разработчик', 'privacy': 'Конфиденциальность', 'terms': 'Условия использования'},
    'zh': {'title': '关于', 'version': '版本', 'dev': '开发者', 'privacy': '隐私政策', 'terms': '使用条款'},
    'it': {'title': 'Informazioni', 'version': 'Versione', 'dev': 'Sviluppatore', 'privacy': 'Privacy', 'terms': 'Termini di utilizzo'},
    'hi': {'title': 'के बारे में', 'version': 'संस्करण', 'dev': 'डेवलपर', 'privacy': 'गोपनीयता नीति', 'terms': 'उपयोग की शर्तें'},
    'bn': {'title': 'সম্পর্কে', 'version': 'সংস্করণ', 'dev': 'ডেভেলপার', 'privacy': 'গোপনীয়তা নীতি', 'terms': 'ব্যবহারের শর্তাবলী'},
  };

  Map<String, String> get t => _tr[lang] ?? _tr['en']!;
  bool get isRtl => ['ar', 'fa'].contains(lang);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(t['title']!, style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
          iconTheme: const IconThemeData(color: Color(0xFFFFD700)),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            const SizedBox(height: 20),
            Image.asset('assets/icons/gtp_icon_512.png', width: 80, height: 80),
            const SizedBox(height: 12),
            const Text('Global Task Planner', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('${t['version']!}: 1.1.0', style: const TextStyle(color: Colors.white54, fontSize: 14)),
            const SizedBox(height: 4),
            Text('${t['dev']!}: Aliapps1', style: const TextStyle(color: Colors.white54, fontSize: 14)),
            const SizedBox(height: 40),
            _item(Icons.privacy_tip, t['privacy']!),
            const SizedBox(height: 14),
            _item(Icons.description, t['terms']!),
          ]),
        ),
      ),
    );
  }

  Widget _item(IconData icon, String label) => SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white10,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
  );
}
