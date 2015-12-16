//
//  RongCloudJsonUtils.h
//  UZApp
//
//  Created by MiaoGuangfa on 12/19/14.
//  Copyright (c) 2014 APICloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <RongIMLib/RongIMLib.h>

static NSString * const SUCCESS     =   @"success";
static NSString * const ERROR       =   @"error";
static NSString * const PROGRESS    =   @"progress";
static NSString * const PREPARE     =   @"prepare";

@interface RongCloudModel : NSObject

+ (RCConversationType) RCTransferConversationType:(NSString *) oldValue;

+ (NSString *) RCGenerateResultJSONString:(id)result withStatus:(NSString *)status;

+ (NSDictionary *) RCGenerateConversationModel:(RCConversation *)conversation;
+ (NSMutableArray *) RCGenerateConversationListModel:(NSArray *) conversationList;


+ (RCSentStatus)RCTransferSendStatusFromString:(NSString *)stringStatus;
+ (NSString *)RCTransferSendStatus:(RCSentStatus)status;

+ (RCReceivedStatus)RCTransferReceivedStatusFromString:(NSString *)stringStatus;
+ (NSString *)RCTransferReceivedStatus:(RCReceivedStatus)status;

+ (NSString *)RCTransferConnectionStatus:(RCConnectionStatus)status;

+ (NSDictionary *) RCGenerateMessageModel:(RCMessage *)message;
+ (NSMutableArray *) RCGenerateMessageListModel:(NSArray *)messageList;
+ (NSDictionary *)RCGenerateMessageContentModel:(RCMessageContent *)messageContent;

+ (NSDictionary *) RCGenerateDiscussionModel:(RCDiscussion *)discussion;

+ (NSDictionary *) RCGenerateUserInfoModel:(RCUserInfo *)userInfo;

+(NSMutableArray *)RCGenerateGroupList:(NSArray *)grouplist;

+ (NSData*)compressedImageAndScalingSize:(UIImage*)image targetSize:(CGSize)targetSize percent:(CGFloat)percent;
+ (UIImage*)imageByScalingAndCropSize:(UIImage *)image targetSize:(CGSize)targetSize;
+ (NSString *) RCTransferConversationTypeToString:(RCConversationType) type;
+ (NSString *) transferNULLToExptyString:(NSString *)value;
+ (void)postLocalNotification:(NSString*)msg;
+ (void)cancelLocalNotification;
+ (NSString *)formatNotificationMessage:(RCMessageContent *)messageContent;

@end
