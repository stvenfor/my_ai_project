import 'package:flutter/material.dart';
import 'package:module_friend/friend/view/friend_page.dart';
import 'package:module_route/module/feature_module.dart';
import 'package:module_route/route/route_path.dart';

class FriendModule extends FeatureModule {
  @override
  String get moduleId => 'friend';

  @override
  Map<String, WidgetBuilder> routes() => {
        RoutePath.friend: (_) => const FriendPage(),
      };
}
