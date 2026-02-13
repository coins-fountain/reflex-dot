Berikut adalah analisis dan rangkuman dari feedback yang diberikan, disusun dalam format Markdown agar mudah dibaca dan ditindaklanjuti.

---

# 📋 Analisis & Rangkuman Feedback Proyek Game

Feedback ini mencakup pembaruan terkait izin aplikasi (permissions), implementasi kebijakan privasi (privacy policy), serta standar kualitas untuk _game_ kedua (Reflex Dot).

## 1. Izin Aplikasi (Permissions)

**Status:** ⚠️ Perlu Perbaikan Segera

- **Yang sudah baik:** Izin lokasi (`ACCESS_FINE`/`COARSE`) sudah dihapus. Izin dasar iklan (`INTERNET` + `ACCESS_NETWORK_STATE`) sudah ada.
- **Masalah:** Masih ditemukan izin `WAKE_LOCK` dan `FOREGROUND_SERVICE`.
- **Instruksi Teknis:**
- Hapus `WAKE_LOCK` dan `FOREGROUND_SERVICE` karena tidak diperlukan untuk _mini-game offline_ sederhana.
- Jika izin ini berasal dari _library_ pihak ketiga (misalnya Flame atau AdMob), lakukan **manifest configuration override** untuk menghapusnya secara paksa jika tidak digunakan.
- **Target Akhir:** Hanya menyisakan izin `INTERNET`, `ACCESS_NETWORK_STATE`, dan `AD_ID` (jika perlu). Pastikan **tidak ada** permintaan izin saat _clean install_.

## 2. Kebijakan Privasi (Privacy Policy)

**Status:** 🛠️ Perlu Implementasi

- **Format:** Harus berupa **URL Web** (gunakan GitHub Pages atau Google Sites), bukan teks _hardcoded_ di dalam aplikasi.
- **Integrasi:** Aplikasi harus memiliki tombol "Privacy Policy" di menu Pengaturan yang membuka URL tersebut.
- **Isi Wajib Kebijakan Privasi:**
- Menyatakan penggunaan **Google AdMob**.
- Menjelaskan pengumpulan data oleh AdMob (Advertising ID/AD_ID, info perangkat, data penggunaan dasar).
- Menegaskan bahwa aplikasi **tidak** mengumpulkan data pribadi (Nama, Email, HP, Lokasi persis).
- Menyatakan aplikasi **tidak** meminta izin lokasi.
- Informasi cara pengguna mengatur personalisasi iklan (via pengaturan perangkat).
- Email kontak untuk _support_.
- Tanggal berlaku (_Effective date_).

## 3. Proyek Kedua: "Reflex Dot"

**Status:** 🚧 Fokus pada Perbaikan Kualitas

- **Teknologi:** Tidak wajib menggunakan _engine_ Flame untuk fase ini (kecuali diputuskan ulang), namun harus memenuhi standar kualitas.
- **Standar Kualitas Wajib:**
- _Clean State Management_ (Single source of truth).
- _Input Lock / Debounce_ (Mencegah _spam tap_).
- _Deterministic Reset_ (Reset game berjalan konsisten).
- _Lifecycle Safety_ (Aman saat aplikasi di-pause/resume).
- Tidak ada izin (permissions) yang tidak perlu.

## 4. Pelaporan Status (Reporting)

Klien meminta update status yang jelas sebelum fase ini ditutup. Format laporan harus memuat:

1. ✅ Poin yang sudah selesai (_Completed_).
2. 🔄 Poin yang sedang dikerjakan (_In Progress_).
3. ⏳ Poin yang tertunda (_Pending_).

---

## ✅ Checklist Tindakan (Action Items)

Sebelum mengirimkan APK dan Repositori terbaru, pastikan hal-hal berikut sudah diselesaikan:

- [ ] **Audit Manifest:** Pastikan `WAKE_LOCK` dan `FOREGROUND_SERVICE` sudah hilang sepenuhnya.
- [ ] **Web Privacy Policy:** Buat halaman web (GitHub Pages/Google Sites) dengan konten poin-poin di atas.
- [ ] **Tombol In-App:** Pasang tombol di _Settings_ yang mengarah ke URL Privacy Policy.
- [ ] **Quality Check Reflex Dot:** Pastikan _Reflex Dot_ memenuhi standar _lifecycle_ dan _state management_.
- [ ] **Clean Install Test:** Tes instalasi baru, pastikan tidak ada _crash_ dan tidak ada _popup_ izin yang aneh.
- [ ] **Laporan Status:** Siapkan daftar _Completed/In Progress/Pending_.

**Tujuan:** Mengirimkan APK final dan repositori yang bersih agar fase ini bisa ditandai sebagai **DONE**.
