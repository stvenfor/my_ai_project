import 'wys_network_error.dart';

/// 业务码 / HTTP 401 等全局回调（UI 由主工程或 module 注册，对齐 iOS Dialog / 旧 Flutter ApiService）。
typedef NetworkEventHandler = void Function(WysNetworkError error);

NetworkEventHandler? onTokenExpired;
NetworkEventHandler? onInvalidAccount;
NetworkEventHandler? onInvalidMember;
NetworkEventHandler? onInvalidAuth;
NetworkEventHandler? onNetworkBusy;
NetworkEventHandler? onBusinessFailure;

void Function(String message)? globalToastHandler;

void notifyToast(String message) {
  globalToastHandler?.call(message);
}