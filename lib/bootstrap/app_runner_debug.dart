import 'dart:io';

import 'package:dokit/dokit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:module_dokit_bootstrap/dokit_biz_kits.dart';
import 'package:module_sample/app/app.dart';
import 'package:module_sample/main.dart';

abstract final class AppRunner {
  static Future<void> launch() async {
    if (!_isDokitSupported) {
      await AppInitializer.init();
      runApp(const App());
      return;
    }

    await DoKit.runApp(
      appCreator: () async {
        await AppInitializer.init();
        DokitBizKits.register();
        return DoKitApp(const App());
      },
      useInRelease: false,
      useRunZoned: false,
      releaseAction: () async {
        await AppInitializer.init();
        runApp(const App());
      },
    );
  }

  static bool get _isDokitSupported {
    if (kIsWeb) return false;
    return Platform.isAndroid ||
        Platform.isIOS ||
        Platform.operatingSystem == 'ohos';
  }
}
