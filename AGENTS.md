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
