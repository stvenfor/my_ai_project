
import { FlutterAbility, FlutterEngine } from '@ohos/flutter_ohos';
import { AbilityConstant, Want } from '@kit.AbilityKit';
import { GeneratedPluginRegistrant } from '../plugins/GeneratedPluginRegistrant';
import HuaweiIapPlugin from '../plugins/HuaweiIapPlugin';
import TfDeepLinkPlugin from 'wys_push';
import JpushHarmonySdkPlugin from 'jpush_flutter';

export default class EntryAbility extends FlutterAbility {
  configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    GeneratedPluginRegistrant.registerWith(flutterEngine)
    flutterEngine.getPlugins()?.add(new HuaweiIapPlugin())
  }

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    super.onCreate(want, launchParam)
    this.handlePushWant(want)
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    super.onNewWant(want, launchParam)
    this.handlePushWant(want)
  }

  /** 冷启动 / 热启动通知点击：提取 URI + 交给极光 SDK。 */
  private handlePushWant(want: Want): void {
    try {
      TfDeepLinkPlugin.offerWant(want)
    } catch (e) {
      console.error(`EntryAbility offerWant failed: ${JSON.stringify(e)}`)
    }
    try {
      JpushHarmonySdkPlugin.setClickWant(want, this.context)
    } catch (e) {
      console.error(`EntryAbility setClickWant failed: ${JSON.stringify(e)}`)
    }
  }
}
