// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppSettings _$AppSettingsFromJson(Map<String, dynamic> json) => AppSettings(
      themeMode: json['themeMode'] as String? ?? 'system',
      languageCode: json['languageCode'] as String? ?? 'zh',
      countryCode: json['countryCode'] as String?,
      immersiveMode: json['immersiveMode'] as bool? ?? true,
    );

Map<String, dynamic> _$AppSettingsToJson(AppSettings instance) =>
    <String, dynamic>{
      'themeMode': instance.themeMode,
      'languageCode': instance.languageCode,
      'countryCode': instance.countryCode,
      'immersiveMode': instance.immersiveMode,
    };
