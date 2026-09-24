import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:module_utils/utils/app_keyboard.dart';

void main() {
  testWidgets('dismissOnTap unfocuses TextField when tapping blank',
      (tester) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: AppKeyboard.dismissOnTap(
          child: Scaffold(
            body: Column(
              children: [
                TextField(focusNode: focusNode),
                const Expanded(child: SizedBox.expand()),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(TextField));
    await tester.pump();
    expect(focusNode.hasFocus, isTrue);

    // 点输入框下方空白区，应收起焦点。
    await tester.tapAt(const Offset(200, 400));
    await tester.pump();
    expect(focusNode.hasFocus, isFalse);
  });

  testWidgets('navigatorObserver dismisses focus on push', (tester) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    final navKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navKey,
        navigatorObservers: [AppKeyboard.navigatorObserver],
        home: Scaffold(
          body: TextField(focusNode: focusNode),
        ),
      ),
    );

    await tester.tap(find.byType(TextField));
    await tester.pump();
    expect(focusNode.hasFocus, isTrue);

    navKey.currentState!.push(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('next')),
      ),
    );
    await tester.pumpAndSettle();
    expect(focusNode.hasFocus, isFalse);
  });
}
