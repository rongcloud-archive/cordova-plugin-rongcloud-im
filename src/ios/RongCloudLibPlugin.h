//
//  RongCloudModule.h
//  UZApp
//
//  Created by xugang on 14/12/17.
//  Copyright (c) 2014年 APICloud. All rights reserved.
//

#import <Cordova/CDV.h>
#import <RongIMLib/RongIMLib.h>


@interface RongCloudLibPlugin : CDVPlugin <RCIMClientReceiveMessageDelegate, RCConnectionStatusChangeDelegate>

- (void)init:(CDVInvokedUrlCommand *)command;
- (void)connect:(CDVInvokedUrlCommand *)command;
- (void)reconnect:(CDVInvokedUrlCommand *)command;
- (void)disconnect:(CDVInvokedUrlCommand *)command;
- (void)setConnectionStatusListener:(CDVInvokedUrlCommand *)command;
- (void)sendTextMessage:(CDVInvokedUrlCommand *)command;
- (void)sendImageMessage:(CDVInvokedUrlCommand *)command;
- (void)sendVoiceMessage:(CDVInvokedUrlCommand *)command;
- (void)sendLocationMessage:(CDVInvokedUrlCommand *)command;
- (void)sendRichContentMessage:(CDVInvokedUrlCommand *)command;
- (void)sendCommandNotificationMessage:(CDVInvokedUrlCommand *)command;
- (void)setOnReceiveMessageListener:(CDVInvokedUrlCommand *)command;
- (void)getConversationList:(CDVInvokedUrlCommand *)command;
- (void)getConversation:(CDVInvokedUrlCommand *)command;
- (void)removeConversation:(CDVInvokedUrlCommand *)command;
- (void)clearConversations:(CDVInvokedUrlCommand *)command;
- (void)setConversationToTop:(CDVInvokedUrlCommand *)command;
- (void)getConversationNotificationStatus:(CDVInvokedUrlCommand *)command;
- (void)setConversationNotificationStatus:(CDVInvokedUrlCommand *)command;
- (void)getLatestMessages:(CDVInvokedUrlCommand *)command;
- (void)getHistoryMessages:(CDVInvokedUrlCommand *)command;
- (void)getHistoryMessagesByObjectName:(CDVInvokedUrlCommand *)command;
- (void)deleteMessages:(CDVInvokedUrlCommand *)command;
- (void)clearMessages:(CDVInvokedUrlCommand *)command;
- (void)getTotalUnreadCount:(CDVInvokedUrlCommand *)command;
- (void)getUnreadCount:(CDVInvokedUrlCommand *)command;
- (void)getUnreadCountByConversationTypes:(CDVInvokedUrlCommand *)command;
- (void)setMessageReceivedStatus:(CDVInvokedUrlCommand *)command;
- (void)clearMessagesUnreadStatus:(CDVInvokedUrlCommand *)command;
- (void)setMessageExtra:(CDVInvokedUrlCommand *)command;
- (void)getTextMessageDraft:(CDVInvokedUrlCommand *)command;
- (void)saveTextMessageDraft:(CDVInvokedUrlCommand *)command;
- (void)clearTextMessageDraft:(CDVInvokedUrlCommand *)command;
- (void)createDiscussion:(CDVInvokedUrlCommand *)command;
- (void)getDiscussion:(CDVInvokedUrlCommand *)command;
- (void)setDiscussionName:(CDVInvokedUrlCommand *)command;
- (void)addMemberToDiscussion:(CDVInvokedUrlCommand *)command;
- (void)removeMemberFromDiscussion:(CDVInvokedUrlCommand *)command;
- (void)quitDiscussion:(CDVInvokedUrlCommand *)command;
- (void)setDiscussionInviteStatus:(CDVInvokedUrlCommand *)command;
- (void)syncGroup:(CDVInvokedUrlCommand *)command;
- (void)joinGroup:(CDVInvokedUrlCommand *)command;
- (void)quitGroup:(CDVInvokedUrlCommand *)command;
- (void)joinChatRoom:(CDVInvokedUrlCommand *)command;
- (void)quitChatRoom:(CDVInvokedUrlCommand *)command;
- (void)getConnectionStatus:(CDVInvokedUrlCommand *)command;
- (void)logout:(CDVInvokedUrlCommand *)command;
- (void)getRemoteHistoryMessages:(CDVInvokedUrlCommand *)command;
- (void)setMessageSentStatus:(CDVInvokedUrlCommand *)command;
- (void)getCurrentUserId:(CDVInvokedUrlCommand *)command;
- (void)addToBlacklist:(CDVInvokedUrlCommand *)command;
- (void)removeFromBlacklist:(CDVInvokedUrlCommand *)command;
- (void)getBlacklistStatus:(CDVInvokedUrlCommand *)command;
- (void)getBlacklist:(CDVInvokedUrlCommand *)command;
- (void)setNotificationQuietHours:(CDVInvokedUrlCommand *)command;
- (void)removeNotificationQuietHours:(CDVInvokedUrlCommand *)command;
- (void)getNotificationQuietHours:(CDVInvokedUrlCommand *)command;
- (void)disableLocalNotification:(CDVInvokedUrlCommand *)command;
@end
