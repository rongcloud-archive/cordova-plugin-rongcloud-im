package io.rong.common.translation;

import io.rong.imlib.model.MessageContent;
import io.rong.message.TextMessage;

/**
 * Created by weiqinxiao on 15/9/15.
 */
public class TranslatedTextMessage extends TranslatedMessageContent {
    String text;
    String extra;

    public TranslatedTextMessage(MessageContent content) {
        TextMessage textMessage = (TextMessage) content;
        this.text = textMessage.getContent() == null ? "" : textMessage.getContent();
        this.extra = textMessage.getExtra() == null ? "" : textMessage.getExtra();
    }
}
