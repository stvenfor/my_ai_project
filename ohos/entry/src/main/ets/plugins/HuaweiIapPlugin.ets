import { MethodCall, MethodCallHandler, MethodChannel, MethodResult } from '@ohos/flutter_ohos';
import { FlutterPlugin, FlutterPluginBinding } from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/FlutterPlugin';

const TAG = 'HuaweiIapPlugin';
const CHANNEL_NAME = 'wys.membership/huawei_iap';

/**
 * 华为 IAP MethodChannel 占位。
 * 正式联调时在 createPurchase / finishPurchase / queryPurchases 中接入 IAP Kit。
 * 当前 debug 返回可被 BFF 本地验单接受的伪凭证（productId 须与 Go 目录 huawei_product_id 一致）。
 */
export default class HuaweiIapPlugin implements FlutterPlugin, MethodCallHandler {
  private channel: MethodChannel | null = null;

  getUniqueClassName(): string {
    return TAG;
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    const productId = `${call.argument('productId') ?? ''}`;
    switch (call.method) {
      case 'createPurchase': {
        if (!productId) {
          result.error('bad_args', 'productId required', null);
          return;
        }
        // TODO: iap.createPurchase(AUTORENEWABLE)
        result.success({
          productId,
          purchaseToken: `dev-token-${productId}-${Date.now()}`,
          purchaseOrderId: `dev-order-${Date.now()}`,
          subscriptionId: '',
          jwsPurchaseOrder: '',
        });
        break;
      }
      case 'finishPurchase':
        // TODO: iap.finishPurchase
        result.success(null);
        break;
      case 'queryPurchases':
        // TODO: iap.queryPurchases
        result.success([]);
        break;
      default:
        result.notImplemented();
    }
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.channel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL_NAME);
    this.channel.setMethodCallHandler(this);
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    this.channel?.setMethodCallHandler(null);
    this.channel = null;
  }
}
