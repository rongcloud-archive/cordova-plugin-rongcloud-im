//
//  RCMentionedInfo.h
//  RongIMLib
//
//  Created by 杜立召 on 16/7/6.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCStatusDefine.h"
#import <Foundation/Foundation.h>

/*!
 消息中的@提醒信息
 */
@interface RCMentionedInfo : NSObject

/*!
 @提醒的类型
 */
@property(nonatomic, assign) RCMentionedType type;

/*!
 @的用户ID列表

 @discussion 如果type是@所有人，则可以传nil
 */
@property(nonatomic, assign) NSArray *userIdList;

/*!
 包含@提醒的消息，本地通知和远程推送显示的内容
 */
@property(nonatomic, assign) NSString *mentionedContent;

/*!
 初始化@提醒信息
 
 @param type       @提醒的类型
 @param userIdList @的用户ID列表
 
 @return @提醒信息的对象
 */
- (instancetype)initWithMentionedType:(RCMentionedType)type
                           userIdList:(NSArray *)userIdList
                     mentionedContent:(NSString *)mentionedContent;

@end
