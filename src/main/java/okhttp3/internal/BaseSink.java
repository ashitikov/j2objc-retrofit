package okhttp3.internal;

import okio.BufferedSink;
import okio.ForwardingTimeout;
import okio.Sink;
import okio.Timeout;

/**
 * Created by ashitikov on 14.09.16.
 */
public abstract class BaseSink implements Sink {
    protected BufferedSink sink;

    protected BaseSink(BufferedSink sink) {
        this.sink = sink;
    }

    /**
     * Sets the delegate of {@code timeout} to {@link Timeout#NONE} and resets its underlying timeout
     * to the default configuration. Use this to avoid unexpected sharing of timeouts between pooled
     * connections.
     */
    protected void detachTimeout(ForwardingTimeout timeout) {
        Timeout oldDelegate = timeout.delegate();
        timeout.setDelegate(Timeout.NONE);
        oldDelegate.clearDeadline();
        oldDelegate.clearTimeout();
    }
}
