package io.rong.common;

public class RongException{

    private int code;

    public RongException(ErrorCode errorCode){
        this.code = errorCode.getValue();
    }

    public RongException(int code){
        ErrorCode errorCode = ErrorCode.setValue(code);
        this.code = errorCode.getValue();
    }

    public RongException(Throwable throwable){
        ErrorCode errorCode = ErrorCode.UNKNOWN;
        this.code = errorCode.getValue();
    }

    public int getCode() {
        return code;
    }

    public void setCode(int code) {
        this.code = code;
    }
}
