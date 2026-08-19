import 'dart:async';

import 'package:module_core/model/im/im_session_state.dart';
import 'package:module_core/service/im_session_service.dart';
import 'package:module_rongcloud_im/api/im_session_api.dart';
import 'package:module_rongcloud_im/config/rong_im_config.dart';
import 'package:module_rongcloud_im/engine/rong_engine_holder.dart';
import 'package:module_utils/module_utils.dart';

class ImSessionServiceImpl implements ImSessionService {
  ImSessionServiceImpl({
    required ImSessionApi sessionApi,
    required RongEngineHolder engineHolder,
  })  : _sessionApi = sessionApi,
        _engineHolder = engineHolder;

  final ImSessionApi _sessionApi;
  final RongEngineHolder _engineHolder;
  final _stateController = StreamController<ImConnectionState>.broadcast();

  ImConnectionState _state = ImConnectionState.disconnected;
  ImSessionInfo? _sessionInfo;

  @override
  Stream<ImConnectionState> get connectionState => _stateController.stream;

  @override
  ImConnectionState get currentState => _state;

  @override
  ImSessionInfo? get sessionInfo => _sessionInfo;

  @override
  String? get currentImUserId => _sessionInfo?.imUserId;

  @override
  Future<void> connect({required String bizUserId}) async {
    if (_state == ImConnectionState.connected) return;
    _setState(ImConnectionState.connecting);
    try {
      final session = await _sessionApi.createSession(bizUserId: bizUserId);
      _sessionInfo = ImSessionInfo(
        imUserId: session.imUserId,
        bizUserId: bizUserId,
        tokenExpiresAt: DateTime.now().add(Duration(seconds: session.expiresInSeconds)),
      );

      if (RongImConfig.useMockIm) {
        await _engineHolder.connectMock(session: session);
      } else {
        await _engineHolder.connectReal(session: session);
      }

      _setState(ImConnectionState.connected);
      LogUtils.i('[ImSession] connected imUserId=${session.imUserId}');
    } catch (e, st) {
      _setState(ImConnectionState.failed);
      LogUtils.e('[ImSession] connect failed', e, st);
      rethrow;
    }
  }

  @override
  Future<void> disconnect({String? reason}) async {
    await _engineHolder.disconnect(reason: reason);
    _sessionInfo = null;
    _setState(ImConnectionState.disconnected);
    LogUtils.i('[ImSession] disconnected reason=$reason');
  }

  void _setState(ImConnectionState state) {
    if (_state == state) return;
    _state = state;
    _stateController.add(state);
  }

  Future<void> dispose() async {
    await disconnect(reason: 'dispose');
    await _stateController.close();
  }
}
