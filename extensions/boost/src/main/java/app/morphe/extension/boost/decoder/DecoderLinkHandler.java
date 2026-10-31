/*
 * Copyright 2026 wchill.
 * https://github.com/wchill/patcheddit
 *
 * See the included NOTICE file for GPLv3 §7(b) and §7(c) terms that apply to this code.
 */

package app.morphe.extension.boost.decoder;

import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.widget.Toast;

import app.morphe.extension.shared.Logger;
import app.morphe.extension.shared.Utils;

/**
 * Handles taps on the decoder's Copy links before Boost's navigation handler opens them.
 *
 * @noinspection unused
 */
public final class DecoderLinkHandler {
    private DecoderLinkHandler() {
        // Prevent instantiation
    }

    /**
     * Injected at the start of Boost's navigation handler.
     *
     * @return true if the link was a Copy link and has been handled.
     */
    public static boolean handleLink(Context context, String url) {
        String text = CommentDecoder.copyText(url);
        if (text == null) return false;
        try {
            Context ctx = context != null ? context : Utils.getContext();
            ClipboardManager clipboard = (ClipboardManager) ctx.getSystemService(Context.CLIPBOARD_SERVICE);
            clipboard.setPrimaryClip(ClipData.newPlainText("Decoded text", text));
            Toast.makeText(ctx, "Copied " + text, Toast.LENGTH_SHORT).show();
        } catch (Exception ex) {
            Logger.printException(() -> "Failed to copy decoded text", ex);
        }
        return true;
    }
}
