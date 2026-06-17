/// 跨模块共享的视频测试源（仅 Mock / 演示，业务层勿直接依赖）。
///
/// 说明：Mockito 用于单元测试里 mock 接口行为，不适合承载运行时 JSON/URL 列表；
/// 各模块通过本文件引用同一份测试数据，业务 Repository 仍对接真实 API。
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
}

/// 与前端示例一致的测试视频源。
const kVideoMockSources = <VideoMockSource>[
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
    desc: 'Google 官方开源测试视频，画质清晰，适合测试高清播放。',
    url:
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
    category: '科幻',
  ),
];

VideoMockSource videoMockSourceAt(int index) =>
    kVideoMockSources[index % kVideoMockSources.length];
