import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// iOS 苹果内购 MethodChannel（与鸿蒙华为桥对称）。
/// 原生侧接 StoreKit；debug 未接好时返回可被 BFF dev 验单接受的伪凭证。
class AppleIapBridge {
  AppleIapBridge._();
  static const _channel = MethodChannel('wys.membership/apple_iap');

  static bool get isIOS {
    if (kIsWeb) return false;
    try {
      return Platform.isIOS;
    } catch (_) {
      return defaultTargetPlatform == TargetPlatform.iOS;
    }
  }

  static Future<ApplePurchaseResult> buySubscription({
    required String productId,
  }) async {
    final raw = await _channel.invokeMethod<Map<dynamic, dynamic>>(
      'buySubscription',
      {'productId': productId},
    );
    if (raw == null) {
      throw PlatformException(code: 'empty', message: '苹果内购无返回');
    }
    return ApplePurchaseResult(
      productId: '${raw['productId'] ?? productId}',
      transactionId: '${raw['transactionId'] ?? ''}',
      originalTransactionId: '${raw['originalTransactionId'] ?? ''}',
      receiptData: '${raw['receiptData'] ?? ''}',
    );
  }

  static Future<void> completePurchase({
    required String transactionId,
  }) async {
    await _channel.invokeMethod<void>('completePurchase', {
      'transactionId': transactionId,
    });
  }

  static Future<List<ApplePurchaseResult>> restorePurchases() async {
    final raw = await _channel.invokeMethod<List<dynamic>>('restorePurchases');
    if (raw == null) return const [];
    return raw.map((e) {
      final m = Map<dynamic, dynamic>.from(e as Map);
      return ApplePurchaseResult(
        productId: '${m['productId'] ?? ''}',
        transactionId: '${m['transactionId'] ?? ''}',
        originalTransactionId: '${m['originalTransactionId'] ?? ''}',
        receiptData: '${m['receiptData'] ?? ''}',
      );
    }).toList();
  }
}

class ApplePurchaseResult {
  const ApplePurchaseResult({
    required this.productId,
    required this.transactionId,
    this.originalTransactionId = '',
    this.receiptData = '',
  });

  final String productId;
  final String transactionId;
  final String originalTransactionId;
  final String receiptData;
}
