class RoutePath{
  //启动页
  static const String splash = '/';
  static const String main = '/main';
  static const String home = '/home';
  static const String homeLearningReport = '/home/learning_report';
  static const String homeCheckInMall = '/home/check_in_mall';
  static const String login = '/login';
  static const String loginPassword = '/login/password';
  static const String loginOtp = '/login/otp';
  static const String authDevHome = '/auth/dev_home';
  static const String register = '/register';
  static const String chat = '/chat';
  /// 聊天详情（模块内跳转，外部模块无需引用）
  static const String chatDetail = '/chat/detail';
  static const String community = '/community';
  static const String communityPublish = '/community/publish';
  static const String friend = '/friend';
  static const String live = '/live';
  static const String liveRoom = '/live/room';
  static const String pay = '/pay';
  static const String mine = '/mine';
  static const String mineHttpTest = '/mine/http_test';
  static const String settings = '/settings';
  static const String dialogDemo = '/settings/dialog_demo';
  static const String linkingDebug = '/settings/linking_debug';
  static const String realtimeDebug = '/settings/realtime_debug';
  static const String imDebug = '/settings/im_debug';
  static const String bluetoothDemo = '/settings/bluetooth_demo';
  static const String video = '/video';
  static const String shortVideo = '/video/short';
  static const String shortVideoPlay = '/video/short/play';

  /// 通用 Web 容器页（[AppWebViewPage]），通过 Get.arguments 传入 [WebPageConfig]。
  static const String web = '/web';
}
