import 'package:catfish_peace/core/thresholds.dart';
import 'package:catfish_peace/features/riwayat/application/history_providers.dart';
import 'package:catfish_peace/features/riwayat/domain/alert_derivation.dart';
import 'package:catfish_peace/features/riwayat/domain/sensor_point.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, Object?> _entry(double amonia, {double ph = 7.2}) => {
      'suhu': 28.5,
      'ph': ph,
      'kekeruhan': 6.5,
      'amonia': amonia,
    };

SensorPoint _p(int sec, double amonia, {double ph = 7.2}) =>
    SensorPoint.tryParse('$sec', _entry(amonia, ph: ph))!;

void main() {
  group('SensorPoint.tryParse', () {
    test('kunci epoch detik dipakai sebagai waktu', () {
      final p = SensorPoint.tryParse('1792574117', _entry(0.1))!;
      expect(p.timestamp.millisecondsSinceEpoch, 1792574117 * 1000);
    });

    test('field timestamp diutamakan', () {
      final p = SensorPoint.tryParse(
          'x', {..._entry(0.1), 'timestamp': 1792574429})!;
      expect(p.timestamp.millisecondsSinceEpoch, 1792574429 * 1000);
    });

    test('entri rusak -> null', () {
      expect(SensorPoint.tryParse('1792574117', null), isNull);
      expect(SensorPoint.tryParse('1792574117', 'x'), isNull);
      expect(
          SensorPoint.tryParse('1792574117', {..._entry(0.1), 'ph': 'abc'}),
          isNull);
      expect(SensorPoint.tryParse('abc', _entry(0.1)), isNull);
    });
  });

  group('parseSensorHistory', () {
    test('urut waktu naik dan entri rusak dilewati', () {
      final pts = parseSensorHistory({
        '1792574429': _entry(0.2),
        '1792574117': _entry(0.1),
        '1792574920': 'rusak',
      });
      expect(pts.length, 2);
      expect(pts.first.amonia, 0.1);
      expect(pts.last.amonia, 0.2);
    });

    test('node kosong -> daftar kosong', () {
      expect(parseSensorHistory(null), isEmpty);
    });
  });

  group('deriveAlertLogs', () {
    test('semua aman -> tidak ada log', () {
      expect(deriveAlertLogs([_p(1000000000, 0.1), _p(1000000060, 0.1)]),
          isEmpty);
    });

    test('naik ke bahaya lalu kembali aman -> 2 log, terbaru dulu', () {
      final logs = deriveAlertLogs([
        _p(1000000000, 0.1),
        _p(1000000060, 0.65),
        _p(1000000120, 0.65),
        _p(1000000180, 0.1),
      ]);
      expect(logs.length, 2);
      expect(logs[0].type, ParamStatus.aman);
      expect(logs[1].type, ParamStatus.bahaya);
      expect(logs[1].parameter, ParamKey.amonia);
    });

    test('titik pertama yang sudah bahaya tetap dilaporkan', () {
      final logs = deriveAlertLogs([_p(1000000000, 0.65)]);
      expect(logs.length, 1);
      expect(logs.first.type, ParamStatus.bahaya);
    });

    test('batas jumlah log', () {
      final pts = [
        for (var i = 0; i < 50; i++) _p(1000000000 + i * 60, i.isEven ? 0.1 : 0.65)
      ];
      expect(deriveAlertLogs(pts, max: 10).length, 10);
    });
  });
}
