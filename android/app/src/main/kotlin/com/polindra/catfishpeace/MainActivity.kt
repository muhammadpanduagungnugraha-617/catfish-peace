package com.polindra.catfishpeace

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Channel prioritas tinggi agar peringatan kolam muncul sebagai heads-up.
        // ID harus sama dengan channelId di functions/index.js dan manifest.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "kolam_alert",
                "Peringatan Kolam",
                NotificationManager.IMPORTANCE_HIGH,
            ).apply { description = "Peringatan kualitas air dan status alat" }
            getSystemService(NotificationManager::class.java)
                .createNotificationChannel(channel)
        }
    }
}
