# Notifikasi (FCM)

## Alur
1. ESP32 menulis `kolam_status/status_kondisi` (Aman / Waspada / Bahaya).
2. Cloud Function `kondisiBerubah` terpicu saat nilai itu **berubah**, lalu
   mengirim FCM ke topik `kolam_alert`.
3. `cekAlatTerputus` (tiap 1 menit) mengirim "Alat IoT terputus" bila
   `last_updated` basi > 60 detik, dan `kondisiBerubah` mengirim
   "Alat tersambung kembali" saat data masuk lagi.
4. App berlangganan topik saat login dan berhenti saat logout. App tertutup /
   di latar belakang: sistem Android yang menampilkan notifikasi. App terbuka:
   ditampilkan sebagai SnackBar.

Aturan kirim (supaya tidak berisik): Bahaya selalu dikirim; Waspada hanya dari
Aman dan minimal 5 menit sejak notifikasi terakhir; kembali Aman dikirim;
Bahaya → Waspada tidak dikirim. Status terakhir disimpan di RTDB
`notifikasi_state` (hanya ditulis Cloud Function).

## Deploy (sekali)
Cloud Functions mewajibkan paket **Blaze** (berbayar, ada kuota gratis; untuk
proyek ini pemakaian wajar masih di dalam kuota). Atur batas anggaran di
Google Cloud Billing.

```
npm i -g firebase-tools
firebase login
# Firebase Console -> Upgrade ke Blaze
cd functions && npm install && cd ..
firebase deploy --only functions
```

## Uji
1. Jalankan app di HP Android (bukan web), login, izinkan notifikasi.
2. Firmware mode uji (`SIMULASI_SKENARIO 1`): kirim `3` di Serial Monitor →
   notifikasi "BAHAYA" muncul; kirim `1` → "kembali aman".
3. Cabut daya ESP32 > 1 menit → "Alat IoT terputus".
4. Log Function: `firebase functions:log`.

## Batasan
- Web dan iOS belum didukung (iOS butuh APNs key).
- Semua perangkat yang login menerima peringatan yang sama (topik tunggal).
- Rules RTDB masih `auth != null`: pengguna login bisa menulis
  `notifikasi_state`. Batasi di tahap rules per-UID.
