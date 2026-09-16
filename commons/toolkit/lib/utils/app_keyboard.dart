import 'package:flutter/widgets.dart';

/// 统一收起软键盘（主按钮提交、搜索等场景）。
class AppKeyboard {
  AppKeyboard._();

  static void dismiss() {
    FocusManager.instance.primaryFocus?.unfocus();
  }
}
