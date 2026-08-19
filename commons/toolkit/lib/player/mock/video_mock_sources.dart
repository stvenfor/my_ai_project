import 'dart:convert';

import 'package:flutter/services.dart';

/// 跨模块共享的视频测试源（仅 Mock / 演示，业务层勿直接依赖）。
///
/// 数据源：`commons/toolkit/assets/data/video_mock_sources.json`
/// 启动时由 [VideoMockSourceLoader.load] 加载；JSON 不可用时使用 [kVideoMockSourcesFallback]。
class VideoMockSource {
  const VideoMockSource({
    required this.id,
    required this.title,
    required this.desc,
    required this.url,
    required this.category,
  });

  final int id;
  final String title;
  final String desc;
  final String url;
  final String category;

  factory VideoMockSource.fromJson(Map<String, dynamic> json) {
    return VideoMockSource(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      desc: json['desc']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'desc': desc,
        'url': url,
        'category': category,
      };
}

/// JSON 加载失败时的兜底（与 JSON 结构一致，不含 Google CDN）。
const kVideoMockSourcesFallback = <VideoMockSource>[
  VideoMockSource(
    id: 1,
    title: '海洋 (Oceans)',
    desc: '经典测试视频，体积适中，加载速度快。',
    url: 'http://vjs.zencdn.net/v/oceans.mp4',
    category: '自然',
  ),
  VideoMockSource(
    id: 2,
    title: '大兔子 (Big Buck Bunny)',
    desc: 'W3School 官方示例，兼容性极佳。',
    url: 'http://www.w3school.com.cn/example/html5/mov_bbb.mp4',
    category: '动画',
  ),
  VideoMockSource(
    id: 3,
    title: '钢铁之泪 (Tears of Steel)',
    desc: '高清演示视频（国内 CDN，非 Google 源）。',
    url:
        'https://sf1-cdn-tos.huoshanstatic.com/obj/media-fe/xgplayer_doc_video/mp4/xgplayer-demo-720p.mp4',
    category: '科幻',
  ),
];

/// 从 assets JSON 加载跨模块共享的视频 Mock 数据。
class VideoMockSourceLoader {
  VideoMockSourceLoader._();

  static const _assetPaths = [
    'packages/module_utils/assets/data/video_mock_sources.json',
    'assets/data/video_mock_sources.json',
  ];

  static List<VideoMockSource>? _cache;
  static String? _loadedFrom;

  /// 启动时调用一次；失败时回退到 [kVideoMockSourcesFallback]。
  static Future<void> load() async {
    if (_cache != null) return;
    for (final path in _assetPaths) {
      try {
        final raw = await rootBundle.loadString(path);
        final parsed = _parseJsonList(raw);
        if (parsed != null) {
          _cache = parsed;
          _loadedFrom = path;
          return;
        }
      } catch (_) {
        continue;
      }
    }
    _cache = List<VideoMockSource>.from(kVideoMockSourcesFallback);
    _loadedFrom = 'fallback';
  }

  static List<VideoMockSource>? _parseJsonList(String raw) {
    final list = jsonDecode(raw);
    if (list is! List || list.isEmpty) return null;
    final items = list
        .whereType<Map>()
        .map((e) => VideoMockSource.fromJson(Map<String, dynamic>.from(e)))
        .where((e) => e.url.isNotEmpty)
        .toList(growable: false);
    return items.isEmpty ? null : items;
  }

  static List<VideoMockSource> get items {
    return _cache ?? kVideoMockSourcesFallback;
  }

  static bool get isLoaded => _cache != null;

  /// 调试用：当前数据来源路径或 fallback。
  static String? get loadedFrom => _loadedFrom;
}

/// 已加载的 Mock 视频源（需先 [VideoMockSourceLoader.load]）。
List<VideoMockSource> get kVideoMockSources => VideoMockSourceLoader.items;

VideoMockSource videoMockSourceAt(int index) {
  final sources = kVideoMockSources;
  if (sources.isEmpty) {
    return kVideoMockSourcesFallback.first;
  }
  return sources[index % sources.length];
}
