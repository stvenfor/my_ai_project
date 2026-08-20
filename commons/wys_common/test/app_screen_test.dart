import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wys_common/src/utils/app_screen.dart';

void main() {
  group('AppScreen.isLargeSize', () {
    test('returns false below the breakpoint', () {
      expect(AppScreen.isLargeSize(const Size(599, 1000)), isFalse);
    });

    test('returns true at the breakpoint', () {
      expect(AppScreen.isLargeSize(const Size(600, 1000)), isTrue);
    });

    test('returns true above the breakpoint', () {
      expect(AppScreen.isLargeSize(const Size(800, 1200)), isTrue);
    });

    test('is independent of orientation', () {
      expect(AppScreen.isLargeSize(const Size(700, 1000)), isTrue);
      expect(AppScreen.isLargeSize(const Size(1000, 700)), isTrue);
    });
  });

  testWidgets('isLargeScreen reads the current MediaQuery window size', (
    tester,
  ) async {
    var isLargeScreen = false;

    Widget buildTestApp(Size size) {
      return MediaQuery(
        data: MediaQueryData(size: size),
        child: Builder(
          builder: (context) {
            isLargeScreen = AppScreen.isLargeScreen(context);
            return const SizedBox.shrink();
          },
        ),
      );
    }

    await tester.pumpWidget(buildTestApp(const Size(599, 1000)));
    expect(isLargeScreen, isFalse);

    await tester.pumpWidget(buildTestApp(const Size(800, 1000)));
    expect(isLargeScreen, isTrue);
  });
}
