package dev.ecec.drawpets.nearby;

import android.app.Activity;
import android.content.ContentResolver;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.net.wifi.WifiManager;
import android.os.Build;
import android.os.ParcelFileDescriptor;
import android.os.SystemClock;
import android.util.Log;

import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GoogleApiAvailability;
import com.google.android.gms.common.api.ApiException;
import com.google.android.gms.nearby.Nearby;
import com.google.android.gms.nearby.connection.AdvertisingOptions;
import com.google.android.gms.nearby.connection.ConnectionInfo;
import com.google.android.gms.nearby.connection.ConnectionLifecycleCallback;
import com.google.android.gms.nearby.connection.ConnectionResolution;
import com.google.android.gms.nearby.connection.ConnectionsClient;
import com.google.android.gms.nearby.connection.ConnectionsStatusCodes;
import com.google.android.gms.nearby.connection.DiscoveredEndpointInfo;
import com.google.android.gms.nearby.connection.DiscoveryOptions;
import com.google.android.gms.nearby.connection.EndpointDiscoveryCallback;
import com.google.android.gms.nearby.connection.Payload;
import com.google.android.gms.nearby.connection.PayloadCallback;
import com.google.android.gms.nearby.connection.PayloadTransferUpdate;
import com.google.android.gms.nearby.connection.Strategy;
import com.journeyapps.barcodescanner.ScanIntentResult;
import com.journeyapps.barcodescanner.ScanOptions;

import org.godotengine.godot.Godot;
import org.godotengine.godot.plugin.GodotPlugin;
import org.godotengine.godot.plugin.SignalInfo;
import org.godotengine.godot.plugin.UsedByGodot;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.channels.FileChannel;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.RejectedExecutionException;

/**
 * Phone-to-phone pet swapping for DrawPets over Google Nearby Connections (Bluetooth and Wi-Fi,
 * no internet, no server), plus the Wi-Fi multicast lock the LAN fallback needs, and the camera
 * scanner that reads a friend's swap code (ZXing - a plain pattern decoder, no AI).
 *
 * GDScript: Engine.get_singleton("DrawPetsNearby"). Methods are called on Godot's render thread;
 * Nearby answers on Android's main thread; every signal is handed back to the render thread, so
 * GDScript always receives them between frames like any other signal.
 *
 * Payloads always travel as FILE payloads (BYTES payloads stop at ~32 KB). Outgoing bytes are
 * written to the app cache and deleted once sent; a received file is read into memory and then
 * deleted at once, so nothing another child sent stays on the device as a file.
 */
public class DrawPetsNearby extends GodotPlugin {
    private static final String TAG = "DrawPetsNearby";
    private static final int PERMISSION_REQUEST = 0x4E42; // "NB"
    private static final int CAMERA_REQUEST = 0x5143; // "QC"
    private static final int SCAN_REQUEST = 0x5153; // "QS"
    /** A swap code is ~50 characters; anything far longer is not one. */
    private static final int MAX_CODE_CHARS = 512;
    private static final String CAMERA = "android.permission.CAMERA";
    /** Refuse anything bigger: a pet is a few MB at most, and it is all read into memory. */
    private static final long MAX_RECEIVE_BYTES = 64L * 1024 * 1024;
    /** At most this often per transfer, plus the last one. */
    private static final long PROGRESS_INTERVAL_MS = 100;

    private static final String FINE_LOCATION = "android.permission.ACCESS_FINE_LOCATION";
    private static final String COARSE_LOCATION = "android.permission.ACCESS_COARSE_LOCATION";

    private volatile ConnectionsClient client;
    private WifiManager.MulticastLock multicastLock;
    private final ExecutorService io = Executors.newSingleThreadExecutor();

    /** A FILE payload on its way out (with the temp file to delete) or on its way in. */
    private static final class Transfer {
        final String endpointId;
        final Payload payload;
        final File tempFile; // outgoing only
        final boolean outgoing;
        long lastProgressMs;

        Transfer(String endpointId, Payload payload, File tempFile, boolean outgoing) {
            this.endpointId = endpointId;
            this.payload = payload;
            this.tempFile = tempFile;
            this.outgoing = outgoing;
        }
    }

    private final Map<Long, Transfer> transfers = new ConcurrentHashMap<>();

    public DrawPetsNearby(Godot godot) {
        super(godot);
        // Anything left in the outbox by a run that was killed mid-send.
        runIo(() -> {
            File dir = outbox();
            File[] old = dir != null ? dir.listFiles() : null;
            if (old != null) {
                for (File f : old) {
                    //noinspection ResultOfMethodCallIgnored
                    f.delete();
                }
            }
        });
    }

    @Override
    public String getPluginName() {
        return "DrawPetsNearby";
    }

    @Override
    public Set<SignalInfo> getPluginSignals() {
        Set<SignalInfo> s = new HashSet<>();
        s.add(new SignalInfo("endpoint_found", String.class, String.class));
        s.add(new SignalInfo("endpoint_lost", String.class));
        s.add(new SignalInfo("connection_initiated", String.class, String.class, String.class, Boolean.class));
        s.add(new SignalInfo("connected", String.class));
        s.add(new SignalInfo("connection_failed", String.class, String.class));
        s.add(new SignalInfo("disconnected", String.class));
        s.add(new SignalInfo("payload_received", String.class, byte[].class));
        s.add(new SignalInfo("transfer_progress", String.class, Integer.class, Integer.class, Boolean.class));
        s.add(new SignalInfo("permissions_result", Boolean.class));
        s.add(new SignalInfo("camera_result", Boolean.class));
        s.add(new SignalInfo("code_scanned", String.class));
        s.add(new SignalInfo("scan_cancelled"));
        s.add(new SignalInfo("error", String.class));
        return s;
    }

    // ---------------------------------------------------------------------------------------
    // Availability and permissions

    @UsedByGodot
    public boolean is_available() {
        Context c = getContext();
        if (c == null) {
            return false;
        }
        try {
            return GoogleApiAvailability.getInstance().isGooglePlayServicesAvailable(c) == ConnectionResult.SUCCESS;
        } catch (Exception e) {
            Log.w(TAG, "Play services check failed", e);
            return false;
        }
    }

    @UsedByGodot
    public String[] missing_permissions() {
        Context c = getContext();
        List<String> missing = new ArrayList<>();
        for (String p : neededPermissions()) {
            if (c == null || c.checkSelfPermission(p) != PackageManager.PERMISSION_GRANTED) {
                missing.add(p);
            }
        }
        return missing.toArray(new String[0]);
    }

    @UsedByGodot
    public void request_permissions() {
        String[] missing = missing_permissions();
        if (missing.length == 0) {
            emit("permissions_result", true);
            return;
        }
        List<String> ask = new ArrayList<>();
        for (String p : missing) {
            ask.add(p);
        }
        // Android 12 ignores a request for fine location that does not also ask for coarse.
        if (ask.contains(FINE_LOCATION) && !ask.contains(COARSE_LOCATION)) {
            ask.add(COARSE_LOCATION);
        }
        final String[] perms = ask.toArray(new String[0]);
        runOnHostThread(() -> {
            Activity a = getActivity();
            if (a == null) {
                emit("permissions_result", false);
                return;
            }
            a.requestPermissions(perms, PERMISSION_REQUEST);
        });
    }

    @Override
    public void onMainRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        super.onMainRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == CAMERA_REQUEST) {
            emit("camera_result", camera_allowed());
            return;
        }
        if (requestCode != PERMISSION_REQUEST) {
            return;
        }
        // Judge by what is granted now, not by this one answer: a permission granted earlier
        // counts, and a dialog that was dismissed comes back with no results at all.
        emit("permissions_result", missing_permissions().length == 0);
    }

    /** The run-time permissions Nearby Connections needs on this Android version. */
    private static String[] neededPermissions() {
        int sdk = Build.VERSION.SDK_INT;
        if (sdk >= 33) {
            return new String[] {
                "android.permission.BLUETOOTH_SCAN",
                "android.permission.BLUETOOTH_ADVERTISE",
                "android.permission.BLUETOOTH_CONNECT",
                "android.permission.NEARBY_WIFI_DEVICES",
            };
        }
        if (sdk >= 31) {
            return new String[] {
                "android.permission.BLUETOOTH_SCAN",
                "android.permission.BLUETOOTH_ADVERTISE",
                "android.permission.BLUETOOTH_CONNECT",
                FINE_LOCATION,
            };
        }
        if (sdk >= 29) {
            return new String[] {FINE_LOCATION};
        }
        return new String[] {COARSE_LOCATION};
    }

    // ---------------------------------------------------------------------------------------
    // Finding each other

    @UsedByGodot
    public void start(String serviceId, String localName) {
        ConnectionsClient c = client();
        if (c == null) {
            emit("error", "start: the game is not ready");
            return;
        }
        // Safe to call again: whatever was running stops first.
        c.stopAdvertising();
        c.stopDiscovery();
        AdvertisingOptions ao = new AdvertisingOptions.Builder()
                .setStrategy(Strategy.P2P_POINT_TO_POINT).build();
        c.startAdvertising(localName, serviceId, lifecycle, ao)
                .addOnFailureListener(e -> {
                    if (statusCode(e) != ConnectionsStatusCodes.STATUS_ALREADY_ADVERTISING) {
                        emit("error", "advertising: " + describe(e));
                    }
                });
        DiscoveryOptions dopt = new DiscoveryOptions.Builder()
                .setStrategy(Strategy.P2P_POINT_TO_POINT).build();
        c.startDiscovery(serviceId, discovery, dopt)
                .addOnFailureListener(e -> {
                    if (statusCode(e) != ConnectionsStatusCodes.STATUS_ALREADY_DISCOVERING) {
                        emit("error", "discovery: " + describe(e));
                    }
                });
    }

    @UsedByGodot
    public void stop() {
        ConnectionsClient c = client;
        if (c != null) {
            try {
                c.stopAdvertising();
                c.stopDiscovery();
                c.stopAllEndpoints();
            } catch (Exception e) {
                Log.w(TAG, "stop", e);
            }
        }
        dropTransfers(null);
    }

    private final EndpointDiscoveryCallback discovery = new EndpointDiscoveryCallback() {
        @Override
        public void onEndpointFound(String endpointId, DiscoveredEndpointInfo info) {
            emit("endpoint_found", endpointId, nonNull(info.getEndpointName()));
        }

        @Override
        public void onEndpointLost(String endpointId) {
            emit("endpoint_lost", endpointId);
        }
    };

    // ---------------------------------------------------------------------------------------
    // Connecting

    @UsedByGodot
    public void request_connection(String endpointId, String localName) {
        ConnectionsClient c = client();
        if (c == null) {
            emit("connection_failed", endpointId, "not ready");
            return;
        }
        c.requestConnection(localName, endpointId, lifecycle)
                .addOnFailureListener(e -> emit("connection_failed", endpointId, describe(e)));
    }

    @UsedByGodot
    public void accept_connection(String endpointId) {
        ConnectionsClient c = client();
        if (c == null) {
            emit("connection_failed", endpointId, "not ready");
            return;
        }
        c.acceptConnection(endpointId, payloads)
                .addOnFailureListener(e -> emit("connection_failed", endpointId, describe(e)));
    }

    @UsedByGodot
    public void reject_connection(String endpointId) {
        ConnectionsClient c = client();
        if (c == null) {
            return;
        }
        c.rejectConnection(endpointId)
                .addOnFailureListener(e -> Log.w(TAG, "reject " + endpointId + ": " + describe(e)));
    }

    /** Hangs up. Like Nearby itself, this does not emit "disconnected" - that is for the other side. */
    @UsedByGodot
    public void disconnect_endpoint(String endpointId) {
        ConnectionsClient c = client;
        if (c != null) {
            c.disconnectFromEndpoint(endpointId);
        }
        dropTransfers(endpointId);
    }

    private final ConnectionLifecycleCallback lifecycle = new ConnectionLifecycleCallback() {
        @Override
        @SuppressWarnings("deprecation") // getAuthenticationToken: only if there are no digits
        public void onConnectionInitiated(String endpointId, ConnectionInfo info) {
            String digits = info.getAuthenticationDigits();
            if (digits == null || digits.isEmpty()) {
                digits = nonNull(info.getAuthenticationToken());
            }
            emit("connection_initiated", endpointId, nonNull(info.getEndpointName()), digits,
                    info.isIncomingConnection());
        }

        @Override
        public void onConnectionResult(String endpointId, ConnectionResolution result) {
            int code = result.getStatus().getStatusCode();
            if (code == ConnectionsStatusCodes.STATUS_OK) {
                // Point to point: one friend at a time. Searching on while connected slows the
                // link and holds back Nearby's upgrade from Bluetooth to Wi-Fi, so stop now;
                // start() again to look for someone else.
                ConnectionsClient c = client;
                if (c != null) {
                    c.stopAdvertising();
                    c.stopDiscovery();
                }
                emit("connected", endpointId);
            } else if (code == ConnectionsStatusCodes.STATUS_CONNECTION_REJECTED) {
                emit("connection_failed", endpointId, "rejected");
            } else {
                emit("connection_failed", endpointId, codeName(code));
            }
        }

        @Override
        public void onDisconnected(String endpointId) {
            dropTransfers(endpointId);
            emit("disconnected", endpointId);
        }
    };

    // ---------------------------------------------------------------------------------------
    // Sending and receiving

    @UsedByGodot
    public void send_bytes(String endpointId, byte[] data) {
        final ConnectionsClient c = client();
        if (c == null) {
            emit("error", "send: the game is not ready");
            return;
        }
        final byte[] bytes = data != null ? data : new byte[0];
        runIo(() -> {
            File dir = outbox();
            if (dir == null) {
                emit("error", "send to " + endpointId + ": no cache folder");
                return;
            }
            File f = new File(dir, "out_" + System.nanoTime() + ".bin");
            Payload p;
            try {
                try (FileOutputStream out = new FileOutputStream(f)) {
                    out.write(bytes);
                }
                p = Payload.fromFile(f);
            } catch (IOException e) {
                //noinspection ResultOfMethodCallIgnored
                f.delete();
                emit("error", "send to " + endpointId + ": " + e.getMessage());
                return;
            }
            final long id = p.getId();
            transfers.put(id, new Transfer(endpointId, p, f, true));
            c.sendPayload(endpointId, p).addOnFailureListener(e -> {
                finish(id);
                emit("error", "send to " + endpointId + ": " + describe(e));
            });
        });
    }

    private final PayloadCallback payloads = new PayloadCallback() {
        @Override
        public void onPayloadReceived(String endpointId, Payload payload) {
            if (payload.getType() == Payload.Type.BYTES) {
                byte[] b = payload.asBytes();
                emit("payload_received", endpointId, b != null ? b : new byte[0]);
                return;
            }
            if (payload.getType() != Payload.Type.FILE || payload.asFile() == null) {
                payload.close(); // streams are not part of the game
                return;
            }
            if (payload.asFile().getSize() > MAX_RECEIVE_BYTES) {
                refuse(endpointId, payload);
                return;
            }
            transfers.put(payload.getId(), new Transfer(endpointId, payload, null, false));
        }

        @Override
        public void onPayloadTransferUpdate(String endpointId, PayloadTransferUpdate update) {
            long id = update.getPayloadId();
            Transfer t = transfers.get(id);
            if (t == null) {
                return; // a BYTES payload, already delivered
            }
            long done = update.getBytesTransferred();
            long total = update.getTotalBytes();
            switch (update.getStatus()) {
                case PayloadTransferUpdate.Status.IN_PROGRESS: {
                    if (!t.outgoing && total > MAX_RECEIVE_BYTES) {
                        refuse(endpointId, t.payload);
                        return;
                    }
                    long now = SystemClock.elapsedRealtime();
                    if (now - t.lastProgressMs >= PROGRESS_INTERVAL_MS) {
                        t.lastProgressMs = now;
                        emit("transfer_progress", endpointId, clampInt(done), clampInt(total), t.outgoing);
                    }
                    break;
                }
                case PayloadTransferUpdate.Status.SUCCESS:
                    emit("transfer_progress", endpointId, clampInt(total), clampInt(total), t.outgoing);
                    if (t.outgoing) {
                        finish(id);
                    } else {
                        transfers.remove(id);
                        runIo(() -> deliver(t));
                    }
                    break;
                case PayloadTransferUpdate.Status.FAILURE:
                case PayloadTransferUpdate.Status.CANCELED:
                    finish(id);
                    String what = update.getStatus() == PayloadTransferUpdate.Status.FAILURE ? "failed" : "cancelled";
                    emit("error", (t.outgoing ? "send to " : "receive from ") + endpointId + " " + what);
                    break;
                default:
                    break;
            }
        }
    };

    /** Reads a finished incoming file, deletes it, then hands its bytes to GDScript. */
    private void deliver(Transfer t) {
        byte[] data = null;
        String problem = null;
        try {
            data = readReceived(t.payload);
        } catch (IOException | RuntimeException e) {
            problem = e.getMessage();
            Log.w(TAG, "reading a received file", e);
        } finally {
            deleteReceived(t.payload);
        }
        if (data != null) {
            emit("payload_received", t.endpointId, data);
        } else {
            emit("error", "receive from " + t.endpointId + ": could not read the file (" + problem + ")");
        }
    }

    private void refuse(String endpointId, Payload payload) {
        ConnectionsClient c = client;
        if (c != null) {
            c.cancelPayload(payload.getId());
        }
        transfers.remove(payload.getId());
        runIo(() -> deleteReceived(payload));
        emit("error", "receive from " + endpointId + ": too big");
    }

    /** Android 10+ keeps a received file where only its content Uri reaches it; older versions
     *  hand over a file descriptor or a plain path. Try them in that order. */
    private byte[] readReceived(Payload payload) throws IOException {
        Payload.File pf = payload.asFile();
        if (pf == null) {
            throw new IOException("no file");
        }
        long size = pf.getSize();
        IOException last = null;
        Context ctx = getContext();
        Uri uri = pf.asUri();
        if (uri != null && ctx != null) {
            try (InputStream in = ctx.getContentResolver().openInputStream(uri)) {
                if (in != null) {
                    return readAll(in, size);
                }
            } catch (IOException | SecurityException e) {
                last = new IOException("uri: " + e.getMessage(), e);
            }
        }
        ParcelFileDescriptor pfd = pf.asParcelFileDescriptor();
        if (pfd != null) {
            // A copy of the descriptor, so closing this stream leaves Nearby's own to close().
            try (ParcelFileDescriptor dup = pfd.dup();
                 FileInputStream in = new ParcelFileDescriptor.AutoCloseInputStream(dup)) {
                FileChannel ch = in.getChannel();
                ch.position(0);
                return readAll(in, size);
            } catch (IOException e) {
                last = e;
            }
        }
        @SuppressWarnings("deprecation")
        File jf = pf.asJavaFile();
        if (jf != null && jf.canRead()) {
            try (InputStream in = new FileInputStream(jf)) {
                return readAll(in, size);
            }
        }
        throw last != null ? last : new IOException("no readable copy");
    }

    @SuppressWarnings("deprecation")
    private void deleteReceived(Payload payload) {
        Payload.File pf = payload.asFile();
        Uri uri = pf != null ? pf.asUri() : null;
        File jf = pf != null ? pf.asJavaFile() : null;
        try {
            payload.close();
        } catch (Exception ignored) {
            // already closed
        }
        Context ctx = getContext();
        if (uri != null && ctx != null && ContentResolver.SCHEME_CONTENT.equals(uri.getScheme())) {
            try {
                ctx.getContentResolver().delete(uri, null, null);
            } catch (Exception e) {
                Log.w(TAG, "could not delete " + uri, e);
            }
        }
        if (jf != null && jf.exists() && !jf.delete()) {
            Log.w(TAG, "could not delete " + jf);
        }
    }

    private static byte[] readAll(InputStream in, long size) throws IOException {
        if (size > MAX_RECEIVE_BYTES) {
            throw new IOException("too big");
        }
        ByteArrayOutputStream out = new ByteArrayOutputStream(size > 0 ? (int) size : 64 * 1024);
        byte[] buf = new byte[64 * 1024];
        long total = 0;
        int n;
        while ((n = in.read(buf)) != -1) {
            total += n;
            if (total > MAX_RECEIVE_BYTES) {
                throw new IOException("too big");
            }
            out.write(buf, 0, n);
        }
        return out.toByteArray();
    }

    /** Forgets a transfer: closes it, and deletes an outgoing temp file. */
    private void finish(long payloadId) {
        Transfer t = transfers.remove(payloadId);
        if (t == null) {
            return;
        }
        runIo(() -> {
            if (t.outgoing) {
                try {
                    t.payload.close();
                } catch (Exception ignored) {
                    // already closed
                }
                if (t.tempFile != null && t.tempFile.exists() && !t.tempFile.delete()) {
                    Log.w(TAG, "could not delete " + t.tempFile);
                }
            } else {
                deleteReceived(t.payload);
            }
        });
    }

    /** Every transfer with that endpoint (or every transfer, for null). */
    private void dropTransfers(String endpointId) {
        Iterator<Map.Entry<Long, Transfer>> it = transfers.entrySet().iterator();
        List<Long> ids = new ArrayList<>();
        while (it.hasNext()) {
            Map.Entry<Long, Transfer> e = it.next();
            if (endpointId == null || endpointId.equals(e.getValue().endpointId)) {
                ids.add(e.getKey());
            }
        }
        for (Long id : ids) {
            finish(id);
        }
    }

    /** The app's own cache folder for outgoing payloads, or null before there is a context. */
    private File outbox() {
        Context ctx = getContext();
        if (ctx == null) {
            return null;
        }
        File dir = new File(ctx.getCacheDir(), "nearby_out");
        if (!dir.isDirectory() && !dir.mkdirs()) {
            Log.w(TAG, "could not make " + dir);
            return null;
        }
        return dir;
    }

    /** File work, off both the main and the render thread, one job at a time. */
    private void runIo(Runnable job) {
        try {
            io.execute(job);
        } catch (RejectedExecutionException e) {
            job.run(); // shutting down: do it here rather than leave a file behind
        }
    }

    // ---------------------------------------------------------------------------------------
    // The LAN fallback: Android drops broadcast/multicast UDP on Wi-Fi unless a lock is held.

    @UsedByGodot
    public void acquire_multicast_lock() {
        synchronized (this) {
            if (multicastLock == null) {
                Context ctx = getContext();
                if (ctx == null) {
                    return;
                }
                WifiManager wm = (WifiManager) ctx.getApplicationContext().getSystemService(Context.WIFI_SERVICE);
                if (wm == null) {
                    emit("error", "multicast lock: no Wi-Fi");
                    return;
                }
                multicastLock = wm.createMulticastLock("DrawPetsLan");
                multicastLock.setReferenceCounted(false);
            }
            try {
                multicastLock.acquire();
            } catch (RuntimeException e) {
                emit("error", "multicast lock: " + e.getMessage());
            }
        }
    }

    @UsedByGodot
    public void release_multicast_lock() {
        synchronized (this) {
            if (multicastLock != null && multicastLock.isHeld()) {
                multicastLock.release();
            }
        }
    }

    // ---------------------------------------------------------------------------------------
    // Reading a friend's swap code: ZXing's scanner screen opens over the game until it reads a
    // QR code or the kid backs out. The game checks what the code says (LanLink.read_code).

    /** True when this device has a camera to scan with. */
    @UsedByGodot
    public boolean can_scan() {
        Context c = getContext();
        return c != null && c.getPackageManager().hasSystemFeature(PackageManager.FEATURE_CAMERA_ANY);
    }

    @UsedByGodot
    public boolean camera_allowed() {
        Context c = getContext();
        return c != null && c.checkSelfPermission(CAMERA) == PackageManager.PERMISSION_GRANTED;
    }

    /** Asks for the camera; answers with camera_result. */
    @UsedByGodot
    public void request_camera() {
        if (camera_allowed()) {
            emit("camera_result", true);
            return;
        }
        runOnHostThread(() -> {
            Activity a = getActivity();
            if (a == null) {
                emit("camera_result", false);
                return;
            }
            a.requestPermissions(new String[] {CAMERA}, CAMERA_REQUEST);
        });
    }

    /** Opens the scanner; answers with code_scanned(text) or scan_cancelled. */
    @UsedByGodot
    public void scan_code(String prompt) {
        runOnHostThread(() -> {
            Activity a = getActivity();
            if (a == null) {
                emit("scan_cancelled");
                return;
            }
            ScanOptions o = new ScanOptions();
            o.setDesiredBarcodeFormats(ScanOptions.QR_CODE);
            o.setPrompt(nonNull(prompt));
            o.setBeepEnabled(false);
            o.setBarcodeImageEnabled(false);
            o.setOrientationLocked(true);
            try {
                a.startActivityForResult(o.createScanIntent(a), SCAN_REQUEST);
            } catch (Exception e) {
                Log.w(TAG, "The scanner did not open", e);
                emit("scan_cancelled");
            }
        });
    }

    @Override
    public void onMainActivityResult(int requestCode, int resultCode, Intent data) {
        super.onMainActivityResult(requestCode, resultCode, data);
        if (requestCode != SCAN_REQUEST) {
            return;
        }
        String text = ScanIntentResult.parseActivityResult(resultCode, data).getContents();
        if (text != null && text.length() <= MAX_CODE_CHARS) {
            emit("code_scanned", text);
        } else {
            emit("scan_cancelled");
        }
    }

    // ---------------------------------------------------------------------------------------

    @Override
    public void onMainDestroy() {
        stop();
        release_multicast_lock();
        io.shutdown();
        super.onMainDestroy();
    }

    private synchronized ConnectionsClient client() {
        if (client == null) {
            Activity a = getActivity();
            Context ctx = a != null ? a : getContext();
            if (ctx == null) {
                return null;
            }
            client = Nearby.getConnectionsClient(ctx);
        }
        return client;
    }

    /** Signals go out on Godot's render thread, where GDScript runs. */
    private void emit(String signal, Object... args) {
        runOnRenderThread(() -> emitSignal(signal, args));
    }

    private static int statusCode(Exception e) {
        return e instanceof ApiException ? ((ApiException) e).getStatusCode() : -1;
    }

    private static String describe(Exception e) {
        if (e instanceof ApiException) {
            return codeName(((ApiException) e).getStatusCode());
        }
        return e.getMessage() != null ? e.getMessage() : e.getClass().getSimpleName();
    }

    private static String codeName(int code) {
        return ConnectionsStatusCodes.getStatusCodeString(code) + " (" + code + ")";
    }

    private static int clampInt(long v) {
        return (int) Math.max(0, Math.min(Integer.MAX_VALUE, v));
    }

    private static String nonNull(String s) {
        return s != null ? s : "";
    }
}
