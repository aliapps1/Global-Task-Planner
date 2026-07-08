import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BillingService {
  static const String monthlyId = 'premium_monthly';
  static const String yearlyId = 'premium_yearly';

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _sub;

  List<ProductDetails> products = [];
  bool isAvailable = false;

  Future<void> init({
    required void Function() onPremiumActivated,
    required void Function(String message) onError,
  }) async {
    if (kIsWeb) return;

    isAvailable = await _iap.isAvailable();

    if (!isAvailable) {
      onError('Google Play Billing is not available.');
      return;
    }

    final response = await _iap.queryProductDetails({
      monthlyId,
      yearlyId,
    });

    products = response.productDetails;

    _sub = _iap.purchaseStream.listen((purchases) async {
      for (final purchase in purchases) {
        if (purchase.status == PurchaseStatus.purchased ||
            purchase.status == PurchaseStatus.restored) {
          await _activatePremium();
          onPremiumActivated();
        }

        if (purchase.status == PurchaseStatus.error) {
          onError(purchase.error?.message ?? 'Purchase failed.');
        }

        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
      }
    });
  }

  ProductDetails? getProduct(String id) {
    try {
      return products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> buy(String productId) async {
    final product = getProduct(productId);
    if (product == null) {
      throw Exception('Product not found: $productId');
    }

    final param = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: param);
  }

  Future<void> restore() async {
    if (kIsWeb) return;
    await _iap.restorePurchases();
  }

  Future<void> _activatePremium() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('premium_active', true);
  }

  Future<bool> isPremiumActive() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('premium_active') ?? false;
  }

  Future<void> dispose() async {
    await _sub?.cancel();
  }
}
