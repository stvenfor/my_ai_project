import { router } from '@kit.ArkUI';
import { MethodCall, MethodCallHandler, MethodChannel, MethodResult } from '@ohos/flutter_ohos';
import { FlutterPlugin, FlutterPluginBinding } from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/FlutterPlugin';
import Log from '@ohos/flutter_ohos/src/main/ets/util/Log';

const TAG: string = 'NativeRouterPlugin';
const CHANNEL_NAME: string = 'com.tf.flutter/native_router';

interface FlutterRoutePayload {
  route: string;
  arguments: Record<string, Object>;
}

export default class NativeRouterPlugin implements FlutterPlugin, MethodCallHandler {
  private channel: MethodChannel | null = null;
  private static sharedChannel: MethodChannel | null = null;

  static openFlutterRoute(route: string, argumentsValue: Record<string, Object>): void {
    const payload: FlutterRoutePayload = {
      route: route,
      arguments: argumentsValue
    };
    NativeRouterPlugin.sharedChannel?.invokeMethod('openFlutterRoute', payload);
  }

  getUniqueClassName(): string {
    return TAG;
  }

  async onMethodCall(call: MethodCall, result: MethodResult): Promise<void> {
    if (call.method !== 'openNativeRoute') {
      result.notImplemented();
      return;
    }

    const path = call.argument('path') as string;
    if (path == null || path.length === 0) {
      result.error('INVALID_NATIVE_ROUTE', '原生页面路径不能为空', null);
      return;
    }

    try {
      const argumentsValue = call.argument('arguments') as Record<string, Object>;
      await router.pushUrl({ url: path, params: argumentsValue });
      result.success(true);
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      Log.e(TAG, `open native route failed: ${path}, ${message}`);
      result.error('OPEN_NATIVE_ROUTE_FAILED', message, path);
    }
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.channel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL_NAME);
    NativeRouterPlugin.sharedChannel = this.channel;
    this.channel.setMethodCallHandler(this);
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    this.channel?.setMethodCallHandler(null);
    if (NativeRouterPlugin.sharedChannel === this.channel) {
      NativeRouterPlugin.sharedChannel = null;
    }
    this.channel = null;
  }
}
