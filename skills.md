### Template Konteks Vibe Coding Flutter: Catfish Peace

##### 1. Ringkasan Sistem

- **Nama aplikasi** : Catfish Peace (Sistem Monitoring & Kontrol Kualitas Air Kolam). Tagline di UI: _"Menuju Budidaya Tanpa Konflik"_ . Versi di UI: v1.0.4 ubah jadi v1.0.0.
- **Tujuan** : Memantau parameter kualitas air kolam lele secara real-time (suhu, pH, kekeruhan, amonia), mendeteksi dini indikasi kanibalisme/luka/kematian ikan lewat lonjakan mendadak gas amonia (sensor MQ-135 di atas permukaan air), serta mengendalikan aktuator (pompa air dan aerator) secara otomatis maupun manual.
- **Target pengguna** : Peternak lele / pengelola kolam (skala kecil, Kabupaten Indramayu).
- **Platform** : Android & Web (desain tersedia untuk layar mobile ±400px dan layar lebar/web ≥1000px).
- **Sumber** : Proposal GINCU AYU 2026 (PROPOSAL-GINCUAYU26-KEL1-RPI.pdf) dan 8 screenshot UI.
- **Cakupan** : Prototipe pada kolam uji (akuarium/drum), bukan kolam produksi penuh.

## pakai logo pada assets/icons/logo.png

##### 2. Role & Hak Akses

| Role     | Bisa melakukan apa                                                                                                                                                                                                                                               | Tidak boleh apa                                      |
| -------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------- |
| **User** | **Akses penuh** : melihat status kualitas air real-time, mengubah mode kontrol (Otomatis/Manual), menyalakan/mematikan pompa air & aerator (saat mode otomatis mati), melihat grafik tren sensor, mengakses log riwayat peringatan, menerima notifikasi darurat. | - _(Tidak ada pembatasan hak akses; satu role saja)_ |

_Catatan: tidak ada layar Register / Lupa Password di desain. Akun dibuat manual lewat Firebase Console._

---

##### 3. Daftar Fitur

###### MVP (wajib ada)

- [ ] **Fitur 1: Autentikasi User** : Login Email & Password via Firebase Auth (ikon tampil/sembunyikan password).
- [ ] **Fitur 2: Dashboard Real-time Monitoring** : 4 kartu parameter (Suhu °C, pH, Kekeruhan NTU, Amonia PPM), masing-masing dengan status AMAN/WASPADA/BAHAYA; banner kondisi keseluruhan; banner "Alat IoT kolam tidak terhubung ke internet"; badge koneksi di header (Terhubung/Terputus). **Ketuk kartu (ikon info ⓘ) untuk melihat rentang ideal parameter** (sesuai teks "Ketuk kartu untuk melihat rentang ideal").
- [ ] **Fitur 3: Kendali Kontrol Kolam** : Toggle Mode Otomatis dan saklar kendali manual untuk pertukaran air (Pompa Buang Air & Pompa Isi Air) serta Aerator Oksigen (sesuai spesifikasi proposal: 2 unit pompa untuk pengurasan/buang air, pengisian air baru. Saklar manual **nonaktif (greyed out) selama Mode Otomatis nyala**, tetapi tetap menampilkan status terkini ("Sedang nyala/mati").
- [ ] **Fitur 4: Riwayat Sensor & Log Peringatan** : Grafik tren 4 parameter (fl_chart) + daftar log peringatan dengan penghitung ("2 kejadian tercatat") kalau tidak ada riwayat kasih indikasi log belum tercatat.
- [ ] **Fitur 5: Early Warning System** : Push notification via FCM saat parameter masuk kondisi **Bahaya** . Untuk amonia (≥ 0.60 PPM) berupa _Emergency Alert_ .
- [ ] **Fitur 5: tambah info dari card di dasbord ketika di klik logo infonya**
- [ ] **Fitur 6: tambah baner notif ketika emergency peringatan waspada atau bahaya**
- [ ] **Fitur 7: Logout, sesuaikan dengan desain**

###### Nanti saja (jangan dikerjakan dulu)

- [ ] Integrasi dengan pengumpan pakan otomatis ( _automatic feeder_ ).
- [ ] Analisis perilaku ikan berbasis kamera dan Machine Learning.
- [ ] Pengelompokan multi-kolam / multi-lokasi.
- [ ] Tampilan ketinggian air (sensor ultrasonik HC-SR04 ada di proposal, belum ada di UI).
- [ ] Pemberian probiotik otomatis setelah penggantian air (disebut di bagian Hasil Inovasi proposal, belum ada di UI).
- [ ] Logout, ganti password, dan layar profil (belum ada di desain).

---

##### 4. Alur Utama (User Flow)

1.  **Splash Screen** → cek sesi Firebase Auth. Sesi ada → DashboardScreen; sesi tidak ada → LoginScreen.
2.  **Login Screen** → input email & password.
3.  **Dashboard Screen** → kondisi air terkini & status perangkat IoT; ketuk kartu untuk melihat rentang ideal.
4.  **Kontrol Screen** → atur mode otomatis atau nyalakan pompa/aerator manual.
5.  **Riwayat Screen** → grafik tren sensor & log peringatan.
    Navigasi utama: **Bottom Navigation Bar 3 tab** (Dashboard, Kontrol, Riwayat), dipakai di mobile maupun web.

---

##### 5. Daftar Screen & Navigasi

| No  | Nama Screen     | File Foto UI                                                                 | Tombol/aksi → tujuan                                                                |
| --- | --------------- | ---------------------------------------------------------------------------- | ----------------------------------------------------------------------------------- |
| 1   | SplashScreen    | -                                                                            | Otomatis → DashboardScreen (sudah login) / LoginScreen                              |
| 2   | LoginScreen     | Mobile: assets/ui/mobile_login_page.png<br>Web: assets/ui/login_page_web.png | Tombol **Masuk ke Dashboard** → DashboardScreen                                     |
| 3   | DashboardScreen | Mobile: assets/ui/Dashboard_mobile.jpg<br>Web: assets/ui/Dashboard_web.jpg   | Ketuk kartu → rentang ideal (dialog/bottom sheet) \| Bottom Nav → Kontrol / Riwayat |
| 4   | KontrolScreen   | Mobile: assets/ui/Kontrol_mobile.jpg<br>Web: assets/ui/Kontrol_web.jpg       | Toggle Mode Otomatis \| Switch Pompa & Aerator \| Bottom Nav                        |
| 5   | RiwayatScreen   | Mobile: assets/ui/Riwayat_mobile.jpg<br>Web: assets/ui/Riwayat_web.jpg       | Melihat grafik & log \| Bottom Nav                                                  |

_Delapan file di atas diletakkan di folder assets/ui/ dengan nama persis seperti tertulis._
**Detail teks & layout dari desain** :

- Header (semua screen utama): logo + "Catfish Peace" + subjudul "Monitoring Kualitas Air Kolam" (subjudul hanya di mobile) + badge outline **Terhubung** (border biru) / **Terputus** (border merah).
- Login mobile: judul "Selamat Datang Kembali", subjudul "Masuk untuk memantau & mengontrol kolam budidaya Anda". Login web: judul "Masuk ke Dashboard", subjudul "Silakan masuk untuk mengakses sistem monitoring kolam". Footer: "Catfish Peace App v1.0.0" (mobile) / "Catfish Peace System v1.0.0 • Platform Monitoring Budidaya Lele" (web).
- Dashboard: kartu 2×2 di mobile, 4 kolom sejajar di web. Ikon kartu (mobile): Suhu = termometer, pH = labu(flask-conical atau vials), Kekeruhan = waves (Gelombang Air) atau droplets / cloud, Amonia = flask-conical (dengan gelembung) atau biohazard / shield-alert. **Gunakan ikon versi mobile di semua platform** (versi web memakai ikon labu untuk semua kartu, itu bug desain).
- Kontrol: judul "Kontrol Kolam" ("Atur perangkat untuk menjaga kualitas air"), kartu Mode Otomatis (label menjadi "Mode Otomatis (Mati)" saat nonaktif), lalu "Kendali Manual" ("Nonaktifkan mode otomatis untuk kendali manual") berisi saklar kendali pertukaran air (Pompa Buang Air, Pompa Isi Air / Sirkulasi) dan Aerator Oksigen.
- Riwayat: judul "Riwayat Sensor" ("Log suhu air, keasaman, kekeruhan, dan amonia."), legend 4 warna, lalu "Log Peringatan" dengan ikon segitiga merah (Bahaya) / centang hijau (Normal). Format tanggal log: 20 Mei 2025, 10.30.00 (locale Indonesia).
  **State tambahan per screen** :
- **Loading** : Skeleton/shimmer pada kartu parameter saat snapshot awal dari Firebase.
- **Data kosong** : Teks _"Belum ada log peringatan tercatat"_ di Riwayat.
- **Terputus** : Banner peach _"Alat IoT kolam tidak terhubung ke internet"_ (tampil di Dashboard dan Kontrol) + badge header "Terputus". Nilai sensor terakhir tetap ditampilkan.
- **Error** (gagal memuat/izin ditolak): belum ada desain, gunakan card error sederhana dengan token warna Bahaya.

---

##### 6. Design Token

_(Nilai diambil dari piksel screenshot, jadi sudah mendekati desain asli.)_

- **Primary / Header** : gradien #0B344A → #164D6B; tombol utama #0D3B53; bottom nav #0C3249
- **Aksen (toggle ON, label tab aktif, badge tagline)** : #EAAB44 (amber/emas); latar badge tagline #FEFAEE; pill tab aktif #314E52
- **Background layar** : #F1F6F9; **latar kartu** : #FAFBFD
- **Teks utama** : #213C4D
- **Status Aman** : teks #34C85A; banner latar #DEF4E8, judul #2EA679
- **Status Waspada** : #FF8E28 (oranye)
- **Status Bahaya** : #FF383B; latar ikon alert #FBE3E1
- **Banner offline** : latar #FBECD5
- **Warna grafik** : suhu air #CA30E0, keasaman #35C75A, kekeruhan #FF8E28, amonia #FF383B
- **Font** : Plus Jakarta Sans (tampak di login web); layar dalam tampak memakai font rounded (mirip Nunito). Gunakan google_fonts, satu font utama saja: **Plus Jakarta Sans** , kecuali desain asli dipastikan lain.
- **Border radius standar** : 16.0 (kartu), 24.0 (pill/badge)
- **Spacing standar** : 8 / 16 / 24
- **Aset** : assets/logo.png, assets/icons/, assets/ui/ (referensi desain)

---

##### 7. Aturan Status & Threshold (dari Tabel 2.3 proposal)

Status per parameter dihitung dengan rentang berikut. Tulis sebagai batas kontinu agar tidak ada celah (misalnya 50.5 NTU):
| Parameter | Aman (Ideal) | Waspada | Bahaya | Aksi sistem saat Bahaya |
| ------ | ------ | ------ | ------ | ------ |
| Suhu (°C) | 25.0 – 30.0 | 24.0 – <25.0 atau >30.0 – 31.0 | < 24.0 atau > 31.0 | Push notifikasi (cek fisik/peneduh, **tanpa ganti air** ) |
| pH | 6.5 – 8.5 | 6.0 – <6.5 atau >8.5 – 9.0 | < 6.0 atau > 9.0 | Push notifikasi + pompa sirkulasi air |
| Kekeruhan (NTU) | 0 – 50 | >50 – 60 | > 60 | Push notifikasi + pompa penggantian air |
| Amonia (PPM) | ≤ 0.50 | >0.50 – <0.60 | ≥ 0.60 | Push _Emergency Alert_ + aerator + pompa penggantian air |

- **Waspada** = mode _manual override_ (user boleh turun tangan manual). **Bahaya** = aktuator otomatis aktif.
- **Banner kondisi keseluruhan** = status terburuk dari 4 parameter.
- Aktuator otomatis dijalankan oleh **firmware ESP32** , bukan oleh aplikasi. Aplikasi hanya menampilkan status dan mengirim perintah manual.
- Threshold disimpan di satu file konstanta (core/) dan dipakai juga untuk dialog "rentang ideal" di kartu.
- Status per parameter dihitung di sisi aplikasi dari nilai sensor, karena status_kondisi di database hanya satu nilai keseluruhan.

---

##### 8. Struktur Data

**Pembagian database** : Realtime Database (RTDB) untuk data yang ditulis ESP32 (kolam_status, kolam_control, sensor_history); Cloud Firestore untuk users dan alert_logs.

###### Entitas: users (Firestore)

| Field | Tipe   | Keterangan                      |
| ----- | ------ | ------------------------------- |
| uid   | string | Primary Key (Firebase Auth UID) |
| nama  | string | Nama pengguna                   |
| email | string | Email pengguna                  |
| role  | string | Default user                    |

###### Entitas: kolam_status (RTDB)

| Field          | Tipe      | Keterangan                             |
| -------------- | --------- | -------------------------------------- |
| is_connected   | boolean   | Status koneksi ESP32                   |
| status_kondisi | string    | Aman / Waspada / Bahaya (keseluruhan)  |
| suhu           | number    | DS18B20 (°C), contoh 28.5              |
| ph             | number    | pH-4502C, contoh 7.2                   |
| kekeruhan      | number    | Turbidity (NTU), contoh 6.5            |
| amonia         | number    | MQ-135 (PPM), contoh 0.15              |
| tinggi_air     | number    | _(Opsional, belum dipakai UI)_ HC-SR04 |
| last_updated   | timestamp | Waktu pembaruan dari ESP32             |

**Aturan koneksi** : tampilkan **Terputus** jika is_connected == false **atau** last_updated lebih lama dari 60 detik (nilai bisa disesuaikan). ESP32 yang mati mendadak tidak sempat menulis false, jadi last_updated wajib dicek. Alternatif: pakai onDisconnect() RTDB.

###### Entitas: kolam_control (RTDB)

| Field           | Tipe    | Keterangan                                                |
| --------------- | ------- | --------------------------------------------------------- |
| mode_otomatis   | boolean | true = otomatis, false = manual                           |
| pompa_buang_air | boolean | Relay pompa kuras/buang air keruh & amonia (true = nyala) |
| pompa_isi_air   | boolean | Relay pompa pengisian air bersih baru (true = nyala)      |
| pompa_sirkulasi | boolean | Relay pompa sirkulasi pembersihan air (true = nyala)      |
| aerator         | boolean | Relay aerator oksigen (true = nyala)                      |

###### Entitas: sensor_history (RTDB, node baru untuk grafik Riwayat)

| Field     | Tipe      | Keterangan                             |
| --------- | --------- | -------------------------------------- |
| timestamp | timestamp | Waktu pencatatan (key diurutkan waktu) |
| suhu      | number    | °C                                     |
| ph        | number    |                                        |
| kekeruhan | number    | NTU                                    |
| amonia    | number    | PPM                                    |

###### Entitas: alert_logs (Firestore, collection)

| Field       | Tipe      | Keterangan                                                                        |
| ----------- | --------- | --------------------------------------------------------------------------------- |
| alert_id    | string    | Primary Key                                                                       |
| type        | string    | Bahaya / Waspada / Aman                                                           |
| parameter   | string    | suhu / ph / kekeruhan / amonia                                                    |
| nilai       | number    | Nilai saat kejadian                                                               |
| title       | string    | Contoh: "Bahaya: Amonia Tinggi · 0.65 PPM"                                        |
| description | string    | Rekomendasi tindakan, contoh: "Aktifkan pompa & aerator untuk menurunkan amonia." |
| timestamp   | timestamp | Waktu kejadian                                                                    |

**Relasi** : tidak ada relasi antar-entitas. Satu kolam saja (tanpa kolam_id), pada tahap ini tanpa multi-kolam.

---

##### 9. Backend

- **Pilihan** : Firebase (Auth, Realtime Database, Cloud Firestore, Cloud Messaging).
- **Autentikasi** : Email + Password via firebase_auth.
- **Realtime Sync** : Stream dari RTDB untuk kolam_status dan kolam_control.
- **Perangkat IoT** : ESP32 menulis sensor ke RTDB lewat Wi-Fi.
- **Early warning** : FCM tidak bisa dikirim aman langsung dari ESP32; butuh Cloud Functions (trigger saat nilai melewati batas Bahaya) yang juga menulis alert_logs. Ini sisi backend, di luar kode Flutter.
- **PENTING** : kredensial/secret tidak di-commit. Pastikan .env ada di .gitignore, dan atur Firebase Security Rules agar hanya user terautentikasi yang bisa baca/tulis.

---

##### 10. Keputusan Teknis

- **Flutter / Dart version** : _(isi dari hasil flutter --version)_
- **State management** : flutter_riverpod
- **Navigasi** : go_router
- **Paket yang boleh dipakai** : firebase_core, firebase_auth, cloud_firestore, firebase_database, firebase_messaging, flutter_riverpod, go_router, fl_chart, google_fonts, shimmer (untuk loading skeleton), intl (format tanggal Indonesia).
- **Struktur folder** :

```
lib/
├── main.dart
├── core/            # Tema, design token, threshold, router, utils
├── features/
│   ├── auth/        # Login screen & state auth
│   ├── dashboard/   # Dashboard real-time sensor
│   ├── kontrol/     # Kendali otomatis & relay manual
│   └── riwayat/     # Grafik fl_chart & log peringatan
└── shared/          # Bottom nav bar, sensor card, banner error/offline

```

---

##### 11. Aturan untuk AI (Tempel di Prompt)

- Satu widget per file; pecah widget besar menjadi komponen reusabel.
- Ikuti struktur folder dan design token di atas, jangan mengarang warna/ukuran.
- Jangan menambah package di luar daftar tanpa bertanya.
- Gunakan Riverpod StreamProvider untuk membaca kolam_status dan kolam_control secara real-time.
- Jangan hardcode API key, URL, atau password.
- Tangani state loading, data kosong, dan terputus/offline di setiap screen yang memuat data.
- Beri validasi input (email & password) pada form login.
- Hitung status Aman/Waspada/Bahaya memakai tabel threshold di bagian 7; jangan mengarang batas sendiri.
- Kerjakan hanya screen/fitur yang diminta pada prompt, jangan sekalian membuat yang lain.
- Jelaskan singkat tiap file yang dibuat/diubah supaya saya bisa memahaminya.
- Jika ada yang ambigu, tanya dulu sebelum menulis kode.

---

##### 12. Checklist Environment

- [ ] Flutter SDK terpasang, flutter doctor semua hijau
- [ ] Project Firebase dikonfigurasi (google-services.json / firebase_options.dart; untuk web, app web terdaftar di Firebase)
- [ ] Package di bagian 10 ditambahkan ke pubspec.yaml
- [ ] Folder assets/ (termasuk assets/ui/) diatur di pubspec.yaml
- [ ] .gitignore sudah menyertakan .env

---

##### 13. Urutan Pengerjaan (Roadmap)

1. [ ] Setup project, AppTheme (design token), konstanta threshold, dan go_router
2. [ ] UI LoginScreen (mobile + web) lalu sambungkan firebase_auth
3. [ ] UI DashboardScreen dengan data dummy (termasuk dialog rentang ideal) lalu sambungkan ke Stream RTDB
4. [ ] UI KontrolScreen lalu sambungkan toggle ke RTDB
5. [ ] UI RiwayatScreen (grafik fl_chart dari sensor_history + daftar alert_logs)
6. [ ] Handler state terputus/offline
7. [ ] Konfigurasi FCM untuk push notification
8. [ ] Tes alur lengkap end-to-end (termasuk simulasi lonjakan amonia)

---

##### 14. Template Prompt

###### Prompt pembuka (sekali di awal sesi)

```
Kamu adalah senior Flutter developer. Berikut konteks project saya:
[tempel isi file ini]

Konfirmasi dulu bahwa kamu paham, lalu sebutkan hal yang masih ambigu.
Jangan menulis kode dulu.

```

###### Prompt per screen

```
Buatkan [NamaScreen] berdasarkan foto UI terlampir.

Perilaku:
- (tombol X menuju screen Y)
- (field apa saja, validasinya apa)

Data: sementara pakai data dummy.
Ikuti design token dan aturan di konteks.
File yang boleh dibuat/diubah: (sebutkan).

```

###### Prompt sambung data

```
Sambungkan [NamaScreen] ke [endpoint/koleksi] sesuai struktur data di konteks.
Tambahkan state loading, kosong, dan error. Jelaskan alur datanya singkat.

```

###### Prompt saat error

```
Saya dapat error berikut saat menjalankan [aksi]:
[tempel pesan error lengkap + stack trace]

File terkait: [tempel kode]
Jelaskan penyebabnya dulu, lalu beri perbaikan minimal.

```

---

##### 15. Catatan Pribadi

**Ketidakkonsistenan di screenshot (data dummy, jangan ditiru):**

- Dashboard web: pH 8.5 berlabel WASPADA (menurut proposal harusnya AMAN, batas aman 6.5–8.5) dan kekeruhan 20.0 NTU berlabel BAHAYA (harusnya AMAN, batas aman ≤50). Banner di atasnya tetap "Kondisi Aman". Ikuti tabel threshold di bagian 7, bukan label di gambar.
- Dashboard mobile: banner "Kondisi Aman" tampil bersamaan dengan "Terputus". Saat terputus, data bersifat basi (stale), jadi jangan klaim aman tanpa keterangan.
- Riwayat: sumbu Y masih placeholder (var x/y/z/w, 0.1) dan sumbu X tidak berlabel. Log memakai tahun 2025 dan "55 PPM" (tidak masuk akal terhadap ambang amonia 0.60 PPM).
- Riwayat: 4 parameter dengan satuan berbeda (°C, pH, NTU, PPM) digambar di satu sumbu Y. Perlu keputusan: normalisasi 0–100%, sumbu terpisah, atau tab per parameter.
  **Pertanyaan yang masih terbuka:**
- Proposal memuat pompa sirkulasi dan pompa penggantian air (RAB: 3 pompa, relay 3 channel), sedangkan UI hanya punya satu "Pompa Air". Satu saklar mengendalikan semuanya, atau perlu dipisah?
- Saat terputus, apakah kontrol manual dinonaktifkan? (Di desain mobile masih bisa diklik.)
- Teks banner untuk kondisi Waspada dan Bahaya belum didesain.
- Tempat logout belum ada di desain.
