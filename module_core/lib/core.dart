/// Core 共享库：只导出模型与抽象服务，不导出实现类。
library module_core;

export 'dev/default_environment_service.dart';
export 'dev/mock_user_service.dart';
export 'env/app_env.dart';
export 'env/env_config.dart';
export 'model/user.dart';
export 'service/app_loading.dart';
export 'service/environment_service.dart';
export 'service/user_service.dart';
