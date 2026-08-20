/// 跨模块地址选择回传桥，对齐 iOS `TFChooseAddressUtil`。
///
/// Mine 地址页在「选择模式」下写入结果；Mall 订单确认等入口读取一次后清空。
abstract final class WysAddressChooseBridge {
  WysAddressChooseBridge._();

  static bool _awaitingChoose = false;
  static Map<String, dynamic>? _pending;

  static bool get isAwaitingChoose => _awaitingChoose;

  static void beginChoose() {
    _awaitingChoose = true;
    _pending = null;
  }

  static void completeChoose(Map<String, dynamic> bookJson) {
    _pending = Map<String, dynamic>.from(bookJson);
    _awaitingChoose = false;
  }

  static void cancelChoose() {
    _awaitingChoose = false;
    _pending = null;
  }

  /// 取一次即清空，供下单页读取。
  static Map<String, dynamic>? takeChosenBook() {
    final data = _pending;
    _pending = null;
    _awaitingChoose = false;
    return data;
  }
}
