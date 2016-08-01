
//
//  RCFileMessage.h
//  RongIMLib
//
//  Created by 珏王 on 16/5/23.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>

/*!
 发送文件消息的类型名
 */
#define RCFileMessageTypeIdentifier @"RC:SFMsg"

@interface RCFileMessage : RCMessageContent

/*!
 文件的本地路径
 */
@property(nonatomic, strong) NSString *filePath;

/*!
 发送文件消息的附加信息
 */
@property(nonatomic, strong) NSString *extra;

/*!
 初始化发送文件消息
 
 @param filePath 文件的本地路径
 @return         发送文件消息对象
 */
+ (instancetype)messageWithFile:(NSString *)filePath;

@end

