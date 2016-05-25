package io.rong.common.translation;

import io.rong.imlib.model.MessageContent;
import io.rong.message.RichContentMessage;

/**
 * Created by weiqinxiao on 15/9/15.
 */
public class TranslatedRichContentMessage extends TranslatedMessageContent {
    String title;
    String description;
    String imageUrl;
    String url;
    String extra;

    public TranslatedRichContentMessage(MessageContent content) {
        RichContentMessage richContentMessage = (RichContentMessage)content;
        this.extra = richContentMessage.getExtra() == null ? "" : richContentMessage.getExtra();
        this.title = richContentMessage.getTitle() == null ? "" : richContentMessage.getTitle();
        this.description = richContentMessage.getContent() == null ? "" : richContentMessage.getContent();
        this.imageUrl = richContentMessage.getImgUrl() == null ? "" : richContentMessage.getImgUrl();
        this.url = richContentMessage.getUrl() == null ? "" : richContentMessage.getUrl();
    }
}
