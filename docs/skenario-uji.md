# Uji skenario: Aman, Waspada, Bahaya

Firmware (branch `uji-skenario`, `SIMULASI_SKENARIO 1`) bisa memaksa nilai
sensor lewat Serial Monitor (115200). **Lepas beban relay saat uji.**

| Kirim | Skenario | suhu / pH / NTU / amonia |
|---|---|---|
| `1` | Aman | 28.0 / 7.2 / 6.5 / 0.15 |
| `2` | Waspada | 30.5 / 8.7 / 55 / 0.55 |
| `3` | Bahaya | 32.0 / 9.5 / 70 / 0.70 |
| `a` | Siklus otomatis aman → waspada → bahaya, tiap 90 detik | |
| `0` | Kembali ke sensor asli | |

Saat uji, `sensor_history` ditulis tiap 10 detik (normal: 1 menit).

## Hasil yang diharapkan di app

1. **Dashboard:** banner dan kartu parameter berubah warna sesuai status
   (hijau / kuning / merah) dalam ±2 detik setelah perintah dikirim.
2. **Riwayat, grafik:** garis bergeser tiap 10 detik.
3. **Riwayat, Log Peringatan:** muncul satu kejadian per perubahan status per
   parameter, mis. `Waspada: Amonia · 0.55 PPM`, lalu `Bahaya: ...`, lalu
   `... Normal` saat kembali ke skenario 1.
4. **Kontrol (mode otomatis):** pada skenario 3 firmware memulai siklus
   kuras/isi; `kolam_relay` berubah dan teks "Sedang nyala" ikut.
5. **Terputus:** cabut daya ESP32, badge jadi "Terputus" dalam ±6 detik dan
   saklar kontrol nonaktif.

Setelah uji: set `SIMULASI_SKENARIO 0`, flash ulang, dan hapus node
`sensor_history` hasil uji di Console.
