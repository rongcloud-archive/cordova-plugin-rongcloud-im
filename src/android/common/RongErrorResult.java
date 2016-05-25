package io.rong.common;

/**
 * Created by weiqinxiao on 15/10/16.
 */
public class RongErrorResult<T> {
    T result;
    int code;

    public T getResult() {
        return result;
    }

    public void setResult(T result) {
        this.result = result;
    }

    public int getStatus() {
        return code;
    }

    public void setStatus(int code) {
        this.code = code;
    }
}
