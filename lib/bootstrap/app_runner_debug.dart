import 'dart:async';
import 'dart:io';

import 'package:dokit/dokit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:module_dokit_bootstrap/dokit_biz_kits.dart';
import 'package:module_sample/app/app.dart';
import 'package:module_sample/main.dart';
import 'package:module_utils/module_utils.dart';

abstract final class AppRunner {
  static const _initBudget = Duration(seconds: 20);

  static Future<void> _initOrContinue() async {
    try {
      await AppInitializer.init().timeout(_initBudget);
    } on TimeoutException {
      // 后端/推送半挂起时仍进入 UI，避免停在原生启动图。
      debugPrint(
        '[App] init timed out after ${_initBudget.inSeconds}s, launching UI',
      );
      try {
        LogUtils.w(
          '[App] init timed out after ${_initBudget.inSeconds}s, launching UI',
        );
      } catch (_) {}
    } finally {
      // timeout 可能发生在 AppBinding 之前；runApp 前必须有 AppController。
      AppInitializer.ensureShellBindings();
    }
  }

  static Future<void> launch() async {
    if (!_isDokitSupported) {
      await _initOrContinue();
      runApp(const App());
      return;
    }

    await DoKit.runApp(
      appCreator: () async {
        await _initOrContinue();
        DokitBizKits.register();
        return DoKitApp(const App());
      },
      useInRelease: false,
      useRunZoned: false,
      releaseAction: () async {
        await _initOrContinue();
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
