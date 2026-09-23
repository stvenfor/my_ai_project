import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 鸿蒙华为 IAP MethodChannel。原生未接好时 createPurchase 抛错，便于联调提示。
class HuaweiIapBridge {
  HuaweiIapBridge._();
  static const _channel = MethodChannel('wys.membership/huawei_iap');

  static bool get isOhos {
    if (kIsWeb) return false;
    try {
      return Platform.operatingSystem.toLowerCase() == 'ohos';
    } catch (_) {
      return defaultTargetPlatform.name == 'ohos';
    }
  }

  static Future<HuaweiPurchaseResult> createPurchase({
    required String productId,
  }) async {
    final raw = await _channel.invokeMethod<Map<dynamic, dynamic>>(
      'createPurchase',
      {'productId': productId, 'productType': 'AUTORENEWABLE'},
    );
    if (raw == null) {
      throw PlatformException(code: 'empty', message: '华为内购无返回');
    }
    return HuaweiPurchaseResult(
      productId: '${raw['productId'] ?? productId}',
      purchaseToken: '${raw['purchaseToken'] ?? ''}',
      purchaseOrderId: '${raw['purchaseOrderId'] ?? ''}',
      subscriptionId: '${raw['subscriptionId'] ?? ''}',
      jwsPurchaseOrder: '${raw['jwsPurchaseOrder'] ?? ''}',
    );
  }

  static Future<void> finishPurchase({
    required String productId,
    required String purchaseToken,
    required String purchaseOrderId,
  }) async {
    await _channel.invokeMethod<void>('finishPurchase', {
      'productId': productId,
      'purchaseToken': purchaseToken,
      'purchaseOrderId': purchaseOrderId,
      'productType': 'AUTORENEWABLE',
    });
  }

  static Future<List<HuaweiPurchaseResult>> queryPurchases() async {
    final raw = await _channel.invokeMethod<List<dynamic>>('queryPurchases', {
      'productType': 'AUTORENEWABLE',
    });
    if (raw == null) return const [];
    return raw.map((e) {
      final m = Map<dynamic, dynamic>.from(e as Map);
      return HuaweiPurchaseResult(
        productId: '${m['productId'] ?? ''}',
        purchaseToken: '${m['purchaseToken'] ?? ''}',
        purchaseOrderId: '${m['purchaseOrderId'] ?? ''}',
        subscriptionId: '${m['subscriptionId'] ?? ''}',
        jwsPurchaseOrder: '${m['jwsPurchaseOrder'] ?? ''}',
      );
    }).toList();
  }
}

class HuaweiPurchaseResult {
  const HuaweiPurchaseResult({
    required this.productId,
    required this.purchaseToken,
    required this.purchaseOrderId,
    this.subscriptionId = '',
    this.jwsPurchaseOrder = '',
  });

  final String productId;
  final String purchaseToken;
  final String purchaseOrderId;
  final String subscriptionId;
  final String jwsPurchaseOrder;
}
