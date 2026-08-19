import 'package:module_core/model/im/im_session_state.dart';

/// 融云 IM 连接会话（与业务 Auth 分离，使用独立 imUserId）。
abstract class ImSessionService {
  Stream<ImConnectionState> get connectionState;

  ImConnectionState get currentState;

  ImSessionInfo? get sessionInfo;

  String? get currentImUserId;

  Future<void> connect({required String bizUserId});

  Future<void> disconnect({String? reason});
}
