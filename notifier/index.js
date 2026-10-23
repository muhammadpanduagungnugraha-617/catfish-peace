// Notifier Catfish Peace: skrip Node.js biasa (TANPA Cloud Functions / Blaze).
// Harus berjalan terus di PC / Raspberry Pi / VPS. Bila skrip mati, notifikasi
// berhenti. Logika sama dengan functions/index.js.
//
//   ESP32 -> RTDB kolam_status -> skrip ini -> FCM topik "kolam_alert" -> HP
const admin = require("firebase-admin");

const SERVICE_ACCOUNT = process.env.SERVICE_ACCOUNT || "./serviceAccount.json";
const DATABASE_URL =
  process.env.DATABASE_URL ||
  "https://catfish-peace-polindra-default-rtdb.asia-southeast1.firebasedatabase.app";
const TOPIC = "kolam_alert";
const CHANNEL = "kolam_alert"; // sama dengan MainActivity.kt
const WASPADA_COOLDOWN_MS = 5 * 60 * 1000;
const OFFLINE_AFTER_S = 60;
const CEK_OFFLINE_MS = 60 * 1000;

admin.initializeApp({
  credential: admin.credential.cert(require(SERVICE_ACCOUNT)),
  databaseURL: DATABASE_URL,
});
const db = admin.database();

async function kirim(title, body, type, status) {
  const id = await admin.messaging().send({
    topic: TOPIC,
    notification: { title, body },
    data: { type, status: status || "" },
    android: { priority: "high", notification: { channelId: CHANNEL } },
  });
  console.log(`[FCM] ${title} -> ${id}`);
}

function ringkas(s) {
  const f = (v, d) => (typeof v === "number" ? v.toFixed(d) : "-");
  return (
    `Suhu ${f(s.suhu, 1)}°C · pH ${f(s.ph, 1)} · ` +
    `Kekeruhan ${f(s.kekeruhan, 0)} NTU · Amonia ${f(s.amonia, 2)} PPM`
  );
}

const JUDUL = {
  bahaya: "BAHAYA: kualitas air kolam",
  waspada: "Waspada: kualitas air kolam",
  aman: "Kondisi kolam kembali aman",
  "sensor error": "Sensor kolam bermasalah",
};

// 1. Perubahan status_kondisi ------------------------------------------------
async function kondisiBerubah(raw) {
  if (typeof raw !== "string") return;
  const status = raw.toLowerCase();
  if (!(status in JUDUL)) return;

  const now = Date.now();
  let jenis = null; // "kondisi" | "tersambung" | null
  const res = await db.ref("/notifikasi_state").transaction((cur) => {
    jenis = null;
    const state = cur || {};
    const prev = state.status || "aman";
    const next = { ...state, status };
    if (state.offline) {
      next.offline = false;
      jenis = "tersambung";
    }
    if (status !== prev) {
      let kirimKondisi = false;
      if (status === "bahaya" || status === "sensor error") kirimKondisi = true;
      else if (status === "waspada" && prev === "aman")
        kirimKondisi = now - (state.notifiedAt || 0) >= WASPADA_COOLDOWN_MS;
      else if (status === "aman" && prev !== "aman") kirimKondisi = true;
      if (kirimKondisi) {
        jenis = "kondisi";
        next.notifiedAt = now;
      }
    }
    return next;
  });
  if (!res.committed || !jenis) return;

  const snap = await db.ref("/kolam_status").get();
  const detail = ringkas(snap.val() || {});
  if (jenis === "kondisi") await kirim(JUDUL[status], detail, "kondisi", status);
  else await kirim("Alat tersambung kembali", detail, "tersambung", status);
}

// 2. Alat terputus -------------------------------------------------------------
async function cekAlatTerputus() {
  const last = (await db.ref("/kolam_status/last_updated").get()).val();
  if (typeof last !== "number") return;
  const lastSec = last >= 1e11 ? last / 1000 : last;
  const stale = Date.now() / 1000 - lastSec;
  if (stale <= OFFLINE_AFTER_S) return;

  let kirimSekarang = false;
  const res = await db.ref("/notifikasi_state").transaction((cur) => {
    kirimSekarang = false;
    const state = cur || {};
    if (state.offline) return undefined; // sudah diberitahu
    kirimSekarang = true;
    return { ...state, offline: true };
  });
  if (!res.committed || !kirimSekarang) return;

  await kirim(
    "Alat IoT terputus",
    `Tidak ada data dari alat selama ±${Math.round(stale / 60)} menit. Cek daya dan Wi-Fi.`,
    "terputus"
  );
}

const aman = (fn) => (...a) =>
  fn(...a).catch((e) => console.error("[ERR]", e.message || e));

db.ref("/kolam_status/status_kondisi").on("value", (snap) =>
  aman(kondisiBerubah)(snap.val())
);
setInterval(aman(cekAlatTerputus), CEK_OFFLINE_MS);
console.log("Notifier berjalan. Menunggu perubahan status kolam...");
