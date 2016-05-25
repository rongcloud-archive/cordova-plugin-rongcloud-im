package io.rong.common.translation;

import io.rong.imlib.model.MessageContent;
import io.rong.message.VoiceMessage;

/**
 * Created by weiqinxiao on 15/9/15.
 */
public class TranslatedVoiceMessage extends TranslatedMessageContent {
    String voicePath;
    int duration;
    String extra;

    public TranslatedVoiceMessage(MessageContent content) {
        VoiceMessage voiceMessage = (VoiceMessage) content;
        this.duration = voiceMessage.getDuration();
        this.extra = voiceMessage.getExtra() == null ? "" : voiceMessage.getExtra();
        this.voicePath = voiceMessage.getUri() != null ? voiceMessage.getUri().getPath() : null;
    }
}
