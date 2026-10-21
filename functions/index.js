// Notifikasi Catfish Peace.
//  1. kondisiBerubah : status_kondisi (ditulis ESP32) berubah -> kirim FCM.
//  2. cekAlatTerputus: tiap menit, bila last_updated basi -> kirim FCM.
// Penerima: semua app yang berlangganan topik "kolam_alert".
const { onValueWritten } = require("firebase-functions/v2/database");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { initializeApp } = require("firebase-admin/app");
const { getDatabase } = require("firebase-admin/database");
const { getMessaging } = require("firebase-admin/messaging");

initializeApp();

const REGION = "asia-southeast1";
const INSTANCE = "catfish-peace-polindra-default-rtdb";
const TOPIC = "kolam_alert";
const CHANNEL = "kolam_alert"; // harus sama dengan MainActivity.kt
const WASPADA_COOLDOWN_MS = 5 * 60 * 1000; // cegah spam saat nilai naik-turun di batas
const OFFLINE_AFTER_S = 60; // lebih longgar dari badge app (6 dtk) agar tidak berisik

const db = () => getDatabase();

async function kirim(title, body, type, status) {
  await getMessaging().send({
    topic: TOPIC,
    notification: { title, body },
    data: { type, status: status || "" },
    android: {
      priority: "high",
      notification: { channelId: CHANNEL },
    },
  });
}

function ringkas(s) {
  const f = (v, d) => (typeof v === "number" ? v.toFixed(d) : "-");
  return (
    `Suhu ${f(s.suhu, 1)}°C · pH ${f(s.ph, 1)} · ` +
    `Kekeruhan ${f(s.kekeruhan, 0)} NTU · Amonia ${f(s.amonia, 2)} PPM`
  );
}

// ---- 1. Perubahan kondisi ---------------------------------------------------
exports.kondisiBerubah = onValueWritten(
  { ref: "/kolam_status/status_kondisi", instance: INSTANCE, region: REGION },
  async (event) => {
    const raw = event.data.after.val();
    if (typeof raw !== "string") return;
    const status = raw.toLowerCase(); // aman | waspada | bahaya
    if (!["aman", "waspada", "bahaya"].includes(status)) return;

    const now = Date.now();
    let kirimJenis = null; // "kondisi" | "tersambung" | null
    const res = await db().ref("/notifikasi_state").transaction((cur) => {
      kirimJenis = null;
      const state = cur || {};
      const prev = state.status || "aman";
      const next = { ...state, status };

      if (state.offline) {
        next.offline = false;
        kirimJenis = "tersambung";
      }
      if (status !== prev) {
        let kirimKondisi = false;
        if (status === "bahaya") kirimKondisi = true;
        else if (status === "waspada" && prev === "aman")
          kirimKondisi = now - (state.notifiedAt || 0) >= WASPADA_COOLDOWN_MS;
        else if (status === "aman" && prev !== "aman") kirimKondisi = true;
        // bahaya -> waspada: tidak dikirim, hanya status disimpan.
        if (kirimKondisi) {
          kirimJenis = "kondisi";
          next.notifiedAt = now;
        }
      }
      return next;
    });
    if (!res.committed || !kirimJenis) return;

    const snap = await db().ref("/kolam_status").get();
    const detail = ringkas(snap.val() || {});
    if (kirimJenis === "kondisi") {
      const title = {
        bahaya: "BAHAYA: kualitas air kolam",
        waspada: "Waspada: kualitas air kolam",
        aman: "Kondisi kolam kembali aman",
      }[status];
      await kirim(title, detail, "kondisi", status);
    } else {
      await kirim("Alat tersambung kembali", detail, "tersambung", status);
    }
  }
);

// ---- 2. Alat terputus -------------------------------------------------------
exports.cekAlatTerputus = onSchedule(
  { schedule: "every 1 minutes", region: REGION, timeZone: "Asia/Jakarta" },
  async () => {
    const snap = await db().ref("/kolam_status/last_updated").get();
    const last = snap.val();
    if (typeof last !== "number") return; // belum pernah ada data
    const lastSec = last >= 1e11 ? last / 1000 : last;
    const stale = Date.now() / 1000 - lastSec;
    if (stale <= OFFLINE_AFTER_S) return;

    let kirimSekarang = false;
    const res = await db().ref("/notifikasi_state").transaction((cur) => {
      kirimSekarang = false;
      const state = cur || {};
      if (state.offline) return undefined; // sudah diberitahu, batalkan
      kirimSekarang = true;
      return { ...state, offline: true };
    });
    if (!res.committed || !kirimSekarang) return;

    const menit = Math.round(stale / 60);
    await kirim(
      "Alat IoT terputus",
      `Tidak ada data dari alat selama ±${menit} menit. Cek daya dan Wi-Fi.`,
      "terputus"
    );
  }
);
