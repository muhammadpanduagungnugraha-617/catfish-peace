import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_config.dart';
import '../../../core/database_provider.dart';
import '../domain/pool_status.dart';

/// Skenario data dummy untuk mengetes tampilan (hanya bila kUseDummyStatus).
/// Saat debug: tekan lama badge koneksi di header untuk berganti skenario.
enum DummyScenario {
  aman('Aman'),
  waspada('Waspada (kekeruhan 55 NTU)'),
  bahaya('Bahaya (amonia 0.65 PPM)'),
  terputus('Alat terputus');

  const DummyScenario(this.label);
  final String label;
}

final dummyScenarioProvider =
    StateProvider<DummyScenario>((ref) => DummyScenario.aman);

PoolStatus _buildDummy(DummyScenario scenario) {
  final now = DateTime.now();
  switch (scenario) {
    case DummyScenario.aman:
      return PoolStatus(
        isConnected: true,
        suhu: 28.5,
        ph: 7.2,
        kekeruhan: 6.5,
        amonia: 0.15,
        lastUpdated: now,
      );
    case DummyScenario.waspada:
      return PoolStatus(
        isConnected: true,
        suhu: 28.5,
        ph: 7.2,
        kekeruhan: 55.0,
        amonia: 0.15,
        lastUpdated: now,
      );
    case DummyScenario.bahaya:
      return PoolStatus(
        isConnected: true,
        suhu: 28.5,
        ph: 7.2,
        kekeruhan: 6.5,
        amonia: 0.65,
        lastUpdated: now,
      );
    case DummyScenario.terputus:
      return PoolStatus(
        isConnected: false,
        suhu: 28.5,
        ph: 7.2,
        kekeruhan: 6.5,
        amonia: 0.15,
        lastUpdated: now.subtract(const Duration(minutes: 5)),
      );
  }
}

Stream<PoolStatus?> _dummyStatusStream(DummyScenario scenario) async* {
  // jeda singkat supaya skeleton loading terlihat
  await Future<void>.delayed(const Duration(milliseconds: 900));
  while (true) {
    yield _buildDummy(scenario);
    await Future<void>.delayed(const Duration(seconds: 3));
  }
}

/// Stream RTDB `kolam_status`.
///
/// - Node kosong / data tidak valid -> emit `null` ("belum ada data").
/// - Jam server (`.info/serverTimeOffset`) dipakai untuk menilai kesegaran.
/// - Timer 1 detik: bila ESP32 berhenti menulis, tidak ada event baru dari
///   RTDB, jadi tanpa timer status "Terputus" tidak akan pernah muncul.
///   Timer hanya meng-emit ulang saat status online/offline berubah.
Stream<PoolStatus?> _liveStatusStream(FirebaseDatabase db) {
  late final StreamController<PoolStatus?> controller;
  StreamSubscription<DatabaseEvent>? statusSub;
  StreamSubscription<DatabaseEvent>? offsetSub;
  Timer? ticker;

  var offset = Duration.zero;
  PoolStatus? latest;
  var hasValue = false;
  bool? lastOnline;

  void emit() {
    if (!hasValue || controller.isClosed) return;
    final status = latest?.withServerOffset(offset);
    lastOnline = status?.isOnline;
    controller.add(status);
  }

  controller = StreamController<PoolStatus?>(
    onListen: () {
      offsetSub = db.ref('.info/serverTimeOffset').onValue.listen(
        (event) {
          final v = event.snapshot.value;
          offset = Duration(milliseconds: v is num ? v.toInt() : 0);
          emit();
        },
        onError: (_) {}, // offset hanya penyempurna; gagal = pakai jam lokal
      );
      statusSub = db.ref('kolam_status').onValue.listen(
        (event) {
          latest = PoolStatus.tryParse(event.snapshot.value);
          hasValue = true;
          emit();
        },
        onError: controller.addError,
      );
      ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        final current = latest;
        if (!hasValue || current == null) return;
        final online = current.withServerOffset(offset).isOnline;
        if (online != lastOnline) emit();
      });
    },
    onCancel: () async {
      ticker?.cancel();
      await statusSub?.cancel();
      await offsetSub?.cancel();
    },
  );
  return controller.stream;
}

/// Status kolam. `null` = node kosong ("belum ada data dari alat").
final poolStatusProvider = StreamProvider<PoolStatus?>((ref) {
  if (kUseDummyStatus) {
    return _dummyStatusStream(ref.watch(dummyScenarioProvider));
  }
  return _liveStatusStream(ref.watch(databaseProvider));
});

enum PoolConnection { checking, online, offline }

/// Ringkasan koneksi alat untuk header, banner, dan kontrol.
/// - checking: data pertama belum datang.
/// - offline: tidak ada data, error, terputus, atau data basi.
final poolConnectionProvider = Provider<PoolConnection>((ref) {
  final async = ref.watch(poolStatusProvider);
  if (async.isLoading && !async.hasValue) return PoolConnection.checking;
  final status = async.valueOrNull;
  if (status == null) return PoolConnection.offline;
  return status.isOnline ? PoolConnection.online : PoolConnection.offline;
});
