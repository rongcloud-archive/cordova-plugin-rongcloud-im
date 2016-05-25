package io.rong.common.translation;

import io.rong.imlib.model.MessageContent;
import io.rong.message.ContactNotificationMessage;

/**
 * Created by weiqinxiao on 15/12/24.
 */
public class TranslatedContactNtfMessage extends TranslatedMessageContent {
    private String operation; // 操作名，对应 ContactOperationXxxx，或自己传任何字符串。
    private String sourceUserId; // 请求者或者响应者的 UserId。
    private String targetUserId; // 被请求者或者被响应者的 UserId。
    private String message; // 请求或者响应消息，如添加理由或拒绝理由。
    private String extra; // 附加信息。

    public TranslatedContactNtfMessage(MessageContent content) {
        ContactNotificationMessage msg = (ContactNotificationMessage)content;
        operation = msg.getOperation() == null ? "" : msg.getOperation();
        sourceUserId = msg.getSourceUserId() == null ? "" : msg.getSourceUserId();
        targetUserId = msg.getTargetUserId() == null ? "" : msg.getTargetUserId();
        message = msg.getMessage() == null ? "" : msg.getMessage();
        extra = msg.getExtra() == null ? "" : msg.getExtra();
    }
}
