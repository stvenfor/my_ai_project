import 'package:module_home/home/model/home_todo_models.dart';
import 'package:module_home/home/model/home_todo_packer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  HomeTodoCard card(String type) => HomeTodoCard(
        type: type,
        title: type,
        subtitle: '',
        actionLabel: '去',
        actionRoute: '/',
        count: 1,
      );

  test('≤2 small wraps without multi-page need', () {
    final cards = [card('order_pending_review'), card('order_pending_review')];
    expect(HomeTodoPacker.shouldWrapOnly(cards), isTrue);
    expect(HomeTodoPacker.packPages(cards), hasLength(1));
  });

  test('1 large alone on a page', () {
    final pages = HomeTodoPacker.packPages([card('partner_pending')]);
    expect(pages, hasLength(1));
    expect(pages.first.single.type, 'partner_pending');
  });

  test('large then mediums pack separately', () {
    final pages = HomeTodoPacker.packPages([
      card('partner_pending'),
      card('follow_up_customer'),
      card('after_sales_appointment'),
    ]);
    expect(pages, hasLength(2));
    expect(pages[0].single.type, 'partner_pending');
    expect(pages[1], hasLength(2));
  });

  test('1 medium + 2 small fill one page', () {
    final pages = HomeTodoPacker.packPages([
      card('follow_up_customer'),
      card('order_pending_review'),
      card('order_pending_review'),
    ]);
    expect(pages, hasLength(1));
    expect(pages.first, hasLength(3));
  });

  test('4 small one page', () {
    final pages = HomeTodoPacker.packPages([
      for (var i = 0; i < 4; i++) card('order_pending_review'),
    ]);
    expect(pages, hasLength(1));
    expect(HomeTodoPacker.shouldWrapOnly(pages.first), isFalse);
  });
}
