import 'package:flutter/material.dart';
import 'package:module_classroom/model/classroom_models.dart';

/// 班级教学 Mock 数据。
abstract final class ClassroomMockData {
  static const defaultClassId = 'class_001';
  static const defaultStudentId = 'student_001';
  static const defaultHomeworkId = 'hw_001';

  static const classes = <ClassInfo>[
    ClassInfo(
      id: 'class_001',
      name: '班级名称',
      inviteCode: '11490rKkz',
      memberCount: 6,
    ),
    ClassInfo(
      id: 'class_002',
      name: '三年级2班',
      inviteCode: '88201aBxP',
      memberCount: 32,
    ),
  ];

  static const statSummary = HomeworkStatSummary(
    totalCount: 12,
    avgCompletion: 10,
    classCompletionRate: 85,
    typeCounts: {
      HomeworkType.dubbing: 5,
      HomeworkType.sync: 3,
      HomeworkType.checkin: 1,
    },
  );

  static const students = <StudentHomeworkRow>[
    StudentHomeworkRow(id: 'student_001', name: '老谭酸菜', completed: 12, pending: 0),
    StudentHomeworkRow(id: 'student_002', name: '乌克丽丽', completed: 12, pending: 0),
    StudentHomeworkRow(id: 'student_003', name: '酸菜', completed: 10, pending: 2),
    StudentHomeworkRow(id: 'student_004', name: '张三李四', completed: 8, pending: 4),
  ];

  static const reviewStudents = [
    '老坛酸菜',
    '乌克丽丽',
    '张三李四',
    '酸菜',
    '王五赵六',
    '小明',
    '小红',
    '小刚',
  ];

  static const studentProfiles = <String, StudentProfile>{
    'student_001': StudentProfile(
      id: 'student_001',
      name: '老谭酸菜',
      avatarEmoji: '🐧',
      homeworkCount: 10,
      completionRate: 100,
    ),
    'student_002': StudentProfile(
      id: 'student_002',
      name: '乌克丽丽',
      avatarEmoji: '🐧',
      homeworkCount: 10,
      completionRate: 100,
    ),
    'student_003': StudentProfile(
      id: 'student_003',
      name: '酸菜',
      avatarEmoji: '🎒',
      homeworkCount: 10,
      completionRate: 74,
    ),
  };

  static const timelineItems = <HomeworkTimelineItem>[
    HomeworkTimelineItem(
      id: 'hw_001',
      title: '周一（7月10日）配音作业',
      className: '三年级2班',
      dateLabel: '2026 05-21',
      type: HomeworkType.dubbing,
      isCompleted: true,
    ),
    HomeworkTimelineItem(
      id: 'hw_002',
      title: '周二（7月11日）同步作业',
      className: '三年级2班',
      dateLabel: '2026 05-20',
      type: HomeworkType.sync,
      isCompleted: true,
    ),
    HomeworkTimelineItem(
      id: 'hw_003',
      title: '周三打卡作业',
      className: '三年级2班',
      dateLabel: '2026 05-19',
      type: HomeworkType.checkin,
      isCompleted: false,
    ),
    HomeworkTimelineItem(
      id: 'hw_004',
      title: '周四（7月13日）配音作业',
      className: '三年级2班',
      dateLabel: '2026 05-18',
      type: HomeworkType.dubbing,
      isCompleted: false,
    ),
  ];

  static const studentHomeworkTasks = <HomeworkTaskItem>[
    HomeworkTaskItem(
      id: 'task_001',
      title: '单词学习',
      subtitle: '共5道题',
      starReward: 3,
      questionCount: 5,
      iconColor: Color(0xFF1890FF),
      iconLabel: 'En',
    ),
    HomeworkTaskItem(
      id: 'task_002',
      title: '单词拼写',
      subtitle: '共22道题',
      starReward: 3,
      questionCount: 22,
      iconColor: Color(0xFF52C41A),
      iconLabel: 'Aa',
    ),
  ];

  static const dubbingHomework = DubbingHomeworkDetail(
    id: 'hw_dub_001',
    studentName: '酸菜',
    title: '周二（7月11日）配音作业',
    className: '三年二班',
    deadline: '7月15日23:59',
    description: '本次作业核心考验大家的发音能力，重点练习a的发音',
    items: [
      DubbingHomeworkItem(
        id: 'dub_001',
        title: '蜘蛛侠之英雄归来',
        score: 100,
        canResubmit: false,
      ),
      DubbingHomeworkItem(
        id: 'dub_002',
        title: '侏罗纪世界2：失落王国',
        score: 0,
        canResubmit: true,
      ),
      DubbingHomeworkItem(
        id: 'dub_003',
        title: '哈利波特与魔法石',
        score: 85,
        canResubmit: false,
      ),
    ],
  );

  static const giftCard = GiftCardInfo(
    studentName: '乌克丽丽',
    teacherName: '老坛酸菜',
    message: '本次作业完成的很棒！老师送你一张体验卡，以资鼓励',
    date: '2026-05-20',
    cardType: '班级会员卡',
    duration: '1天 AI SVIP',
  );

  static const videoTitle =
      '恐龙科幻电影回归：《侏罗纪世界2：失落王国》电影预告';

  static const videoAlbumParts = <VideoAlbumPart>[
    VideoAlbumPart(
      id: 'part_1',
      title: 'Part 1 制服牛油果小怪兽',
      isSelected: true,
      badge: '试听',
    ),
    VideoAlbumPart(
      id: 'part_2',
      title: 'Part 2 想到制服牛油果...',
      isSelected: false,
      badge: '付费',
    ),
    VideoAlbumPart(
      id: 'part_3',
      title: 'Part 3 顺利制服...',
      isSelected: false,
    ),
  ];

  static ClassInfo? findClass(String? id) {
    if (id == null) return classes.first;
    for (final c in classes) {
      if (c.id == id) return c;
    }
    return classes.first;
  }

  static StudentProfile? findStudent(String? id) {
    if (id == null) return studentProfiles[defaultStudentId];
    return studentProfiles[id] ?? studentProfiles[defaultStudentId];
  }

  static List<HomeworkTimelineItem> timelineForStudent(String? studentId) {
    return timelineItems;
  }

  static String homeworkTypeLabel(HomeworkType type) {
    switch (type) {
      case HomeworkType.dubbing:
        return '配音作业';
      case HomeworkType.sync:
        return '同步作业';
      case HomeworkType.checkin:
        return '打卡作业';
    }
  }

  static Color homeworkTypeColor(HomeworkType type) {
    switch (type) {
      case HomeworkType.dubbing:
        return const Color(0xFF52C41A);
      case HomeworkType.sync:
        return const Color(0xFFFF8A34);
      case HomeworkType.checkin:
        return const Color(0xFF1890FF);
    }
  }
}
