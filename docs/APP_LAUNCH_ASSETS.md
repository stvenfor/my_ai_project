# App 启动图标与启动图维护说明

本文档记录根目录主 Flutter App 的 iOS / Android 启动图标与启动图资源。当前已放入一版 mock 资源，方便开发和真机运行时先看到明确的应用占位视觉。

## 当前 mock 资源

### iOS

- 启动图标目录：`ios/Runner/Assets.xcassets/AppIcon.appiconset/`
- 启动图目录：`ios/Runner/Assets.xcassets/LaunchImage.imageset/`
- 启动页配置：`ios/Runner/Base.lproj/LaunchScreen.storyboard`

当前 mock 图标使用 “AI” 标识和多色几何图形。启动页使用浅色背景，居中展示 `LaunchImage`。

### Android

- 启动图标目录：
  - `android/app/src/main/res/mipmap-mdpi/ic_launcher.png`
  - `android/app/src/main/res/mipmap-hdpi/ic_launcher.png`
  - `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png`
  - `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png`
  - `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png`
- 启动图目录：
  - `android/app/src/main/res/mipmap-mdpi/launch_image.png`
  - `android/app/src/main/res/mipmap-hdpi/launch_image.png`
  - `android/app/src/main/res/mipmap-xhdpi/launch_image.png`
  - `android/app/src/main/res/mipmap-xxhdpi/launch_image.png`
  - `android/app/src/main/res/mipmap-xxxhdpi/launch_image.png`
- 启动页配置：
  - `android/app/src/main/res/drawable/launch_background.xml`
  - `android/app/src/main/res/drawable-v21/launch_background.xml`
  - `android/app/src/main/res/values/colors.xml`

Android 启动页由 `LaunchTheme` 的 `android:windowBackground` 展示，当前是浅色背景加居中的 `@mipmap/launch_image`。

## 正式素材建议

### App 图标

建议让设计同学先交付一张 1024 x 1024 px 的无透明背景 PNG 原图，再用工具生成各平台尺寸。

iOS 需要保留 `Contents.json` 中列出的全部 PNG 文件名，不建议改文件名。iOS App Icon 不要带透明通道，也不要预先切圆角，系统会自动处理圆角。

Android 当前使用传统 `ic_launcher.png`。如果后续要适配 Android 自适应图标，可以再补 `mipmap-anydpi-v26/ic_launcher.xml`、前景图和背景色；当前 mock 先保持和项目现状一致。

### 启动图

启动图建议交付居中 logo 或品牌符号，不要把完整业务页面截图作为启动图。启动图应适合浅色背景，边缘留足安全区域。

推荐交付：

- iOS：一张正方形 PNG 源图，建议 540 x 540 px 或更大，然后导出 `1x / 2x / 3x`。
- Android：一张正方形 PNG 源图，建议按 160dp 视觉尺寸导出多密度资源。

当前 Android 启动图尺寸：

| 密度 | 文件 | 像素 |
| --- | --- | --- |
| mdpi | `mipmap-mdpi/launch_image.png` | 160 x 160 |
| hdpi | `mipmap-hdpi/launch_image.png` | 240 x 240 |
| xhdpi | `mipmap-xhdpi/launch_image.png` | 320 x 320 |
| xxhdpi | `mipmap-xxhdpi/launch_image.png` | 480 x 480 |
| xxxhdpi | `mipmap-xxxhdpi/launch_image.png` | 640 x 640 |

## 替换步骤

### 方式一：手动替换

1. 用正式图标替换 `ios/Runner/Assets.xcassets/AppIcon.appiconset/` 下的所有 `Icon-App-*.png` 文件，文件名保持不变。
2. 用正式启动图替换 `ios/Runner/Assets.xcassets/LaunchImage.imageset/` 下的 `LaunchImage.png`、`LaunchImage@2x.png`、`LaunchImage@3x.png`。
3. 用正式 Android 图标替换 `android/app/src/main/res/mipmap-*/ic_launcher.png`。
4. 用正式 Android 启动图替换 `android/app/src/main/res/mipmap-*/launch_image.png`。
5. 如果正式启动页背景色变化，更新 `android/app/src/main/res/values/colors.xml` 中的 `launch_background`，并同步调整 `ios/Runner/Base.lproj/LaunchScreen.storyboard` 的 `backgroundColor`。

### 方式二：使用 Flutter 资源生成工具

后续也可以接入 `flutter_launcher_icons` 和 `flutter_native_splash` 统一生成资源。接入前建议先确认团队是否希望把生成配置写进 `pubspec.yaml`，避免手动资源和工具生成资源混用。

如果使用工具生成，生成后仍需要检查以下文件是否符合预期：

- `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
- `ios/Runner/Assets.xcassets/LaunchImage.imageset/`
- `ios/Runner/Base.lproj/LaunchScreen.storyboard`
- `android/app/src/main/res/mipmap-*/ic_launcher.png`
- `android/app/src/main/res/mipmap-*/launch_image.png`
- `android/app/src/main/res/drawable*/launch_background.xml`

## 验证方式

替换后建议执行：

```bash
flutter clean
flutter pub get
flutter run
```

验证重点：

- iOS 桌面图标是否显示正式图标。
- Android 桌面图标是否显示正式图标。
- 冷启动时是否先出现原生启动图，再进入 Flutter 页面。
- 启动图背景色是否和 Flutter 首屏背景自然衔接，避免明显闪白或闪黑。

## 范围说明

本次只处理根目录主 App 的 `ios/` 和 `android/`。`packages/*/ios`、`packages/*/android` 多为 package 示例壳或插件壳，暂未修改。
