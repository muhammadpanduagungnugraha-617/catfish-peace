# Catfish Peace (Flutter) - Tahap UI

Tahap ini baru **frontend dengan data dummy** (sesuai roadmap langkah 1-6 UI). Firebase belum disambungkan.

## Cara menjalankan
```bash
# 1) di dalam folder ini, buat folder platform (tidak menimpa lib/ dan pubspec)
flutter create . --project-name catfish_peace --org id.ac.polindra --platforms=android,web

# 2) ambil package
flutter pub get

# 3) jalankan
flutter run -d chrome      # web
flutter run                # Android (emulator / HP)
```

## Mencoba semua kondisi tampilan
Saat mode debug, **tekan lama badge "Terhubung" di header** untuk berganti skenario dummy:
Aman -> Waspada -> Bahaya -> Terputus.
Untuk melihat state log kosong, ubah `kDummyEmptyLogs` di `lib/core/app_config.dart`.

## Struktur
```
lib/
  core/       warna (app_colors), tema, threshold, router, breakpoint, config
  features/   auth, dashboard, kontrol, riwayat (domain / application / presentation)
  shared/     header, bottom nav, banner, kartu error, shimmer, dll
docs/ui/      8 screenshot desain (referensi, tidak ikut di-bundle)
```

## Titik sambung Firebase (nanti)
| Yang diganti | File |
|---|---|
| Login / logout / cek sesi | `features/auth/...login_form.dart`, `app_header.dart`, `splash_screen.dart`, `auth_provider.dart` |
| Stream `kolam_status` | `dashboard/application/pool_status_provider.dart` |
| Tulis & baca `kolam_control` | `kontrol/application/control_provider.dart` |
| `sensor_history`, `alert_logs` | `riwayat/application/history_providers.dart` |

Semua titik sudah ditandai `TODO(firebase)`.
