package io.rong.cordova.translation;

import io.rong.imlib.model.MessageContent;
import io.rong.message.ImageMessage;

/**
 * Created by weiqinxiao on 15/9/15.
 */
public class TranslatedImageMessage extends TranslatedMessageContent {
    String imageUrl;
    String thumbPath;
    String extra;

    public TranslatedImageMessage(MessageContent content) {
        ImageMessage imageMessage = (ImageMessage) content;

        this.imageUrl = imageMessage.getRemoteUri() != null ?
                imageMessage.getRemoteUri().toString() :
                (imageMessage.getLocalUri() != null ? imageMessage.getLocalUri().getPath() : "");
        this.thumbPath = imageMessage.getThumUri() != null ? imageMessage.getThumUri().getPath() : null;
        this.extra = imageMessage.getExtra() == null ? "" : imageMessage.getExtra();
    }
}
