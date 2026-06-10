// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Flutter Module Sample';

  @override
  String get tabHome => 'Home';

  @override
  String get tabChat => 'Chat';

  @override
  String get tabCommunity => 'Community';

  @override
  String get tabMine => 'Mine';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsTheme => 'Dark mode';

  @override
  String get settingsThemeDesc => 'Switch between light and dark theme';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageDesc => 'Switch app display language';

  @override
  String get settingsImmersive => 'Immersive mode';

  @override
  String get settingsImmersiveDesc => 'Transparent status and navigation bars';

  @override
  String get languageZh => '简体中文';

  @override
  String get languageEn => 'English';

  @override
  String get splashLoading => 'Loading...';
}
