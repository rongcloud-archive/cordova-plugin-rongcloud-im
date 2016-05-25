package io.rong.common;

public class RongResult<T> {
    T result;
    Status status;

    public T getResult() {
        return result;
    }

    public void setResult(T result) {
        this.result = result;
    }

    public Status getStatus() {
        return status;
    }

    public void setStatus(Status status) {
        this.status = status;
    }

    public static enum Status{
        prepare, success, error, progress
    }
}
