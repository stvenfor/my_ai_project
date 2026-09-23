import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    if let registrar = self.registrar(forPlugin: "AppleIapPlugin") {
      AppleIapPlugin.register(with: registrar)
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

/// 苹果内购 MethodChannel 占位（与鸿蒙华为桥对称）。正式联调换 StoreKit 2。
final class AppleIapPlugin: NSObject, FlutterPlugin {
  static let channelName = "wys.membership/apple_iap"

  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: channelName,
      binaryMessenger: registrar.messenger()
    )
    registrar.addMethodCallDelegate(AppleIapPlugin(), channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as? [String: Any] ?? [:]
    switch call.method {
    case "buySubscription":
      let productId = "\(args["productId"] ?? "")"
      if productId.isEmpty {
        result(FlutterError(code: "bad_args", message: "productId required", details: nil))
        return
      }
      // TODO: StoreKit Product.purchase
      let ts = Int(Date().timeIntervalSince1970 * 1000)
      result([
        "productId": productId,
        "transactionId": "dev-ap-tx-\(productId)-\(ts)",
        "originalTransactionId": "dev-ap-orig-\(productId)",
        "receiptData": "",
      ] as [String: Any])
    case "completePurchase":
      result(nil)
    case "restorePurchases":
      result([] as [Any])
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
