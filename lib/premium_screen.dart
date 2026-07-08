import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'billing_service.dart';

class PremiumScreen extends StatefulWidget {
  final String lang;
  const PremiumScreen({super.key, required this.lang});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  final BillingService _billing = BillingService();

  bool _isPremium = false;
  bool _loading = true;
  String _selPlan = BillingService.yearlyId;

  final Map<String, Map<String, String>> _tr = {
    'en': {
      'title': 'Premium',
      'monthly': 'Monthly',
      'yearly': 'Yearly',
      'save': 'Save 40%',
      'restore': 'Restore Purchase',
      'feature1': 'Remove Ads',
      'feature2': 'Unlimited Tasks',
      'feature3': 'Priority Support',
      'active': 'Premium Active ✓',
      'buy': 'Get Premium',
      'unavailable': 'Purchases are available only on Android through Google Play.',
    },
    'fa': {
      'title': 'پریمیوم',
      'monthly': 'ماهانه',
      'yearly': 'سالانه',
      'save': '۴۰٪ تخفیف',
      'restore': 'بازگردانی خرید',
      'feature1': 'حذف تبلیغات',
      'feature2': 'کارهای نامحدود',
      'feature3': 'پشتیبانی ویژه',
      'active': 'پریمیوم فعال است ✓',
      'buy': 'خرید پریمیوم',
      'unavailable': 'خرید فقط در نسخه اندروید از طریق Google Play فعال است.',
    },
    'ar': {
      'title': 'بريميوم',
      'monthly': 'شهري',
      'yearly': 'سنوي',
      'save': 'وفر 40%',
      'restore': 'استعادة الشراء',
      'feature1': 'إزالة الإعلانات',
      'feature2': 'مهام غير محدودة',
      'feature3': 'دعم مميز',
      'active': 'بريميوم مفعّل ✓',
      'buy': 'احصل على بريميوم',
      'unavailable': 'الشراء متاح فقط على أندرويد عبر Google Play.',
    },
  };

  Map<String, String> get t => _tr[widget.lang] ?? _tr['en']!;
  bool get isRtl => ['ar', 'fa'].contains(widget.lang);

  @override
  void initState() {
    super.initState();
    _initBilling();
  }

  Future<void> _initBilling() async {
    _isPremium = await _billing.isPremiumActive();

    await _billing.init(
      onPremiumActivated: () {
        if (mounted) {
          setState(() {
            _isPremium = true;
            _loading = false;
          });
        }
      },
      onError: (msg) {
        if (mounted) {
          setState(() => _loading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg)),
          );
        }
      },
    );

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _billing.dispose();
    super.dispose();
  }

  Future<void> _purchase() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t['unavailable']!)),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await _billing.buy(_selPlan);
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _restore() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t['unavailable']!)),
      );
      return;
    }

    await _billing.restore();
  }

  @override
  Widget build(BuildContext context) {
    final monthly = _billing.getProduct(BillingService.monthlyId);
    final yearly = _billing.getProduct(BillingService.yearlyId);

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            t['title']!,
            style: const TextStyle(
              color: Color(0xFFFFD700),
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: const IconThemeData(color: Color(0xFFFFD700)),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Icon(
                Icons.workspace_premium,
                color: Color(0xFFFFD700),
                size: 80,
              ),
              const SizedBox(height: 12),
              const Text(
                'Global Task Planner',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                t['title']!,
                style: const TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 30),

              _feature(Icons.block, t['feature1']!),
              _feature(Icons.all_inclusive, t['feature2']!),
              _feature(Icons.star, t['feature3']!),

              const SizedBox(height: 30),

              Row(
                children: [
                  Expanded(
                    child: _planCard(
                      BillingService.monthlyId,
                      monthly?.price ?? '\$4.99',
                      t['monthly']!,
                      null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _planCard(
                      BillingService.yearlyId,
                      yearly?.price ?? '\$35.99',
                      t['yearly']!,
                      t['save']!,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              if (_isPremium)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        t['active']!,
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.black)
                        : Text(
                            t['buy']!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: _loading ? null : _restore,
                child: Text(
                  t['restore']!,
                  style: const TextStyle(color: Colors.white54),
                ),
              ),

              if (kIsWeb)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    t['unavailable']!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _feature(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFFD700), size: 22),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _planCard(String plan, String price, String label, String? badge) {
    final selected = _selPlan == plan;

    return GestureDetector(
      onTap: () => setState(() => _selPlan = plan),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFFFD700).withOpacity(0.15)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFFFFD700) : Colors.white24,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (badge != null) const SizedBox(height: 8),
            Text(
              price,
              style: TextStyle(
                color: selected ? const Color(0xFFFFD700) : Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
