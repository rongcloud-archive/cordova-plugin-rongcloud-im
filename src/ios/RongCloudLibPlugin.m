//
//  RongCloudModule.m
//  UZApp
//
//  Created by xugang on 14/12/17.
//  Copyright (c) 2014年 APICloud. All rights reserved.
//

#import "RongCloudLibPlugin.h"
#import "RongCloudHybridAdapter.h"
#import "RongCloudAppEventReceiver.h"

@interface RongCloudLibPlugin () <RongCloud2HybridDelegation>
@property (nonatomic, strong)RongCloudHybridAdapter *rongCloudAdapter;
@property (nonatomic, strong)RongCloudAppEventReceiver *appEventReceiver;
@end


@implementation RongCloudLibPlugin

- (instancetype)initWithWebView:(UIWebView*)theWebView {
  if ([super respondsToSelector:@selector(initWithWebView:)]) {
    self = [super initWithWebView:theWebView];
  } else {
    self = [super init];
  }
  
  if (self) {
    self.appEventReceiver = [[RongCloudAppEventReceiver alloc] init];
  }
  return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.appEventReceiver = [[RongCloudAppEventReceiver alloc] init];
    }
    return self;
}


#pragma mark private methods
- (RongCloudHybridAdapter *)rongCloudAdapter {
    if (!_rongCloudAdapter) {
        _rongCloudAdapter = [[RongCloudHybridAdapter alloc] initWithDelegate:self];
    }
    return _rongCloudAdapter;
}
- (void)sendResult:(NSDictionary *)resultDict error:(NSDictionary *)errorDict withCallbackId:(id)callbackId doDelete:(BOOL)doDelete {
    if (errorDict) {
        id code = errorDict[@"code"];
        id msg = errorDict[@"msg"];
        if (code) {
            resultDict = [resultDict mutableCopy];
            [resultDict setValue:code forKey:@"code"];
            [resultDict setValue:msg?msg:@"" forKey:@"msg"];
        }
    }
    CDVPluginResult *pluginResult;
    if (! errorDict) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDict];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:resultDict];
    }
    
    [pluginResult setKeepCallbackAsBool:!doDelete];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}
- (NSString *)getAbsolutePath:(NSString *)relativePath {
    return relativePath;
}

# pragma mark Public methods
/**
 * initialize & connection
 */
- (void)init:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    NSString *_appkey = [command argumentAtIndex:0 withDefault:nil];
    NSString *_deviceToken = [command argumentAtIndex:1 withDefault:nil];
    NSLog(@"_appkey >> %@, %@", _appkey, _deviceToken);

    if (command.callbackId) {
        [self.rongCloudAdapter init:_appkey callbackId:command.callbackId];
    }
}

- (void)connect:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    
    NSString *token = [command argumentAtIndex:0 withDefault:nil];
    if (command.callbackId) {
        [self.rongCloudAdapter connectWithToken:token callbackId:command.callbackId];
    }
}

- (void)disconnect:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
  
    NSNumber *isReceivePush = [command argumentAtIndex:0 withDefault:nil];
    if (command.callbackId) {
        [self.rongCloudAdapter disconnect:isReceivePush callbackId:command.callbackId];
    }
}

- (void)setConnectionStatusListener:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    if (command.callbackId) {
        [self.rongCloudAdapter setConnectionStatusListener:command.callbackId];
    }
}

- (void)onConnectionStatusChanged:(RCConnectionStatus)status {
    [self.rongCloudAdapter onConnectionStatusChanged:status];
}
/**
 * message send & receive
 */
- (void)sendTextMessage:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    
    NSString * _conversationTypeString = [command argumentAtIndex:0 withDefault:nil];
    NSString *_targetId                = [command argumentAtIndex:1 withDefault:nil];
    NSString *_content                 = [command argumentAtIndex:2 withDefault:nil];
    NSString *_extra                   = [command argumentAtIndex:3 withDefault:nil];
    
    if (command.callbackId) {
        [self.rongCloudAdapter sendTextMessage:_conversationTypeString targetId:_targetId content:_content extra:_extra callbackId:command.callbackId];
    }
    
}

- (void)sendImageMessage : (CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);

    NSString * _conversationTypeString = [command argumentAtIndex:0 withDefault:nil];
    NSString *_targetId                = [command argumentAtIndex:1 withDefault:nil];
    NSString *_imagepath                 = [command argumentAtIndex:2 withDefault:nil];
    NSString *_extra                   = [command argumentAtIndex:3 withDefault:nil];
    
    if (command.callbackId) {
        [self.rongCloudAdapter sendImageMessage:_conversationTypeString targetId:_targetId imagePath:_imagepath extra:_extra callbackId:command.callbackId];
    }
}

- (void)sendVoiceMessage:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);

    NSString * _conversationTypeString = [command argumentAtIndex:0 withDefault:nil];
    NSString *_targetId                = [command argumentAtIndex:1 withDefault:nil];
    NSString *_voicePath               = [command argumentAtIndex:2 withDefault:nil];
    NSNumber *_duration                = [command argumentAtIndex:3 withDefault:nil];
    NSString *_extra                   = [command argumentAtIndex:4 withDefault:nil];
        
    if (command.callbackId) {
        [self.rongCloudAdapter sendVoiceMessage:_conversationTypeString targetId:_targetId voicePath:_voicePath duration:_duration extra:_extra callbackId:command.callbackId];
    }
}

- (void)sendLocationMessage:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);

    NSString * _conversationTypeString = [command argumentAtIndex:0 withDefault:nil];
    NSString *_targetId                = [command argumentAtIndex:1 withDefault:nil];
    NSNumber *_latitude                = [command argumentAtIndex:2 withDefault:nil];
    NSNumber *_longitude               = [command argumentAtIndex:3 withDefault:nil];
    NSString *_locationName            = [command argumentAtIndex:4 withDefault:nil];
    NSString *_imagePath               = [command argumentAtIndex:5 withDefault:nil];
    NSString *_extra                   = [command argumentAtIndex:6 withDefault:nil];
    
    if (command.callbackId) {
        [self.rongCloudAdapter sendLocationMessage:_conversationTypeString targetId:_targetId imagePath:_imagePath latitude:_latitude longitude:_longitude locationName:_locationName extra:_extra callbackId:command.callbackId];
    }
}

- (void)sendRichContentMessage : (CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);

    NSString * _conversationTypeString = [command argumentAtIndex:0 withDefault:nil];
    NSString *_targetId                = [command argumentAtIndex:1 withDefault:nil];
    NSString *_tiltle                  = [command argumentAtIndex:2 withDefault:nil];
    NSString *_content                 = [command argumentAtIndex:3 withDefault:nil];
    NSString *_imageUrl                = [command argumentAtIndex:4 withDefault:nil];
    NSString *_extra                   = [command argumentAtIndex:5 withDefault:nil];
    
    if (command.callbackId) {
        [self.rongCloudAdapter sendRichContentMessage:_conversationTypeString targetId:_targetId title:_tiltle content:_content imageUrl:_imageUrl extra:_extra callbackId:command.callbackId];
    }
}
-(void)sendCommandNotificationMessage : (CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);

    NSString * _conversationTypeString = [command argumentAtIndex:0 withDefault:nil];
    NSString *_targetId                = [command argumentAtIndex:1 withDefault:nil];
    NSString *_name                    = [command argumentAtIndex:2 withDefault:nil];
    NSString *_data                    = [command argumentAtIndex:3 withDefault:nil];
    
    if (command.callbackId) {
        [self.rongCloudAdapter sendCommandNotificationMessage:_conversationTypeString targetId:_targetId name:_name data:_data callbackId:command.callbackId];
    }
}
-(void)sendCommandMessage : (CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    
    NSString * _conversationTypeString = [command argumentAtIndex:0 withDefault:nil];
    NSString *_targetId                = [command argumentAtIndex:1 withDefault:nil];
    NSString *_name                    = [command argumentAtIndex:2 withDefault:nil];
    NSString *_data                    = [command argumentAtIndex:3 withDefault:nil];
    
    if (command.callbackId) {
        [self.rongCloudAdapter sendCommandMessage:_conversationTypeString targetId:_targetId name:_name data:_data callbackId:command.callbackId];
    }
}
- (void)setOnReceiveMessageListener:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    
    if (command.callbackId) {
        [self.rongCloudAdapter setOnReceiveMessageListener:command.callbackId];
    }
}

- (void)onReceived:(RCMessage *)message left:(int)nLeft object:(id)object {
    [self.rongCloudAdapter onReceived:message left:nLeft object:object];
}

/**
 * conversation
 */
- (void)getConversationList:(CDVInvokedUrlCommand *)command
{
    if (command.callbackId) {
        [self.rongCloudAdapter getConversationList:command.callbackId];
    }
    
}

- (void)getConversation:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);

    NSString * _conversationTypeString = [command argumentAtIndex:0 withDefault:nil];
    NSString *_targetId                = [command argumentAtIndex:1 withDefault:nil];

    if (command.callbackId) {
        [self.rongCloudAdapter getConversation:_conversationTypeString targetId:_targetId callbackId:command.callbackId];
    }
}

- (void)removeConversation:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);

    NSString * _conversationTypeString = [command argumentAtIndex:0 withDefault:nil];
    NSString *_targetId                = [command argumentAtIndex:1 withDefault:nil];
    
    if (command.callbackId) {
        [self.rongCloudAdapter removeConversation:_conversationTypeString targetId:_targetId callbackId:command.callbackId];
    }
}

- (void)clearConversations: (CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);

    NSArray *__conversationTypes = [command argumentAtIndex:0 withDefault:nil];
    if (command.callbackId) {
        [self.rongCloudAdapter clearConversations:__conversationTypes callbackId:command.callbackId];
    }
}

- (void)setConversationToTop:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);

    NSString * _conversationTypeString = [command argumentAtIndex:0 withDefault:nil];
    NSString *_targetId                = [command argumentAtIndex:1 withDefault:nil];
    NSNumber * _isTop                  = [command argumentAtIndex:2 withDefault:nil];
    
    if (command.callbackId) {
        [self.rongCloudAdapter setConversationToTop:_conversationTypeString targetId:_targetId isTop:_isTop callbackId:command.callbackId];
    }
}

/**
 * conversation notification
 */
- (void)getConversationNotificationStatus:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);

    NSString * _conversationTypeString = [command argumentAtIndex:0 withDefault:nil];
    NSString *_targetId                = [command argumentAtIndex:1 withDefault:nil];
    
    if (command.callbackId) {
        [self.rongCloudAdapter getConversationNotificationStatus:_conversationTypeString targetId:_targetId callbackId:command.callbackId];
    }
    
}
- (void)setConversationNotificationStatus:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);

    NSString * _conversationTypeString        = [command argumentAtIndex:0 withDefault:nil];
    
    NSString *_targetId                       = [command argumentAtIndex:1 withDefault:nil];
    NSString *_conversationnotificationStatus = [command argumentAtIndex:2 withDefault:nil];
    
 
    if (command.callbackId) {
        [self.rongCloudAdapter setConversationNotificationStatus:_conversationTypeString targetId:_targetId conversationnotificationStatus:_conversationnotificationStatus callbackId:command.callbackId];
    }
}

/**
 * read message & delete
 */
- (void)getLatestMessages:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);

    NSString * _conversationTypeString = [command argumentAtIndex:0 withDefault:nil];
    NSString *_targetId                = [command argumentAtIndex:1 withDefault:nil];
    NSNumber *_count                   = [command argumentAtIndex:2 withDefault:nil];
    
    if (command.callbackId) {
        [self.rongCloudAdapter getLatestMessages:_conversationTypeString targetId:_targetId count:_count callbackId:command.callbackId];
    }
 }

- (void)getHistoryMessages:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);

    NSString * _conversationTypeString = [command argumentAtIndex:0 withDefault:nil];
    NSString *_targetId                = [command argumentAtIndex:1 withDefault:nil];
    NSNumber *_count                   = [command argumentAtIndex:2 withDefault:nil];
    NSNumber *_oldestMessageId         = [command argumentAtIndex:3 withDefault:nil];
    
    if (command.callbackId) {
        [self.rongCloudAdapter getHistoryMessages:_conversationTypeString targetId:_targetId count:_count oldestMessageId:_oldestMessageId callbackId:command.callbackId];
    }
}

- (void)getHistoryMessagesByObjectName:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);

    NSString * _conversationTypeString = [command argumentAtIndex:0 withDefault:nil];
    NSString *_targetId                = [command argumentAtIndex:1 withDefault:nil];
    NSNumber *_count                   = [command argumentAtIndex:2 withDefault:nil];
    NSNumber *_oldestMessageId         = [command argumentAtIndex:3 withDefault:nil];
    NSString *_objectName              = [command argumentAtIndex:4 withDefault:nil];

    if (command.callbackId) {
        [self.rongCloudAdapter getHistoryMessagesByObjectName:_conversationTypeString targetId:_targetId count:_count oldestMessageId:_oldestMessageId objectName:_objectName callbackId:command.callbackId];
    }
}

- (void) deleteMessages:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);

    NSArray *_messageIds = [command argumentAtIndex:0 withDefault:nil];
    
    if (command.callbackId) {
        [self.rongCloudAdapter deleteMessages:_messageIds callbackId:command.callbackId];
    }
}

- (void) clearMessages:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);

    NSString * _conversationTypeString = [command argumentAtIndex:0 withDefault:nil];
    NSString *_targetId = [command argumentAtIndex:1 withDefault:nil];

    if (command.callbackId) {
        [self.rongCloudAdapter clearMessages:_conversationTypeString targetId:_targetId callbackId:command.callbackId];
    }
}

/**
 * unread message count
 */
- (void) getTotalUnreadCount:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    
    if (command.callbackId) {
        [self.rongCloudAdapter getTotalUnreadCount:command.callbackId];
    }
}

- (void) getUnreadCount:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);

    NSString * _conversationTypeString = [command argumentAtIndex:0 withDefault:nil];
    NSString *_targetId = [command argumentAtIndex:1 withDefault:nil];
    
    if (command.callbackId) {
        [self.rongCloudAdapter getUnreadCount:_conversationTypeString targetId:_targetId callbackId:command.callbackId];
    }
}

-(void)getUnreadCountByConversationTypes:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    
    NSArray *nsstring_conversationTypes = [command argumentAtIndex:0 withDefault:nil];
    
    if (command.callbackId) {
        [self.rongCloudAdapter getUnreadCountByConversationTypes:nsstring_conversationTypes callbackId:command.callbackId];
    }
}

/**
 * message status
 */
-(void) setMessageReceivedStatus: (CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    NSNumber *__messageId = [command argumentAtIndex:0 withDefault:nil];
    NSString *__receivedStatus = [command argumentAtIndex:1 withDefault:nil];
    if (command.callbackId) {
        [self.rongCloudAdapter setMessageReceivedStatus:__messageId withReceivedStatus:__receivedStatus withCallBackId:command.callbackId];
    }
}

- (void) clearMessagesUnreadStatus: (CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    
    NSString * _conversationTypeString = [command argumentAtIndex:0 withDefault:nil];
    
    NSString *_targetId = [command argumentAtIndex:1 withDefault:nil];
    
    if (command.callbackId) {
        [self.rongCloudAdapter clearMessagesUnreadStatus:_conversationTypeString withTargetId:_targetId withCallBackId:command.callbackId];
    }
}

-(void) setMessageExtra : (CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    NSNumber *__messageId =[command argumentAtIndex:0 withDefault:nil];
    NSString *__value = [command argumentAtIndex:1 withDefault:nil];
    if (command.callbackId) {
        [self.rongCloudAdapter setMessageExtra:__messageId withValue:__value withCallBackId:command.callbackId];
    }
}

/**
 * message draft
 */
-(void) getTextMessageDraft : (CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    NSString * _conversationTypeString = [command argumentAtIndex:0 withDefault:nil];
    
    NSString *_targetId = [command argumentAtIndex:1 withDefault:nil];
    if (command.callbackId) {
        [self.rongCloudAdapter getTextMessageDraft:_conversationTypeString withTargetId:_targetId withCallBackId:command.callbackId];
    }
}

-(void) saveTextMessageDraft : (CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    NSString * _conversationTypeString = [command argumentAtIndex:0 withDefault:nil];
    NSString *_targetId = [command argumentAtIndex:1 withDefault:nil];
    NSString *_content =  [command argumentAtIndex:2 withDefault:nil];
    if (command.callbackId) {
        [self.rongCloudAdapter saveTextMessageDraft:_conversationTypeString withTargetId:_targetId withContent:_content withCallBackId:command.callbackId];
    }
}

-(void)clearTextMessageDraft : (CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    NSString *conversationTypeString = [command argumentAtIndex:0 withDefault:nil];
    NSString *targetId = [command argumentAtIndex:1 withDefault:nil];
    
    if (command.callbackId) {
        [self.rongCloudAdapter clearTextMessageDraft:conversationTypeString withTargetId:targetId withCallBackId:command.callbackId];
    }
}

/**
 * discussion
 */
- (void) createDiscussion:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    NSString *name = [command argumentAtIndex:0 withDefault:nil];
    NSArray *userIds = [command argumentAtIndex:1 withDefault:nil];
    
    if (command.callbackId) {
        [self.rongCloudAdapter createDiscussion:name withUserIdList:userIds withCallBackId:command.callbackId];
    }
}

-(void)getDiscussion:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    NSString *discussionId = [command argumentAtIndex:0 withDefault:nil];
    
    if (command.callbackId) {
        [self.rongCloudAdapter getDiscussion:discussionId withCallBackId:command.callbackId];
    }
}

-(void)setDiscussionName :(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    NSString *discussionId = [command argumentAtIndex:0 withDefault:nil];
    NSString *name = [command argumentAtIndex:1 withDefault:nil];
    
    if (command.callbackId) {
        [self.rongCloudAdapter setDiscussionName:discussionId withName:name withCallBackId:command.callbackId];
    }
}

- (void) addMemberToDiscussion:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);

    NSString *discussionId = [command argumentAtIndex:0 withDefault:nil];
    NSArray *userIds = [command argumentAtIndex:1 withDefault:nil];
    
    if (command.callbackId) {
        [self.rongCloudAdapter addMemberToDiscussion:discussionId withUserIdList:userIds withCallBackId:command.callbackId];
    }
}

- (void) removeMemberFromDiscussion:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    NSString *discussionId = [command argumentAtIndex:0 withDefault:nil];
    NSString *userIds = [command argumentAtIndex:1 withDefault:nil];
    
    if (command.callbackId) {
        [self.rongCloudAdapter removeMemberFromDiscussion:discussionId withUserIds:userIds withCallBackId:command.callbackId];
    }
}

- (void) quitDiscussion:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    
    NSString *discussionId = [command argumentAtIndex:0 withDefault:nil];

    if (command.callbackId) {
        [self.rongCloudAdapter quitDiscussion:discussionId withCallBackId:command.callbackId];
    }
}

- (void) setDiscussionInviteStatus:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    
    NSString *targetId = [command argumentAtIndex:0 withDefault:nil];
    NSString *discussionInviteStatus = [command argumentAtIndex:1 withDefault:nil];
    
    if (command.callbackId) {
        [self.rongCloudAdapter setDiscussionInviteStatus:targetId withInviteStatus:discussionInviteStatus withCallBackId:command.callbackId];
    }
}

/**
 * group
 */
- (void) syncGroup:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    
    NSArray *groups = [command argumentAtIndex:0 withDefault:nil];

    if (command.callbackId) {
        [self.rongCloudAdapter syncGroup:groups withCallBackId:command.callbackId];
    }
}

- (void) joinGroup:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    NSString *groupId      = [command argumentAtIndex:0 withDefault:nil];
    NSString *groupName    = [command argumentAtIndex:1 withDefault:nil];
    
    if (command.callbackId) {
        [self.rongCloudAdapter joinGroup:groupId withGroupName:groupName withCallBackId:command.callbackId];
    }
}

- (void) quitGroup:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    NSString *groupId = [command argumentAtIndex:0 withDefault:nil];

    if (command.callbackId) {
        [self.rongCloudAdapter quitGroup:groupId withCallBackId:command.callbackId];
    }
}

/**
 * chatRoom
 */
- (void)joinChatRoom:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    
    NSString *chatRoomId       = [command argumentAtIndex:0 withDefault:nil];
    NSNumber *defMessageCount  = [command argumentAtIndex:1 withDefault:nil];
    
    if (command.callbackId) {
        [self.rongCloudAdapter joinChatRoom:chatRoomId messageCount:defMessageCount withCallBackId:command.callbackId];
    }
}

- (void)quitChatRoom:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    
    NSString *chatRoomId = [command argumentAtIndex:0 withDefault:nil];

    if (command.callbackId) {
        [self.rongCloudAdapter quitChatRoom:chatRoomId withCallBackId:command.callbackId];
    }
}

- (void)getConnectionStatus:(CDVInvokedUrlCommand *)command {
    NSLog(@"%s", __FUNCTION__);

    if (command.callbackId) {
        [self.rongCloudAdapter getConnectionStatus:command.callbackId];
    }
}

- (void)logout:(CDVInvokedUrlCommand *)command {
    NSLog(@"%s", __FUNCTION__);
    
    if (command.callbackId) {
        [self.rongCloudAdapter logout:command.callbackId];
    }
}

- (void)getRemoteHistoryMessages:(CDVInvokedUrlCommand *)command {
    NSLog(@"%s", __FUNCTION__);
    
    NSString *conversationTypeString = [command argumentAtIndex:0 withDefault:nil];
    NSString *targetId = [command argumentAtIndex:1 withDefault:nil];
    NSNumber *dateTime = [command argumentAtIndex:2 withDefault:nil];
    NSNumber *count = [command argumentAtIndex:3 withDefault:nil];
    
    if (command.callbackId) {
        [self.rongCloudAdapter getRemoteHistoryMessages:conversationTypeString targetId:targetId recordTime:dateTime count:count withCallBackId:command.callbackId];
    }
}

- (void)setMessageSentStatus:(CDVInvokedUrlCommand *)command {
    NSLog(@"%s", __FUNCTION__);
    
    NSNumber *messageId = [command argumentAtIndex:0 withDefault:nil];
    NSString *statusString = [command argumentAtIndex:1 withDefault:nil];
    
    if (command.callbackId) {
        [self.rongCloudAdapter setMessageSentStatus:messageId sentStatus:statusString withCallBackId:command.callbackId];
    }
}

- (void)getCurrentUserId:(CDVInvokedUrlCommand *)command {
    NSLog(@"%s", __FUNCTION__);
    
    if (command.callbackId) {
        [self.rongCloudAdapter getCurrentUserId:command.callbackId];
    }
}

- (void)addToBlacklist:(CDVInvokedUrlCommand *)command {
    NSLog(@"%s", __FUNCTION__);
    
    NSString *userId = [command argumentAtIndex:0 withDefault:nil];
    
    if (command.callbackId) {
        [self.rongCloudAdapter addToBlacklist:userId withCallBackId:command.callbackId];
    }
}

- (void)removeFromBlacklist:(CDVInvokedUrlCommand *)command {
    NSLog(@"%s", __FUNCTION__);
    
    NSString *userId = [command argumentAtIndex:0 withDefault:nil];
    
    if (command.callbackId) {
        [self.rongCloudAdapter removeFromBlacklist:userId withCallBackId:command.callbackId];
    }
}

- (void)getBlacklistStatus:(CDVInvokedUrlCommand *)command {
    NSLog(@"%s", __FUNCTION__);
    
    NSString *userId = [command argumentAtIndex:0 withDefault:nil];
    
    if (command.callbackId) {
        [self.rongCloudAdapter getBlacklistStatus:userId withCallBackId:command.callbackId];
    }
}

- (void)getBlacklist:(CDVInvokedUrlCommand *)command {
    NSLog(@"%s", __FUNCTION__);
    
    if (command.callbackId) {
        [self.rongCloudAdapter getBlacklist:command.callbackId];
    }
}

- (void)setNotificationQuietHours:(CDVInvokedUrlCommand *)command {
    NSLog(@"%s", __FUNCTION__);
    
    NSString *startTime = [command argumentAtIndex:0 withDefault:nil];
    NSNumber *spanMinutes = [command argumentAtIndex:1 withDefault:nil];
    
    if (command.callbackId) {
        [self.rongCloudAdapter setNotificationQuietHours:startTime spanMins:spanMinutes withCallBackId:command.callbackId];
    }
}

- (void)removeNotificationQuietHours:(CDVInvokedUrlCommand *)command {
    NSLog(@"%s", __FUNCTION__);
    
    if (command.callbackId) {
        [self.rongCloudAdapter removeNotificationQuietHours:command.callbackId];
    }
}

- (void)getNotificationQuietHours:(CDVInvokedUrlCommand *)command {
    NSLog(@"%s", __FUNCTION__);
    
    if (command.callbackId) {
        [self.rongCloudAdapter getNotificationQuietHours:command.callbackId];
    }
}
- (void)disableLocalNotification:(CDVInvokedUrlCommand *)command {
    NSLog(@"%s", __FUNCTION__);
    
    
    if (command.callbackId) {
        [self.rongCloudAdapter disableLocalNotification:command.callbackId];
    }
}

@end
