import 'package:catfish_peace/core/app_config.dart';
import 'package:catfish_peace/core/thresholds.dart';
import 'package:catfish_peace/features/dashboard/domain/pool_status.dart';
import 'package:flutter_test/flutter_test.dart';

int _nowSec() => DateTime.now().millisecondsSinceEpoch ~/ 1000;

Map<String, Object?> _raw({
  Object? lastUpdated,
  Object? isConnected = true,
  bool withIsConnected = true,
}) =>
    {
      'suhu': 28.5,
      'ph': 7.2,
      'kekeruhan': 6.5,
      'amonia': 0.15,
      if (withIsConnected) 'is_connected': isConnected,
      'last_updated': lastUpdated ?? _nowSec(),
    };

void main() {
  group('PoolStatus.tryParse', () {
    test('node kosong atau bukan map -> null', () {
      expect(PoolStatus.tryParse(null), isNull);
      expect(PoolStatus.tryParse('x'), isNull);
      expect(PoolStatus.tryParse(42), isNull);
      expect(PoolStatus.tryParse(<String, Object?>{}), isNull);
    });

    test('data valid terbaca', () {
      final s = PoolStatus.tryParse(_raw())!;
      expect(s.suhu, 28.5);
      expect(s.ph, 7.2);
      expect(s.kekeruhan, 6.5);
      expect(s.amonia, 0.15);
      expect(s.isConnected, isTrue);
    });

    test('field sensor hilang atau bukan angka -> null (bukan angka palsu)', () {
      for (final key in ['suhu', 'ph', 'kekeruhan', 'amonia', 'last_updated']) {
        final missing = _raw()..remove(key);
        expect(PoolStatus.tryParse(missing), isNull, reason: 'hilang: $key');

        final wrong = _raw()..[key] = 'abc';
        expect(PoolStatus.tryParse(wrong), isNull, reason: 'string: $key');

        final nan = _raw()..[key] = double.nan;
        expect(PoolStatus.tryParse(nan), isNull, reason: 'NaN: $key');
      }
    });

    test('is_connected hilang dianggap terhubung (andalkan last_updated)', () {
      final s = PoolStatus.tryParse(_raw(withIsConnected: false))!;
      expect(s.isConnected, isTrue);
      expect(s.isOnline, isTrue);
    });

    test('nilai integer dari RTDB tetap terbaca sebagai double', () {
      final raw = _raw()
        ..['suhu'] = 29
        ..['ph'] = 7;
      final s = PoolStatus.tryParse(raw)!;
      expect(s.suhu, 29.0);
      expect(s.ph, 7.0);
    });
  });

  group('PoolStatus.isOnline', () {
    test('data segar -> online', () {
      expect(PoolStatus.tryParse(_raw())!.isOnline, isTrue);
    });

    test('setengah batas stale -> masih online', () {
      final s = PoolStatus.tryParse(_raw(lastUpdated: _nowSec() - kStaleAfter.inSeconds ~/ 2))!;
      expect(s.isOnline, isTrue);
    });

    test('melewati batas stale -> terputus', () {
      final s = PoolStatus.tryParse(_raw(lastUpdated: _nowSec() - kStaleAfter.inSeconds - 3))!;
      expect(s.isOnline, isFalse);
    });

    test('is_connected false -> terputus walau data segar', () {
      final s = PoolStatus.tryParse(_raw(isConnected: false))!;
      expect(s.isOnline, isFalse);
    });

    test('last_updated jauh di masa depan (jam ESP32 salah) -> terputus', () {
      final s = PoolStatus.tryParse(_raw(lastUpdated: _nowSec() + 120))!;
      expect(s.isOnline, isFalse);
    });

    test('selisih kecil di masa depan ditoleransi', () {
      final s = PoolStatus.tryParse(_raw(lastUpdated: _nowSec() + 4))!;
      expect(s.isOnline, isTrue);
    });

    test('jam HP meleset 1 jam tidak membuat alat tampak terputus', () {
      // Jam server tertinggal 1 jam dari jam HP; offset RTDB = -1 jam.
      final serverSec = _nowSec() - 3600;
      const offset = Duration(hours: -1);

      final tanpaKoreksi = PoolStatus.tryParse(_raw(lastUpdated: serverSec))!;
      expect(tanpaKoreksi.isOnline, isFalse);

      final denganKoreksi = PoolStatus.tryParse(
        _raw(lastUpdated: serverSec),
        serverOffset: offset,
      )!;
      expect(denganKoreksi.isOnline, isTrue);
    });

    test('last_updated dalam milidetik tetap terbaca (salah satuan firmware)',
        () {
      final s = PoolStatus.tryParse(
        _raw(lastUpdated: DateTime.now().millisecondsSinceEpoch),
      )!;
      expect(s.isOnline, isTrue);
    });

    test('withServerOffset mempertahankan data dan mengganti offset', () {
      final s = PoolStatus.tryParse(_raw())!;
      final shifted = s.withServerOffset(const Duration(seconds: 30));
      expect(shifted.suhu, s.suhu);
      expect(shifted.lastUpdated, s.lastUpdated);
      expect(shifted.serverOffset, const Duration(seconds: 30));
    });
  });

  group('status per parameter', () {
    test('amonia 0.65 PPM -> bahaya dan jadi status keseluruhan', () {
      final raw = _raw()..['amonia'] = 0.65;
      final s = PoolStatus.tryParse(raw)!;
      expect(s.statusOf(ParamKey.amonia), ParamStatus.bahaya);
      expect(s.overall, ParamStatus.bahaya);
    });

    test('semua normal -> aman', () {
      expect(PoolStatus.tryParse(_raw())!.overall, ParamStatus.aman);
    });
  });
}
