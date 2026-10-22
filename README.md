# Catfish Peace

Aplikasi pemantau dan pengendali kualitas air kolam lele (Flutter, Android dan
web) untuk alat IoT ESP32. Firmware ada di repo `esp32-catfish-peace`.

## Fitur
- Login email/password (Firebase Auth).
- Dashboard: suhu, pH, kekeruhan, amonia + status Aman/Waspada/Bahaya, dan
  status alat "Terhubung/Terputus" (data basi > 6 detik).
- Kontrol: mode otomatis/manual dan 4 aktuator (pompa buang air, pompa isi air,
  pompa probiotik, aerator). Status "Sedang nyala/mati" dari relay asli.
- Riwayat: grafik dari `sensor_history` (tiap 1 menit, 120 titik terakhir) dan
  log peringatan yang diturunkan dari perubahan status.
- Peringatan "Sensor bermasalah" bila alat hidup tetapi sensor tidak terbaca.

## Menjalankan
Butuh `lib/firebase_options.dart` dan `android/app/google-services.json`
(dibuat `flutterfire configure`, sengaja tidak masuk git).
```bash
flutter pub get
flutter test
flutter run                # Android
flutter run -d chrome      # web
```

## Struktur
```
lib/core/       tema, threshold, router, config, provider database
lib/features/   auth, dashboard, kontrol, riwayat (domain/application/presentation)
lib/shared/     header, bottom nav, banner, kartu error, dll
docs/           data-contract.md, skenario-uji.md, firebase-rules.md
```

## Dokumen
- `docs/data-contract.md`: struktur RTDB dan siapa menulis apa.
- `docs/skenario-uji.md`: menguji Aman/Waspada/Bahaya lewat Serial Monitor.
- `docs/firebase-rules.md`: aturan keamanan yang harus dipasang sebelum dipakai.

## Catatan
- Mode debug: tekan lama badge di header hanya berfungsi bila
  `kUseDummyStatus = true` di `lib/core/app_config.dart`.
- Amonia dibaca MQ-135 (bukan sensor amonia spesifik): nilainya perkiraan.
