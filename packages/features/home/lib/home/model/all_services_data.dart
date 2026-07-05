import 'package:module_home/home/model/all_services_model.dart';
import 'package:module_route/route/route_path.dart';

/// 全部服务页静态数据。
abstract final class AllServicesData {
  static const minFavoriteCount = 3;
  static const maxFavoriteCount = 8;

  static const _introductionAnimation = AllServiceItem(
    label: '引导动画',
    assetName: 'smart_online_marketing.png',
    routePath: RoutePath.bfuiIntroductionAnimation,
  );
  static const _hotelBooking = AllServiceItem(
    label: '酒店预订',
    assetName: 'customer_profile.png',
    routePath: RoutePath.bfuiHotelBooking,
  );
  static const _hotelFilters = AllServiceItem(
    label: '酒店筛选',
    assetName: 'smart_sale.png',
    routePath: RoutePath.bfuiHotelFilters,
  );
  static const _fitnessApp = AllServiceItem(
    label: '健身应用',
    assetName: 'new_car_deal.png',
    routePath: RoutePath.bfuiFitnessApp,
  );
  static const _myDiary = AllServiceItem(
    label: '我的日记',
    assetName: 'exhibition_hall_shooting.png',
    routePath: RoutePath.bfuiMyDiary,
  );
  static const _training = AllServiceItem(
    label: '训练计划',
    assetName: 'intelligence_task.png',
    routePath: RoutePath.bfuiTraining,
  );
  static const _designCourse = AllServiceItem(
    label: '设计课程',
    assetName: 'marketing.png',
    routePath: RoutePath.bfuiDesignCourse,
  );
  static const _courseInfo = AllServiceItem(
    label: '课程详情',
    assetName: 'business_poster.png',
    routePath: RoutePath.bfuiCourseInfo,
  );
  static const _help = AllServiceItem(
    label: '帮助中心',
    assetName: 'after_sales_area.png',
    routePath: RoutePath.bfuiHelp,
  );
  static const _feedback = AllServiceItem(
    label: '意见反馈',
    assetName: 'calculator.png',
    routePath: RoutePath.bfuiFeedback,
  );
  static const _musicPlayer = AllServiceItem(
    label: '音频列表',
    assetName: 'used_car.png',
    routePath: RoutePath.musicList,
  );
  static const _navigationDrawer = AllServiceItem(
    label: '侧滑导航',
    assetName: 'service_management.png',
    routePath: RoutePath.bfuiNavigationDrawer,
  );
  static const _glassView = AllServiceItem(
    label: '玻璃卡片',
    assetName: 'online_customer_acquisition.png',
    routePath: RoutePath.bfuiGlassView,
  );
  static const _waveView = AllServiceItem(
    label: '波浪动画',
    assetName: 'smart_number.png',
    routePath: RoutePath.bfuiWaveView,
  );
  static const _runningView = AllServiceItem(
    label: '跑步数据',
    assetName: 'new_car_in_store.png',
    routePath: RoutePath.bfuiRunningView,
  );
  static const _workoutView = AllServiceItem(
    label: '训练视图',
    assetName: 'v_store.png',
    routePath: RoutePath.bfuiWorkoutView,
  );
  static const _mediterraneanDiet = AllServiceItem(
    label: '地中海饮食',
    assetName: 'small_video.png',
    routePath: RoutePath.bfuiMediterraneanDiet,
  );
  static const _classroom = AllServiceItem(
    label: '班级教学',
    assetName: 'intelligence_task.png',
    routePath: RoutePath.classroomMyClass,
  );
  static const _dubbingVideoList = AllServiceItem(
    label: '视频列表',
    assetName: 'small_video.png',
    routePath: RoutePath.dubbingVideoList,
  );
  static const _dubbingWorkList = AllServiceItem(
    label: '作品列表',
    assetName: 'exhibition_hall_shooting.png',
    routePath: RoutePath.dubbingWorkList,
  );
  static const _dubbingHome = AllServiceItem(
    label: '配音首页',
    assetName: 'dubbing_home.png',
    routePath: RoutePath.homeDubbingFeed,
  );
  static const _membershipRenew = AllServiceItem(
    label: '会员续费',
    assetName: 'marketing.png',
    routePath: RoutePath.payMembership,
  );

  static const defaultFavoriteItems = <AllServiceItem>[
    _introductionAnimation,
    _glassView,
    _mediterraneanDiet,
    _navigationDrawer,
    _myDiary,
    _training,
    _runningView,
    _waveView,
  ];

  static const favoriteSectionMeta = (
    title: '常用服务',
    subtitle: '将按自定义顺序出现在首页',
  );

  static const catalogSections = <AllServiceSection>[
    AllServiceSection(
      title: '线索服务',
      items: [
        _introductionAnimation,
        _hotelBooking,
        _hotelFilters,
        _fitnessApp,
        _glassView,
        _runningView,
        _waveView,
      ],
    ),
    AllServiceSection(
      title: '营销服务',
      items: [
        _myDiary,
        _designCourse,
        _training,
        _workoutView,
        _mediterraneanDiet,
        _courseInfo,
      ],
    ),
    AllServiceSection(
      title: '教学服务',
      items: [
        _classroom,
        _dubbingHome,
        _dubbingVideoList,
        _dubbingWorkList,
      ],
    ),
    AllServiceSection(
      title: '其他服务',
      items: [
        _membershipRenew,
        _help,
        _feedback,
        _navigationDrawer,
        _musicPlayer,
      ],
    ),
  ];

  static final Map<String, AllServiceItem> _catalogById = {
    for (final item in _allCatalogItems) item.id: item,
  };

  static List<AllServiceItem> get _allCatalogItems => [
        ...defaultFavoriteItems,
        for (final section in catalogSections) ...section.items,
      ];

  static AllServiceItem? findItemById(String id) => _catalogById[id];

  static List<AllServiceItem> resolveItems(List<String> ids) {
    return [
      for (final id in ids)
        if (_catalogById[id] != null) _catalogById[id]!,
    ];
  }

  static List<String> get defaultFavoriteIds =>
      defaultFavoriteItems.map((item) => item.id).toList();
}
