package io.rong.common.translation;

import io.rong.imlib.model.Conversation;
import io.rong.imlib.model.Message;
import io.rong.imlib.model.MessageContent;
import io.rong.message.CommandMessage;
import io.rong.message.CommandNotificationMessage;
import io.rong.message.ContactNotificationMessage;
import io.rong.message.DiscussionNotificationMessage;
import io.rong.message.GroupNotificationMessage;
import io.rong.message.ImageMessage;
import io.rong.message.InformationNotificationMessage;
import io.rong.message.LocationMessage;
import io.rong.message.ProfileNotificationMessage;
import io.rong.message.RichContentMessage;
import io.rong.message.TextMessage;
import io.rong.message.VoiceMessage;

/**
 * Created by weiqinxiao on 15/9/15.
 */
public class TranslatedMessage implements ITranslatedMessage {
    private Conversation.ConversationType conversationType;
    private String targetId;
    private Integer messageId;
    private Message.MessageDirection messageDirection;
    private String senderUserId;
    private Message.SentStatus sentStatus;
    private Long receivedTime;
    private Long sentTime;
    private String objectName;
    private TranslatedMessageContent content;
    private String extra;

    public TranslatedMessage(Message message) {
        this.conversationType = message.getConversationType();
        this.targetId = message.getTargetId() == null ? "" : message.getTargetId();
        this.messageId = message.getMessageId();
        this.messageDirection = message.getMessageDirection();
        this.senderUserId = message.getSenderUserId() == null ? "" : message.getSenderUserId();
        this.sentStatus = message.getSentStatus();
        this.receivedTime = message.getReceivedTime();
        this.sentTime = message.getSentTime();
        this.objectName = message.getObjectName() == null ? "" : message.getObjectName();
        this.extra = message.getExtra() == null ? "" : message.getExtra();
        this.content = translateMessageContent(message.getContent());
    }

    public static TranslatedMessageContent translateMessageContent(MessageContent msgContent) {
        TranslatedMessageContent content = null;
        if (msgContent == null)
            return null;

        if (msgContent instanceof TextMessage) {
            content = new TranslatedTextMessage(msgContent);
        } else if (msgContent instanceof ImageMessage) {
            content = new TranslatedImageMessage(msgContent);
        } else if (msgContent instanceof VoiceMessage) {
            content = new TranslatedVoiceMessage(msgContent);
        } else if (msgContent instanceof RichContentMessage) {
            content = new TranslatedRichContentMessage(msgContent);
        } else if (msgContent instanceof CommandNotificationMessage) {
            content = new TranslatedCommandNotificationMessage(msgContent);
        } else if (msgContent instanceof LocationMessage) {
            content = new TranslatedLocationMessage(msgContent);
        } else if (msgContent instanceof InformationNotificationMessage) {
            content = new TranslatedInformationNtfMessage(msgContent);
        } else if (msgContent instanceof DiscussionNotificationMessage) {
            content = new TranslatedDiscussionNtfMessage(msgContent);
        } else if (msgContent instanceof CommandMessage) {
            content = new TranslatedCommandMessage(msgContent);
        } else if (msgContent instanceof ContactNotificationMessage) {
            content = new TranslatedContactNtfMessage(msgContent);
        } else if (msgContent instanceof ProfileNotificationMessage) {
            content = new TranslatedProfileNtfMessage(msgContent);
        } else if (msgContent instanceof GroupNotificationMessage) {
            content = new TranslatedGrpNtfMessage(msgContent);
        }
        return content;
    }

    public TranslatedMessage() {

    }

    public void setMessageId(int id) {
        this.messageId = id;
    }

    public void setMessageContent(TranslatedMessageContent content) {
        this.content = content;
    }
}
