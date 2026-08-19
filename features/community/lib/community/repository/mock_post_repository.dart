import 'dart:math';

import 'package:module_community/community/models/comment_model.dart';
import 'package:module_community/community/models/community_avatar_urls.dart';
import 'package:module_community/community/models/post_model.dart';
import 'package:module_community/community/repository/post_repository.dart';

class MockPostRepository implements PostRepository {
  MockPostRepository._();

  static final MockPostRepository instance = MockPostRepository._();

  final List<PostModel> _allPosts = [];
  final Map<String, List<CommentModel>> _commentsByPost = {};
  bool _seeded = false;
  int _commentSeq = 0;

  static const _sampleContents = [
    '今天去了 @张三 推荐的咖啡店，环境不错。\n#Flutter开发\n欢迎访问：https://flutter.dev',
    '周末 hiking，天气太好了！#户外',
    '刚读完一本好书，推荐 @李四 也看看。',
    '分享一张随手拍～',
    '项目上线啦，感谢团队！#Flutter开发 https://dart.dev',
    '午餐打卡 @王五',
    '学习 GetX 状态管理中…',
  ];

  void _ensureSeed() {
    if (_seeded) return;
    _seeded = true;
    final now = DateTime.now();
    final random = Random(42);

    for (var i = 0; i < 35; i++) {
      final id = 'post_$i';
      final imgCount = i % 10 == 0 ? 0 : (i % 9) + 1;
      final isVideo = i % 10 == 0;
      final images = isVideo
          ? <String>[]
          : List.generate(
              imgCount,
              (j) => 'https://picsum.photos/seed/${id}_$j/400/400',
            );

      final post = PostModel(
        id: id,
        userId: 'user_${i % 8}',
        nickname: _nicknames[i % _nicknames.length],
        avatar: CommunityAvatarUrls.user((i % 70) + 1),
        content: _sampleContents[i % _sampleContents.length],
        publishTime: now.subtract(Duration(minutes: i * 17 + random.nextInt(30))),
        source: i.isEven ? '来自 iPhone' : '来自 Android',
        images: images,
        videoUrl: isVideo
            ? 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'
            : null,
        videoCoverUrl: isVideo
            ? 'https://picsum.photos/seed/video_$i/640/360'
            : null,
        likeCount: random.nextInt(200),
        commentCount: 2 + random.nextInt(8),
        isLiked: i % 4 == 0,
        isMine: i == 0,
        previewComments: _seedComments(id, now, i),
      );
      _allPosts.add(post);
      _commentsByPost[id] = List<CommentModel>.from(post.previewComments);
    }
  }

  List<CommentModel> _seedComments(String postId, DateTime now, int index) {
    return [
      CommentModel(
        id: 'c_${postId}_1',
        postId: postId,
        nickname: _nicknames[(index + 1) % _nicknames.length],
        avatar: CommunityAvatarUrls.user((index + 2) % 70 + 1),
        content: '说得对！',
        createTime: now.subtract(Duration(minutes: index * 5 + 3)),
      ),
      CommentModel(
        id: 'c_${postId}_2',
        postId: postId,
        nickname: _nicknames[(index + 3) % _nicknames.length],
        avatar: CommunityAvatarUrls.user((index + 4) % 70 + 1),
        content: '同感 +1',
        createTime: now.subtract(Duration(minutes: index * 5 + 1)),
        replyToNickname: _nicknames[index % _nicknames.length],
      ),
    ];
  }

  static const _nicknames = [
    '张三', '李四', '王五', '赵六', '小明', '小红', '开发者', '产品经理',
  ];

  @override
  Future<List<PostModel>> fetchPosts({
    required int page,
    int pageSize = 10,
  }) async {
    _ensureSeed();
    await Future<void>.delayed(Duration(milliseconds: 400 + page * 50));
    final start = page * pageSize;
    if (start >= _allPosts.length) return [];
    final end = min(start + pageSize, _allPosts.length);
    return _allPosts.sublist(start, end);
  }

  @override
  Future<List<CommentModel>> fetchComments(String postId) async {
    _ensureSeed();
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return List<CommentModel>.from(_commentsByPost[postId] ?? []);
  }

  @override
  Future<CommentModel> addComment({
    required String postId,
    required String content,
    String? replyToNickname,
  }) async {
    _ensureSeed();
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _commentSeq++;
    final comment = CommentModel(
      id: 'c_new_$_commentSeq',
      postId: postId,
      nickname: '我',
      avatar: CommunityAvatarUrls.user(12),
      content: content,
      createTime: DateTime.now(),
      replyToNickname: replyToNickname,
    );
    _commentsByPost.putIfAbsent(postId, () => []).insert(0, comment);

    final index = _allPosts.indexWhere((p) => p.id == postId);
    if (index >= 0) {
      final post = _allPosts[index];
      final previews = [comment, ...post.previewComments].take(2).toList();
      _allPosts[index] = post.copyWith(
        commentCount: post.commentCount + 1,
        previewComments: previews,
      );
    }
    return comment;
  }

  @override
  Future<PostModel> toggleLike(String postId, bool liked) async {
    _ensureSeed();
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final index = _allPosts.indexWhere((p) => p.id == postId);
    if (index < 0) throw StateError('post not found');
    final post = _allPosts[index];
    final updated = post.copyWith(
      isLiked: liked,
      likeCount: max(0, post.likeCount + (liked ? 1 : -1)),
    );
    _allPosts[index] = updated;
    return updated;
  }

  @override
  Future<void> deletePost(String postId) async {
    _ensureSeed();
    _allPosts.removeWhere((p) => p.id == postId);
    _commentsByPost.remove(postId);
  }
}
