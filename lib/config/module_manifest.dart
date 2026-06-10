/// 模块启用清单：注释掉 import 与列表项即可移除模块，主工程仍可编译运行。
library module_manifest;

import 'package:module_auth/auth_module.dart';
import 'package:module_chat/chat_module.dart';
import 'package:module_community/community_module.dart';
import 'package:module_friend/friend_module.dart';
import 'package:module_home/home_module.dart';
import 'package:module_live/live_module.dart';
import 'package:module_pay/pay_module.dart';
import 'package:module_route/module/feature_module.dart';
import 'package:module_settings/settings_module.dart';
import 'package:module_video/video_module.dart';

/// 在此列表中注释任意模块，即可从主 App 中移除（需同步注释上方 import）。
List<FeatureModule> buildEnabledModules() {
  return [
    HomeModule(),
    ChatModule(),
    CommunityModule(),
    SettingsModule(),
    AuthModule(),
    FriendModule(),
    LiveModule(),
    PayModule(),
    VideoModule(),
  ];
}
