//
//  RCCommandMessage.h
//  RongIMLib
//
//  Created by 张改红 on 15/12/2.
//  Copyright © 2015年 RongCloud. All rights reserved.
//
#import "RCMessageContent.h"

#define RCCommandMessageIdentifier @"RC:CmdMsg"
/**
 *  此消息不计数不保存，可用于传递命令，而消息不展示
 */
@interface RCCommandMessage : RCMessageContent
/**
 *  命令名。
 */
@property(nonatomic, strong) NSString *name;
/**
 *  命令数据，可以为任意格式，如 JSON。
 */
@property(nonatomic, strong) NSString *data;
/**
 *  构造方法
 *
 *  @param name 命令名。
 *  @param data 命令数据，可以为任意格式，如 JSON。
 *
 *  @return 类实例
 */
+ (instancetype)messageWithName:(NSString *)name data:(NSString *)data;

@end
