package com.nurebo.nurebo;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

public class RestartReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
        if (intent.getAction() != null && intent.getAction().equals("com.nurebo.nurebo.RESTART_APP")) {
            Intent i = context.getPackageManager().getLaunchIntentForPackage(context.getPackageName());
            if (i != null) {
                i.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
                context.startActivity(i);
            }
        }
    }
}
