import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

  Future<void> _support(String productId) async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Support purchases are available only on Android through Google Play.')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await _billing.init(
        onPremiumActivated: () {},
        onError: (msg) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
        },
      );

      await _billing.buy(productId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thank you for supporting Aliapps1!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _billing.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Support', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFFFD700)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Icon(Icons.favorite, color: Color(0xFFFFD700), size: 90),
            const SizedBox(height: 24),
            const Text(
              'Thank you for your support!',
              style: TextStyle(color: Colors.white70, fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 50),

            _supportButton(
              icon: '☕',
              text: 'Support \$5',
              color: const Color(0xFFFF9800),
              onTap: () => _support(BillingService.support5Id),
            ),

            const SizedBox(height: 16),

            _supportButton(
              icon: '❤️',
              text: 'Support \$10',
              color: const Color(0xFF00BFA5),
              onTap: () => _support(BillingService.support10Id),
            ),

            const SizedBox(height: 24),

            if (kIsWeb)
              const Text(
                'Support purchases are available only on Android through Google Play.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white38, fontSize: 13),
              ),
          ],
        ),
      ),
    );
  }

  Widget _supportButton({
    required String icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 68,
      child: ElevatedButton(
        onPressed: _loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        child: _loading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                '$icon  $text',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
