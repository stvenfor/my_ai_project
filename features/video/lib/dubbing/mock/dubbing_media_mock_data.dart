import 'package:module_utils/player/mock/short_video_mock_samples.dart';
import 'package:module_utils/player/mock/video_mock_sources.dart';

class DubbingVideoItem {
  const DubbingVideoItem({
    required this.id,
    required this.title,
    required this.desc,
    required this.videoUrl,
    required this.coverUrl,
    required this.category,
    required this.likeCount,
    required this.dislikeCount,
    required this.sentenceCount,
    required this.difficulty,
    required this.uploaderName,
    required this.subtitleEn,
    required this.subtitleZh,
    required this.albumCount,
    this.tags = const [],
    this.albumParts = const [],
    this.latestWorkAvatars = const [],
    this.leaderboard,
  });

  final String id;
  final String title;
  final String desc;
  final String videoUrl;
  final String coverUrl;
  final String category;
  final int likeCount;
  final int dislikeCount;
  final int sentenceCount;
  final String difficulty;
  final String uploaderName;
  final String subtitleEn;
  final String subtitleZh;
  final int albumCount;
  final List<String> tags;
  final List<DubbingAlbumPart> albumParts;
  final List<String> latestWorkAvatars;
  final DubbingLeaderboardEntry? leaderboard;
}

class DubbingLeaderboardEntry {
  const DubbingLeaderboardEntry({
    required this.rank,
    required this.userName,
    required this.avatarUrl,
    required this.date,
    required this.location,
    required this.likeCount,
    required this.level,
  });

  final int rank;
  final String userName;
  final String avatarUrl;
  final String date;
  final String location;
  final int likeCount;
  final String level;
}

class DubbingAlbumPart {
  const DubbingAlbumPart({
    required this.id,
    required this.title,
    this.badge,
  });

  final String id;
  final String title;
  final String? badge;
}

class DubbingWorkItem {
  const DubbingWorkItem({
    required this.id,
    required this.title,
    required this.authorName,
    required this.authorAvatar,
    required this.videoUrl,
    required this.coverUrl,
    required this.likeCount,
    required this.commentCount,
    required this.publishedAt,
    required this.location,
    this.badge,
    this.duration,
  });

  final String id;
  final String title;
  final String authorName;
  final String authorAvatar;
  final String videoUrl;
  final String coverUrl;
  final int likeCount;
  final int commentCount;
  final String publishedAt;
  final String location;
  final String? badge;
  final String? duration;
}

/// 配音视频/作品 Mock 数据（底层 URL 来自 [kVideoMockSources]）。
abstract final class DubbingMediaMockData {
  static const _videoTitles = [
    '恐龙科幻电影回归：《侏罗纪世界2：失落王国》电影预告',
    '【合作】制服牛油果小怪兽 Part 1',
    '哈利波特与魔法石 · 赫敏特辑（上）',
  ];

  static const _videoDescs = [
    '经典科幻大片预告，适合练习口语节奏与情感表达。',
    '趣味动画片段，句子短、难度低，适合入门配音。',
    '人物特辑片段，练习 RP 女音与角色语气。',
  ];

  static const _workTitles = [
    '你好世界，这里是中国！',
    '【RP女音】赫敏：It is LeviOsa, not LevioSA!',
    '美诺明年夏天见 · 配音作品',
  ];

  static const _authors = [
    ('小趣友宁Sir', 'https://picsum.photos/seed/author1/100/100'),
    ('唯有爱与美不可辜...', 'https://picsum.photos/seed/author2/100/100'),
    ('美诺明年夏天见', 'https://picsum.photos/seed/author3/100/100'),
  ];

  static List<DubbingVideoItem> get videos {
    final sources = kVideoMockSources;
    return [
      for (var i = 0; i < sources.length; i++)
        DubbingVideoItem(
          id: '${sources[i].id}',
          title: i < _videoTitles.length ? _videoTitles[i] : sources[i].title,
          desc: i < _videoDescs.length ? _videoDescs[i] : sources[i].desc,
          videoUrl: sources[i].url,
          coverUrl: ShortVideoMockSamples.coverAt(i),
          category: sources[i].category,
          likeCount: 3983 - i * 500,
          dislikeCount: 12 + i,
          sentenceCount: 10 - i * 2,
          difficulty: 'PreA${i + 1}',
          uploaderName: _authors[i % _authors.length].$1,
          subtitleEn:
              "It's said they can accelerate faster than a Ferrari.",
          subtitleZh: '据说他们能比法拉利更快地加速',
          albumCount: 20,
          tags: i == 0
              ? ['合作', '10句', '难度 PreA1', '漫威', '经典大片', '超级英雄']
              : ['合作', '${10 - i * 2}句', '难度 PreA${i + 1}', sources[i].category],
          albumParts: [
            DubbingAlbumPart(
              id: 'part_${i}_1',
              title: i == 0 ? '制服牛油果小怪兽' : 'Part 1 ${sources[i].title}',
              badge: '试听',
            ),
            DubbingAlbumPart(
              id: 'part_${i}_2',
              title: i == 0 ? '想到制服牛油果...' : 'Part 2 续集片段...',
              badge: i == 0 ? '付费' : (i == 1 ? '付费' : null),
            ),
            DubbingAlbumPart(
              id: 'part_${i}_3',
              title: '顺利制服...',
            ),
          ],
          latestWorkAvatars: List.generate(
            6,
            (j) => 'https://picsum.photos/seed/work_${i}_$j/80/80',
          ),
          leaderboard: DubbingLeaderboardEntry(
            rank: 1,
            userName: '美诺明年夏天见',
            avatarUrl: 'https://picsum.photos/seed/leader_$i/80/80',
            date: '2020-11-03',
            location: '杭州市',
            likeCount: 11000,
            level: 'V5',
          ),
        ),
    ];
  }

  static List<DubbingWorkItem> get works {
    final sources = kVideoMockSources;
    return [
      for (var i = 0; i < sources.length; i++)
        DubbingWorkItem(
          id: 'work_${sources[i].id}',
          title: i < _workTitles.length ? _workTitles[i] : sources[i].title,
          authorName: _authors[i % _authors.length].$1,
          authorAvatar: _authors[i % _authors.length].$2,
          videoUrl: sources[i].url,
          coverUrl: ShortVideoMockSamples.coverAt(i),
          likeCount: 11000 - i * 2000,
          commentCount: 22 + i * 5,
          publishedAt: '2023-11-${23 - i}',
          location: i == 2 ? '杭州市' : '北京',
          badge: i == 0 ? '精选' : (i == 1 ? '高秀' : null),
          duration: '${1 + i}:${10 + i * 5}',
        ),
    ];
  }

  static DubbingVideoItem? findVideoById(String? id) {
    if (id == null) return videos.isNotEmpty ? videos.first : null;
    for (final item in videos) {
      if (item.id == id) return item;
    }
    return videos.isNotEmpty ? videos.first : null;
  }

  static DubbingWorkItem? findWorkById(String? id) {
    if (id == null) return works.isNotEmpty ? works.first : null;
    for (final item in works) {
      if (item.id == id) return item;
    }
    return works.isNotEmpty ? works.first : null;
  }

  static String? resolveId(dynamic arguments) {
    if (arguments is Map) return arguments['id']?.toString();
    if (arguments is String) return arguments;
    return null;
  }
}
