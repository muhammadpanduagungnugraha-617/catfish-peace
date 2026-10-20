import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/pool_status.dart';

/// Skenario data dummy untuk mengetes tampilan.
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

/// Stream status kolam. Tahap UI: dummy.
/// Nanti ganti isi dengan stream dari RTDB `kolam_status`.
final poolStatusProvider = StreamProvider<PoolStatus>((ref) async* {
  final scenario = ref.watch(dummyScenarioProvider);
  // jeda singkat supaya skeleton loading terlihat
  await Future<void>.delayed(const Duration(milliseconds: 900));
  while (true) {
    yield _buildDummy(scenario);
    await Future<void>.delayed(const Duration(seconds: 3));
  }
});
