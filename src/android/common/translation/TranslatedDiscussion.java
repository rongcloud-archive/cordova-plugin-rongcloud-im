package io.rong.common.translation;

import java.util.List;

import io.rong.imlib.model.Discussion;

/**
 * Created by weiqinxiao on 15/9/16.
 */
public class TranslatedDiscussion {
    String creatorId;
    String id;
    String name;
    List<String> memberIdList;
    String inviteStatus;

    public TranslatedDiscussion(Discussion discussion) {
        this.creatorId = discussion.getCreatorId();
        this.id = discussion.getId();
        this.name = discussion.getName();
        this.memberIdList = discussion.getMemberIdList();
        this.inviteStatus = discussion.isOpen() ? "OPENED" : "CLOSED";
    }
}
