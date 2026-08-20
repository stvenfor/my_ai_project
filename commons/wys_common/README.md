# wys_common

FanGroup 公共能力：Toast、本地存储、文案工具、列表刷新与页面态组件。

## 依赖

```yaml
wys_common:
  path: ../commons/wys_common
```

## Toast

```dart
import 'package:wys_common/wys_common.dart';

WysToast.show('提示');
// 主工程统一风格（可选）
WysToast.configure((msg) => Get.snackbar('提示', msg));
```

与 `wys_network` 的 `notifyToast` 可在 `main` 里一起配置：

```dart
globalToastHandler = (msg) => WysToast.show(msg);
```

## 本地存储

```dart
await WysPrefs.save('key', 'value');
final s = await WysPrefs.getString('key');
```

旧 API：`WysUtils.saveData`（已标记 `@Deprecated`，请迁到 `WysPrefs`）。

## 页面态

- `WysLoadingView` / `WysEmptyView` / `WysErrorRetryView`
- `WysRefresh`（easy_refresh 封装）

## 其它

- `WysText`：空串、手机号掩码、价格格式化
- `WysDebounce.debounce` / `throttle`

## 扫码（WysScan）

基于 [flutter_scan](https://gitee.com/zgp1027/flutter_scan) 封装，支持 Android / iOS 实时扫码与图片解析；OHOS 等平台 `WysScan.isSupported == false` 时会 toast 提示。

```dart
import 'package:wys_common/wys_common.dart';

// 打开全屏扫码页，成功返回码值
final code = await WysScan.scan(
  context,
  config: WysScanConfig(
    title: '扫一扫',
    requestCameraPermission: () async {
      // 由业务侧处理相机权限
      return true;
    },
  ),
);

// 从本地图片解析
final text = await WysScan.parseImage('/path/to/image.jpg');
```

**平台权限（Runner 工程）**

- iOS：`NSCameraUsageDescription`、`io.flutter.embedded_views_preview = YES`
- Android：相机权限声明

真机验证：Android/iOS 打开扫码页 → 识别成功返回 → 手电筒切换 → 取消返回 null。