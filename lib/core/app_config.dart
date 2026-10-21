/// Pengaturan perilaku & koneksi yang bisa disesuaikan di satu tempat.

/// true = status kolam memakai data dummy (4 skenario; ganti skenario dengan
/// tekan lama badge koneksi di header saat debug). false = baca RTDB
/// `kolam_status`. Kontrol (`kolam_control`) selalu memakai RTDB.
const bool kUseDummyStatus = false;

/// Batas "Terputus": tidak ada pembaruan `last_updated` selama durasi ini.
/// Firmware saat ini menulis tiap 16 detik (INTERVAL_UPDATE_MS), jadi batas
/// 40 detik = toleransi ~2 paket hilang. Jika interval firmware dipercepat
/// ke 2 detik, ubah kembali menjadi 6 detik.
const Duration kStaleAfter = Duration(seconds: 40);

/// Jika true, semua saklar kontrol dinonaktifkan saat alat IoT terputus
/// (perintah tidak akan sampai ke alat, jadi jangan beri kesan berhasil).
const bool kDisableControlsWhenOffline = true;

/// Cadangan URL Realtime Database (region Singapore) bila `firebase_options`
/// tidak memuat `databaseURL`. URL ini identitas database, bukan rahasia;
/// keamanan datanya dijaga oleh Security Rules, bukan oleh URL.
const String kRtdbUrlFallback =
    'https://catfish-peace-polindra-default-rtdb.asia-southeast1.firebasedatabase.app';

/// Jika true, daftar log peringatan dikosongkan (untuk melihat state kosong).
const bool kDummyEmptyLogs = false;
