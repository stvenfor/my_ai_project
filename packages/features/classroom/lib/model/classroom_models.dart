import 'package:flutter/material.dart';

enum HomeworkType { dubbing, sync, checkin }

enum TimeFilter { thisWeek, thisMonth, lastMonth, custom }

enum HomeworkTab { all, dubbing, sync }

enum HomeworkStatusTab { all, completed, incomplete }

enum DubbingMode { practice, standard, challenge }

enum ScoringMode { children, standard, off }

class ClassInfo {
  const ClassInfo({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.memberCount,
  });

  final String id;
  final String name;
  final String inviteCode;
  final int memberCount;
}

class HomeworkStatSummary {
  const HomeworkStatSummary({
    required this.totalCount,
    required this.avgCompletion,
    required this.classCompletionRate,
    required this.typeCounts,
  });

  final int totalCount;
  final int avgCompletion;
  final double classCompletionRate;
  final Map<HomeworkType, int> typeCounts;
}

class StudentHomeworkRow {
  const StudentHomeworkRow({
    required this.id,
    required this.name,
    required this.completed,
    required this.pending,
  });

  final String id;
  final String name;
  final int completed;
  final int pending;
}

class HomeworkTimelineItem {
  const HomeworkTimelineItem({
    required this.id,
    required this.title,
    required this.className,
    required this.dateLabel,
    required this.type,
    required this.isCompleted,
  });

  final String id;
  final String title;
  final String className;
  final String dateLabel;
  final HomeworkType type;
  final bool isCompleted;
}

class StudentProfile {
  const StudentProfile({
    required this.id,
    required this.name,
    required this.avatarEmoji,
    required this.homeworkCount,
    required this.completionRate,
  });

  final String id;
  final String name;
  final String avatarEmoji;
  final int homeworkCount;
  final double completionRate;
}

class HomeworkTaskItem {
  const HomeworkTaskItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.starReward,
    required this.questionCount,
    required this.iconColor,
    required this.iconLabel,
  });

  final String id;
  final String title;
  final String subtitle;
  final int starReward;
  final int questionCount;
  final Color iconColor;
  final String iconLabel;
}

class DubbingHomeworkItem {
  const DubbingHomeworkItem({
    required this.id,
    required this.title,
    required this.score,
    required this.canResubmit,
  });

  final String id;
  final String title;
  final int score;
  final bool canResubmit;
}

class DubbingHomeworkDetail {
  const DubbingHomeworkDetail({
    required this.id,
    required this.studentName,
    required this.title,
    required this.className,
    required this.deadline,
    required this.description,
    required this.items,
  });

  final String id;
  final String studentName;
  final String title;
  final String className;
  final String deadline;
  final String description;
  final List<DubbingHomeworkItem> items;
}

class GiftCardInfo {
  const GiftCardInfo({
    required this.studentName,
    required this.teacherName,
    required this.message,
    required this.date,
    required this.cardType,
    required this.duration,
  });

  final String studentName;
  final String teacherName;
  final String message;
  final String date;
  final String cardType;
  final String duration;
}

class VideoAlbumPart {
  const VideoAlbumPart({
    required this.id,
    required this.title,
    required this.isSelected,
    this.badge,
  });

  final String id;
  final String title;
  final bool isSelected;
  final String? badge;
}

class ClassroomRouteArgs {
  const ClassroomRouteArgs({
    this.classId,
    this.studentId,
    this.homeworkId,
    this.videoId,
  });

  final String? classId;
  final String? studentId;
  final String? homeworkId;
  final String? videoId;

  static ClassroomRouteArgs? from(dynamic arguments) {
    if (arguments is ClassroomRouteArgs) return arguments;
    if (arguments is Map) {
      return ClassroomRouteArgs(
        classId: arguments['classId'] as String?,
        studentId: arguments['studentId'] as String?,
        homeworkId: arguments['homeworkId'] as String?,
        videoId: arguments['videoId'] as String?,
      );
    }
    return null;
  }
}
