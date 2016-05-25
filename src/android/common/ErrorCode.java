package io.rong.common;

import android.util.Log;

/**
 * RongIMClient ErrorCode
 */
public enum ErrorCode {
    /**
     * 尚未初始化。
     */
    NOT_INIT(-10000, "Not Init"),

    /**
     * 尚未连接。
     */
    NOT_CONNECTED(-10001, "Not Connected."),
    /**
     * 参数异常。
     */
    ARGUMENT_EXCEPTION(-10002, "Argument Exception."),
    /**
     * IPC 进程意外终止。
     */
    IPC_DISCONNECT(-2, "IPC is not conntected"),
    /**
     * 未知错误。
     */
    UNKNOWN(-1, "unknown"),
    /**
     * 连接成功。
     */
    CONNECTED(0, ""),
    /**
     * 不在讨论组。
     */
    NOT_IN_DISCUSSION(21406, ""),
    /**
     * 不在群组。
     */
    NOT_IN_GROUP(22406, ""),
    /**
     * 群组被禁言
     */
    FORBIDDEN_IN_GROUP(22408,""),
    /**
     * 不在聊天室。
     */
    NOT_IN_CHATROOM(23406, ""),

    /**
     * 在黑名单中。
     */
    REJECTED_BY_BLACKLIST(405, "rejected by blacklist"),

    /**
     * 通信过程中，当前 Socket 不存在。
     */
    RC_NET_CHANNEL_INVALID(30001, "IPC is not conntected"),
    /**
     * Socket 连接不可用。
     */
    RC_NET_UNAVAILABLE(30002, ""),
    /**
     * 通信超时。
     */
    RC_MSG_RESP_TIMEOUT(30003, ""), // timeout while receive response of tcp message(publish,query)
    /**
     * 导航操作时，Http 请求失败。
     */
    RC_HTTP_SEND_FAIL(30004, ""),
    /**
     * HTTP 请求失败。
     */
    RC_HTTP_REQ_TIMEOUT(30005, ""),
    /**
     * HTTP 接收失败。
     */
    RC_HTTP_RECV_FAIL(30006, ""),
    /**
     * 导航操作的 HTTP 请求，返回不是200。
     */
    RC_NAVI_RESOURCE_ERROR(30007, ""), // http status code is not 200 while get navi data
    /**
     * 导航数据解析后，其中不存在有效数据。
     */
    RC_NODE_NOT_FOUND(30008, ""),
    /**
     * 导航数据解析后，其中不存在有效 IP 地址。
     */
    RC_DOMAIN_NOT_RESOLVE(30009, ""),
    /**
     * 创建 Socket 失败。
     */
    RC_SOCKET_NOT_CREATED(30010, ""),
    /**
     * Socket 被断开。
     */
    RC_SOCKET_DISCONNECTED(30011, ""),
    /**
     * PING 操作失败。
     */
    RC_PING_SEND_FAIL(30012, ""), // timeout of ping response need
    /**
     * PING 超时。
     */
    RC_PONG_RECV_FAIL(30013, ""), // timeout of ping response need

    /**
     * 消息发送失败。
     */
    RC_MSG_SEND_FAIL(30014, ""),
    /**
     * 做 connect 连接时，收到的 ACK 超时。
     */
    RC_CONN_ACK_TIMEOUT(31000, ""),
    /**
     * 参数错误。
     */
    RC_CONN_PROTO_VERSION_ERROR(31001, ""),
    /**
     * 参数错误，App Id 错误。
     */
    RC_CONN_ID_REJECT(31002, ""),
    /**
     * 服务器不可用。
     */
    RC_CONN_SERVER_UNAVAILABLE(31003, ""),
    /**
     * Token 错误。
     */
    RC_CONN_USER_OR_PASSWD_ERROR(31004, ""),
    /**
     * App Id 与 Token 不匹配。
     */
    RC_CONN_NOT_AUTHRORIZED(31005, ""),
    /**
     * 重定向，地址错误。
     */
    RC_CONN_REDIRECTED(31006, ""),
    /**
     * NAME 与后台注册信息不一致。
     */
    RC_CONN_PACKAGE_NAME_INVALID(31007, ""),
    /**
     * APP 被屏蔽、删除或不存在。
     */
    RC_CONN_APP_BLOCKED_OR_DELETED(31008, ""),
    /**
     * 用户被屏蔽。
     */
    RC_CONN_USER_BLOCKED(31009, ""),
    /**
     * Disconnect，由服务器返回，比如用户互踢。
     */
    RC_DISCONN_KICK(31010, ""),
    /**
     * Disconnect，由服务器返回，比如用户互踢。
     */
    RC_DISCONN_EXCEPTION(31011, ""),
    /**
     * 协议层内部错误。query，上传下载过程中数据错误。
     */
    RC_QUERY_ACK_NO_DATA(32001, ""),
    /**
     * 协议层内部错误。
     */
    RC_MSG_DATA_INCOMPLETE(32002, ""),

    /**
     * 未调用 init 初始化函数。
     */
    BIZ_ERROR_CLIENT_NOT_INIT(33001, ""),
    /**
     * 数据库初始化失败。
     */
    BIZ_ERROR_DATABASE_ERROR(33002, ""),
    /**
     * 传入参数无效。
     */
    BIZ_ERROR_INVALID_PARAMETER(33003, ""),
    /**
     * 通道无效。
     */
    BIZ_ERROR_NO_CHANNEL(33004, ""),
    /**
     * 重新连接成功。
     */
    BIZ_ERROR_RECONNECT_SUCCESS(33005, ""),
    /**
     * 连接中，再调用 connect 被拒绝。
     */
    BIZ_ERROR_CONNECTING(33006, "");

    private int code;
    private String msg;

    /**
     * 构造函数。
     *
     * @param code 错误代码。
     * @param msg  错误消息。
     */
    ErrorCode(int code, String msg) {
        this.code = code;
        this.msg = msg;
    }

    /**
     * 获取错误代码值。
     *
     * @return 错误代码值。
     */
    public int getValue() {
        return this.code;
    }

    /**
     * 获取错误消息。
     *
     * @return 错误消息。
     */
    public String getMessage() {
        return this.msg;
    }

    /**
     * 设置错误代码值。
     *
     * @param code 错误代码。
     * @return 错误代码枚举。
     */
    public static ErrorCode setValue(int code) {
        for (ErrorCode c : ErrorCode.values()) {
            if (code == c.getValue()) {
                return c;
            }
        }

        Log.d("RongIMClient", "setValue : ErrorCode = " + code);
        return UNKNOWN;
    }
}
