import 'package:module_auth/api/auth_http_config.dart';
import 'package:module_core/env/app_env.dart';
import 'package:module_core/service/environment_service.dart';
import 'package:module_http/module_http.dart';
import 'package:module_realtime/config/realtime_config.dart';
import 'package:module_utils/module_utils.dart';

/// WS Ticket（HTTP 换票，Go BFF）。
class WsTicketApi {
  WsTicketApi({EnvironmentService? envService})
      : _envService = envService;

  final EnvironmentService? _envService;

  Future<WsTicketResult> fetchTicket({required String accessToken}) async {
    if (accessToken.isEmpty) {
      throw StateError('缺少 access token，请先登录');
    }
    AuthHttpConfig.ensureInitialized();

    final result = await HttpManager.instance.post<WsTicketResult>(
      RealtimeConfig.ticketPath,
      data: const {
        'platform': 'mobile',
      },
      converter: (json) => WsTicketResult.fromJson(
        Map<String, dynamic>.from(json as Map),
      ),
    );

    final ticket = result.data;
    if (!result.success || ticket == null) {
      throw HttpRequestException(
        message: result.message ?? '获取 WS ticket 失败',
        code: result.code?.toString(),
      );
    }

    final env = _envService?.currentEnv.value ?? AppEnv.test;
    LogUtils.i(
      '[WsTicketApi] ticket env=${env.name} wsUrl=${ticket.wsUrl}',
    );
    return ticket;
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

  factory WsTicketResult.fromJson(Map<String, dynamic> json) {
    return WsTicketResult(
      ticket: json['ticket']?.toString() ?? '',
      wsUrl: json['wsUrl']?.toString() ?? '',
      expiresInSeconds: _asInt(json['expiresInSeconds']) ?? 0,
      connId: json['connId']?.toString() ?? '',
    );
  }

  static int? _asInt(Object? value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}
