package io.rong.common.translation;

import io.rong.imlib.model.MessageContent;
import io.rong.message.CommandNotificationMessage;

/**
 * Created by weiqinxiao on 15/9/15.
 */
public class TranslatedCommandNotificationMessage extends TranslatedMessageContent {
    String name;
    String data;

    public TranslatedCommandNotificationMessage(MessageContent content) {
        CommandNotificationMessage msg = (CommandNotificationMessage) content;
        this.name = msg.getName() == null ? "" : msg.getName();
        this.data = msg.getData() == null ? "" : msg.getData();
    }
}
