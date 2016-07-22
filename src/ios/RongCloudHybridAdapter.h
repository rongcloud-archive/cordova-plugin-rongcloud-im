//
//  RongCloudModule.h
//  UZApp
//
//  Created by xugang on 14/12/17.
//  Copyright (c) 2014年 APICloud. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>


@protocol RongCloud2HybridDelegation <NSObject>
- (void)sendResult:(NSDictionary *)resultDict error:(NSDictionary *)errorDict withCallbackId:(id)callbackId doDelete:(BOOL)doDelete;
- (NSString *)getAbsolutePath:(NSString *)relativePath;
@end


@interface RongCloudHybridAdapter : NSObject <RCIMClientReceiveMessageDelegate, RCConnectionStatusChangeDelegate>
- (instancetype)initWithDelegate:(id<RongCloud2HybridDelegation>) commandDelegate;

- (void)init:(NSString *)appKey callbackId:(id)callbackId;
- (void)connectWithToken:(NSString *)token callbackId:(id)callbackId;
- (void)disconnect:(NSNumber *)isReceivePush callbackId:(id)callbackId;
- (void)setConnectionStatusListener:(id)connectionCallbackId;
- (void)sendTextMessage:(NSString *)conversationTypeString targetId:(NSString *)targetId content:(NSString *)textContent extra:(NSString *)extra callbackId:(id)callbackId;
- (void)sendImageMessage:(NSString *)conversationTypeString targetId:(NSString *)targetId imagePath:(NSString *)imagePath extra:(NSString *)extra callbackId:(id)callbackId;
- (void)sendVoiceMessage:(NSString *)conversationTypeString targetId:(NSString *)targetId voicePath:(NSString *)voicePath duration:(NSNumber *)duration extra:(NSString *)extra callbackId:(id)callbackId;
- (void)sendLocationMessage:(NSString *)conversationTypeString targetId:(NSString *)targetId imagePath:(NSString *)imagePath latitude:(NSNumber *)latitude longitude:(NSNumber *)longitude locationName:(NSString *)locationName extra:(NSString *)extra callbackId:(id)callbackId;
- (void)sendRichContentMessage:(NSString *)conversationTypeString targetId:(NSString *)targetId title:(NSString *)title content:(NSString *)content imageUrl:(NSString *)imageUrl extra:(NSString *)extra callbackId:(id)callbackId;
- (void)sendCommandNotificationMessage:(NSString *)conversationTypeString targetId:(NSString *)targetId name:(NSString *)name data:(NSString *)data callbackId:(id)callbackId;
-(void)sendCommandMessage:(NSString *)conversationTypeString targetId:(NSString *)targetId name:(NSString *)name data:(NSString *)data callbackId:(id)callbackId;
- (void)setOnReceiveMessageListener:(id)receiveMessageCbId;
- (void)getConversationList:(id)callbackId;
- (void)getConversation:(NSString *)conversationTypeString targetId:(NSString *)targetId callbackId:(id)callbackId;
- (void)removeConversation:(NSString *)conversationTypeString targetId:(NSString *)targetId callbackId:(id)callbackId;
- (void)clearConversations:(NSArray *)conversationTypes callbackId:(id)callbackId;
- (void)setConversationToTop:(NSString *)conversationTypeString targetId:(NSString *)targetId isTop:(NSNumber *)isTop callbackId:(id)callbackId;
- (void)getConversationNotificationStatus:(NSString *)conversationTypeString targetId:(NSString *)targetId callbackId:(id)callbackId;
- (void)setConversationNotificationStatus:(NSString *)conversationTypeString targetId:(NSString *)targetId conversationnotificationStatus:(NSString *)conversationnotificationStatus callbackId:(id)callbackId;
- (void)getLatestMessages:(NSString *)conversationTypeString targetId:(NSString *)targetId count:(NSNumber *)count callbackId:(id)callbackId;
- (void)getHistoryMessages:(NSString *)conversationTypeString targetId:(NSString *)targetId count:(NSNumber *)count oldestMessageId:(NSNumber *)oldestMessageId callbackId:(id)callbackId;
- (void)getHistoryMessagesByObjectName:(NSString *)conversationTypeString targetId:(NSString *)targetId count:(NSNumber *)count oldestMessageId:(NSNumber *)oldestMessageId objectName:(NSString *)objectName callbackId:(id)callbackId;

- (void) deleteMessages:(NSArray *)messageIds callbackId:(id)callbackId;
- (void) clearMessages:(NSString *)conversationTypeString targetId:(NSString *)targetId callbackId:(id)callbackId;
- (void) getTotalUnreadCount:(id)callbackId;
- (void) getUnreadCount:(NSString *)conversationTypeString targetId:(NSString *)targetId callbackId:(id)callbackId;
-(void)getUnreadCountByConversationTypes:(NSArray *)conversationTypes callbackId:(id)callbackId;
-(void)setMessageReceivedStatus:(NSNumber *)messageId withReceivedStatus:(NSString *)receivedStatus withCallBackId:(id)callbackId;

- (void) clearMessagesUnreadStatus: (NSString*)conversationTypeString withTargetId:(NSString *)targetId withCallBackId:(id)cbId;
-(void) setMessageExtra : (NSNumber *)messageId withValue:(NSString *)value withCallBackId:(id)cbId;
-(void) getTextMessageDraft :(NSString*)conversationTypeString withTargetId:(NSString *)targetId withCallBackId:(id)cbId;
-(void) saveTextMessageDraft:(NSString *)conversationTypeString withTargetId:(NSString *)targetId withContent:(NSString *)content withCallBackId:(id)cbId;
-(void)clearTextMessageDraft:(NSString *)conversationTypeString  withTargetId:(NSString *)targetId withCallBackId:(id)cbId;
- (void) createDiscussion:(NSString *)name withUserIdList:(NSArray *)userIdList withCallBackId:(id)cbId;
-(void)getDiscussion:(NSString *)discussionId withCallBackId:(id)cbId;
-(void)setDiscussionName:(NSString *)discussionId withName:(NSString *)name withCallBackId:(id)cbId;
- (void) addMemberToDiscussion:(NSString *)discussionId withUserIdList:(NSArray *)userIdList withCallBackId:(id)cbId;
- (void) removeMemberFromDiscussion:(NSString *)discussionId  withUserIds:(NSString *)userIds withCallBackId:(id)cbId;
- (void) quitDiscussion:(NSString *)discussionId withCallBackId:(id)cbId;
- (void) setDiscussionInviteStatus:(NSString *)discussionId withInviteStatus:(NSString *)inviteStatus withCallBackId:(id)cbId;
- (void) syncGroup:(NSArray *)groups withCallBackId:(id)cbId;
- (void) joinGroup:(NSString *)groupId withGroupName:(NSString *)groupName withCallBackId:(id)cbId;

- (void) quitGroup:(NSString *)groupId
    withCallBackId:(id)cbId;

- (void)joinChatRoom:(NSString *)chatRoomId
        messageCount:(NSNumber *)defMessageCount
      withCallBackId:(id)cbId;

- (void)quitChatRoom:(NSString *)chatRoomId
      withCallBackId:(id)cbId;

- (void)getConnectionStatus:(id)callbackId;

- (void)logout:(id)callbackId;

- (void)getRemoteHistoryMessages:(NSString *)conversationTypeString
                        targetId:(NSString *)targetId
                      recordTime:(NSNumber *)dateTime
                           count:(NSNumber *)count
                  withCallBackId:(id)cbId;

- (void)setMessageSentStatus:(NSNumber *)messageId
                  sentStatus:(NSString *)statusString
              withCallBackId:(id)cbId;

- (void)getCurrentUserId:(id)callbackId;

- (void)addToBlacklist:(NSString *)userId
        withCallBackId:(id)cbId;

- (void)removeFromBlacklist:(NSString *)userId
             withCallBackId:(id)cbId;

- (void)getBlacklistStatus:(NSString *)userId
            withCallBackId:(id)cbId;

- (void)getBlacklist:(id)callbackId;

- (void)setNotificationQuietHours:(NSString *)startTime
                         spanMins:(NSNumber *)spanMinutes
                   withCallBackId:(id)cbId;

- (void)removeNotificationQuietHours:(id)callbackId;

- (void)getNotificationQuietHours:(id)callbackId;

- (void)disableLocalNotification:(id)callbackId;

#ifdef RC_SUPPORT_IMKIT
- (void)startSingleCall:(NSString *)calleeId mediaType:(int)mediaType withCallBackId:(id)cbId;
#endif

@end
