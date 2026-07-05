class RoutePath{
  //启动页
  static const String splash = '/';
  static const String main = '/main';
  static const String home = '/home';
  static const String homeLearningReport = '/home/learning_report';
  static const String homeCheckInMall = '/home/check_in_mall';
  static const String homeAllServices = '/home/all_services';
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
  static const String dealInvoiceDemo = '/settings/deal_invoice_demo';
  static const String dealInvoiceUpload = '/settings/deal_invoice/upload';
  static const String video = '/video';
  static const String shortVideo = '/video/short';
  static const String shortVideoPlay = '/video/short/play';

  /// 通用 Web 容器页（[AppWebViewPage]），通过 Get.arguments 传入 [WebPageConfig]。
  static const String web = '/web';

  // BFUI 模板示例
  static const String bfuiIntroductionAnimation = '/bfui/introduction_animation';
  static const String bfuiHotelBooking = '/bfui/hotel_booking';
  static const String bfuiHotelFilters = '/bfui/hotel_filters';
  static const String bfuiFitnessApp = '/bfui/fitness_app';
  static const String bfuiMyDiary = '/bfui/my_diary';
  static const String bfuiTraining = '/bfui/training';
  static const String bfuiDesignCourse = '/bfui/design_course';
  static const String bfuiCourseInfo = '/bfui/course_info';
  static const String bfuiHelp = '/bfui/help';
  static const String bfuiFeedback = '/bfui/feedback';
  static const String bfuiInviteFriend = '/bfui/invite_friend';
  static const String bfuiNavigationDrawer = '/bfui/navigation_drawer';
  static const String bfuiGlassView = '/bfui/glass_view';
  static const String bfuiWaveView = '/bfui/wave_view';
  static const String bfuiRunningView = '/bfui/running_view';
  static const String bfuiWorkoutView = '/bfui/workout_view';
  static const String bfuiMediterraneanDiet = '/bfui/mediterranean_diet';

  // 音乐播放器（Flutter Music Player P1）
  static const String musicList = '/music/list';
  static const String musicNowPlaying = '/music/now_playing';

  // 班级教学
  static const String classroomMyClass = '/classroom/my_class';
  static const String classroomHomeworkStats = '/classroom/homework_stats';
  static const String classroomHomeworkDetailTeacher =
      '/classroom/homework/detail_teacher';
  static const String classroomHomeworkDetailStudent =
      '/classroom/homework/detail_student';
  static const String classroomDubbingHomework = '/classroom/homework/dubbing';
  static const String classroomHomeworkReview = '/classroom/homework/review';
  static const String classroomClaimGift = '/classroom/gift/claim';
  static const String classroomVideoDetail = '/classroom/video/detail';

  // 配音视频/作品（全部服务入口）
  static const String dubbingVideoList = '/video/dubbing/videos';
  static const String dubbingVideoDetail = '/video/dubbing/videos/detail';
  static const String dubbingWorkList = '/video/dubbing/works';
  static const String dubbingWorkDetail = '/video/dubbing/works/detail';
}
