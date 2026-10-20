import 'dart:async';

import 'package:firebase_core/firebase_core.dart' show FirebaseException;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database_provider.dart';
import '../domain/pool_control.dart';

/// Gagal mengirim perintah; [message] siap ditampilkan ke user.
class ControlFailure implements Exception {
  const ControlFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Perintah dari app (RTDB `kolam_control`).
final poolControlProvider = StreamProvider<PoolControl>((ref) {
  final db = ref.watch(databaseProvider);
  return db
      .ref('kolam_control')
      .onValue
      .map((event) => PoolControl.fromRaw(event.snapshot.value));
});

/// Status asli relay yang dilaporkan ESP32 (RTDB `kolam_relay`).
/// `null` = belum pernah dilaporkan.
final poolRelayProvider = StreamProvider<RelayState?>((ref) {
  final db = ref.watch(databaseProvider);
  return db
      .ref('kolam_relay')
      .onValue
      .map((event) => RelayState.tryParse(event.snapshot.value));
});

/// Menulis perintah per-field (bukan seluruh node), jadi field lain yang
/// ditulis pihak lain tidak pernah tertimpa.
class PoolControlActions {
  PoolControlActions(this._db);

  final FirebaseDatabase _db;

  /// RTDB menahan write yang belum terkonfirmasi server dan tetap
  /// mengeksekusinya saat koneksi pulih. Tanpa batas waktu, user tidak
  /// pernah tahu perintahnya belum sampai.
  static const Duration _timeout = Duration(seconds: 5);

  /// Beralih ke manual: semua perintah aktuator diseragamkan dengan status
  /// ASLI relay (mati bila belum dilaporkan) dalam satu update atomik. Tanpa
  /// ini, perintah lama yang tertinggal di database (mis. pompa buang air =
  /// true dari minggu lalu) langsung menyalakan pompa begitu mode manual aktif.
  Future<void> setModeOtomatis(bool value, {RelayState? currentRelay}) {
    if (value) {
      return _run(() => _db.ref('kolam_control/mode_otomatis').set(true));
    }
    return _run(
      () => _db.ref('kolam_control').update({
        'mode_otomatis': false,
        for (final a in Actuator.values)
          a.dbKey: currentRelay?.valueOf(a) ?? false,
      }),
    );
  }

  Future<void> setActuator(Actuator actuator, bool value) =>
      _run(() => _db.ref('kolam_control/${actuator.dbKey}').set(value));

  Future<void> _run(Future<void> Function() write) async {
    try {
      await write().timeout(_timeout);
    } on TimeoutException {
      throw const ControlFailure(
        'Perintah belum terkonfirmasi server. Periksa koneksi internet.',
      );
    } on FirebaseException catch (e) {
      throw ControlFailure(
        e.code == 'permission-denied'
            ? 'Tidak punya izin mengirim perintah.'
            : 'Gagal mengirim perintah. Coba lagi.',
      );
    }
  }
}

final poolControlActionsProvider = Provider<PoolControlActions>(
  (ref) => PoolControlActions(ref.watch(databaseProvider)),
);
