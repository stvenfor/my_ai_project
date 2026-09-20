import 'package:flutter/material.dart';
import 'package:module_ai/ai/binding/ai_stream_binding.dart';
import 'package:module_ai/ai/view/ai_stream_page.dart';
import 'package:wys_router/src/module/feature_module.dart';
import 'package:wys_router/src/route/route_path.dart';

class AiModule extends FeatureModule {
  @override
  String get moduleId => 'ai';

  @override
  Map<String, WidgetBuilder> routes() => {
        RoutePath.aiStream: (_) {
          AiStreamBinding().dependencies();
          return const AiStreamPage();
        },
      };
}
