package io.rong.common.translation;

import io.rong.imlib.model.MessageContent;
import io.rong.message.InformationNotificationMessage;

/**
 * Created by weiqinxiao on 15/9/16.
 */
public class TranslatedInformationNtfMessage extends TranslatedMessageContent {
    String message;
    String extra;

    public TranslatedInformationNtfMessage(MessageContent content) {
        InformationNotificationMessage message = (InformationNotificationMessage)content;
        this.message = message.getMessage() == null ? "" : message.getMessage();
        this.extra = message.getExtra() == null ? "" : message.getExtra();
    }
}
