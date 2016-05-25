package io.rong.common.translation;

import io.rong.imlib.model.Conversation;

/**
 * Created by weiqinxiao on 15/9/16.
 */
public class TranslatedConversationNtfyStatus {
    int code;
    String notificationStatus;

    public TranslatedConversationNtfyStatus(Conversation.ConversationNotificationStatus status) {
        this.code = status.getValue();
        this.notificationStatus = (status == null ? "" : status.toString());
    }
}
