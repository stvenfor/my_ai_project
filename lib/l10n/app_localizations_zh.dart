// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Flutter 模块化示例';

  @override
  String get tabHome => '首页';

  @override
  String get tabChat => '聊天';

  @override
  String get tabCommunity => '社区';

  @override
  String get tabMine => '我的';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsTheme => '深色模式';

  @override
  String get settingsThemeDesc => '切换浅色 / 深色主题';

  @override
  String get settingsLanguage => '语言';

  @override
  String get settingsLanguageDesc => '切换应用显示语言';

  @override
  String get settingsImmersive => '沉浸式模式';

  @override
  String get settingsImmersiveDesc => '透明状态栏与导航栏，全屏显示';

  @override
  String get languageZh => '简体中文';

  @override
  String get languageEn => 'English';

  @override
  String get splashLoading => '正在进入应用...';
}
