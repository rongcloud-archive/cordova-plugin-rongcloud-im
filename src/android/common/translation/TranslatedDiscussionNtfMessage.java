package io.rong.common.translation;

import io.rong.imlib.model.MessageContent;
import io.rong.message.DiscussionNotificationMessage;

/**
 * Created by weiqinxiao on 15/9/17.
 */
public class TranslatedDiscussionNtfMessage extends TranslatedMessageContent {
    String extension;
    String operator;
    int type;

    public TranslatedDiscussionNtfMessage(MessageContent content) {
        DiscussionNotificationMessage message = (DiscussionNotificationMessage) content;
        this.extension = message.getExtension() == null ? "" : message.getExtension();
        this.operator = message.getOperator() == null ? "" : message.getOperator();
        this.type = message.getType();
    }
}
