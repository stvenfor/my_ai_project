import 'package:flutter_test/flutter_test.dart';
import 'package:wys_network/wys_network.dart';
import 'package:wys_push/wys_push.dart';

void main() {
  group('PushConfig', () {
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
