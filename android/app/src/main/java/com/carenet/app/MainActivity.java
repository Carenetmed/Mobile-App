package com.carenet.app;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.os.Build;
import android.os.Bundle;

import io.flutter.embedding.android.FlutterActivity;

public class MainActivity extends FlutterActivity {
    private static final String TRANSACTIONAL_CHANNEL_ID = "carenet_transactional";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        createTransactionalNotificationChannel();
    }

    private void createTransactionalNotificationChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            return;
        }

        NotificationChannel channel = new NotificationChannel(
                TRANSACTIONAL_CHANNEL_ID,
                "CareNet updates",
                NotificationManager.IMPORTANCE_HIGH);
        channel.setDescription("Appointment and account updates from CareNet.");

        NotificationManager manager = getSystemService(NotificationManager.class);
        if (manager != null) {
            manager.createNotificationChannel(channel);
        }
    }
}
