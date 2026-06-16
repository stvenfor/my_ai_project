# 社区动态模块设计 Spec

> 决策确认：1A 2B 3B 4A 5C 6A 7B 8B

## 决策锁定

| # | 选择 | 含义 |
|---|------|------|
| 1 | A | `CommunityViewModel` + `CommunityPage`，目录 `view/viewmodel` |
| 2 | B | 按完整 spec 一次实现（转发除外） |
| 3 | B | 头像用 pravatar，`CacheImageUtils` 失败占位 |
| 4 | A | 图文与视频互斥 |
| 5 | C | 转发 P1 不做，互动栏不展示转发 |
| 6 | A | @/# Toast 占位，链接 `RoutePath.web` |
| 7 | B | `video_player` 封装在 `module_utils` |
| 8 | B | 发布按钮跳转空白发布页 |

## 架构

```
module_community
├── models/          PostModel, CommentModel, RichSegment
├── repository/      PostRepository + MockPostRepository
├── services/        RichTextParser
├── viewmodel/       CommunityViewModel, PublishViewModel
├── view/            CommunityPage, PublishPage, VideoPlayPage, ImagePreviewPage
└── widgets/         PostCard, ImageGrid, LikeBar, CommentSheet, Skeleton...
```

## 数据流

MockPostRepository → CommunityViewModel → GetBuilder(id) 局部刷新 → PostCardWidget

## 扩展点

- `PostRepository` 替换为 Supabase/API
- 发布页 P1 接发帖接口
- 转发 P1 增加 shareCount + UI
