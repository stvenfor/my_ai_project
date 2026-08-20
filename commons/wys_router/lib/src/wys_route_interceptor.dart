/// 路由拦截器：`true` 继续跳转，`false` 拦截（对齐 gaodun [GdRouter.addInterceptor]）。
typedef WysRouteInterceptor = bool Function(
  String urlOrPath,
  Map<String, dynamic> arguments,
);