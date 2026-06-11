/// Core 共享库：只导出模型与抽象服务，不导出 [UserServiceImpl]。
library module_core;

export 'model/user.dart';
export 'service/user_service.dart';
