//
//  RongCloudAppEventReceiver.m
//  CordovaDemo
//
//  Created by litao on 15/11/2.
//
//

#import "RongCloudAppEventReceiver.h"

#import "RongCloudApplicationHandler.h"
#import <UIKit/UIKit.h>
#import <RongIMLib/RongIMLib.h>

extern NSString* const CDVPageDidLoadNotification;
extern NSString* const CDVPluginHandleOpenURLNotification;
extern NSString* const CDVPluginResetNotification;
extern NSString* const CDVLocalNotification;
extern NSString* const CDVRemoteNotification;
extern NSString* const CDVRemoteNotificationError;


@implementation RongCloudAppEventReceiver
- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveLocalNotification:) name:CDVLocalNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRegisterForRemoteNotificationsWithDeviceToken:) name:CDVRemoteNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didApplicationEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willApplicationEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
        [RongCloudApplicationHandler didApplicationFinishLaunchingWithOptions:nil];
    }
    return self;
}
- (void)didReceiveLocalNotification:(UILocalNotification*)notification {

}
- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSNotification*)notification {
    NSString *deviceToken = notification.object;
    [RongCloudApplicationHandler didApplicationRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}
- (void)didApplicationEnterBackground {
    [RongCloudApplicationHandler didApplicationEnterBackground];
}

- (void)willApplicationEnterForeground {
    [RongCloudApplicationHandler willApplicationEnterForeground];
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
