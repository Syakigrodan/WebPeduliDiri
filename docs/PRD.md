# PRD — Peduli Diri

**Product Requirement Document (Draf)**

|               |                                                             |
| ------------- | ----------------------------------------------------------- |
| Dokumen       | PRD-PeduliDiri-001                                          |
| Versi         | 0.1 — **Draf**                                              |
| Tanggal       | 2026-10-18                                                  |
| Status        | Draft, menunggu review                                      |
| Penulis       | _[isi nama pemilik proyek]_                                 |
| Dokumen terkait | [Rancangan Database](database.md), [README](../README.md) |

---

## 1. Ringkasan Produk

Peduli Diri adalah aplikasi web untuk **pencatatan perjalanan harian** dan **pemantauan suhu tubuh** sederhana per pengguna. Pengguna mendaftarkan akun dengan NIK, login ke dasbor pribadi, lalu mengelola catatannya: tanggal, jam, lokasi, dan suhu tubuh.

**Masalah yang dipecahkan:**

- Pencatatan manual (kertas / notes ponsel) sulit ditelusuri, diubah, dan direkap.
- Data perjalanan tercecer tanpa riwayat yang tersusun per orang.
- Belum ada tempat terpusat yang aman untuk menyimpan catatan harian tersebut.

## 2. Tujuan

1. Menyediakan satu tempat pencatatan perjalanan & suhu yang mudah diakses dari browser, di perangkat apa pun.
2. Menjamin privasi: data hanya terlihat dan dikelola oleh pemiliknya.
3. Menyiapkan fondasi teknis yang layak (database, autentikasi aman) agar aplikasi dapat di-hosting publik tanpa membahayakan data pengguna.

**Ukuran keberhasilan awal (v1.0):**

- Seluruh akun tersimpan dengan password ter-hash (nol teks biasa di database).
- Nol baris data pribadi dalam riwayat Git repositori.
- Pengguna baru dapat mendaftar, login, dan menyimpan catatan pertama dalam waktu < 2 menit.

## 3. Target Pengguna

| Persona | Deskripsi | Kebutuhan |
| --- | --- | --- |
| **A — Warga / pelajar / karyawan** | Tidak teknis, terbiasa memakai ponsel dan web sederhana. | Mencatat perjalanan & suhu harian secara rutin; melihat riwayatnya kapan saja. |
| **B — Pengelola / pengawas** | _Fitur lanjutan, di luar v1.0._ | Melihat rekapitulasi data banyak pengguna. |

## 4. Ruang Lingkup

### 4.1 Termasuk dalam v1.0

- Registrasi, login, logout, dan proteksi halaman.
- CRUD catatan perjalanan milik sendiri.
- Penyimpanan data pada MySQL/MariaDB (migrasi dari file teks).
- Tampilan dasbor dan tabel riwayat catatan.

### 4.2 Tidak termasuk (sekarang)

- Lupa password via email.
- Role admin / dashboard pengawas.
- Aplikasi mobile dan push notifikasi.
- Multi-bahasa (baru Bahasa Indonesia).
- Ekspor laporan (masuk daftar pengembangan, bukan v1.0).
- Geotagging / pemetaan lokasi otomatis.

## 5. Kebutuhan Fungsional

| ID | Fitur | Prioritas | Keterangan ringkas |
| --- | --- | --- | --- |
| FR-01 | Registrasi akun | Must | NIK unik + nama + password |
| FR-02 | Login NIK + password | Must | Sesuai keputusan desain autentikasi |
| FR-03 | Logout | Must | Menghancurkan sesi, redirect ke login |
| FR-04 | Proteksi halaman | Must | Semua halaman dalam wajib login |
| FR-05 | Tambah catatan | Must | Tanggal, jam, lokasi, suhu |
| FR-06 | Lihat daftar catatan | Must | Hanya catatan milik sesi pengguna |
| FR-07 | Ubah catatan | Must | Hanya milik sendiri + konfirmasi simpan |
| FR-08 | Hapus catatan | Must | Konfirmasi + hanya milik sendiri |
| FR-09 | Dasbor | Should | Sapaan pengguna + ringkasan jumlah catatan |
| FR-10 | Validasi input | Should | NIK 16 digit, panjang & rentang field |
| FR-11 | Rate-limiting login | Should | Maksimal 5 percobaan gagal / 5 menit |

**Rincian penting:**

**FR-01 — Registrasi**

- Input: NIK (16 digit angka, unik), nama lengkap (2–100 karakter), password (min. 8 karakter) + konfirmasi password.
- Hasil: akun dibuat, password disimpan sebagai hash, pengguna diarahkan ke halaman login.
- NIK yang sudah terdaftar harus ditolak dengan pesan yang jelas.

**FR-02 — Login**

- Input: NIK + password.
- Berhasil: sesi dibuat (_session ID regenerate_), redirect ke dasbor.
- Gagal: pesan **generik** — "NIK atau password salah" — tanpa mengindikasikan mana yang keliru, dan tanpa membuka sesi.

**FR-05 s/d FR-08 — Catatan**

- Field: tanggal (`date`), jam (`time`), lokasi (2–150 karakter), suhu (angka desimal, rentang wajar 30.0–45.0 °C, boleh kosong).
- Hapus selalu meminta konfirmasi dan memakai metode POST ber-token (bukan GET).
- Edit/hapus hanya berhasil bila catatan dimiliki pengguna yang sedang login.

## 6. Kebutuhan Non-Fungsional

| ID | Kategori | Keterangan |
| --- | --- | --- |
| NFR-01 | Keamanan autentikasi | Password hanya via `password_hash()` / `password_verify()`; pesan gagal login generik; regenerasi session ID saat login. |
| NFR-02 | Keamanan data & query | Prepared statements (PDO); output di-escape (`htmlspecialchars`) mencegah XSS; token CSRF pada semua form & aksi penghapusan. |
| NFR-03 | Keamanan repositori | `config.txt`, `catatan.txt`, dan `.env` masuk `.gitignore`; audit `git status` sebelum setiap push. |
| NFR-04 | Performa | Halaman termuat < 2 detik pada koneksi 4G; query daftar catatan memakai indeks `(user_id, tanggal)`. |
| NFR-05 | Kompatibilitas | Chrome, Firefox, Edge, Safari (2 versi terakhir); desktop & layar ponsel (responsif Bootstrap 4). |
| NFR-06 | Ketersediaan data | Backup database terjadwal; penghapusan data selalu melalui konfirmasi. |
| NFR-07 | Bahasa & aksesibilitas | Antarmuka Bahasa Indonesia; setiap input punya `<label>`; kontras teks memadai. |
| NFR-08 | Cookie sesi | `httponly`, `samesite=Lax`, `secure` saat dijalankan di HTTPS. |

## 7. Alur Pengguna Utama

**Alur 1 — Registrasi → Login**

Buka `index.php` → "Belum punya akun?" → isi NIK, nama, password → daftar berhasil → halaman login → isi NIK + password → dasbor.

**Alur 2 — Menulis catatan**

Dasbor → menu "Tulis Catatan / Perjalanan" → isi tanggal, jam, lokasi, suhu → Simpan → notifikasi sukses → daftar catatan menampilkan data baru.

**Alur 3 — Ubah / hapus catatan**

Dasbor → "Catatan Perjalanan" → tombol Ubah (form terisi, simpan) atau Hapus (konfirmasi → terhapus) → kembali ke daftar.

**Alur 4 — Kegagalan login**

Login salah → pesan generik → setelah 5 kali gagal berturut-turut, percobaan berikutnya ditolak sementara (pesan: terlalu banyak percobaan, coba lagi nanti).

## 8. Kriteria Penerimaan — Fitur Login

| ID | Skenario | Kriteria |
| --- | --- | --- |
| AC-01 | Registrasi dengan NIK sudah ada | Ditolak; pengguna tetap di halaman register dengan pesan jelas. |
| AC-02 | Login dengan NIK + password benar | Berhasil; redirect ke dasbor; sesi berisi identitas pengguna. |
| AC-03 | Login dengan password salah | Ditolak; pesan generik; **tidak ada sesi yang terbentuk**. |
| AC-04 | Pemeriksaan database | Password hanya tersimpan sebagai hash (diverifikasi dengan `password_verify`, bukan perbandingan teks biasa). |
| AC-05 | Halaman tanpa sesi | Semua halaman terproteksi mengalihkan ke `index.php`. |
| AC-06 | Setelah logout | Sesi habis; tombol _Back_ browser tidak menampilkan halaman terproteksi. |
| AC-07 | 5 kali gagal berturut-turut | Percobaan berikutnya ditolak sementara dengan pesan yang sesuai. |

## 9. Prioritas (MoSCoW)

| Kategori | Item |
| --- | --- |
| **Must** | Registrasi + login NIK/password, proteksi halaman, CRUD catatan dengan ownership check, migrasi ke MySQL, perbaikan logout. |
| **Should** | CSRF token, escaping output, rate-limiting login, validasi suhu numerik, dasbor ringkasan. |
| **Could** | Ekspor CSV, grafik riwayat suhu (Chart.js sudah tersedia), tema gelap. |
| **Won't (periode ini)** | Aplikasi mobile, role admin, reset password via email, multi-bahasa. |

## 10. Rencana Teknis & Migrasi

Rancangan tabel lengkap ada di [docs/database.md](database.md) dan [`database.sql`](../database.sql). Tahapan pengerjaan:

1. **Fondasi DB** — buat skema, lapisan koneksi (PDO, kredensial di luar repositori).
2. **Autentikasi** — pindahkan registrasi & login ke tabel `users` + `password_hash()`.
3. **CRUD catatan** — pindahkan ke `catatan_perjalanan` + klausa `WHERE user_id` di setiap operasi.
4. **Migrasi data lama** — impor `config.txt` & `catatan.txt`; akun lama belum punya password, sehingga perlu password sementara yang di-hash (wajib diganti) atau pendaftaran ulang.
5. **Pembersihan** — berhenti menulis file teks, dokumentasikan perubahan, rilis v1.0.

## 11. Risiko & Mitigasi

| Risiko | Dampak | Mitigasi |
| --- | --- | --- |
| Data pribadi (NIK) ter-commit ke repo publik | Tinggi | `.gitignore` untuk file data; audit sebelum push; jangan menaruh data contoh berisi NIK asli. |
| Login saat ini tanpa password | Tinggi | Menjadi item **Must** — dihapus pada rilis 1.0. |
| IDOR: edit/hapus catatan tanpa cek pemilik | Tinggi | Selalu sertakan `WHERE user_id = ?` pada query ubah/hapus. |
| XSS lewat input lokasi/suhu | Sedang | `htmlspecialchars()` pada setiap output dinamis. |
| CSRF — hapus lewat GET tanpa token | Sedang | Ganti ke POST + token CSRF di semua form. |
| ID catatan `rand(0,100000)` bisa bentrok | Sedang | Primary key `AUTO_INCREMENT`. |
| File teks rusak / tabrakan penggunaan serentak | Sedang | Transaksi database; berhenti memakai file teks. |
| Tautan logout rusak (sidebar & modal) | Sedang | Arahkan ke `logout.php` yang melakukan `session_destroy`. |
| Ketergantungan upstream SB Admin 2 | Rendah | Aset sudah lokal di folder `vendor/`. |

## 12. Metrik Keberhasilan

- 100% akun memiliki password ter-hash; nol teks biasa di kolom `password`.
- Nol data pribadi dalam riwayat Git.
- Seluruh skenario AC-01 … AC-07 lulus uji manual/otomatis.
- Waktu "daftar → catatan pertama" < 2 menit pada pengujian dengan pengguna baru.

## 13. Riwayat Perubahan

| Versi | Tanggal | Perubahan | Penulis |
| --- | --- | --- | --- |
| 0.1 | 2026-10-18 | Draf pertama — analisis kode lama, keputusan MySQL + NIK/Password | _[nama]_ |
