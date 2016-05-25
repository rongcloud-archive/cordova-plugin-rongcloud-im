package io.rong.common.translation;

import io.rong.imlib.model.MessageContent;
import io.rong.message.ProfileNotificationMessage;

/**
 * Created by weiqinxiao on 15/12/24.
 */
public class TranslatedProfileNtfMessage extends TranslatedMessageContent {
    private String operation; // 资料变更的操作名。
    private String data; // 资料变更的数据，可以为任意格式，如 JSON。
    private String extra; // 附加信息。

    public TranslatedProfileNtfMessage(MessageContent content) {
        ProfileNotificationMessage message = (ProfileNotificationMessage)content;
        operation = message.getOperation() == null ? "" : message.getOperation();
        data = message.getData() == null ? "" : message.getData();
        extra = message.getExtra() == null ? "" : message.getExtra();
    }
}
