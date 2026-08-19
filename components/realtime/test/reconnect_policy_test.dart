import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:module_realtime/connection/reconnect_policy.dart';

void main() {
  test('ReconnectPolicy exponential backoff capped', () {
    final policy = ReconnectPolicy(random: Random(0));
    expect(policy.nextDelay().inMilliseconds, greaterThanOrEqualTo(500));
    policy.nextDelay();
    final third = policy.nextDelay();
    expect(third.inMilliseconds, lessThanOrEqualTo(60000));
    policy.reset();
    expect(policy.attempt, 0);
  });
}
