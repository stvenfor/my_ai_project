import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:fluwx/fluwx.dart';

import 'wys_wechat_config.dart';
import 'wys_wechat_models.dart';
import 'wys_wechat_thumb.dart';

class WysWechatService {
  WysWechatService._();

  static final WysWechatService instance = WysWechatService._();

  static const _operationTimeout = Duration(minutes: 5);
  static const _thumbTimeout = Duration(seconds: 8);
  static const _maxThumbDownloadBytes = 10 * 1024 * 1024;

  final Fluwx _fluwx = Fluwx();
  FluwxCancelable? _subscription;
  Future<bool>? _initializing;
  bool _initialized = false;
  Completer<WysWechatResult>? _authCompleter;
  Completer<WysWechatResult>? _payCompleter;

  bool get isInitialized => _initialized;

  Future<bool> init() {
    if (_initialized) return Future.value(true);
    return _initializing ??= _initialize();
  }

  Future<bool> _initialize() async {
    if (!WysWechatConfig.isConfigured) {
      return false;
    }
    try {
      final registered = await _fluwx.registerApi(
        appId: WysWechatConfig.appId,
        universalLink: WysWechatConfig.universalLink,
      );
      if (!registered) return false;
      _subscription ??= _fluwx.addSubscriber(_handleResponse);
      _initialized = true;
      return true;
    } catch (_) {
      return false;
    } finally {
      _initializing = null;
    }
  }

  Future<bool> isInstalled() async {
    if (!await init()) return false;
    try {
      return await _fluwx.isWeChatInstalled;
    } catch (_) {
      return false;
    }
  }

  Future<WysWechatResult> authorize({
    String scope = 'snsapi_userinfo',
    String state = 'wys_wechat_auth',
  }) async {
    final readiness = await _prepareOperation();
    if (readiness != null) return readiness;
    if (_authCompleter != null) {
      return const WysWechatResult(
        status: WysWechatStatus.launchFailed,
        message: '微信授权正在进行',
      );
    }
    final completer = Completer<WysWechatResult>();
    _authCompleter = completer;
    try {
      final launched = await _fluwx.authBy(
        which: NormalAuth(scope: scope, state: state),
      );
      if (!launched) {
        _completeAuth(
          const WysWechatResult(status: WysWechatStatus.launchFailed),
        );
      }
      return await completer.future.timeout(
        _operationTimeout,
        onTimeout: () {
          _authCompleter = null;
          return const WysWechatResult(status: WysWechatStatus.timeout);
        },
      );
    } catch (error) {
      _authCompleter = null;
      return WysWechatResult(
        status: WysWechatStatus.sdkError,
        message: error.toString(),
      );
    }
  }

  Future<WysWechatResult> shareWebpage({
    required String title,
    required String description,
    required String webpageUrl,
    String thumbUrl = '',
    WysWechatScene scene = WysWechatScene.session,
  }) async {
    final readiness = await _prepareOperation();
    if (readiness != null) return readiness;
    try {
      final thumbData = await _downloadThumb(thumbUrl);
      final launched = await _fluwx.share(
        WeChatShareWebPageModel(
          webpageUrl,
          title: title,
          description: description,
          scene: scene == WysWechatScene.timeline
              ? WeChatScene.timeline
              : WeChatScene.session,
          thumbData: thumbData,
        ),
      );
      // 鸿蒙微信返回时不保证下发 SendMessageToWXResp。分享只以
      // sendReq 是否成功唤起作为结果，避免等待缺失回调锁死后续分享。
      return WysWechatResult(
        status: launched ? WysWechatStatus.success : WysWechatStatus.launchFailed,
      );
    } catch (error) {
      return WysWechatResult(
        status: WysWechatStatus.sdkError,
        message: error.toString(),
      );
    }
  }

  Future<WysWechatResult> pay(
    Map<String, dynamic> params, {
    void Function()? onLaunched,
  }) async {
    final readiness = await _prepareOperation();
    if (readiness != null) return readiness;
    final payment = WysWechatPayParams.fromMap(params);
    if (!payment.isValid) {
      return const WysWechatResult(
        status: WysWechatStatus.launchFailed,
        message: '微信支付参数不完整',
      );
    }
    if (_payCompleter != null) {
      return const WysWechatResult(
        status: WysWechatStatus.launchFailed,
        message: '微信支付正在进行',
      );
    }
    final completer = Completer<WysWechatResult>();
    _payCompleter = completer;
    try {
      final launched = await _fluwx.pay(
        which: Payment(
          appId: payment.appId,
          partnerId: payment.partnerId,
          prepayId: payment.prepayId,
          packageValue: payment.packageValue,
          nonceStr: payment.nonceStr,
          timestamp: payment.timestamp,
          sign: payment.sign,
          signType: payment.signType,
          extData: payment.extData,
        ),
      );
      if (!launched) {
        _completePay(const WysWechatResult(status: WysWechatStatus.launchFailed));
      } else {
        onLaunched?.call();
      }
      return await completer.future.timeout(
        _operationTimeout,
        onTimeout: () {
          _payCompleter = null;
          return const WysWechatResult(status: WysWechatStatus.timeout);
        },
      );
    } catch (error) {
      _payCompleter = null;
      return WysWechatResult(
        status: WysWechatStatus.sdkError,
        message: error.toString(),
      );
    }
  }

  void cancelPendingPayment() {
    _completePay(
      const WysWechatResult(
        status: WysWechatStatus.sdkError,
        message: 'app_resumed',
      ),
    );
  }

  Future<WysWechatResult?> _prepareOperation() async {
    if (!await init()) {
      return const WysWechatResult(status: WysWechatStatus.launchFailed);
    }
    if (!await isInstalled()) {
      return const WysWechatResult(status: WysWechatStatus.notInstalled);
    }
    return null;
  }

  void _handleResponse(WeChatResponse response) {
    if (response is WeChatAuthResponse) {
      final base = WysWechatResult.fromSdkCode(
        response.errCode,
        message: response.errStr,
      );
      _completeAuth(
        WysWechatResult(
          status: base.status,
          code: base.code,
          message: base.message,
          authCode: response.code,
        ),
      );
    } else if (response is WeChatPaymentResponse) {
      _completePay(
        WysWechatResult.fromSdkCode(response.errCode, message: response.errStr),
      );
    }
  }

  void _completeAuth(WysWechatResult result) {
    final completer = _authCompleter;
    _authCompleter = null;
    if (completer != null && !completer.isCompleted) completer.complete(result);
  }

  void _completePay(WysWechatResult result) {
    final completer = _payCompleter;
    _payCompleter = null;
    if (completer != null && !completer.isCompleted) completer.complete(result);
  }

  Future<Uint8List?> _downloadThumb(String url) async {
    if (url.isEmpty) return null;
    final client = HttpClient()..connectionTimeout = _thumbTimeout;
    try {
      final request = await client
          .getUrl(Uri.parse(url))
          .timeout(_thumbTimeout);
      final response = await request.close().timeout(_thumbTimeout);
      if (response.statusCode != HttpStatus.ok) return null;
      final bytes = <int>[];
      await for (final chunk in response.timeout(_thumbTimeout)) {
        bytes.addAll(chunk);
        if (bytes.length > _maxThumbDownloadBytes) return null;
      }
      return compressWechatThumb(Uint8List.fromList(bytes));
    } catch (_) {
      return null;
    } finally {
      client.close(force: true);
    }
  }
}
