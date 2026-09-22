import 'package:module_home/home/view/daily_check_in_dialog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DailyCheckInDialog.shouldShow', () {
    test('logged out → false', () {
      expect(
        DailyCheckInDialog.shouldShow(
          isLoggedIn: false,
          checkedInToday: false,
          ackDate: null,
          todayLocal: '2026-09-22',
        ),
        isFalse,
      );
    });

    test('already checked in → false', () {
      expect(
        DailyCheckInDialog.shouldShow(
          isLoggedIn: true,
          checkedInToday: true,
          ackDate: null,
          todayLocal: '2026-09-22',
        ),
        isFalse,
      );
    });

    test('prefs already shown today → false', () {
      expect(
        DailyCheckInDialog.shouldShow(
          isLoggedIn: true,
          checkedInToday: false,
          ackDate: '2026-09-22',
          todayLocal: '2026-09-22',
        ),
        isFalse,
      );
    });

    test('logged in, not checked in, no ack → true', () {
      expect(
        DailyCheckInDialog.shouldShow(
          isLoggedIn: true,
          checkedInToday: false,
          ackDate: null,
          todayLocal: '2026-09-22',
        ),
        isTrue,
      );
    });

    test('ack from previous day → true', () {
      expect(
        DailyCheckInDialog.shouldShow(
          isLoggedIn: true,
          checkedInToday: false,
          ackDate: '2026-09-21',
          todayLocal: '2026-09-22',
        ),
        isTrue,
      );
    });
  });

  test('todayLocalString format', () {
    expect(
      DailyCheckInDialog.todayLocalString(DateTime(2026, 9, 22)),
      '2026-09-22',
    );
  });
}
