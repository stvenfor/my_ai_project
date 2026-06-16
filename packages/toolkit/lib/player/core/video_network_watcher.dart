import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// 网络断开/恢复监听。
class VideoNetworkWatcher {
  VideoNetworkWatcher();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _wasDisconnected = false;

  void start({
    required Future<void> Function() onReconnect,
    void Function()? onDisconnect,
  }) {
    _subscription?.cancel();
    _subscription = _connectivity.onConnectivityChanged.listen((results) async {
      final connected = results.any((r) => r != ConnectivityResult.none);
      if (!connected) {
        _wasDisconnected = true;
        onDisconnect?.call();
        return;
      }
      if (_wasDisconnected) {
        _wasDisconnected = false;
        await onReconnect();
      }
    });
  }

  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
