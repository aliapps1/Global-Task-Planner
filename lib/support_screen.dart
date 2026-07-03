import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
class SupportScreen extends StatelessWidget {
  final String lang;
  const SupportScreen({super.key, required this.lang});

  final Map<String, Map<String, String>> _tr = const {
    'en': {'title': 'Support', 'email': 'Send Email', 'play': 'Google Play', 'rate': 'Rate the App', 'share': 'Share App', 'thanks': 'Thank you for your support!'},
    'fa': {'title': 'پشتیبانی', 'email': 'ارسال ایمیل', 'play': 'گوگل پلی', 'rate': 'امتیاز دهید', 'share': 'اشتراک‌گذاری', 'thanks': 'ممنون از حمایت شما!'},
    'ar': {'title': 'الدعم', 'email': 'إرسال بريد', 'play': 'جوجل بلاي', 'rate': 'قيّم التطبيق', 'share': 'مشاركة', 'thanks': 'شكراً لدعمك!'},
    'de': {'title': 'Support', 'email': 'E-Mail senden', 'play': 'Google Play', 'rate': 'App bewerten', 'share': 'App teilen', 'thanks': 'Danke für Ihre Unterstützung!'},
    'fr': {'title': 'Support', 'email': 'Envoyer email', 'play': 'Google Play', 'rate': 'Noter l\'app', 'share': 'Partager', 'thanks': 'Merci pour votre soutien!'},
    'pt': {'title': 'Suporte', 'email': 'Enviar email', 'play': 'Google Play', 'rate': 'Avaliar app', 'share': 'Compartilhar', 'thanks': 'Obrigado pelo seu apoio!'},
    'ru': {'title': 'Поддержка', 'email': 'Написать email', 'play': 'Google Play', 'rate': 'Оценить', 'share': 'Поделиться', 'thanks': 'Спасибо за поддержку!'},
    'zh': {'title': '支持', 'email': '发送邮件', 'play': 'Google Play', 'rate': '评分', 'share': '分享', 'thanks': '感谢您的支持！'},
    'it': {'title': 'Supporto', 'email': 'Invia email', 'play': 'Google Play', 'rate': 'Valuta l\'app', 'share': 'Condividi', 'thanks': 'Grazie per il tuo supporto!'},
    'hi': {'title': 'सहायता', 'email': 'ईमेल भेजें', 'play': 'गूगल प्ले'، 'rate': 'ऐप रेट करें', 'share': 'साझा करें', 'thanks': 'आपके समर्थन के लिए धन्यवाद!'},
'bn': {'title': 'সহায়তা', 'email': 'ইমেইল পাঠান', 'play': 'গুগল প্লে', 'rate': 'অ্যাপ রেট করুন', 'share': 'শেয়ার করুন', 'thanks': 'আপনার সমর্থনের জন্য ধন্যবাদ!'},
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
            const Icon(Icons.favorite, color: Color(0xFFFFD700), size: 70),
            const SizedBox(height: 12),
            Text(t['thanks']!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 40),
            _btn(Icons.email, t['email']!, 'mailto:Globaltb.app@gmail.com', context),
            const SizedBox(height: 14),
            _btn(Icons.star, t['rate']!, 'https://play.google.com/store/apps/details?id=com.aliapps1.globaltaskplanner', context),
            const SizedBox(height: 14),
            _btn(Icons.shop, t['play']!, 'https://play.google.com/store/apps/developer?id=Aliapps1', context),
          ]),
        ),
      ),
    );
  }

  Widget _btn(IconData icon, String label, String url, BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
},
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
}
