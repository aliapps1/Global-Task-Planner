import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class PremiumScreen extends StatefulWidget {
  final String lang;
  const PremiumScreen({super.key, required this.lang});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  bool _isPremium = false;
  bool _loading = false;

  final Map<String, Map<String, String>> _tr = {
    'en': {'title': 'Premium', 'monthly': 'Monthly', 'yearly': 'Yearly', 'save': 'Save 40%', 'restore': 'Restore Purchase', 'feature1': 'Remove Ads', 'feature2': 'Unlimited Tasks', 'feature3': 'Priority Support', 'active': 'Premium Active ✓', 'buy': 'Get Premium'},
    'fa': {'title': 'پریمیوم', 'monthly': 'ماهانه', 'yearly': 'سالانه', 'save': '۴۰٪ تخفیف', 'restore': 'بازگردانی خرید', 'feature1': 'حذف تبلیغات', 'feature2': 'کارهای نامحدود', 'feature3': 'پشتیبانی ویژه', 'active': 'پریمیوم فعال است ✓', 'buy': 'خرید پریمیوم'},
    'ar': {'title': 'بريميوم', 'monthly': 'شهري', 'yearly': 'سنوي', 'save': 'وفر 40%', 'restore': 'استعادة الشراء', 'feature1': 'إزالة الإعلانات', 'feature2': 'مهام غير محدودة', 'feature3': 'دعم مميز', 'active': 'بريميوم مفعّل ✓', 'buy': 'احصل على بريميوم'},
    'de': {'title': 'Premium', 'monthly': 'Monatlich', 'yearly': 'Jährlich', 'save': '40% sparen', 'restore': 'Kauf wiederherstellen', 'feature1': 'Werbung entfernen', 'feature2': 'Unbegrenzte Aufgaben', 'feature3': 'Prioritätssupport', 'active': 'Premium aktiv ✓', 'buy': 'Premium kaufen'},
    'fr': {'title': 'Premium', 'monthly': 'Mensuel', 'yearly': 'Annuel', 'save': 'Économisez 40%', 'restore': 'Restaurer l\'achat', 'feature1': 'Supprimer les pubs', 'feature2': 'Tâches illimitées', 'feature3': 'Support prioritaire', 'active': 'Premium actif ✓', 'buy': 'Obtenir Premium'},
    'pt': {'title': 'Premium', 'monthly': 'Mensal', 'yearly': 'Anual', 'save': 'Economize 40%', 'restore': 'Restaurar compra', 'feature1': 'Remover anúncios', 'feature2': 'Tarefas ilimitadas', 'feature3': 'Suporte prioritário', 'active': 'Premium ativo ✓', 'buy': 'Obter Premium'},
    'ru': {'title': 'Премиум', 'monthly': 'В месяц', 'yearly': 'В год', 'save': 'Скидка 40%', 'restore': 'Восстановить покупку', 'feature1': 'Без рекламы', 'feature2': 'Безлимитные задачи', 'feature3': 'Приоритетная поддержка', 'active': 'Премиум активен ✓', 'buy': 'Купить Премиум'},
    'zh': {'title': '高级版', 'monthly': '每月', 'yearly': '每年', 'save': '节省40%', 'restore': '恢复购买', 'feature1': '去除广告', 'feature2': '无限任务', 'feature3': '优先支持', 'active': '高级版已激活 ✓', 'buy': '获取高级版'},
    'it': {'title': 'Premium', 'monthly': 'Mensile', 'yearly': 'Annuale', 'save': 'Risparmia 40%', 'restore': 'Ripristina acquisto', 'feature1': 'Rimuovi pubblicità', 'feature2': 'Attività illimitate', 'feature3': 'Supporto prioritario', 'active': 'Premium attivo ✓', 'buy': 'Ottieni Premium'},
  'hi': {'title': 'प्रीमियम', 'monthly': 'मासिक', 'yearly': 'वार्षिक', 'save': '40% बचाएं', 'restore': 'खरीद पुनर्स्थापित करें', 'feature1': 'विज्ञापन हटाएं', 'feature2': 'असीमित कार्य', 'feature3': 'प्राथमिकता समर्थन', 'active': 'प्रीमियम सक्रिय ✓', 'buy': 'प्रीमियम प्राप्त करें'},
'bn': {'title': 'প্রিমিয়াম', 'monthly': 'মাসিক', 'yearly': 'বার্ষিক', 'save': '40% সাশ্রয়', 'restore': 'ক্রয় পুনরুদ্ধার', 'feature1': 'বিজ্ঞাপন সরান', 'feature2': 'সীমাহীন কাজ', 'feature3': 'অগ্রাধিকার সহায়তা', 'active': 'প্রিমিয়াম সক্রিয় ✓', 'buy': 'প্রিমিয়াম পান'},
  };

  Map<String, String> get t => _tr[widget.lang] ?? _tr['en']!;

  bool get isRtl => ['ar', 'fa'].contains(widget.lang);

  String _selPlan = 'yearly';

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
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            const SizedBox(height: 10),

            // آیکون و عنوان
            const Icon(Icons.workspace_premium, color: Color(0xFFFFD700), size: 80),
            const SizedBox(height: 12),
            Text('Global Task Planner', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(t['title']!, style: const TextStyle(color: Color(0xFFFFD700), fontSize: 16)),
            const SizedBox(height: 30),

            // امکانات
            _feature(Icons.block, t['feature1']!),
            _feature(Icons.all_inclusive, t['feature2']!),
            _feature(Icons.star, t['feature3']!),
            const SizedBox(height: 30),

            // انتخاب پلن
            Row(children: [
              Expanded(child: _planCard('monthly', '\$4.99', t['monthly']!, null)),
              const SizedBox(width: 12),
              Expanded(child: _planCard('yearly', '\$35.99', t['yearly']!, t['save']!)),
            ]),
            const SizedBox(height: 24),

            // دکمه خرید
            if (_isPremium)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(t['active']!, style: const TextStyle(color: Colors.green, fontSize: 16)),
                ]),
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _purchase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : Text(t['buy']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            const SizedBox(height: 12),

            // بازگردانی خرید
            TextButton(
              onPressed: _restore,
              child: Text(t['restore']!, style: const TextStyle(color: Colors.white54)),
            ),
            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }

  Widget _feature(IconData icon, String label) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(children: [
      Icon(icon, color: const Color(0xFFFFD700), size: 22),
      const SizedBox(width: 12),
      Text(label, style: const TextStyle(color: Colors.white, fontSize: 15)),
    ]),
  );

  Widget _planCard(String plan, String price, String label, String? badge) {
    final selected = _selPlan == plan;
    return GestureDetector(
      onTap: () => setState(() => _selPlan = plan),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFD700).withOpacity(0.15) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? const Color(0xFFFFD700) : Colors.white24, width: selected ? 2 : 1),
        ),
        child: Column(children: [
          if (badge != null) Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: const Color(0xFFFFD700), borderRadius: BorderRadius.circular(8)),
            child: Text(badge, style: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
          if (badge != null) const SizedBox(height: 8),
          Text(price, style: TextStyle(color: selected ? const Color(0xFFFFD700) : Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ]),
      ),
    );
  }

  Future<void> _purchase() async {
    setState(() => _loading = true);
    // TODO: اتصال واقعی به Google Play Billing
    await Future.delayed(const Duration(seconds: 1));
    setState(() { _loading = false; _isPremium = true; });
  }

  Future<void> _restore() async {
    // TODO: بازگردانی خرید از Google Play
  }
}
