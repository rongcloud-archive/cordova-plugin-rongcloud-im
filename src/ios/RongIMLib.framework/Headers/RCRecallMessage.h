//
//  RCRecallMessage.h
//  RongIMLib
//
//  Created by 杜立召 on 16/1/25.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCMessageContent.h"
#import <Foundation/Foundation.h>
/*!
 命令消息的类型名
 */
#define RCRecallMessageIdentifier @"RC:RC"

/*!
 命令消息类

 @discussion 命令消息类，此消息不存储不计入未读消息数。
 与RCCommandNotificationMessage的区别是，此消息不存储，也不会在界面上显示。
 */
@interface RCRecallMessage : RCMessageContent

/*!
 消息的发送时间
 */
@property(nonatomic, assign) long long serverSentTime;

//liulin add
/*!
 要撤回的消息id
 */
//@property(nonatomic, assign) long messageId;
@property(nonatomic, copy) NSString *messageUId;

///*!
// 消息的发送者ID
// */
//@property(nonatomic, copy) NSString *senderUserId;

/*!
 操作者的用户ID
 */
@property(nonatomic, strong) NSString *operatorId;


@end
