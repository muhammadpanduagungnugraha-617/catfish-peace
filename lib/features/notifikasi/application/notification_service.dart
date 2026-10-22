import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_provider.dart';

/// Topik FCM yang dikirim Cloud Function (functions/index.js).
const String kAlertTopic = 'kolam_alert';

/// Dipakai untuk menampilkan peringatan saat app sedang terbuka.
final rootMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// Berlangganan topik peringatan. Semua kegagalan ditelan: notifikasi tidak
/// boleh membuat app gagal (mis. HP tanpa Google Play Services).
class NotificationService {
  NotificationService(this._fm);

  final FirebaseMessaging _fm;

  Future<void> enable() async {
    if (kIsWeb) return; // Web butuh service worker + VAPID, belum didukung.
    try {
      await _fm.requestPermission(); // Android 13+ menampilkan dialog izin.
      await _fm.subscribeToTopic(kAlertTopic);
      if (kDebugMode) {
        // Untuk "Send test message" di Firebase Console. Hanya di debug.
        debugPrint('FCM token: ${await _fm.getToken()}');
      }
      if (kDebugMode) {
        // Untuk "Send test message" di Firebase Console. Hanya mode debug.
        debugPrint('FCM token: ${await _fm.getToken()}');
      }
    } catch (e) {
      debugPrint('Notifikasi: gagal berlangganan ($e)');
    }
  }

  Future<void> disable() async {
    if (kIsWeb) return;
    try {
      await _fm.unsubscribeFromTopic(kAlertTopic);
    } catch (e) {
      debugPrint('Notifikasi: gagal berhenti berlangganan ($e)');
    }
  }
}

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(FirebaseMessaging.instance),
);

/// Login -> berlangganan; logout -> berhenti (HP bersama tidak ikut
/// menerima peringatan kolam setelah akun keluar).
final notificationBootstrapProvider = Provider<void>((ref) {
  ref.listen(
    authStateProvider,
    (prev, next) {
      final was = prev?.valueOrNull != null;
      final now = next.valueOrNull != null;
      final service = ref.read(notificationServiceProvider);
      if (now && !was) {
        service.enable();
      } else if (!now && was) {
        service.disable();
      }
    },
    fireImmediately: true,
  );
});

/// Pesan yang masuk saat app di layar depan (sistem tidak menampilkannya
/// sebagai notifikasi, jadi app yang menampilkannya).
final foregroundAlertProvider = StreamProvider<RemoteMessage>(
  (ref) => kIsWeb ? const Stream.empty() : FirebaseMessaging.onMessage,
);

void showForegroundAlert(RemoteMessage message) {
  final n = message.notification;
  if (n == null) return;
  final text = [n.title, n.body].whereType<String>().join('\n');
  rootMessengerKey.currentState
    ?..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(text),
        duration: const Duration(seconds: 8),
        behavior: SnackBarBehavior.floating,
      ),
    );
}
