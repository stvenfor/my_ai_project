/// 页面布局模式。
enum AppPageLayout {
  /// 标准：NavBar + 正文（正文顶不再重复 SafeArea.top）。
  standard,

  /// 全屏延伸：body 顶到屏幕顶，NavBar 叠在 body 上。
  fullBleed,

  /// 无 NavBar：全屏 body，业务自行处理 top inset。
  edgeToEdge,

  /// Tab 根页：无 NavBar，业务自绘头部（Home / Mine）。
  mainTabRoot,
}
