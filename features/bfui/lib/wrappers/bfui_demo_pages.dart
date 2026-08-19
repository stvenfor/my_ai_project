import 'package:flutter/material.dart';
import 'package:module_bfui/design_course/course_info_screen.dart';
import 'package:module_bfui/design_course/home_design_course.dart';
import 'package:module_bfui/feedback_screen.dart';
import 'package:module_bfui/fitness_app/fitness_app_home_screen.dart';
import 'package:module_bfui/fitness_app/fitness_app_theme.dart';
import 'package:module_bfui/fitness_app/my_diary/my_diary_screen.dart';
import 'package:module_bfui/fitness_app/training/training_screen.dart';
import 'package:module_bfui/fitness_app/ui_view/glass_view.dart';
import 'package:module_bfui/fitness_app/ui_view/mediterranean_diet_view.dart';
import 'package:module_bfui/fitness_app/ui_view/running_view.dart';
import 'package:module_bfui/fitness_app/ui_view/wave_view.dart';
import 'package:module_bfui/fitness_app/ui_view/workout_view.dart';
import 'package:module_bfui/help_screen.dart';
import 'package:module_bfui/hotel_booking/filters_screen.dart';
import 'package:module_bfui/hotel_booking/hotel_home_screen.dart';
import 'package:module_bfui/introduction_animation/introduction_animation_screen.dart';
import 'package:module_bfui/invite_friend_screen.dart';
import 'package:module_bfui/navigation_home_screen.dart';
import 'package:module_bfui/wrappers/bfui_animation_wrapper.dart';

class BfuiIntroductionAnimationPage extends StatelessWidget {
  const BfuiIntroductionAnimationPage({super.key});

  @override
  Widget build(BuildContext context) => IntroductionAnimationScreen();
}

class BfuiHotelBookingPage extends StatelessWidget {
  const BfuiHotelBookingPage({super.key});

  @override
  Widget build(BuildContext context) => HotelHomeScreen();
}

class BfuiHotelFiltersPage extends StatelessWidget {
  const BfuiHotelFiltersPage({super.key});

  @override
  Widget build(BuildContext context) => FiltersScreen();
}

class BfuiFitnessAppPage extends StatelessWidget {
  const BfuiFitnessAppPage({super.key});

  @override
  Widget build(BuildContext context) => FitnessAppHomeScreen();
}

class BfuiMyDiaryPage extends StatelessWidget {
  const BfuiMyDiaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BfuiAnimatedScreenPage(
      childBuilder: (controller) => MyDiaryScreen(animationController: controller),
    );
  }
}

class BfuiTrainingPage extends StatelessWidget {
  const BfuiTrainingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BfuiAnimatedScreenPage(
      childBuilder: (controller) => TrainingScreen(animationController: controller),
    );
  }
}

class BfuiDesignCoursePage extends StatelessWidget {
  const BfuiDesignCoursePage({super.key});

  @override
  Widget build(BuildContext context) => DesignCourseHomeScreen();
}

class BfuiCourseInfoPage extends StatelessWidget {
  const BfuiCourseInfoPage({super.key});

  @override
  Widget build(BuildContext context) => CourseInfoScreen();
}

class BfuiHelpPage extends StatelessWidget {
  const BfuiHelpPage({super.key});

  @override
  Widget build(BuildContext context) => HelpScreen();
}

class BfuiFeedbackPage extends StatelessWidget {
  const BfuiFeedbackPage({super.key});

  @override
  Widget build(BuildContext context) => FeedbackScreen();
}

class BfuiInviteFriendPage extends StatelessWidget {
  const BfuiInviteFriendPage({super.key});

  @override
  Widget build(BuildContext context) => InviteFriend();
}

class BfuiNavigationDrawerPage extends StatelessWidget {
  const BfuiNavigationDrawerPage({super.key});

  @override
  Widget build(BuildContext context) => NavigationHomeScreen();
}

class BfuiGlassViewPage extends StatelessWidget {
  const BfuiGlassViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BfuiComponentPreviewPage(
      title: '玻璃卡片',
      backgroundColor: FitnessAppTheme.background,
      childBuilder: (controller, animation) => GlassView(
        animationController: controller,
        animation: animation,
      ),
    );
  }
}

class BfuiWaveViewPage extends StatelessWidget {
  const BfuiWaveViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('波浪动画')),
      backgroundColor: FitnessAppTheme.background,
      body: const Center(child: WaveView(percentageValue: 62)),
    );
  }
}

class BfuiRunningViewPage extends StatelessWidget {
  const BfuiRunningViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BfuiComponentPreviewPage(
      title: '跑步数据',
      backgroundColor: FitnessAppTheme.background,
      childBuilder: (controller, animation) => RunningView(
        animationController: controller,
        animation: animation,
      ),
    );
  }
}

class BfuiWorkoutViewPage extends StatelessWidget {
  const BfuiWorkoutViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BfuiComponentPreviewPage(
      title: '训练视图',
      backgroundColor: FitnessAppTheme.background,
      childBuilder: (controller, animation) => WorkoutView(
        animationController: controller,
        animation: animation,
      ),
    );
  }
}

class BfuiMediterraneanDietPage extends StatelessWidget {
  const BfuiMediterraneanDietPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BfuiComponentPreviewPage(
      title: '地中海饮食',
      backgroundColor: FitnessAppTheme.background,
      childBuilder: (controller, animation) => MediterranesnDietView(
        animationController: controller,
        animation: animation,
      ),
    );
  }
}
