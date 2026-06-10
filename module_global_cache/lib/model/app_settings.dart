import 'package:json_annotation/json_annotation.dart';

part 'app_settings.g.dart';

@JsonSerializable()
class AppSettings {
  const AppSettings({
    this.themeMode = 'system',
    this.languageCode = 'zh',
    this.countryCode,
    this.immersiveMode = true,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsFromJson(json);

  final String themeMode;
  final String languageCode;
  final String? countryCode;
  final bool immersiveMode;

  Map<String, dynamic> toJson() => _$AppSettingsToJson(this);

  AppSettings copyWith({
    String? themeMode,
    String? languageCode,
    String? countryCode,
    bool? immersiveMode,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      languageCode: languageCode ?? this.languageCode,
      countryCode: countryCode ?? this.countryCode,
      immersiveMode: immersiveMode ?? this.immersiveMode,
    );
  }
}
