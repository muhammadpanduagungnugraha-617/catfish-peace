import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_config.dart';

/// Realtime Database dengan URL region yang benar. Database di luar
/// us-central1 WAJIB diberi URL eksplisit, kalau tidak koneksi diarahkan ke
/// instance default yang salah.
final databaseProvider = Provider<FirebaseDatabase>((ref) {
  final app = Firebase.app();
  final fromOptions = app.options.databaseURL;
  final url = (fromOptions != null && fromOptions.isNotEmpty)
      ? fromOptions
      : kRtdbUrlFallback;
  return FirebaseDatabase.instanceFor(app: app, databaseURL: url);
});

/// Apakah APP ini sedang tersambung ke server Firebase (`.info/connected`).
/// Beda dengan status alat IoT. Saat false, perintah tidak boleh dikirim:
/// RTDB menahan write dan mengeksekusinya belakangan saat koneksi pulih,
/// sehingga pompa bisa menyala tiba-tiba setelah user mengira gagal.
final firebaseConnectedProvider = StreamProvider<bool>((ref) {
  return ref
      .watch(databaseProvider)
      .ref('.info/connected')
      .onValue
      .map((event) => event.snapshot.value == true);
});
