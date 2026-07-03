# BFUI 模板迁移文档

本文档记录 [Best-Flutter-UI-Templates](https://github.com/mitesh77/Best-Flutter-UI-Templates) 迁入本项目的方案与入口映射。

## 上游版本

| 项 | 值 |
|---|---|
| 仓库 | https://github.com/mitesh77/Best-Flutter-UI-Templates |
| Pin Commit | `c85450cb4367742e879ebfae6cda2b7b4da1c3cd` |
| 模块包名 | `module_bfui` |
| 模块路径 | `packages/features/bfui/` |

## 模块结构

```
packages/features/bfui/
  lib/
    bfui_module.dart              # FeatureModule 路由注册
    module_bfui.dart              # 对外 export
    hex_color.dart                # 自上游 main.dart 提取
    app_theme.dart
    custom_drawer/
    design_course/
    fitness_app/
    hotel_booking/
    introduction_animation/
    wrappers/
      bfui_animation_wrapper.dart # AnimationController 包装
      bfui_demo_pages.dart        # 17 个示例入口页
  assets/
    design_course/
    fitness_app/
    fonts/
    hotel/
    images/
    introduction_animation/
```

## 全部服务入口映射（17 项）

保留原有 `assetName`（图标不变），仅改 `label` 与 `routePath`。

| assetName | 示例名称 | 路由 |
|---|---|---|
| smart_online_marketing.png | 引导动画 | `/bfui/introduction_animation` |
| customer_profile.png | 酒店预订 | `/bfui/hotel_booking` |
| smart_sale.png | 酒店筛选 | `/bfui/hotel_filters` |
| new_car_deal.png | 健身应用 | `/bfui/fitness_app` |
| exhibition_hall_shooting.png | 我的日记 | `/bfui/my_diary` |
| intelligence_task.png | 训练计划 | `/bfui/training` |
| marketing.png | 设计课程 | `/bfui/design_course` |
| business_poster.png | 课程详情 | `/bfui/course_info` |
| after_sales_area.png | 帮助中心 | `/bfui/help` |
| calculator.png | 意见反馈 | `/bfui/feedback` |
| used_car.png | 邀请好友 | `/bfui/invite_friend` |
| service_management.png | 侧滑导航 | `/bfui/navigation_drawer` |
| online_customer_acquisition.png | 玻璃卡片 | `/bfui/glass_view` |
| smart_number.png | 波浪动画 | `/bfui/wave_view` |
| new_car_in_store.png | 跑步数据 | `/bfui/running_view` |
| v_store.png | 训练视图 | `/bfui/workout_view` |
| small_video.png | 地中海饮食 | `/bfui/mediterranean_diet` |

常用服务默认 8 项与上表前 8 个示例一致。持久化 key 已升级为 `home_favorite_service_ids_v2`。

## 依赖

`module_bfui` 引入：

- `font_awesome_flutter`
- `flutter_rating_bar`
- `intl`
- `animations`
- `vector_math`

均为 Dart/Font 层，无 Platform Channel，鸿蒙侧无需 CPF-Flutter 适配分支。

## 代码改造要点

1. `package:best_flutter_ui_templates/` → `package:module_bfui/`
2. 上游 `main.dart` 中的 `HexColor` 提取为 `hex_color.dart`
3. 所有 `Image.asset` 增加 `package: 'module_bfui'`
4. Demo 内部 `Navigator.push` 保留，子页（如 CourseInfo、Filters）仍可在 Demo 内跳转
5. `MyDiaryScreen` / `TrainingScreen` / ui_view 组件通过 `BfuiAnimationHost` 注入 `AnimationController`

## 启用方式

1. [`lib/config/module_manifest.dart`](../lib/config/module_manifest.dart) 注册 `BfuiModule()`
2. 根 [`pubspec.yaml`](../pubspec.yaml) 依赖 `module_bfui`
3. [`RoutePath`](../packages/route/lib/route/route_path.dart) 含 17 个 `/bfui/*` 常量

## OHOS 验证清单

- [ ] 引导动画（Introduction Animation）各 step 动画正常
- [ ] 酒店预订日历弹窗与筛选页
- [ ] Fitness 玻璃卡片 / 波浪动画 / 跑步数据
- [ ] Design Course 字体（WorkSans / Roboto）渲染
- [ ] Font Awesome 图标（Hotel Filters 等）
- [ ] 全部服务 17 项点击均可进入对应页

## 相关文件

- 入口数据：[`all_services_data.dart`](../packages/features/home/lib/home/model/all_services_data.dart)
- 点击跳转：[`all_services_controller.dart`](../packages/features/home/lib/home/controller/all_services_controller.dart)
- 路由注册：[`bfui_module.dart`](../packages/features/bfui/lib/bfui_module.dart)
