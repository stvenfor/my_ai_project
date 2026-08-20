#import <Flutter/Flutter.h>

@interface NativeRouterPlugin : NSObject<FlutterPlugin>
+ (void)openFlutterRoute:(NSString *)route arguments:(nullable NSDictionary *)arguments;
@end
