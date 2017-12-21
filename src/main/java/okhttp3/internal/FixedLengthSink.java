package okhttp3.internal;

import java.io.IOException;
import java.net.ProtocolException;

import okio.Buffer;
import okio.BufferedSink;
import okio.ForwardingTimeout;
import okio.Sink;
import okio.Timeout;

import static okhttp3.internal.Util.checkOffsetAndCount;

/** An HTTP body with a fixed length known in advance. */
public final class FixedLengthSink extends BaseSink {
    private boolean closed;
    private long bytesRemaining;

    private final ForwardingTimeout timeout = new ForwardingTimeout(sink.timeout());

    protected FixedLengthSink(long bytesRemaining, BufferedSink sink) {
        super(sink);

        this.bytesRemaining = bytesRemaining;
    }

    public static Sink createFixedLengthSink(long bytesRemaining, BufferedSink sink) {
        return new FixedLengthSink(bytesRemaining, sink);
    }

    @Override public Timeout timeout() {
        return timeout;
    }

    @Override public void write(Buffer source, long byteCount) throws IOException {
        if (closed) throw new IllegalStateException("closed");
        checkOffsetAndCount(source.size(), 0, byteCount);
        if (byteCount > bytesRemaining) {
            throw new ProtocolException("expected " + bytesRemaining
                    + " bytes but received " + byteCount);
        }
        sink.write(source, byteCount);
        bytesRemaining -= byteCount;
    }

    @Override public void flush() throws IOException {
        if (closed) return; // Don't throw; this stream might have been closed on the caller's behalf.
        sink.flush();
    }

    @Override public void close() throws IOException {
        if (closed) return;
        closed = true;
        if (bytesRemaining > 0) throw new ProtocolException("unexpected end of stream");
        detachTimeout(timeout);
    }
}