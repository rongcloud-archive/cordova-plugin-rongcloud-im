package io.rong.cordova.translation;

import io.rong.imlib.model.Message;
import io.rong.notification.PushNotificationMessage;

/**
 * Created by weiqinxiao on 15/9/16.
 */
public class TranslatedPushMessage implements ITranslatedMessage {
    private String senderName;
    private String senderPortraitUri;
    private String targetUserName;
    private String pushContent;
    private String pushData;

    public TranslatedPushMessage(Message content) {
        PushNotificationMessage message = (PushNotificationMessage)content;
        this.senderName = message.getSenderName();
        this.senderPortraitUri = message.getSenderPortraitUri() != null ? message.getSenderPortraitUri().getPath() : null;
        this.targetUserName = message.getTargetUserName();
        this.pushContent = message.getPushContent() == null ? "" : message.getPushContent();
        this.pushData = message.getPushData() == null ? "" : message.getPushData();
    }
}
