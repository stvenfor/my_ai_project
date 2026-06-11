import 'package:flutter/foundation.dart';
import 'package:module_http/module_http.dart';
import 'package:module_repository/repository/app_http_bootstrap.dart';

class HomeHttpConfig {
  static String get baseUrl => AppHttpBootstrap.resolveBaseUrl();

  static void ensureInitialized({
    bool enableLog = kDebugMode,
    int maxRetries = 3,
  }) {
    if (HttpManager.instance.isInitialized) return;
    AppHttpBootstrap.initialize(
      enableLog: enableLog,
      maxRetries: maxRetries,
    );
  }
}
