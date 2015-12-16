//
//  RongCloudApplicationHandler.m
//  CordovaDemo
//
//  Created by litao on 15/11/2.
//
//

#import "RongCloudApplicationHandler.h"
#import <RongIMLib/RongIMLib.h>

NSString *const kAppBackgroundMode = @"kAppBackgroundMode";
NSString *const kDeviceToken = @"RongCloud_SDK_DeviceToken";


@implementation RongCloudApplicationHandler
+ (void)didApplicationFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeAlert];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
}
+ (void)didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    
}
+ (void)didApplicationRegisterForRemoteNotificationsWithDeviceToken:(NSString *)deviceToken {
    [[RCIMClient sharedRCIMClient]setDeviceToken:deviceToken];
    
    [[NSUserDefaults standardUserDefaults] setObject:deviceToken forKey:kDeviceToken];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (void)didApplicationEnterBackground {
    [[NSUserDefaults standardUserDefaults]setObject:@(YES) forKey:kAppBackgroundMode];
    [[NSUserDefaults standardUserDefaults]synchronize];
}
+ (void)willApplicationEnterForeground {
    [[NSUserDefaults standardUserDefaults]setObject:@(NO) forKey:kAppBackgroundMode];
    [[NSUserDefaults standardUserDefaults]synchronize];
}
@end
