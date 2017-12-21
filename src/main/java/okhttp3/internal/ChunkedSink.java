package okhttp3.internal;

import java.io.IOException;

import okio.Buffer;
import okio.BufferedSink;
import okio.ForwardingTimeout;
import okio.Sink;
import okio.Timeout;

/**
 * An HTTP body with alternating chunk sizes and chunk bodies. It is the caller's responsibility
 * to buffer chunks; typically by using a buffered sink with this sink.
 */
public final class ChunkedSink extends BaseSink {
    private BufferedSink sink;
    private boolean closed;

    private final ForwardingTimeout timeout = new ForwardingTimeout(sink.timeout());

    protected ChunkedSink(BufferedSink sink) {
        super(sink);
    }

    public static Sink createChunkedSink(BufferedSink sink) {
        return new ChunkedSink(sink);
    }

    @Override
    public Timeout timeout() {
        return timeout;
    }

    @Override
    public void write(Buffer source, long byteCount) throws IOException {
        if (closed) throw new IllegalStateException("closed");
        if (byteCount == 0) return;

        sink.writeHexadecimalUnsignedLong(byteCount);
        sink.writeUtf8("\r\n");
        sink.write(source, byteCount);
        sink.writeUtf8("\r\n");
    }

    @Override
    public synchronized void flush() throws IOException {
        if (closed) return; // Don't throw; this stream might have been closed on the caller's behalf.
        sink.flush();
    }

    @Override
    public synchronized void close() throws IOException {
        if (closed) return;
        closed = true;
        sink.writeUtf8("0\r\n\r\n");
        detachTimeout(timeout);
    }
}
