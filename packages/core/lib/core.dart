/// Core 共享库：只导出模型与抽象服务，不导出实现类。
library module_core;

export 'dev/default_environment_service.dart';
export 'dev/mock_auth_service.dart';
export 'dev/mock_user_service.dart';
export 'env/app_env.dart';
export 'env/env_config.dart';
export 'env/supabase_config.dart';
export 'model/auth/auth_credential_mode.dart';
export 'model/auth/auth_failure.dart';
export 'model/auth/auth_session_state.dart';
export 'model/auth/phone_auth_utils.dart';
export 'model/user.dart';
export 'service/auth_service.dart';
export 'service/user_service.dart';
export 'service/app_loading.dart';
export 'service/environment_service.dart';
export 'web/web_bridge_actions.dart';
export 'web/web_bridge_constants.dart';
export 'web/web_bridge_registry.dart';
export 'web/web_message.dart';
export 'web/web_page_config.dart';
