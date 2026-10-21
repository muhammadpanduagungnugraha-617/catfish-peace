# Kontrak Data Realtime Database (ESP32 ⇄ App)

Dokumen ini adalah acuan untuk firmware ESP32 dan app Flutter. Kalau salah satu
sisi mengubah nama field atau tipe, ubah dokumen ini juga.

- Database: Realtime Database, region Singapore (`asia-southeast1`).
- Semua nilai boolean memakai `true` / `false` (bukan `0` / `1` / string).
- Semua waktu: **epoch detik, integer, UTC, dari NTP**.

## Ringkasan node

| Node             | Penulis | Pembaca    | Isi                                   |
| ---------------- | ------- | ---------- | ------------------------------------- |
| `kolam_status`   | ESP32   | App        | Pembacaan sensor + penanda koneksi    |
| `kolam_control`  | App     | ESP32      | **Perintah** mode & aktuator          |
| `kolam_relay`    | ESP32   | App        | **Status asli** relay (hasil eksekusi) |
| `sensor_history` | ESP32   | App        | Riwayat untuk grafik (belum dipakai app) |

Perintah dan status asli sengaja dipisah. App menampilkan "Sedang nyala/mati"
dari `kolam_relay`, bukan dari `kolam_control`, supaya UI tidak pernah
mengklaim pompa menyala padahal relay gagal.

## `kolam_status` (ESP32 tulis, tiap ±2 detik)

```json
{
  "suhu": 28.5,
  "ph": 7.2,
  "kekeruhan": 6.5,
  "amonia": 0.15,
  "is_connected": true,
  "last_updated": 1761000000
}
```

- `suhu` (°C), `ph`, `kekeruhan` (NTU), `amonia` (PPM): number. **Keempatnya
  wajib.** Bila ada yang hilang atau bukan angka, app menganggap node tidak
  valid dan menampilkan "belum ada data" (bukan angka palsu).
- `last_updated`: epoch **detik**. Wajib dari jam NTP. Jangan pakai `millis()`
  atau jam yang belum sinkron: app menilai "Terputus" dari nilai ini.
- `is_connected`: set `true` saat menulis. Library Firebase ESP32 yang dipakai
  (4.4.x) **tidak punya `onDisconnect()`**, jadi ia tidak akan jadi `false`
  sendiri; app menilai putus dari `last_updated` yang basi (`kStaleAfter`).
- `status_kondisi` dan `tinggi_air` boleh ada tetapi **tidak dipakai** app.
  Status Aman/Waspada/Bahaya dihitung app dari nilai sensor
  (`lib/core/thresholds.dart`).

### Kapan app menampilkan "Terputus"
Salah satu terpenuhi:
1. `is_connected == false`
2. `last_updated` lebih tua dari **6 detik** (`kStaleAfter` di
   `lib/core/app_config.dart`) menurut jam server
3. `last_updated` lebih dari 10 detik di masa depan (jam ESP32 salah / NTP
   belum sinkron)

Jam server dikoreksi lewat `.info/serverTimeOffset`, jadi jam HP yang meleset
tidak membuat alat tampak terputus.

## `kolam_control` (App tulis, ESP32 baca)

```json
{
  "mode_otomatis": true,
  "pompa_buang_air": false,
  "pompa_isi_air": false,
  "pompa_probiotik": false,
  "aerator": false
}
```

- `mode_otomatis = true`: ESP32 mengendalikan aktuator sendiri sesuai
  ambang. Field `pompa_*` dan `aerator` **diabaikan**.
- `mode_otomatis = false`: ESP32 mengikuti field `pompa_*` dan `aerator`.
- Node kosong atau `mode_otomatis` hilang diperlakukan sebagai **otomatis**.
- App menulis per field, tidak pernah menimpa seluruh node.
- Saat user beralih ke manual, app menulis `mode_otomatis: false` **dan**
  menyeragamkan semua perintah dengan status asli di `kolam_relay` dalam satu
  update atomik. Tujuannya mencegah perintah lama yang tertinggal menyalakan
  pompa tiba-tiba.

## `kolam_relay` (ESP32 tulis)

```json
{
  "pompa_buang_air": false,
  "pompa_isi_air": false,
  "pompa_probiotik": false,
  "aerator": false
}
```

Tulis setiap kali kondisi relay berubah (dibaca dari pin/feedback, bukan
sekadar menyalin perintah), dan ulangi berkala (mis. tiap 10 detik). Bila node
ini belum ada, app menampilkan "Status belum dilaporkan alat".

## `sensor_history` (ESP32 tulis, ±tiap 5 menit)

Satu entri per pencatatan, kuncinya epoch detik (`/sensor_history/<epoch>`):

```json
{ "timestamp": 1761000000, "suhu": 28.5, "ph": 7.2, "kekeruhan": 6.5, "amonia": 0.15 }
```

Jangan menulis tiap 2 detik: itu 43.200 entri per hari. Layar Riwayat di app
**belum** membaca node ini.

## Tanggung jawab firmware (bukan app)

- Mode otomatis **harus tetap berjalan walau Wi-Fi atau Firebase mati**.
  Keselamatan ikan tidak boleh bergantung pada cloud.
- Beri histeresis pada ambang agar relay tidak menyala-mati berulang.
- Tulis `kolam_relay` dari kondisi relay yang sebenarnya.
- Login ke Firebase memakai akun Auth khusus perangkat. Jangan commit
  kredensialnya ke repo.

## Cara mencoba app tanpa ESP32

1. Firebase Console → Realtime Database → Data → ⋮ → **Import JSON**.
2. Tempel contoh `kolam_status` di atas, ganti `last_updated` dengan waktu
   sekarang (PowerShell: `[DateTimeOffset]::UtcNow.ToUnixTimeSeconds()`).
3. Karena data statis tidak diperbarui tiap 2 detik, app akan menjadi
   "Terputus" setelah 6 detik. Untuk menguji tampilan "Terhubung", naikkan
   `kStaleAfter` di `lib/core/app_config.dart` sementara (mis. 1 jam), **lalu
   kembalikan ke 6 detik sebelum commit**.
4. Atau set `kUseDummyStatus = true` untuk data dummy (4 skenario).
