import 'package:flutter/material.dart';
import 'package:module_sample/app/app.dart';
import 'package:module_sample/main.dart';

abstract final class AppRunner {
  static Future<void> launch() async {
    await AppInitializer.init();
    runApp(const App());
  }
}
