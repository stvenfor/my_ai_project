# Agent 开发指南

本文档供 AI Agent 与协作者查阅，约定本项目常见陷阱与正确写法。

## GetX / Obx 响应式 UI

### 问题现象

```
[Get] the improper use of a GetX has been detected.
You should only use GetX or Obx for the specific widget that will be updated.
```

通常表示 `Obx` / `GetX` 的 builder **在 build 期间没有读取任何 `.obs` 变量**，GetX 无法建立依赖，会在 debug 模式下抛错。

### 正确写法

在 `Obx` builder **内部**显式读取响应式数据，再传给子组件：

```dart
// ✅ 正确：在 Obx 内读取 .value / .toList() / .length
Obx(() {
  final items = controller.functions.toList();
  return MineReorderableFunctionGrid(
    key: ValueKey(items.map((e) => e.id).join(',')),
    items: items,
    onReorder: controller.reorderFunction,
    onItemTap: controller.onFunctionTap,
  );
});

// ✅ 正确：读取 Rxn / Rx 的 .value
Obx(() {
  final profile = controller.profile.value;
  if (profile == null) return const SizedBox.shrink();
  return ProfileHeader(data: profile);
});
```

```dart
// ❌ 错误：直接把 RxList 传给子组件，builder 内未触发订阅
Obx(() => MyGrid(items: controller.functions));

// ❌ 错误：在 Obx 外读取 obs，builder 内只用普通变量
final list = controller.functions;
Obx(() => MyGrid(items: list));

// ❌ 错误：obs 只在回调里读，build 期间未读
Obx(() => ElevatedButton(
  onPressed: () => controller.count.value++,
  child: const Text('Add'), // 未读 count
));
```

### 规则清单

1. **`Obx` builder 必须是块级函数**，在 return 之前读取 obs（`.value`、`.toList()`、`.length` 等）。
2. **不要把 `RxList` / `Rx` 原样当普通类型传给 StatelessWidget**，先在 Obx 内快照为普通值（如 `List.from(...)`、`toList()`）。
3. **StatefulWidget 依赖列表顺序时**，列表重排后加 `ValueKey`（如 id 拼接），避免 drag 等内部状态与数据错位。
4. **父、子都要响应不同 obs 时**，各自包一层 `Obx`，不要指望外层 Obx 更新深层子树。
5. **纯静态 UI 不要用 Obx**；没有 obs 就不包。

### 参考实现

- `packages/features/settings/lib/mine/widgets/mine_function_section_widget.dart` — 个人功能拖动排序
- `packages/features/settings/lib/mine/widgets/mine_header_widget.dart` — `profile.value` 读取
- `packages/features/home/lib/home/view/all_services_page.dart` — `favoriteItems.toList()` 读取

## Flutter 拖动排序（LongPressDraggable）

### 问题现象

长按时出现：

```
'!_debugDoingThisLayout': is not true
'hasSize': is not true
Cannot hit test a render box with no size
```

### 原因与修复

1. **`feedback` 必须有明确的宽高**。若 feedback 内子组件含 `Expanded`/`Flexible`，只设 width 不设 height 会导致 overlay 无尺寸。
2. **不要在 `DragTarget.onMove` 里 `setState`**，会在 layout 阶段触发重绘。改用 `builder` 的 `candidateData.isNotEmpty` 做高亮。
3. **拖动状态变更**（`onDragStarted` / `onDragEnd`）用 `SchedulerBinding.instance.addPostFrameCallback` 延迟到下一帧再 `setState`。
4. **宫格 reorder 优先 `childDragAnchorStrategy`**，避免 `pointerDragAnchorStrategy` 在边缘长按时 feedback 起手大跳；`feedback` 用 `Transform.scale(0.94)` 略缩小视觉占位，仍保留 `SizedBox` 明确宽高。

### 参考实现

- `packages/features/settings/lib/mine/widgets/mine_reorderable_function_grid.dart`

## 三方库鸿蒙（OpenHarmony）适配

### Flutter SDK

本项目使用 [CPF-Flutter/flutter_flutter](https://gitcode.com/CPF-Flutter/flutter_flutter/tree/3.35.8-ohos-1.0.1) **3.35.8-ohos-1.0.1**（含 `TargetPlatform.ohos`）。IDE 与构建请指向 `.fvm/versions/custom_3.35-ohos`（见 [`.vscode/settings.json`](.vscode/settings.json)），**不要**用标准 pub.dev Flutter 编此项目，否则 CPF 插件会因缺少 `ohos` 平台报错。

### 原则

带原生能力的第三方库**必须**具备鸿蒙适配后再引入或升级，不能仅依赖 pub.dev 官方版本。

### 官方适配源

- 主仓库：[CPF-Flutter/flutter_packages](https://gitcode.com/CPF-Flutter/flutter_packages)（原 openharmony-tpc 已迁移）
- 适配清单见仓库 README「OpenHarmony平台已适配packages三方库」
- 不在 packages 内的库（如 `permission_handler`）查 CPF-Flutter 组织下对应鸿蒙仓库
- 示例 Demo：[flutter_samples](https://gitcode.com/openharmony-tpc/flutter_samples)（ohos 子目录）

### 依赖写法

1. 各 feature 模块 `pubspec.yaml` 保持 pub.dev 语义化版本（如 `image_picker: ^1.1.2`）。
2. 根 [`pubspec.yaml`](pubspec.yaml) `dependency_overrides` 统一指向鸿蒙 git 源（优先 `ref` 标签，其次 `br_<库名>-v<版本>_ohos` 分支）。
3. **federated 插件**需同时 override 主包与 `*_ohos` 实现包（如 `image_picker` + `image_picker_ohos`）。
4. 部分插件还需在根 `dependencies` 显式添加 `permission_handler_ohos` 等实现包。
5. `flutter pub get` 后检查 `ohos/entry/oh-package.json5` 是否自动注入 har 依赖。

### 权限

在 `ohos/entry/src/main/module.json5` 声明权限（如 `ohos.permission.CAMERA`），并在 Dart 层拍照等敏感操作前动态申请（`permission_handler` + `permission_handler_ohos`）。

### 本项目已接入

- `ImagePickerUtils` / `MediaPickSource` — 相册选图、相机拍照（[`image_picker_utils.dart`](packages/commons/toolkit/lib/utils/image_picker_utils.dart)）
- `MediaSourceBottomSheet` — 相册/相机来源选择弹框（[`media_source_bottom_sheet.dart`](packages/commons/ui/lib/dialog/media_source_bottom_sheet.dart)）
- `image_picker` / `image_picker_ohos` — 三方库声明在 `module_utils`，鸿蒙 override 在根 [`pubspec.yaml`](pubspec.yaml)
- `permission_handler_ohos` — 权限动态申请
- `ScanUtils` / `ScanPage` — 相机实时扫码、相册图片解析（[`scan_utils.dart`](packages/commons/toolkit/lib/utils/scan_utils.dart)）
- `scan` — 声明在 `module_utils`（`^1.6.0`），根 [`pubspec.yaml`](pubspec.yaml) `dependency_overrides` 指向 [CPF-Flutter/fluttertpc_scan](https://gitcode.com/CPF-Flutter/fluttertpc_scan)（iOS / Android / Harmony 统一 git 源，需在上述鸿蒙 Flutter SDK 下编译）
