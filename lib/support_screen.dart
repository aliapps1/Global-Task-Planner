import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'billing_service.dart';

class SupportScreen extends StatefulWidget {
  final String lang;
  const SupportScreen({super.key, required this.lang});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final BillingService _billing = BillingService();
  bool _loading = false;

  final Map<String, Map<String, String>> _tr = {
    'en': {'title':'Support','thanks':'Thank you for your support!','support5':'Support \$5','support10':'Support \$10','email':'Send Email','rate':'Rate the App','play':'Google Play','web':'Support purchases are available only on Android through Google Play.','done':'Thank you for supporting Aliapps1!'},
    'pt': {'title':'Suporte','thanks':'Obrigado pelo seu apoio!','support5':'Apoiar \$5','support10':'Apoiar \$10','email':'Enviar e-mail','rate':'Avaliar app','play':'Google Play','web':'As compras de suporte estão disponíveis apenas no Android pelo Google Play.','done':'Obrigado por apoiar a Aliapps1!'},
    'fr': {'title':'Support','thanks':'Merci pour votre soutien !','support5':'Soutenir \$5','support10':'Soutenir \$10','email':'Envoyer un e-mail','rate':'Noter l’app','play':'Google Play','web':'Les achats de soutien sont disponibles uniquement sur Android via Google Play.','done':'Merci de soutenir Aliapps1 !'},
    'de': {'title':'Support','thanks':'Danke für deine Unterstützung!','support5':'Unterstützen \$5','support10':'Unterstützen \$10','email':'E-Mail senden','rate':'App bewerten','play':'Google Play','web':'Support-Käufe sind nur auf Android über Google Play verfügbar.','done':'Danke für deine Unterstützung von Aliapps1!'},
    'ru': {'title':'Поддержка','thanks':'Спасибо за поддержку!','support5':'Поддержать \$5','support10':'Поддержать \$10','email':'Отправить email','rate':'Оценить приложение','play':'Google Play','web':'Покупки поддержки доступны только на Android через Google Play.','done':'Спасибо за поддержку Aliapps1!'},
    'zh': {'title':'支持','thanks':'感谢你的支持！','support5':'支持 \$5','support10':'支持 \$10','email':'发送邮件','rate':'评价应用','play':'Google Play','web':'支持购买仅可在 Android 通过 Google Play 使用。','done':'感谢你支持 Aliapps1！'},
    'it': {'title':'Supporto','thanks':'Grazie per il tuo supporto!','support5':'Supporta \$5','support10':'Supporta \$10','email':'Invia email','rate':'Valuta l’app','play':'Google Play','web':'Gli acquisti di supporto sono disponibili solo su Android tramite Google Play.','done':'Grazie per supportare Aliapps1!'},
    'ar': {'title':'الدعم','thanks':'شكراً لدعمك!','support5':'ادعم \$5','support10':'ادعم \$10','email':'إرسال بريد','rate':'قيّم التطبيق','play':'Google Play','web':'مشتريات الدعم متاحة فقط على أندرويد عبر Google Play.','done':'شكراً لدعم Aliapps1!'},
    'fa': {'title':'پشتیبانی','thanks':'از حمایت شما سپاسگزاریم!','support5':'حمایت \$5','support10':'حمایت \$10','email':'ارسال ایمیل','rate':'امتیاز به برنامه','play':'Google Play','web':'خریدهای حمایتی فقط در نسخه اندروید از طریق Google Play فعال است.','done':'از حمایت شما از Aliapps1 سپاسگزاریم!'},
    'hi': {'title':'सहायता','thanks':'आपके समर्थन के लिए धन्यवाद!','support5':'समर्थन \$5','support10':'समर्थन \$10','email':'ईमेल भेजें','rate':'ऐप रेट करें','play':'Google Play','web':'समर्थन खरीदारी केवल Android पर Google Play के माध्यम से उपलब्ध है।','done':'Aliapps1 का समर्थन करने के लिए धन्यवाद!'},
    'bn': {'title':'সহায়তা','thanks':'আপনার সহায়তার জন্য ধন্যবাদ!','support5':'সহায়তা \$5','support10':'সহায়তা \$10','email':'ইমেইল পাঠান','rate':'অ্যাপ রেট করুন','play':'Google Play','web':'সহায়তা ক্রয় শুধুমাত্র Android-এ Google Play এর মাধ্যমে উপলব্ধ।','done':'Aliapps1 সমর্থন করার জন্য ধন্যবাদ!'},
  };

  Map<String, String> get t => _tr[widget.lang] ?? _tr['en']!;
  bool get isRtl => ['ar', 'fa'].contains(widget.lang);

  Future<void> _support(String productId) async {
    if (kIsWeb) {
      _msg(t['web']!);
      return;
    }

    setState(() => _loading = true);

    try {
      await _billing.init(
        onPremiumActivated: () {},
        onError: (msg) => _msg(msg),
      );
      await _billing.buy(productId);
      _msg(t['done']!);
    } catch (e) {
      _msg(e.toString());
    }

    if (mounted) setState(() => _loading = false);
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _msg(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  void dispose() {
    _billing.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(t['title']!, style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Color(0xFFFFD700)),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 35),
              const Icon(Icons.favorite, color: Color(0xFFFFD700), size: 90),
              const SizedBox(height: 24),
              Text(t['thanks']!, style: const TextStyle(color: Colors.white70, fontSize: 20), textAlign: TextAlign.center),
              const SizedBox(height: 45),

              _supportButton('☕', t['support5']!, const Color(0xFFFF9800), () => _support(BillingService.support5Id)),
              const SizedBox(height: 14),
              _supportButton('❤️', t['support10']!, const Color(0xFF00BFA5), () => _support(BillingService.support10Id)),

              const SizedBox(height: 30),

              _normalButton(Icons.email, t['email']!, () => _openUrl('mailto:globaltb.app@gmail.com')),
              const SizedBox(height: 14),
              _normalButton(Icons.star, t['rate']!, () => _openUrl('https://play.google.com/store/apps/details?id=com.aliapps1.globaltaskplanner')),
              const SizedBox(height: 14),
              _normalButton(Icons.shop, t['play']!, () => _openUrl('https://play.google.com/store/apps/details?id=com.aliapps1.globaltaskplanner')),

              const SizedBox(height: 24),

              if (kIsWeb)
                Text(t['web']!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white38, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _supportButton(String icon, String text, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 66,
      child: ElevatedButton(
        onPressed: _loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        child: _loading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text('$icon  $text', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _normalButton(IconData icon, String text, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white),
        label: Text(text, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.10),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
