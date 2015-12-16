//
//  RongCloudApplicationHandler.h
//  CordovaDemo
//
//  Created by litao on 15/11/2.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
UIKIT_EXTERN NSString *const kAppBackgroundMode;
UIKIT_EXTERN NSString *const kDeviceToken;


@interface RongCloudApplicationHandler : NSObject
+ (void)didApplicationFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
+ (void)didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings;
+ (void)didApplicationRegisterForRemoteNotificationsWithDeviceToken:(NSString *)deviceToken;
+ (void)didApplicationEnterBackground;
+ (void)willApplicationEnterForeground;
@end
