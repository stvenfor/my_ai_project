import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_home/home/theme/check_in_mall_theme.dart';
import 'package:module_utils/module_utils.dart';

class CheckInMallPage extends StatefulWidget {
  const CheckInMallPage({super.key});

  @override
  State<CheckInMallPage> createState() => _CheckInMallPageState();
}

class _CheckInMallPageState extends State<CheckInMallPage> {
  bool _reminderEnabled = false;
  final int _consecutiveDays = 26;
  final int _iCarCoins = 320;
  final int _growthValue = 780;

  final List<_CheckInDay> _checkInDays = [
    _CheckInDay(day: 1, reward: 5, status: CheckInStatus.signed),
    _CheckInDay(day: 2, reward: 5, status: CheckInStatus.today),
    _CheckInDay(day: 3, reward: 10, status: CheckInStatus.pending),
    _CheckInDay(day: 4, reward: 5, status: CheckInStatus.pending),
    _CheckInDay(day: 5, reward: 5, status: CheckInStatus.pending),
    _CheckInDay(day: 6, reward: 5, status: CheckInStatus.pending),
    _CheckInDay(day: 7, reward: 20, status: CheckInStatus.pending),
  ];

  final List<_TaskItem> _tasks = [
    _TaskItem(
      icon: Icons.arrow_upward,
      iconColor: Color(0xFF4A90E2),
      iconBgColor: Color(0xFFE8F1FA),
      title: '每日登录',
      subtitle: '+10成长值 +5i车币',
      actionText: '去完成',
      actionType: TaskActionType.primary,
    ),
    _TaskItem(
      icon: Icons.chat_bubble,
      iconColor: Color(0xFF4A90E2),
      iconBgColor: Color(0xFFE8F1FA),
      title: '回复客户消息',
      subtitle: '+50成长值 +20i车币',
      showHelp: true,
      actionText: '已完成',
      actionType: TaskActionType.completed,
    ),
    _TaskItem(
      icon: Icons.person_add,
      iconColor: Color(0xFF4A90E2),
      iconBgColor: Color(0xFFE8F1FA),
      title: '邀请新销售顾问',
      subtitle: '+200成长值 +50i车币',
      actionText: '去邀请',
      actionType: TaskActionType.primary,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CheckInMallTheme.background,
      body: CustomScrollView(
        slivers: [
          _buildHeader(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCheckInCard(),
                SizedBox(height: 16.h),
                _buildTaskSection(),
                SizedBox(height: 16.h),
                _buildGiftSection(),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SliverAppBar(
      backgroundColor: CheckInMallTheme.primaryBlue,
      expandedHeight: 180.h,
      pinned: true,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20.sp),
        onPressed: () => Get.back<void>(),
      ),
      title: Text(
        '签到商城',
        style: TextStyle(
          color: Colors.white,
          fontSize: 17.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      flexibleSpace: FlexibleSpaceBar(
        background: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 56.h),
              _buildNoticeBar(),
              SizedBox(height: 16.h),
              _buildStatsRow(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoticeBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Color(0xFF3A8EE6),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        children: [
          Icon(Icons.volume_up, color: Colors.white, size: 16.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              '温馨提示：本页面只保留近3个月内的i车币记录',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              label: '我的i车币',
              value: '$_iCarCoins',
              onTap: () {},
            ),
          ),
          Expanded(
            child: _buildStatItem(
              label: '我的成长值',
              value: '$_growthValue',
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 13.sp,
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.8), size: 16.sp),
            ],
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 4.w),
              Icon(Icons.help_outline, color: Colors.white.withOpacity(0.6), size: 16.sp),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckInCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '连签7日可得65成长值',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: CheckInMallTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '已累计签到 ',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: CheckInMallTheme.textSecondary,
                          ),
                        ),
                        TextSpan(
                          text: '$_consecutiveDays',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: CheckInMallTheme.primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text: ' 天',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: CheckInMallTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: CheckInMallTheme.primaryBlue,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  '立即签到',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _checkInDays.map((day) => _buildDayItem(day)).toList(),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '断签或者签完需重新开始',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: CheckInMallTheme.textHint,
                ),
              ),
              Row(
                children: [
                  Text(
                    '签到提醒',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: CheckInMallTheme.textSecondary,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  SizedBox(
                    width: 44.w,
                    height: 24.h,
                    child: Switch(
                      value: _reminderEnabled,
                      onChanged: (value) {
                        setState(() {
                          _reminderEnabled = value;
                        });
                      },
                      activeColor: Colors.white,
                      activeTrackColor: CheckInMallTheme.primaryBlue,
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: CheckInMallTheme.textHint.withOpacity(0.3),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayItem(_CheckInDay day) {
    Color bgColor;
    Color textColor;
    String label;

    switch (day.status) {
      case CheckInStatus.signed:
        bgColor = CheckInMallTheme.primaryBlue;
        textColor = Colors.white;
        label = '已签';
        break;
      case CheckInStatus.today:
        bgColor = CheckInMallTheme.coinGold;
        textColor = Colors.white;
        label = '${day.day}天';
        break;
      case CheckInStatus.pending:
        bgColor = Color(0xFFF5F6F8);
        textColor = CheckInMallTheme.textSecondary;
        label = '${day.day}天';
        break;
    }

    return Column(
      children: [
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '+${day.reward}',
                style: TextStyle(
                  color: textColor,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(
                Icons.arrow_forward,
                color: textColor.withOpacity(0.8),
                size: 10.sp,
              ),
            ],
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            color: day.status == CheckInStatus.signed
                ? CheckInMallTheme.primaryBlue
                : CheckInMallTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildTaskSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '成长值任务',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: CheckInMallTheme.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              children: _tasks.asMap().entries.map((entry) {
                final index = entry.key;
                final task = entry.value;
                return Column(
                  children: [
                    _buildTaskItem(task),
                    if (index < _tasks.length - 1)
                      Divider(
                        height: 1,
                        indent: 56.w,
                        endIndent: 16.w,
                        color: CheckInMallTheme.divider,
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(_TaskItem task) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: task.iconBgColor,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(task.icon, color: task.iconColor, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: CheckInMallTheme.textPrimary,
                      ),
                    ),
                    if (task.showHelp)
                      Padding(
                        padding: EdgeInsets.only(left: 4.w),
                        child: Icon(
                          Icons.help_outline,
                          color: CheckInMallTheme.textHint,
                          size: 14.sp,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  task.subtitle,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: CheckInMallTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          _buildTaskButton(task),
        ],
      ),
    );
  }

  Widget _buildTaskButton(_TaskItem task) {
    switch (task.actionType) {
      case TaskActionType.primary:
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: CheckInMallTheme.primaryBlue,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text(
            task.actionText,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      case TaskActionType.completed:
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: Color(0xFFF5F6F8),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text(
            task.actionText,
            style: TextStyle(
              color: CheckInMallTheme.textHint,
              fontSize: 12.sp,
            ),
          ),
        );
    }
  }

  Widget _buildGiftSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'i车币换礼',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: CheckInMallTheme.textPrimary,
            ),
          ),
          SizedBox(height: 40.h),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.card_giftcard_outlined,
                  size: 80.sp,
                  color: CheckInMallTheme.textHint.withOpacity(0.3),
                ),
                SizedBox(height: 16.h),
                Text(
                  '商城筹备中，礼品马上就到',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: CheckInMallTheme.textHint,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }
}

enum CheckInStatus { signed, today, pending }

class _CheckInDay {
  final int day;
  final int reward;
  final CheckInStatus status;

  _CheckInDay({
    required this.day,
    required this.reward,
    required this.status,
  });
}

enum TaskActionType { primary, completed }

class _TaskItem {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final bool showHelp;
  final String actionText;
  final TaskActionType actionType;

  _TaskItem({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    this.showHelp = false,
    required this.actionText,
    required this.actionType,
  });
}
