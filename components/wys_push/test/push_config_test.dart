import 'package:flutter_test/flutter_test.dart';
import 'package:wys_network/wys_network.dart';
import 'package:wys_push/wys_push.dart';

void main() {
  group('PushConfig', () {
    test('uninitialized AppEnvironment is treated as non-production', () {
      // 不调用 AppEnvironment.initialize：启动早期 Linking 也会读 isConfigured。
      expect(PushConfig.isProduction, isFalse);
      expect(PushConfig.appKey, PushConfig.testAppKey);
      expect(PushConfig.isConfigured, isFalse);
    });

    test('product uses the production AppKey placeholder', () {
      AppEnvironment.initialize(
        AppEnv.debug,
        netEnvironment: WysNetEnvironment.product,
      );

      expect(PushConfig.isProduction, isTrue);
      expect(PushConfig.appKey, PushConfig.productionAppKey);
      expect(PushConfig.isConfigured, isFalse);
    });

    for (final environment in <WysNetEnvironment>[
      WysNetEnvironment.dev,
      WysNetEnvironment.test,
      WysNetEnvironment.custom,
    ]) {
      test('$environment uses the test AppKey placeholder', () {
        AppEnvironment.initialize(AppEnv.release, netEnvironment: environment);

        expect(PushConfig.isProduction, isFalse);
        expect(PushConfig.appKey, PushConfig.testAppKey);
        expect(PushConfig.isConfigured, isFalse);
      });
    }
  });
}
