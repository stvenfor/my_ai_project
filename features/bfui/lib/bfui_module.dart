import 'package:flutter/material.dart';
import 'package:module_bfui/wrappers/bfui_demo_pages.dart';
import 'package:module_route/module/feature_module.dart';
import 'package:module_route/route/route_path.dart';

class BfuiModule extends FeatureModule {
  @override
  String get moduleId => 'bfui';

  @override
  Map<String, WidgetBuilder> routes() => {
        RoutePath.bfuiIntroductionAnimation: (_) =>
            const BfuiIntroductionAnimationPage(),
        RoutePath.bfuiHotelBooking: (_) => const BfuiHotelBookingPage(),
        RoutePath.bfuiHotelFilters: (_) => const BfuiHotelFiltersPage(),
        RoutePath.bfuiFitnessApp: (_) => const BfuiFitnessAppPage(),
        RoutePath.bfuiMyDiary: (_) => const BfuiMyDiaryPage(),
        RoutePath.bfuiTraining: (_) => const BfuiTrainingPage(),
        RoutePath.bfuiDesignCourse: (_) => const BfuiDesignCoursePage(),
        RoutePath.bfuiCourseInfo: (_) => const BfuiCourseInfoPage(),
        RoutePath.bfuiHelp: (_) => const BfuiHelpPage(),
        RoutePath.bfuiFeedback: (_) => const BfuiFeedbackPage(),
        RoutePath.bfuiInviteFriend: (_) => const BfuiInviteFriendPage(),
        RoutePath.bfuiNavigationDrawer: (_) => const BfuiNavigationDrawerPage(),
        RoutePath.bfuiGlassView: (_) => const BfuiGlassViewPage(),
        RoutePath.bfuiWaveView: (_) => const BfuiWaveViewPage(),
        RoutePath.bfuiRunningView: (_) => const BfuiRunningViewPage(),
        RoutePath.bfuiWorkoutView: (_) => const BfuiWorkoutViewPage(),
        RoutePath.bfuiMediterraneanDiet: (_) =>
            const BfuiMediterraneanDietPage(),
      };
}
