import { MethodCall, MethodCallHandler, MethodChannel, MethodResult } from '@ohos/flutter_ohos';
import { FlutterPlugin, FlutterPluginBinding } from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/FlutterPlugin';
import Log from '@ohos/flutter_ohos/src/main/ets/util/Log';
import Want from '@ohos.app.ability.Want';

const TAG: string = 'TfDeepLinkPlugin';
const CHANNEL_NAME: string = 'com.xiaomao.flutter/deeplink';
const URI_KEYS: string[] = ['uri', 'url', 'deeplink', 'deepLink', 'route', 'page', 'path'];

/** 把 HarmonyOS Want 中的推送/深链 URI 转发给 wys_push Dart 层。 */
export default class TfDeepLinkPlugin implements FlutterPlugin, MethodCallHandler {
  private static pendingUri: string | null = null;
  private static instance: TfDeepLinkPlugin | null = null;

  private channel: MethodChannel | null = null;

  /** 接收 EntryAbility.onCreate/onNewWant 传入的 Want。 */
  static offerWant(want: Want | null | undefined): void {
    const uri: string | null = TfDeepLinkPlugin.extractUri(want);
    if (uri !== null) {
      TfDeepLinkPlugin.offerUri(uri);
    }
  }

  /** 接收已经解析完成的 URI。 */
  static offerUri(uri: string): void {
    const normalized: string = uri.trim();
    if (normalized.length === 0) {
      return;
    }
    TfDeepLinkPlugin.pendingUri = normalized;
    TfDeepLinkPlugin.instance?.emit(normalized);
  }

  private static extractUri(want: Want | null | undefined): string | null {
    if (want === null || want === undefined) {
      return null;
    }
    if (want.uri !== undefined && want.uri.length > 0) {
      return want.uri.trim();
    }

    const params = want.parameters;
    if (params === null || params === undefined) {
      return null;
    }
    const direct: string | null = TfDeepLinkPlugin.firstUri(params);
    if (direct !== null) {
      return direct;
    }

    const extrasRaw = params['extras'] ?? params['extra'];
    const extras: Record<string, Object> | null = TfDeepLinkPlugin.toRecord(extrasRaw);
    if (extras !== null) {
      const extrasUri: string | null = TfDeepLinkPlugin.firstUri(extras);
      if (extrasUri !== null) {
        return extrasUri;
      }
      const intent: Record<string, Object> | null = TfDeepLinkPlugin.toRecord(extras['intent']);
      if (intent !== null) {
        const intentUri: string | null = TfDeepLinkPlugin.firstUri(intent);
        if (intentUri !== null) {
          return intentUri;
        }
      }
    }

    const paramKeys: string[] = Object.keys(params);
    for (let index = 0; index < paramKeys.length; index++) {
      const value = params[paramKeys[index]];
      if (typeof value === 'string' &&
          (value.startsWith('xiaomao://') || value.startsWith('https://'))) {
        return value.trim();
      }
    }
    return null;
  }

  private static firstUri(values: Record<string, Object>): string | null {
    for (let index = 0; index < URI_KEYS.length; index++) {
      const value = values[URI_KEYS[index]];
      if (typeof value === 'string' && value.trim().length > 0) {
        return value.trim();
      }
    }
    return null;
  }

  private static toRecord(value: Object | string | undefined): Record<string, Object> | null {
    if (typeof value === 'object' && value !== null) {
      return value as Record<string, Object>;
    }
    if (typeof value !== 'string' || value.trim().length === 0) {
      return null;
    }
    try {
      const decoded = JSON.parse(value) as Object;
      if (typeof decoded === 'object' && decoded !== null) {
        return decoded as Record<string, Object>;
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  getUniqueClassName(): string {
    return TAG;
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    if (call.method === 'getInitialLink') {
      const uri: string | null = TfDeepLinkPlugin.pendingUri;
      TfDeepLinkPlugin.pendingUri = null;
      result.success(uri);
      return;
    }
    result.notImplemented();
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    Log.i(TAG, 'onAttachedToEngine');
    TfDeepLinkPlugin.instance = this;
    this.channel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL_NAME);
    this.channel.setMethodCallHandler(this);
    if (TfDeepLinkPlugin.pendingUri !== null) {
      this.emit(TfDeepLinkPlugin.pendingUri);
    }
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    Log.i(TAG, 'onDetachedFromEngine');
    this.channel?.setMethodCallHandler(null);
    this.channel = null;
    if (TfDeepLinkPlugin.instance === this) {
      TfDeepLinkPlugin.instance = null;
    }
  }

  private emit(uri: string): void {
    try {
      this.channel?.invokeMethod('onLink', uri);
    } catch (error) {
      Log.e(TAG, 'emit onLink failed: ' + String(error));
    }
  }
}
