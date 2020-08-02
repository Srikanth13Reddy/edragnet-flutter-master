#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //for google maps initialization below line is used..
  [GMSServices provideAPIKey:@"AIzaSyCM8is9gu7L10Iw4NYi5mujvaxly06rdKc"];
    int flutter_native_splash = 1;
    UIApplication.sharedApplication.statusBarHidden = false;
    if (@available(iOS 10.0, *)) {
        [UNUserNotificationCenter currentNotificationCenter].delegate =
            (id<UNUserNotificationCenterDelegate>)self;
      }

  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end