import 'package:module_http/module_http.dart';

class MineHttpConfig {
  static String get baseUrl => AppHttpBootstrap.resolveBaseUrl();

  static const String transactionsPath = '/api/v1/transactions';

  static void init({bool enableLog = false, int maxRetries = 0}) {
    AppHttpBootstrap.initialize(
      headerProvider: const AuthHeaderProvider(),
      enableLog: enableLog,
      maxRetries: maxRetries,
    );
  }
}
