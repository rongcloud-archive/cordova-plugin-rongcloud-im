var argscheck = require('cordova/argscheck');

var RongCloudLibPlugin = function() {};

RongCloudLibPlugin.prototype.init = function(options, retCallback) {
    var getValue = argscheck.getValue;
    options = options || {};
    var appKey_ = getValue(options.appKey, null);
    var deviceToken_ = getValue(options.deviceToken, null);
    cordova.exec(function(ret){retCallback(ret)}, function(err){retCallback(null, err)}, "RongCloudLibPlugin","init", [appKey_, deviceToken_]);
};
RongCloudLibPlugin.prototype.connect = function(options, retCallback) {
    var getValue = argscheck.getValue;
    options = options || {};
    var token_ = getValue(options.token, null);
    cordova.exec(function(ret){retCallback(ret)}, function(err){retCallback(null, err)}, "RongCloudLibPlugin","connect", [token_]);
};
RongCloudLibPlugin.prototype.reconnect = function(retCallback) {
    cordova.exec(function(ret){retCallback(ret)}, function(err){retCallback(null, err)}, "RongCloudLibPlugin","reconnect", []);
};
RongCloudLibPlugin.prototype.disconnect = function(options, retCallback) {
    var getValue = argscheck.getValue;
    options = options || {};
    var isReceivePush_ = getValue(options.isReceivePush, null);
    cordova.exec(function(ret){retCallback(ret)}, function(err){retCallback(null, err)}, "RongCloudLibPlugin","disconnect", [isReceivePush_]);
};
RongCloudLibPlugin.prototype.setConnectionStatusListener = function(retCallback) {

    cordova.exec(function(ret){retCallback(ret)}, function(err){retCallback(null, err)}, "RongCloudLibPlugin","setConnectionStatusListener", []);
};
RongCloudLibPlugin.prototype.sendTextMessage = function(options, retCallback) {
    var getValue = argscheck.getValue;
    options = options || {};
    var conversationType_ = getValue(options.conversationType, null);
    var targetId_ = getValue(options.targetId, null);
    var text_ = getValue(options.text, null);
    var extra_ = getValue(options.extra, null);
    cordova.exec(function(ret){retCallback(ret)}, function(err){retCallback(null, err)}, "RongCloudLibPlugin","sendTextMessage", [conversationType_, targetId_, text_, extra_]);
};


RongCloudLibPlugin.prototype.sendImageMessage = function(options, retCallback) {
    var getValue = argscheck.getValue;
    options = options || {};
    var conversationType_ = getValue(options.conversationType, null);
    var targetId_ = getValue(options.targetId, null);
    var imagePath_ = getValue(options.imagePath, null);
    var extra_ = getValue(options.extra, null);
    cordova.exec(function(ret){retCallback(ret)}, function(err){retCallback(null, err)}, "RongCloudLibPlugin","sendImageMessage", [conversationType_, targetId_, imagePath_, extra_]);
};
RongCloudLibPlugin.prototype.sendVoiceMessage = function(options, retCallback) {
    var getValue = argscheck.getValue;
    options = options || {};
    var conversationType_ = getValue(options.conversationType, null);
    var targetId_ = getValue(options.targetId, null);
    var voicePath_ = getValue(options.voicePath, null);
    var duration_ = getValue(options.duration, null);
    var extra_ = getValue(options.extra, null);
    cordova.exec(function(ret){retCallback(ret)}, function(err){retCallback(null, err)}, "RongCloudLibPlugin","sendVoiceMessage", [conversationType_, targetId_, voicePath_, duration_, extra_]);
};
RongCloudLibPlugin.prototype.sendLocationMessage = function(options, retCallback) {
    var getValue = argscheck.getValue;
    options = options || {};
    var conversationType_ = getValue(options.conversationType, null);
    var targetId_ = getValue(options.targetId, null);
    var latitude_ = getValue(options.latitude, null);
    var longitude_ = getValue(options.longitude, null);
    var locationName_ = getValue(options.poi, null);
    var imagePath_ = getValue(options.imagePath, null);
    var extra_ = getValue(options.extra, null);
    cordova.exec(function(ret){retCallback(ret)}, function(err){retCallback(null, err)}, "RongCloudLibPlugin","sendLocationMessage", [conversationType_, targetId_, latitude_, longitude_, locationName_, imagePath_, extra_]);
};
RongCloudLibPlugin.prototype.sendRichContentMessage = function(options, retCallback) {
    var getValue = argscheck.getValue;
    options = options || {};
    var conversationType_ = getValue(options.conversationType, null);
    var targetId_ = getValue(options.targetId, null);
    var title_ = getValue(options.title, null);
    var content_ = getValue(options.description, null);
    var imageUrl_ = getValue(options.imageUrl, null);
    var extra_ = getValue(options.extra, null);
    cordova.exec(function(ret){retCallback(ret)}, function(err){retCallback(null, err)}, "RongCloudLibPlugin","sendRichContentMessage", [conversationType_, targetId_, title_, content_, imageUrl_, extra_]);
};
RongCloudLibPlugin.prototype.sendCommandNotificationMessage = function(options, retCallback) {
    var getValue = argscheck.getValue;
    options = options || {};
    var conversationType_ = getValue(options.conversationType, null);
    var targetId_ = getValue(options.targetId, null);
    var name_ = getValue(options.name, null );
    var data_ = getValue(options.data, null);
    cordova.exec(function(ret){retCallback(ret)}, function(err){retCallback(null, err)}, "RongCloudLibPlugin","sendCommandNotificationMessage", [conversationType_, targetId_, name_, data_]);
};
RongCloudLibPlugin.prototype.setOnReceiveMessageListener = function(retCallback) {

    cordova.exec(function(ret){retCallback(ret)}, function(err){retCallback(null, err)}, "RongCloudLibPlugin","setOnReceiveMessageListener", []);
};
RongCloudLibPlugin.prototype.getConversationList = function(retCallback) {

    cordova.exec(function(ret){retCallback(ret)}, function(err){retCallback(null, err)}, "RongCloudLibPlugin","getConversationList", []);
};
RongCloudLibPlugin.prototype.getConversation = function(options, retCallback) {
    var getValue = argscheck.getValue;
    options = options || {};
    var conversationType_ = getValue(options.conversationType, null);
    var targetId_ = getValue(options.targetId, null);
    cordova.exec(function(ret){retCallback(ret)}, function(err){retCallback(null, err)}, "RongCloudLibPlugin","getConversation", [conversationType_, targetId_]);
};
RongCloudLibPlugin.prototype.removeConversation = function(options, retCallback) {
    var getValue = argscheck.getValue;
    options = options || {};
    var conversationType_ = getValue(options.conversationType, null);
    var targetId_ = getValue(options.targetId, null);
    cordova.exec(function(ret){retCallback(ret)}, function(err){retCallback(null, err)}, "RongCloudLibPlugin","removeConversation", [conversationType_, targetId_]);
};
RongCloudLibPlugin.prototype.clearConversations = function(options, retCallback) {
    var getValue = argscheck.getValue;
    options = options || {};
    var conversationTypes_ = getValue(options.conversationTypes, null);
    cordova.exec(function(ret){retCallback(ret)}, function(err){retCallback(null, err)}, "RongCloudLibPlugin","clearConversations", [conversationTypes_]);
};
RongCloudLibPlugin.prototype.setConversationToTop = function(options, retCallback) {
    var getValue = argscheck.getValue;
    options = options || {};
    var conversationType_ = getValue(options.conversationType, null);
    var targetId_ = getValue(options.targetId, null);
    var isTop_ = getValue(options.isTop, null);
    cordova.exec(function(ret){retCallback(ret)}, function(err){retCallback(null, err)}, "RongCloudLibPlugin","setConversationToTop", [conversationType_, targetId_, isTop_]);
};
RongCloudLibPlugin.prototype.getConversationNotificationStatus = function(options, retCallback) {
    var getValue = argscheck.getValue;
    options = options || {};
    var conversationType_ = getValue(options.conversationType, null);
    var targetId_ = getValue(options.targetId, null);
    cordova.exec(function(ret){retCallback(ret)}, function(err){retCallback(null, err)}, "RongCloudLibPlugin","getConversationNotificationStatus", [conversationType_, targetId_]);
};
RongCloudLibPlugin.prototype.setConversationNotificationStatus = function(options, retCallback) {
    var getValue = argscheck.getValue;
    options = options || {};
    var conversationType_ = getValue(options.conversationType, null);
    var targetId_ = getValue(options.targetId, null);
    var conversationNotificationStatus_ = getValue(options.notificationStatus, null);
    cordova.exec(function(ret){retCallback(ret)}, function(err){retCallback(null, err)}, "RongCloudLibPlugin","setConversationNotificationStatus", [conversationType_, targetId_,conversationNotificationStatus_]);
};
RongCloudLibPlugin.prototype.getLatestMessages = function(options, retCallback) {
    var getValue = argscheck.getValue;
    options = options || {};
    var conversationType_ = getValue(options.conversationType, null);
    var targetId_ = getValue(options.targetId, null);
    var count_ = getValue(options.count, null);
    cordova.exec(function(ret){retCallback(ret)}, function(err){retCallback(null, err)}, "RongCloudLibPlugin","getLatestMessages", [conversationType_, targetId_,count_]);
};
RongCloudLibPlugin.prototype.getHistoryMessages = function(options, retCallback) {
    var getValue = argscheck.getValue;
    options = options || {};
    var conversationType_ = getValue(options.conversationType, null);
    var targetId_ = getValue(options.targetId, null);
    var count_ = getValue(options.count, null);
    var oldestMessageId_ = getValue(options.oldestMessageId, null);
    cordova.exec(function(ret){retCallback(ret)}, function(err){retCallback(null, err)}, "RongCloudLibPlugin","getHistoryMessages", [conversationType_, targetId_,count_, oldestMessageId_]);
};
RongCloudLibPlugin.prototype.getHistoryMessagesByObjectName = function(options, retCallback) {
    var getValue = argscheck.getValue;
    options = options || {};
    var conversationType_ = getValue(options.conversationType, null);
    var targetId_ = getValue(options.targetId, null);
    var count_ = getValue(options.count, null);
    var oldestMessageId_ = getValue(options.oldestMessageId, null);
    var objectName_ = getValue(options.objectName, null);
    cordova.exec(function(ret){retCallback(ret)}, function(err){retCallback(null, err)}, "RongCloudLibPlugin","getHistoryMessagesByObjectName", [conversationType_, targetId_,count_, oldestMessageId_, objectName_]);
};
RongCloudLibPlugin.prototype.deleteMessages = function(options, retCallback) {
    var getValue = argscheck.getValue;
    options = options || {};
    var messageIds_  = getValue(options.messageIds, null);
    cordova.exec(function(ret){retCallback(ret)}, function(err){retCallback(null, err)}, "RongCloudLibPlugin","deleteMessages", [messageIds_]);
};
RongCloudLibPlugin.prototype.clearMessages = function(options, retCallback) {
    var getValue = argscheck.getValue;
    options = options || {};
    var conversationType_ = getValue(options.conversationType, null);
    var targetId_ = getValue(options.targetId, null);
    cordova.exec(function(ret){retCallback(ret)}, function(err){retCallback(null, err)}, "RongCloudLibPlugin","clearMessages", [conversationType_,targetId_]);
};
RongCloudLibPlugin.prototype.getTotalUnreadCount = function(retCallback) {

    cordova.exec(function(ret){retCallback(ret)}, function(err){retCallback(null, err)}, "RongCloudLibPlugin","getTotalUnreadCount", []);
};
RongCloudLibPlugin.prototype.getUnreadCount = function(options, retCallback) {
    var getValue = argscheck.getValue;
    options = options || {};
    var conversationType_ = getValue(options.conversationType, null);
    var targetId_ = getValue(options.targetId, null);
    cordova.exec(function(ret){retCallback(ret)}, function(err){retCallback(null, err)}, "RongCloudLibPlugin","getUnreadCount", [conversationType_,targetId_]);
};
RongCloudLibPlugin.prototype.getUnreadCountByConversationTypes = function(options, retCallback) {
    var getValue = argscheck.getValue;
    options = options || {};
    var conversationTypes_ = getValue(options.conversationTypes, null);
    cordova.exec(function(ret){retCallback(ret)}, function(err){retCallback(null, err)}, "RongCloudLibPlugin","getUnreadCountByConversationTypes", [conversationTypes_]);
};
RongCloudLibPlugin.prototype.setMessageReceivedStatus = function(options, retCallback) {
    var getValue = argscheck.getValue;
    options = options || {};
    var messageId_ = getValue(options.messageId, null);
    var receivedStatus_ = getValue(options.receivedStatus, null);
    cordova.exec(function(ret){retCallback(ret)}, function(err){retCallback(null, err)}, "RongCloudLibPlugin","setMessageReceivedStatus", [messageId_, receivedStatus_]);
};
RongCloudLibPlugin.prototype.clearMessagesUnreadStatus = function(options, retCallback) {
    var getValue = argscheck.getValue;
    options = options || {};
    var conversationType_ = getValue(options.conversationType, null);
    var targetId_ = getValue(options.targetId, null);
    cordova.exec(function(ret){retCallback(ret)}, function(err){retCallback(null, err)}, "RongCloudLibPlugin","clearMessagesUnreadStatus", [conversationType_, targetId_]);
};
RongCloudLibPlugin.prototype.setMessageExtra = function(options, retCallback) {
    var getValue = argscheck.getValue;
    options = options || {};
    var messageId_ = getValue(options.messageId, null);
    var value_ = getValue(options.value, null);
    cordova.exec(function(ret){retCallback(ret)}, function(err){retCallback(null, err)}, "RongCloudLibPlugin","setMessageExtra", [messageId_, value_]);
};
RongCloudLibPlugin.prototype.getTextMessageDraft = function(options, retCallback) {
    var getValue = argscheck.getValue;
    options = options || {};
    var conversationType_ = getValue(options.conversationType, null);
    var targetId_ = getValue(options.targetId, null);
    cordova.exec(function(ret){retCallback(ret)}, function(err){retCallback(null, err)}, "RongCloudLibPlugin","getTextMessageDraft", [conversationType_, targetId_]);
};
RongCloudLibPlugin.prototype.saveTextMessageDraft = function(options, retCallback) {
    var getValue = argscheck.getValue;
    options = options || {};
    var conversationType_ = getValue(options.conversationType, null);
    var targetId_ = getValue(options.targetId, null);
    var content_ = getValue(options.content, null);
    cordova.exec(function(ret){retCallback(ret)}, function(err){retCallback(null, err)}, "RongCloudLibPlugin","saveTextMessageDraft", [conversationType_, targetId_, content_]);
};
RongCloudLibPlugin.prototype.clearTextMessageDraft = function(options, retCallback) {
    var getValue = argscheck.getValue;
    options = options || {};
    var conversationType_ = getValue(options.conversationType, null);
    var targetId_ = getValue(options.targetId, null);
    cordova.exec(function(ret){retCallback(ret)}, function(err){retCallback(null, err)}, "RongCloudLibPlugin","clearTextMessageDraft", [conversationType_, targetId_]);
};
RongCloudLibPlugin.prototype.createDiscussion = function(options, retCallback) {
    var getValue = argscheck.getValue;
    options = options || {};
    var name_ = getValue(options.name, null);
    var userIds_ = getValue(options.userIdList, null);
    cordova.exec(function(ret){retCallback(ret)}, function(err){retCallback(null, err)}, "RongCloudLibPlugin","createDiscussion", [name_, userIds_]);
};
RongCloudLibPlugin.prototype.getDiscussion = function(options, retCallback) {
    var getValue = argscheck.getValue;
    options = options || {};
    var discussionId_ = getValue(options.discussionId, null);
    cordova.exec(function(ret){retCallback(ret)}, function(err){retCallback(null, err)}, "RongCloudLibPlugin","getDiscussion", [discussionId_]);
};
RongCloudLibPlugin.prototype.setDiscussionName = function(options, retCallback) {
    var getValue = argscheck.getValue;
    options = options || {};
    var discussionId_ = getValue(options.discussionId, null);
    var name_ = getValue(options.name, null);
    cordova.exec(function(ret){retCallback(ret)}, function(err){retCallback(null, err)}, "RongCloudLibPlugin","setDiscussionName", [discussionId_, name_]);
};
RongCloudLibPlugin.prototype.addMemberToDiscussion = function(options, retCallback) {
    var getValue = argscheck.getValue;
    options = options || {};
    var discussionId_ = getValue(options.discussionId, null);
    var userIds_ = getValue(options.userIdList, null);
    cordova.exec(function(ret){retCallback(ret)}, function(err){retCallback(null, err)}, "RongCloudLibPlugin","addMemberToDiscussion", [discussionId_, userIds_]);
};
RongCloudLibPlugin.prototype.removeMemberFromDiscussion = function(options, retCallback) {
    var getValue = argscheck.getValue;
    options = options || {};
    var discussionId_ = getValue(options.discussionId, null);
    var userId_ = getValue(options.userId, null);
    cordova.exec(function(ret){retCallback(ret)}, function(err){retCallback(null, err)}, "RongCloudLibPlugin","removeMemberFromDiscussion", [discussionId_, userId_]);
};
RongCloudLibPlugin.prototype.quitDiscussion = function(options, retCallback) {
    var getValue = argscheck.getValue;
    options = options || {};
    var discussionId_ = getValue(options.discussionId, null);
    cordova.exec(function(ret){retCallback(ret)}, function(err){retCallback(null, err)}, "RongCloudLibPlugin","quitDiscussion", [discussionId_]);
};
RongCloudLibPlugin.prototype.setDiscussionInviteStatus = function(options, retCallback) {
    var getValue = argscheck.getValue;
    options = options || {};
    var discussionId_ = getValue(options.discussionId, null);
    var inviteStatus_ = getValue(options.inviteStatus, null);
    cordova.exec(function(ret){retCallback(ret)}, function(err){retCallback(null, err)}, "RongCloudLibPlugin","setDiscussionInviteStatus", [discussionId_, inviteStatus_]);
};
RongCloudLibPlugin.prototype.syncGroup = function(options, retCallback) {
    var getValue = argscheck.getValue;
    options = options || {};
    var groups_ = getValue(options.groups, null);
    cordova.exec(function(ret){retCallback(ret)}, function(err){retCallback(null, err)}, "RongCloudLibPlugin","syncGroup", [groups_]);
};
RongCloudLibPlugin.prototype.joinGroup = function(options, retCallback) {
    var getValue = argscheck.getValue;
    options = options || {};
    var groupId_ = getValue(options.groupId, null);
    var groupName_ = getValue(options.groupName, null);
    cordova.exec(function(ret){retCallback(ret)}, function(err){retCallback(null, err)}, "RongCloudLibPlugin","joinGroup", [groupId_, groupName_]);
};
RongCloudLibPlugin.prototype.quitGroup = function(options, retCallback) {
    var getValue = argscheck.getValue;
    options = options || {};
     var groupId_ = getValue(options.groupId, null);
    cordova.exec(function(ret){retCallback(ret)}, function(err){retCallback(null, err)}, "RongCloudLibPlugin","quitGroup", [groupId_]);
};
RongCloudLibPlugin.prototype.joinChatRoom = function(options, retCallback) {
    var getValue = argscheck.getValue;
    options = options || {};
    var chatRoomId_ = getValue(options.chatRoomId, null);
    var defMessageCount_ = getValue(options.defMessageCount, null);
    cordova.exec(function(ret){retCallback(ret)}, function(err){retCallback(null, err)}, "RongCloudLibPlugin","joinChatRoom", [chatRoomId_, defMessageCount_]);
};
RongCloudLibPlugin.prototype.quitChatRoom = function(options, retCallback) {
    var getValue = argscheck.getValue;
    options = options || {};
    var chatRoomId_ = getValue(options.chatRoomId, null);
    cordova.exec(function(ret){retCallback(ret)}, function(err){retCallback(null, err)}, "RongCloudLibPlugin","quitChatRoom", [chatRoomId_]);
};
RongCloudLibPlugin.prototype.getConnectionStatus = function(retCallback) {
    cordova.exec(function(ret){retCallback(ret)}, function(err){retCallback(null, err)}, "RongCloudLibPlugin","getConnectionStatus", []);
};
RongCloudLibPlugin.prototype.logout = function(retCallback) {
    cordova.exec(function(ret){retCallback(ret)}, function(err){retCallback(null, err)}, "RongCloudLibPlugin","logout", []);
};
RongCloudLibPlugin.prototype.getRemoteHistoryMessages = function(options, retCallback) {
    var getValue = argscheck.getValue;
    options = options || {};
    var conversationType_ = getValue(options.conversationType, null);
    var targetId_ = getValue(options.targetId, null);
    var count_ = getValue(options.count, null);
    var dateTime_ = getValue(options.dateTime, null);
    cordova.exec(function(ret){retCallback(ret)}, function(err){retCallback(null, err)}, "RongCloudLibPlugin","getRemoteHistoryMessages", [conversationType_, targetId_, dateTime_, count_]);
};
RongCloudLibPlugin.prototype.setMessageSentStatus = function(options, retCallback) {
    var getValue = argscheck.getValue;
    options = options || {};
    var messageId_ = getValue(options.messageId, null);
    var sentStatus_ = getValue(options.sentStatus, null);
    cordova.exec(function(ret){retCallback(ret)}, function(err){retCallback(null, err)}, "RongCloudLibPlugin","setMessageSentStatus", [messageId_, sentStatus_]);
};
RongCloudLibPlugin.prototype.getCurrentUserId = function(retCallback) {
    cordova.exec(function(ret){retCallback(ret)}, function(err){retCallback(null, err)}, "RongCloudLibPlugin","getCurrentUserId", []);
};
RongCloudLibPlugin.prototype.addToBlacklist = function(options, retCallback) {
    var getValue = argscheck.getValue;
    options = options || {};
    var userId_ = getValue(options.userId, null);
    cordova.exec(function(ret){retCallback(ret)}, function(err){retCallback(null, err)}, "RongCloudLibPlugin","addToBlacklist", [userId_]);
};
RongCloudLibPlugin.prototype.removeFromBlacklist = function(options, retCallback) {
    var getValue = argscheck.getValue;
    options = options || {};
    var userId_ = getValue(options.userId, null);
    cordova.exec(function(ret){retCallback(ret)}, function(err){retCallback(null, err)}, "RongCloudLibPlugin","removeFromBlacklist", [userId_]);
};
RongCloudLibPlugin.prototype.getBlacklistStatus = function(options, retCallback) {
    var getValue = argscheck.getValue;
    options = options || {};
    var userId_ = getValue(options.userId, null);
    cordova.exec(function(ret){retCallback(ret)}, function(err){retCallback(null, err)}, "RongCloudLibPlugin","getBlacklistStatus", [userId_]);
};
RongCloudLibPlugin.prototype.getBlacklist = function(retCallback) {
    cordova.exec(function(ret){retCallback(ret)}, function(err){retCallback(null, err)}, "RongCloudLibPlugin","getBlacklist", []);
};

RongCloudLibPlugin.prototype.setNotificationQuietHours = function(options, retCallback) {
    var getValue = argscheck.getValue;
    options = options || {};
    var startTime_ = getValue(options.startTime, null);
    var spanMinutes_ = getValue(options.spanMinutes, null);
    cordova.exec(function(ret){retCallback(ret)}, function(err){retCallback(null, err)}, "RongCloudLibPlugin","setNotificationQuietHours", [startTime_, spanMinutes_]);
};
RongCloudLibPlugin.prototype.removeNotificationQuietHours = function(retCallback) {
    cordova.exec(function(ret){retCallback(ret)}, function(err){retCallback(null, err)}, "RongCloudLibPlugin","removeNotificationQuietHours", []);
};
RongCloudLibPlugin.prototype.getNotificationQuietHours = function(retCallback) {
    cordova.exec(function(ret){retCallback(ret)}, function(err){retCallback(null, err)}, "RongCloudLibPlugin","getNotificationQuietHours", []);
};
RongCloudLibPlugin.prototype.disableLocalNotification = function(retCallback) {
    cordova.exec(function(ret){retCallback(ret)}, function(err){retCallback(null, err)}, "RongCloudLibPlugin","disableLocalNotification", []);
};


module.exports = new RongCloudLibPlugin();
