#import "NativeRouterPlugin.h"
#import <UIKit/UIKit.h>

static NSString *const TFNativeRouterChannel = @"com.tf.flutter/native_router";
static FlutterMethodChannel *TFNativeRouterMethodChannel;

@implementation NativeRouterPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:TFNativeRouterChannel
                                  binaryMessenger:registrar.messenger];
  TFNativeRouterMethodChannel = channel;
  NativeRouterPlugin *instance = [[NativeRouterPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

+ (void)openFlutterRoute:(NSString *)route arguments:(NSDictionary *)arguments {
  if (route.length == 0 || TFNativeRouterMethodChannel == nil) {
    return;
  }
  [TFNativeRouterMethodChannel invokeMethod:@"openFlutterRoute"
                                  arguments:@{
    @"route": route,
    @"arguments": arguments ?: @{}
  }];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  if (![call.method isEqualToString:@"openNativeRoute"]) {
    result(FlutterMethodNotImplemented);
    return;
  }

  NSDictionary *payload = [call.arguments isKindOfClass:NSDictionary.class]
                              ? call.arguments
                              : @{};
  NSString *path = [payload[@"path"] isKindOfClass:NSString.class]
                       ? [payload[@"path"] stringByTrimmingCharactersInSet:
                                                NSCharacterSet.whitespaceAndNewlineCharacterSet]
                       : @"";
  if (path.length == 0) {
    result([FlutterError errorWithCode:@"INVALID_NATIVE_ROUTE"
                               message:@"原生页面路径不能为空"
                               details:nil]);
    return;
  }

  NSString *urlString = [path containsString:@"://"]
                            ? path
                            : [NSString stringWithFormat:@"tfapp://tf.com%@%@",
                                                         [path hasPrefix:@"/"] ? @"" : @"/",
                                                         path];
  NSURLComponents *components = [NSURLComponents componentsWithString:urlString];
  NSDictionary *arguments = [payload[@"arguments"] isKindOfClass:NSDictionary.class]
                                ? payload[@"arguments"]
                                : @{};
  NSMutableArray<NSURLQueryItem *> *items = [NSMutableArray arrayWithArray:components.queryItems ?: @[]];
  [arguments enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
    if (value != NSNull.null) {
      [items addObject:[NSURLQueryItem queryItemWithName:[key description]
                                                   value:[value description]]];
    }
  }];
  components.queryItems = items;

  NSURL *url = components.URL;
  if (url == nil) {
    result([FlutterError errorWithCode:@"INVALID_NATIVE_ROUTE"
                               message:@"原生页面地址无效"
                               details:path]);
    return;
  }

  [[UIApplication sharedApplication] openURL:url
                                     options:@{}
                           completionHandler:^(BOOL success) {
    if (success) {
      result(@YES);
    } else {
      result([FlutterError errorWithCode:@"OPEN_NATIVE_ROUTE_FAILED"
                                 message:@"无法打开原生页面"
                                 details:path]);
    }
  }];
}

@end
