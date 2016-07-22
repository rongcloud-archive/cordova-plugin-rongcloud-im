//
//  RongCloudJsonUtils.m
//  UZApp
//
//  Created by MiaoGuangfa on 12/19/14.
//  Copyright (c) 2014 APICloud. All rights reserved.
//

#import "RongCloudModel.h"
#import <RongIMLib/RongIMLib.h>
//#import "RCTextMessage.h"
//#import "RCImageMessage.h"
//#import "RCVoiceMessage.h"
//#import "RCLocationMessage.h"
//#import "RCRichContentMessage.h"
//#import "RCDiscussionNotification.h"
//#import "RCInformationNotificationMessage.h"
#import <CommonCrypto/CommonDigest.h>

#define RC_KIT_LOCAL_NOTIFICATION_TAG 9999

@implementation RongCloudModel
+ (NSString *) md5:(NSString *) input
{
    const char *cStr = [input UTF8String];
    CC_LONG len = (CC_LONG)strlen(cStr);
    unsigned char digest[16];
    CC_MD5( cStr, len, digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
    
}
+(NSString*) sha1:(NSData*)input
{
    //const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
   // NSData *data = [NSData dataWithBytes:cstr length:input.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(input.bytes, (CC_LONG)input.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
    
}

+ (NSString *)formatNotificationMessage:(RCMessageContent *)messageContent
{
    NSString * localizedDescription = @"";
    if ([messageContent isMemberOfClass:RCDiscussionNotificationMessage.class]) {
        localizedDescription = @"[讨论组新信息]";
    }
    else if ([messageContent isMemberOfClass:RCImageMessage.class]) {
        localizedDescription = @"［图片］";//NSLocalizedString(@"［图片］", nil);
    } else if ([messageContent isMemberOfClass:RCTextMessage.class]) {
        RCTextMessage* textContent = (RCTextMessage*)messageContent;
        localizedDescription = textContent.content;
    } else if ([messageContent isMemberOfClass:RCVoiceMessage.class]) {
        localizedDescription = @"［语音］";//NSLocalizedString(@"［语音］", nil);
    } else if ([messageContent isMemberOfClass:RCRichContentMessage.class]) {
        localizedDescription = @" [图文] ";//NSLocalizedString(@" [图文] ",nil);
    }
    else if ([messageContent isMemberOfClass:RCLocationMessage.class]) {
        localizedDescription = @" [位置] ";//NSLocalizedString(@" [位置] ", nil);
    }else if([messageContent isMemberOfClass:RCInformationNotificationMessage.class]){
        
        RCInformationNotificationMessage  *msg = (RCInformationNotificationMessage*)messageContent;
        
        localizedDescription =msg.message;
    }
    return localizedDescription;
}
+ (void)cancelLocalNotification
{
    NSArray* myArray = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (int i = 0; i < [myArray count]; i++) {
        UILocalNotification* myUILocalNotification = myArray[i];
        if ([[myUILocalNotification userInfo][@"key1"] intValue] == RC_KIT_LOCAL_NOTIFICATION_TAG) {
            [[UIApplication sharedApplication] cancelLocalNotification:myUILocalNotification];
        }
    }
}

+ (void)postLocalNotification:(NSString*)msg
{
    [RongCloudModel cancelLocalNotification];
    
    UILocalNotification *localNotify = [[UILocalNotification alloc] init];
    
    NSDate* now1 = [NSDate date];
    localNotify.timeZone = [NSTimeZone defaultTimeZone];
    localNotify.repeatInterval = kCFCalendarUnitEra;
    localNotify.alertAction = NSLocalizedString(@"显示", nil);
    localNotify.alertBody = msg;
    localNotify.fireDate = [now1 dateByAddingTimeInterval:1];
    
    [localNotify setSoundName:UILocalNotificationDefaultSoundName];
    NSDictionary* dict = @{ @"key1" : [NSString stringWithFormat:@"%d", RC_KIT_LOCAL_NOTIFICATION_TAG] };
    [localNotify setUserInfo:dict];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotify];
}

+ (NSString *) saveMessageDataToLocalPath:(NSData *)messageData
{
    
    
    NSArray *array =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
   // NSString *str_data = [[NSString alloc]initWithData:messageData encoding:NSUTF8StringEncoding];
    
    NSString *fileName = [RongCloudModel sha1:messageData];//[RongCloudModel md5:str_data];
    
//    NSNumber *numberObj = @([messageData hash]);
//    NSString *fileName = [numberObj stringValue];
    
    
    NSString *path = [[array objectAtIndex:0] stringByAppendingPathComponent:fileName];
    
    [messageData writeToFile:path atomically:YES];
    NSLog(@"saveMessageDataToLocalPath > path >>%@", path);
    return path;
}
+ (RCConversationType)RCTransferConversationType:(NSString *)oldValue
{
    RCConversationType newConversationType;
    if ([oldValue isEqualToString:@"PRIVATE"]) {
        newConversationType = ConversationType_PRIVATE;
    }else if ([oldValue isEqualToString:@"GROUP"])
    {
      newConversationType = ConversationType_GROUP;
    }else if ([oldValue isEqualToString:@"DISCUSSION"])
    {
        newConversationType = ConversationType_DISCUSSION;
    }else if ([oldValue isEqualToString:@"CHATROOM"])
    {
        newConversationType = ConversationType_CHATROOM;
    }else if ([oldValue isEqualToString:@"CUSTOMER_SERVICE"])
    {
        newConversationType = ConversationType_CUSTOMERSERVICE;
    }else if ([oldValue isEqualToString:@"SYSTEM"] ||
              [oldValue isEqualToString:@"system"]) //小写的system是为了兼容历史遗留问题。
    {
        newConversationType = ConversationType_SYSTEM;
    }
    return newConversationType;
}
+ (RCSentStatus)RCTransferSendStatusFromString:(NSString *)stringStatus
{
    RCSentStatus status = SentStatus_FAILED;
    if ([stringStatus isEqualToString:@"SENDING"]) {
        status = SentStatus_SENDING;
    }else if ([stringStatus isEqualToString:@"SENT"])
    {
        status= SentStatus_SENT;
    }else if ([stringStatus isEqualToString:@"FAILED"])
    {
        status = SentStatus_FAILED;
    }else if ([stringStatus isEqualToString:@"RECEIVE"])
    {
        status = SentStatus_RECEIVED;
    }else if ([stringStatus isEqualToString:@"READ"])
    {
        status = SentStatus_READ;
    }else if ([stringStatus isEqualToString:@"DESTROYED"])
    {
        status = SentStatus_DESTROYED;
    }
    return status;
}

+ (NSString *)RCTransferSendStatus:(RCSentStatus)status
{
    NSString *stringStatus = @"SENT";
    if (status == SentStatus_SENT) {
        stringStatus = @"SENDING";
    } else if (status == SentStatus_SENT) {
        stringStatus = @"SENT";
    } else if (status == SentStatus_FAILED) {
        stringStatus = @"FAILED";
    } else if (status == SentStatus_RECEIVED) {
        stringStatus = @"RECEIVE";
    } else if (status == SentStatus_READ) {
        stringStatus = @"READ";
    } else if (status == SentStatus_DESTROYED) {
        stringStatus = @"DESTROYED";
    }
    return stringStatus;
}
+ (RCReceivedStatus)RCTransferReceivedStatusFromString:(NSString *)stringStatus
{
    RCReceivedStatus status = ReceivedStatus_UNREAD;
    if ([stringStatus isEqualToString:@"READ"]) {
        status = ReceivedStatus_READ;
    }else if ([stringStatus isEqualToString:@"LISTENED"])
    {
        status= ReceivedStatus_READ | ReceivedStatus_LISTENED ;
    }else if ([stringStatus isEqualToString:@"DOWNLOADED"])
    {
        status= ReceivedStatus_READ | ReceivedStatus_DOWNLOADED ;
    }
    return status;
}

+ (NSString *)RCTransferReceivedStatus:(RCReceivedStatus)status
{
    NSString *stringStatus = @"UNREAD";
    if (status == ReceivedStatus_READ) {
        stringStatus = @"READ";
    } else if (status & ReceivedStatus_LISTENED) {
        stringStatus = @"LISTENED";
    } else if (status & ReceivedStatus_DOWNLOADED) {
        stringStatus = @"DOWNLOADED";
    }
    return stringStatus;
}
+ (NSString *)RCTransferConnectionStatus:(RCConnectionStatus)status {
    switch (status) {
        case ConnectionStatus_Connected:
            return @"CONNECTED";
        case ConnectionStatus_KICKED_OFFLINE_BY_OTHER_CLIENT:
            return @"KICKED";
        case ConnectionStatus_Connecting:
            return @"CONNECTING";
        case ConnectionStatus_TOKEN_INCORRECT:
            return @"TOKEN_INCORRECT";
        case ConnectionStatus_SignUp:
            return @"DISCONNECTED";
        case ConnectionStatus_SERVER_INVALID:
            return @"SERVER_INVALID";
        default:
            return @"NETWORK_UNAVAILABLE";
    }
}
+ (NSDictionary *)createContentModel:(RCMessageContent *)messageContent
{
    if (!messageContent) {
        return nil;
    }
    NSDictionary * _content;
    if ([messageContent isKindOfClass:[RCTextMessage class]]) {
        RCTextMessage *textMsg = (RCTextMessage*)messageContent;

        _content = @{
                     @"text" : [RongCloudModel transferNULLToExptyString:textMsg.content],
                     @"extra": [RongCloudModel transferNULLToExptyString:textMsg.extra]
                     };
    }else if ([messageContent isKindOfClass:[RCImageMessage class]])
    {
        RCImageMessage *imgMsg = (RCImageMessage *)messageContent;
        
        NSData *_data = UIImageJPEGRepresentation(imgMsg.thumbnailImage, 0);
        NSString *_path = [RongCloudModel saveMessageDataToLocalPath:_data];
    
        _content = @{
                     @"imageUrl" : [RongCloudModel transferNULLToExptyString:imgMsg.imageUrl],
                     @"thumbPath": [RongCloudModel transferNULLToExptyString:_path],//存储路径
                     @"extra": [RongCloudModel transferNULLToExptyString:imgMsg.extra]
                     };
    }else if ([messageContent isKindOfClass:[RCVoiceMessage class]])
    {
        RCVoiceMessage *voiceMsg = (RCVoiceMessage *)messageContent;
        
        NSString *_path = @"";
        _path = [RongCloudModel saveMessageDataToLocalPath:voiceMsg.wavAudioData];
        
        
        _content = @{
                     @"voicePath": [RongCloudModel transferNULLToExptyString:_path],//存储路径
                     @"duration" : @(voiceMsg.duration),
                     @"extra": [RongCloudModel transferNULLToExptyString:voiceMsg.extra]
                     };
    }else if ([messageContent isKindOfClass:[RCLocationMessage class]])
    {
        RCLocationMessage *localMsg = (RCLocationMessage *)messageContent;
        CLLocationCoordinate2D location = localMsg.location;
        
        NSData *_data = UIImageJPEGRepresentation(localMsg.thumbnailImage, 0);
        NSString *_path = [RongCloudModel saveMessageDataToLocalPath:_data];
        
        _content = @{
                     @"latitude": @(location.latitude),
                     @"longitude" : @(location.longitude),
                     @"poi" : [RongCloudModel transferNULLToExptyString:localMsg.locationName],
                     @"imagePath":[RongCloudModel transferNULLToExptyString:_path],//存储路径
                     @"extra": [RongCloudModel transferNULLToExptyString:localMsg.extra]
                     };
    }else if ([messageContent isKindOfClass:[RCRichContentMessage class]])
    {
        RCRichContentMessage *richMsg = (RCRichContentMessage *)messageContent;
        _content = @{
                     @"title" : [RongCloudModel transferNULLToExptyString:richMsg.title],
                     @"description": [RongCloudModel transferNULLToExptyString:richMsg.digest],
                     @"imageUrl":[RongCloudModel transferNULLToExptyString:richMsg.imageURL],
                     @"extra": [RongCloudModel transferNULLToExptyString:richMsg.extra],
                     @"url" : [RongCloudModel transferNULLToExptyString:richMsg.url]
                     };
    }else{
        NSData *encodeData = [messageContent encode];
        _content = [NSJSONSerialization JSONObjectWithData:encodeData options:NSJSONReadingMutableContainers error:nil];
    }
    
    return _content;
}
+ (NSString *)transferNULLToExptyString:(NSString *)value
{
    NSString *_newValue = @"";
    if (value == nil) {
        return _newValue;
    }
    return value;
}
+ (NSString *)RCTransferConversationTypeToString:(RCConversationType)type
{
    NSString *_default = @"";
    if (type == ConversationType_PRIVATE) {
        _default = @"PRIVATE";
    }else if (type == ConversationType_GROUP)
    {
        _default = @"GROUP";
    }else if (type == ConversationType_DISCUSSION)
    {
        _default = @"DISCUSSION";
    }else if (type == ConversationType_CHATROOM)
    {
        _default = @"CHATROOM";
    }else if (type == ConversationType_CUSTOMERSERVICE)
    {
        _default = @"CUSTOMER_SERVICE";
    }else if (type == ConversationType_SYSTEM)
    {
        _default = @"SYSTEM";
    }
    return _default;
}
/*+ (NSString *)RCGenerateResultJSONString:(id)result withSuccess:(BOOL)success
{
    if (!result) result = @"";
    
    NSDictionary *_ret = @{@"result": result, @"status": @(success)};
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:_ret options:NSJSONWritingPrettyPrinted error:nil];
    NSString *_jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    return _jsonString;
}*/

+ (NSString *)RCGenerateResultJSONString:(id)result withStatus:(NSString *)status
{
    if (!result) result = @"";
    
    NSDictionary *_ret = @{@"status": status, @"result": result};
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:_ret options:NSJSONWritingPrettyPrinted error:nil];
    NSString *_jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    return _jsonString;
}
+ (NSDictionary *)RCGenerateConversationModel:(RCConversation *)conversation
{
    if (!conversation) return ([NSDictionary new]);
    
//    if (!conversation.lastestMessage) {
//        return nil;
//    }
    
    NSString *_conversation_type = [RongCloudModel RCTransferConversationTypeToString:conversation.conversationType];

    NSDictionary *_content = [RongCloudModel createContentModel:conversation.lastestMessage];
    
    NSDictionary *_ret = @{
                           @"conversationTitle"     :   conversation.conversationTitle,
                           @"conversationType"      :   _conversation_type,
                           @"draft"                 :   conversation.draft,
                           @"targetId"              :   conversation.targetId,
                           /*@"latestMessage"         :   @{
                                   @"content": _content//conversation.jsonDict
                                   },*/
                           @"latestMessage"         : _content?_content:@"",
                           @"sentStatus"            :   conversation.sentStatus==SentStatus_SENDING?@"SENDING":conversation.sentStatus==SentStatus_SENT?@"SENT":@"FAILED",
                           //@"notificationStatus"    :   @(conversation.), // No this tag for ios version, need to confirm -- miaoguangfa
                           @"objectName"            :   conversation.objectName,
                           @"receivedStatus"        :   [self RCTransferReceivedStatus:conversation.receivedStatus],
                           //@"senderUserName"        :   conversation.senderUserName,
                           @"senderUserId"          :   conversation.senderUserId,
                           @"unreadMessageCount"    :   @(conversation.unreadMessageCount),
                           @"receivedTime"          :   @(conversation.receivedTime),
                           @"sentTime"              :   @(conversation.sentTime),
                           @"isTop"                 :   @(conversation.isTop),
                           @"latestMessageId"       :   @(conversation.lastestMessageId)
                           
                           };
    return _ret;
}
+ (NSMutableArray *)RCGenerateConversationListModel:(NSArray *)conversationList
{
    if (!conversationList || 0 == [conversationList count]) return ([NSMutableArray new]);
    
    NSMutableArray *_ret = [[NSMutableArray alloc] init];
    
    NSInteger _count = [conversationList count];
    
    for (int index = 0; index < _count; index++) {
        RCConversation *_conversation       = [conversationList objectAtIndex:index];
        NSDictionary *_conversationModel    = [RongCloudModel RCGenerateConversationModel:_conversation];
        if (_conversationModel) {
            [_ret addObject: _conversationModel];
        }
    }
    return _ret;
}

+ (NSDictionary *)RCGenerateMessageModel:(RCMessage *)message
{
    if (!message) return ([NSDictionary new]);
    
    NSDictionary *_content = [RongCloudModel createContentModel:message.content];
    
    NSString *_sentStatus = nil;
    if(SentStatus_SENDING == message.sentStatus)
    {
        _sentStatus = @"SENDING";
    }else if (SentStatus_SENT == message.sentStatus)
    {
        _sentStatus = @"SENT";
    }else if (SentStatus_FAILED == message.sentStatus)
    {
        _sentStatus = @"FAILED";
    }
    
    NSString *_msgDirection = nil;
    if (MessageDirection_RECEIVE == message.messageDirection) {
        _msgDirection = @"RECEIVE";
    }else if (MessageDirection_SEND == message.messageDirection)
    {
        _msgDirection = @"SEND";
    }
    NSString *_conversation_type = [RongCloudModel RCTransferConversationTypeToString:message.conversationType];
    NSDictionary *_ret = @{
                           @"conversationType"      :   _conversation_type,
                           @"targetId"              :   message.targetId,
                           @"messageId"             :   @(message.messageId),
                           @"messageDirection"      :   _msgDirection,//@(message.messageDirection),
                           @"senderUserId"          :   message.senderUserId,
                           @"receivedStatus"        :   [self RCTransferReceivedStatus:message.receivedStatus],
                           @"sentStatus"            :   _sentStatus,//@(message.sentStatus),
                           @"receivedTime"          :   @(message.receivedTime),
                           @"sentTime"              :   @(message.sentTime),
                           @"objectName"            :   message.objectName,
                           @"extra"                 :   message.extra == nil?@"":message.extra,
                           @"content"               :   _content
    
                           };
    
    return _ret;
}

+ (NSMutableArray *)RCGenerateMessageListModel:(NSArray *)messageList
{
    if (!messageList || 0 == [messageList count]) return ([[NSMutableArray alloc]init]);
    
    NSMutableArray *_ret = [[NSMutableArray alloc]init];
    NSInteger _count = [messageList count];
    
    for (int index = 0; index < _count; index++ ) {
        RCMessage *_message = [messageList objectAtIndex:index];
        NSDictionary *_messageModel = [RongCloudModel RCGenerateMessageModel:_message];
        if (_messageModel) {
            [_ret addObject:_messageModel];
        }
    }
    return _ret;
}

+ (NSDictionary *)RCGenerateMessageContentModel:(RCMessageContent *)messageContent
{
    if (!messageContent) {
        return ([NSDictionary new]);
    }
    NSMutableDictionary * dic = nil;
    
    NSData *__data = [messageContent encode ];
    
    //NSString *__jsonString = [[NSString alloc]initWithData:__data encoding:NSUTF8StringEncoding];
    __autoreleasing NSError* error = nil;
    dic = [NSJSONSerialization JSONObjectWithData:__data
                                          options:kNilOptions
                                            error:&error];
    
    return dic;
}


+ (NSDictionary *)RCGenerateDiscussionModel:(RCDiscussion *)discussion
{
    if (!discussion) return ([NSDictionary new]);
    BOOL isOpen = (BOOL)discussion.inviteStatus;
    NSString * _inviteStatus = @"";
    if (!isOpen) {
        _inviteStatus = @"OPENED";
    }else{
        _inviteStatus = @"CLOSED";
    }
    NSDictionary *_ret = @{
                                @"id"                   : discussion.discussionId,
                                @"name"                 : discussion.discussionName,
                                @"creatorId"            : discussion.creatorId,
                               // @"conversationType"     : @(discussion.conversationType),
                                @"memberIdList"         : discussion.memberIdList,
                                @"inviteStatus"         : _inviteStatus,
                                //@"pushMessageNotificationStatus" : @(discussion.pushMessageNotificationStatus)
                           };
    return _ret;
}
+ (NSDictionary *)RCGenerateUserInfoModel:(RCUserInfo *)userInfo
{
    if (!userInfo) {
        return ([NSDictionary new]);
    }
    
    NSDictionary *_ret = @{
                                @"userId"       : userInfo.userId,
                                @"name"         : userInfo.name,
                                @"portraitUri"  : userInfo.portraitUri
                           };
    return _ret;
}

+ (NSMutableArray *)RCGenerateGroupList:(NSArray *)grouplist
{
    if (nil == grouplist || [grouplist count] == 0) {
        return ([NSMutableArray new]);
    }
    
    NSMutableArray * result = [NSMutableArray new];
    int _count = (int)[grouplist count];
    for (int i=0; i< _count; i++) {
        NSDictionary *_dic  = grouplist[i];
        NSString *_id       = _dic[@"groupId"];
        NSString *_name     = _dic[@"groupName"];
        NSString *_portraitUrl = _dic[@"portraitUrl"];
        
        if (![_id isKindOfClass:[NSString class ]] ||
            ![_name isKindOfClass:[NSString class ]] ||
            ![_portraitUrl isKindOfClass:[NSString class ]]) {
            return nil;
        }
        
        RCGroup *group = [[RCGroup alloc]initWithGroupId:_dic[@"groupId"] groupName:_dic[@"groupName"] portraitUri:_dic[@"portraitUrl"]];
        [result addObject:group];
    }
    
    return result;
}


+ (NSData*)compressedImageAndScalingSize:(UIImage*)image targetSize:(CGSize)targetSize percent:(CGFloat)percent
{
    
    UIImage* reScaledImage = [RongCloudModel imageByScalingAndCropSize:image targetSize:targetSize];
    // UIImage* reScaledImage = [RCUtilities scaleToSize:targetSize original:image];
    return UIImageJPEGRepresentation(reScaledImage, percent);
}
+ (UIImage*)imageByScalingAndCropSize:(UIImage *)image targetSize:(CGSize)targetSize
{
    UIImage *sourceImage = image;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor < heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if (widthFactor < heightFactor)
        {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContext(CGSizeMake(scaledWidth, scaledHeight)); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

@end
