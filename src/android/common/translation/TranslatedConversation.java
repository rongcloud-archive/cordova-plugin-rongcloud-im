package io.rong.common.translation;

import io.rong.imlib.model.Conversation;
import io.rong.imlib.model.Message;
import io.rong.imlib.model.MessageContent;

/**
 * Created by weiqinxiao on 15/9/15.
 */
public class TranslatedConversation {
    String conversationTitle;
    Conversation.ConversationType conversationType;
    String draft;
    String targetId;
    TranslatedMessageContent latestMessage;
    Message.SentStatus sentStatus;
    String objectName;
    String receivedStatus;
    String senderUserId;
    int unreadMessageCount;
    long receivedTime;
    long sentTime;
    boolean isTop;
    int latestMessageId;

    public TranslatedConversation(Conversation conversation) {
        this.conversationTitle = conversation.getConversationTitle() == null ? "" : conversation.getConversationTitle();
        this.conversationType = conversation.getConversationType();
        this.draft = conversation.getDraft() == null ? "" : conversation.getDraft();
        this.targetId = conversation.getTargetId() == null ? "" : conversation.getTargetId();
        this.sentStatus = conversation.getSentStatus();
        this.objectName = conversation.getObjectName();
        int flag = conversation.getReceivedStatus().getFlag();
        if(flag == 0)
            this.receivedStatus = "UNREAD";
        else if(flag == 1)
            this.receivedStatus = "READ";
        else if(flag == 3 || flag == 2)
            this.receivedStatus = "LISTENED";
        else if(flag == 4)
            this.receivedStatus = "DOWNLOADED";
        else
            this.receivedStatus = "READ";

        this.senderUserId = conversation.getSenderUserId() == null ? "" : conversation.getSenderUserId();
        this.unreadMessageCount = conversation.getUnreadMessageCount();
        this.receivedTime = conversation.getReceivedTime();
        this.sentTime = conversation.getSentTime();
        this.isTop = conversation.isTop();
        this.latestMessageId = conversation.getLatestMessageId();

        MessageContent msgContent = conversation.getLatestMessage();
        TranslatedMessageContent tc = TranslatedMessage.translateMessageContent(msgContent);
        this.latestMessage = (tc == null ? new TranslatedMessageContent() : tc);
    }
}
