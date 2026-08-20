import { MethodCall, MethodCallHandler, MethodChannel, MethodResult } from '@ohos/flutter_ohos';
import AbilityAware from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/ability/AbilityAware';
import { AbilityPluginBinding } from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/ability/AbilityPluginBinding';
import { FlutterPlugin, FlutterPluginBinding } from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/FlutterPlugin';
import Log from '@ohos/flutter_ohos/src/main/ets/util/Log';
import { UIAbility } from '@kit.AbilityKit';
import {
  InputData,
  WbCloudFaceVerifySdk,
  WbFaceError,
  WbFaceVerifyConfig,
  WbFaceVerifyResult
} from 'wbcloudfaceverifysdk';

const TAG: string = 'TfFaceVerifyPlugin';
const CHANNEL_NAME: string = 'com.tf.flutter/cloud_face_verify';

interface TfFaceResult {
  success: boolean;
  code?: string;
  desc?: string;
  reason?: string;
  orderNo?: string;
}

/** 腾讯云慧眼 HarmonyOS NEXT 人脸核身 Flutter 桥接。 */
export default class TfFaceVerifyPlugin implements FlutterPlugin, AbilityAware, MethodCallHandler {
  private channel: MethodChannel | null = null;
  private ability: UIAbility | null = null;
  private verifying: boolean = false;

  getUniqueClassName(): string {
    return TAG;
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    Log.i(TAG, 'onAttachedToEngine');
    this.channel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL_NAME);
    this.channel.setMethodCallHandler(this);
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    Log.i(TAG, 'onDetachedFromEngine');
    this.channel?.setMethodCallHandler(null);
    this.channel = null;
    this.verifying = false;
    WbCloudFaceVerifySdk.getInstance().release();
  }

  onAttachedToAbility(binding: AbilityPluginBinding): void {
    Log.i(TAG, 'onAttachedToAbility');
    this.ability = binding.getAbility();
  }

  onDetachedFromAbility(): void {
    Log.i(TAG, 'onDetachedFromAbility');
    this.ability = null;
    this.verifying = false;
    WbCloudFaceVerifySdk.getInstance().release();
  }

  async onMethodCall(call: MethodCall, result: MethodResult): Promise<void> {
    if (call.method !== 'startVerify') {
      result.notImplemented();
      return;
    }
    if (this.ability === null) {
      result.success({
        success: false,
        code: 'NO_CONTEXT',
        desc: '无法获取鸿蒙页面上下文'
      } as TfFaceResult);
      return;
    }
    if (this.verifying) {
      result.success({
        success: false,
        code: 'VERIFYING',
        desc: '人脸核身正在进行'
      } as TfFaceResult);
      return;
    }

    const orderNo: string = call.argument('orderNo') ?? '';
    const appId: string = call.argument('appId') ?? '';
    const version: string = call.argument('version') ?? '';
    const nonce: string = call.argument('nonce') ?? '';
    const userId: string = call.argument('userid') ?? '';
    const sign: string = call.argument('sign') ?? '';
    const licence: string = call.argument('licence') ?? '';
    const faceId: string = call.argument('faceId') ?? '';
    if ([orderNo, appId, version, nonce, userId, sign, licence, faceId]
      .some((value: string) => value.length === 0)) {
      result.success({
        success: false,
        code: 'INVALID_ARGUMENT',
        desc: '人脸核身参数不完整'
      } as TfFaceResult);
      return;
    }

    const context = this.ability.context;
    this.verifying = true;
    const sdk: WbCloudFaceVerifySdk = WbCloudFaceVerifySdk.getInstance();
    const inputData = new InputData(
      orderNo,
      appId,
      version,
      nonce,
      userId,
      sign,
      licence,
      faceId
    );
    const config = new WbFaceVerifyConfig(inputData);
    config.language = 'zh_CN';
    config.isEnableLog = false;

    try {
      sdk.initPlusSdk(context, config, {
        onLoginSuccess: () => {
          Log.i(TAG, 'onLoginSuccess');
          sdk.startWbFaceVerifySdk(context, {
            onFinish: (verifyResult: WbFaceVerifyResult) => {
              const error = verifyResult.getError();
              const payload: TfFaceResult = {
                success: verifyResult.isSuccess,
                orderNo: verifyResult.getOrderNo()
              };
              if (error) {
                payload.code = error.code;
                payload.desc = error.desc;
                payload.reason = error.reason;
              }
              this.finish(sdk, result, payload);
            }
          });
        },
        onLoginFail: (error: WbFaceError) => {
          Log.e(TAG, 'onLoginFail: ' + error.toString());
          this.finish(sdk, result, {
            success: false,
            code: error.code,
            desc: error.desc,
            reason: error.reason
          });
        }
      });
    } catch {
      Log.e(TAG, 'startVerify failed');
      this.finish(sdk, result, {
        success: false,
        code: 'SDK_EXCEPTION',
        desc: '启动人脸核身失败'
      });
    }
  }

  private finish(
    sdk: WbCloudFaceVerifySdk,
    result: MethodResult,
    payload: TfFaceResult
  ): void {
    sdk.release();
    this.verifying = false;
    result.success(payload);
  }
}
