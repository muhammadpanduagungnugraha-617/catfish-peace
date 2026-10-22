# Aturan keamanan Firebase

Sekarang RTDB `auth != null` dan Firestore test mode. Ganti sebelum dipakai.

## Firestore (tidak dipakai app saat ini)
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} { allow read, write: if false; }
  }
}
```

## Realtime Database
Ganti `UID_ESP32` dengan UID akun perangkat ESP32 (Firebase Console →
Authentication → Users → salin User UID). Akun lain adalah pengguna app.
```json
{
  "rules": {
    ".read": false,
    ".write": false,
    "kolam_status":   { ".read": "auth != null", ".write": "auth.uid === 'UID_ESP32'" },
    "kolam_relay":    { ".read": "auth != null", ".write": "auth.uid === 'UID_ESP32'" },
    "sensor_history": { ".read": "auth != null", ".write": "auth.uid === 'UID_ESP32'", ".indexOn": [".key"] },
    "kolam_control": {
      ".read": "auth != null",
      ".write": "auth != null",
      "mode_otomatis":   { ".validate": "newData.isBoolean()" },
      "pompa_buang_air": { ".validate": "newData.isBoolean()" },
      "pompa_isi_air":   { ".validate": "newData.isBoolean()" },
      "pompa_probiotik": { ".validate": "newData.isBoolean()" },
      "aerator":         { ".validate": "newData.isBoolean()" },
      "$other": { ".validate": false }
    }
  }
}
```
Catatan: ESP32 juga menulis `kolam_control/<pompa>` = false saat pengaman
manual menolak perintah, jadi `kolam_control` harus bisa ditulis akun ESP32
juga (sudah, lewat `auth != null`). Pastikan login anonim dinonaktifkan dan
ESP32 memakai akun email/password khusus.
