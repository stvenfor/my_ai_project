import 'dart:async';

import 'package:flutter/material.dart';
import 'package:module_sample/app/app.dart';
import 'package:module_sample/main.dart';
import 'package:module_utils/module_utils.dart';

abstract final class AppRunner {
  static Future<void> launch() async {
    try {
      await AppInitializer.init().timeout(const Duration(seconds: 20));
    } on TimeoutException {
      // ignore: avoid_print
      print('[App] init timed out, launching UI');
      try {
        LogUtils.w('[App] init timed out, launching UI');
      } catch (_) {}
    } finally {
      AppInitializer.ensureShellBindings();
    }
    runApp(const App());
  }
}
