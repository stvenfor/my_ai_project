import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:module_common_ui/kit/bot_toast_loading_service.dart';
import 'package:module_common_ui/kit/ui_kit_config.dart';

void main() {
  testWidgets('BotToastAppLoading show/dismiss and overlay cleanup', (tester) async {
    const config = UiKitConfig();
    applyBotToastConfig(config);
    final loading = BotToastAppLoading(config);

    await tester.pumpWidget(
      MaterialApp(
        builder: BotToastInit(),
        navigatorObservers: [BotToastNavigatorObserver()],
        home: const Scaffold(body: SizedBox.shrink()),
      ),
    );
    await tester.pump();

    loading.show('加载中');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    loading.dismiss();
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);

    expect(() => loading.showToast('普通提示'), returnsNormally);
    expect(() => loading.showSuccess('成功'), returnsNormally);
    expect(() => loading.showError('失败'), returnsNormally);
    expect(() => loading.showInfo('信息'), returnsNormally);
    await tester.pump();

    loading.dismiss();
    await tester.pumpAndSettle();

    loading.show('再次加载');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
