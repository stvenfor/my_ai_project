import 'package:module_core/env/app_env.dart';
import 'package:module_core/service/environment_service.dart';
import 'package:module_utils/module_utils.dart';
import 'package:uuid/uuid.dart';

/// WS Ticket（HTTP 换票，Mock 实现）。
class WsTicketApi {
  WsTicketApi({EnvironmentService? envService})
      : _envService = envService;

  final EnvironmentService? _envService;
  final _uuid = const Uuid();

  Future<WsTicketResult> fetchTicket({required String accessToken}) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final env = _envService?.currentEnv.value ?? AppEnv.test;
    final wsUrl = _envService?.wsBaseUrl ??
        'wss://mock-ws.test.xiaomaomain.com/realtime/v1/connect';

    LogUtils.i('[WsTicketApi] mock ticket env=${env.name} wsUrl=$wsUrl');

    return WsTicketResult(
      ticket: 'mock_ticket_${_uuid.v4()}',
      wsUrl: wsUrl,
      expiresInSeconds: 120,
      connId: 'mock_conn_${DateTime.now().millisecondsSinceEpoch}',
    );
  }
}

class WsTicketResult {
  const WsTicketResult({
    required this.ticket,
    required this.wsUrl,
    required this.expiresInSeconds,
    required this.connId,
  });

  final String ticket;
  final String wsUrl;
  final int expiresInSeconds;
  final String connId;
}
