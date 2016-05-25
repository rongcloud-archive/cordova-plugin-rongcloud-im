package io.rong.common.translation;

import io.rong.imlib.model.MessageContent;
import io.rong.message.LocationMessage;

/**
 * Created by weiqinxiao on 15/9/15.
 */
public class TranslatedLocationMessage extends TranslatedMessageContent{
    double latitude;
    double longitude;
    String poi;
    String imagePath;
    String extra;

    public TranslatedLocationMessage(MessageContent messageContent) {
        LocationMessage locationMessage = (LocationMessage) messageContent;
        extra = locationMessage.getExtra() == null ? "" : locationMessage.getExtra();
        latitude = locationMessage.getLat();
        longitude = locationMessage.getLng();
        imagePath = locationMessage.getImgUri() != null ? locationMessage.getImgUri().getPath() : null;
        poi = locationMessage.getPoi() == null ? "" : locationMessage.getPoi();
    }
}
