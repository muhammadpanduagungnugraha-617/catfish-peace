import 'package:catfish_peace/features/kontrol/domain/pool_control.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Actuator', () {
    test('nama field RTDB sesuai kontrak data', () {
      expect(
        Actuator.values.map((a) => a.dbKey).toList(),
        ['pompa_buang_air', 'pompa_isi_air', 'pompa_probiotik', 'aerator'],
      );
    });
  });

  group('PoolControl.fromRaw', () {
    test('node kosong -> otomatis, semua aktuator mati', () {
      final c = PoolControl.fromRaw(null);
      expect(c.modeOtomatis, isTrue);
      for (final a in Actuator.values) {
        expect(c.valueOf(a), isFalse, reason: a.dbKey);
      }
    });

    test('mode_otomatis hilang -> otomatis', () {
      expect(PoolControl.fromRaw({'aerator': true}).modeOtomatis, isTrue);
    });

    test('field terbaca sesuai nilainya', () {
      final c = PoolControl.fromRaw({
        'mode_otomatis': false,
        'pompa_buang_air': true,
        'pompa_isi_air': false,
        'pompa_probiotik': true,
        'aerator': true,
      });
      expect(c.modeOtomatis, isFalse);
      expect(c.valueOf(Actuator.pompaBuangAir), isTrue);
      expect(c.valueOf(Actuator.pompaIsiAir), isFalse);
      expect(c.valueOf(Actuator.pompaProbiotik), isTrue);
      expect(c.valueOf(Actuator.aerator), isTrue);
    });

    test('perintah aktuator hanya sah bila persis true', () {
      final c = PoolControl.fromRaw({
        'mode_otomatis': false,
        'pompa_buang_air': 'true',
        'pompa_isi_air': 1,
        'aerator': null,
      });
      for (final a in Actuator.values) {
        expect(c.valueOf(a), isFalse, reason: a.dbKey);
      }
    });
  });

  group('RelayState.tryParse', () {
    test('belum dilaporkan -> null', () {
      expect(RelayState.tryParse(null), isNull);
      expect(RelayState.tryParse('x'), isNull);
    });

    test('status asli terbaca', () {
      final r = RelayState.tryParse({
        'pompa_buang_air': true,
        'pompa_isi_air': false,
        'pompa_probiotik': false,
        'aerator': true,
      })!;
      expect(r.valueOf(Actuator.pompaBuangAir), isTrue);
      expect(r.valueOf(Actuator.pompaIsiAir), isFalse);
      expect(r.valueOf(Actuator.pompaProbiotik), isFalse);
      expect(r.valueOf(Actuator.aerator), isTrue);
    });

    test('field hilang dianggap mati', () {
      final r = RelayState.tryParse({'aerator': true})!;
      expect(r.valueOf(Actuator.pompaBuangAir), isFalse);
      expect(r.valueOf(Actuator.aerator), isTrue);
    });
  });
}
