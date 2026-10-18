-- =====================================================================
-- Peduli Diri — Skema Database
-- ---------------------------------------------------------------------
-- DBMS    : MySQL 5.7+ / MariaDB 10.3+
-- Versi   : 1.0.0-draft (2026-10-18)
-- Penggunaan:
--   1. Via CLI   : mysql -u root -p < database.sql
--   2. Via GUI   : import melalui phpMyAdmin
-- Dokumen desain: docs/database.md
-- =====================================================================

CREATE DATABASE IF NOT EXISTS peduli_diri
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE peduli_diri;

-- ---------------------------------------------------------------------
-- Tabel users — inti fitur autentikasi (NIK + Password)
-- Menggantikan file config.txt (format: NIK|NAMA_LENGKAP)
-- ---------------------------------------------------------------------
CREATE TABLE users (
    id            INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nik           VARCHAR(16)  NOT NULL
                  COMMENT 'NIK 16 digit — VARCHAR agar nol di depan tetap aman',
    nama_lengkap  VARCHAR(100) NOT NULL,
    password      VARCHAR(255) NOT NULL
                  COMMENT 'Hasil password_hash() bcrypt/argon2id — TIDAK PERNAH teks biasa',
    created_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
                  ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    UNIQUE KEY uq_users_nik (nik)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- Tabel catatan_perjalanan — catatan harian per pengguna (1:N)
-- Menggantikan file catatan.txt
-- (format: ID|NIK|NAMA|TANGGAL|JAM|LOKASI|SUHU)
-- ---------------------------------------------------------------------
CREATE TABLE catatan_perjalanan (
    id         INT UNSIGNED NOT NULL AUTO_INCREMENT,
    user_id    INT UNSIGNED NOT NULL,
    tanggal    DATE         NOT NULL,
    jam        TIME         NOT NULL,
    lokasi     VARCHAR(150) NOT NULL,
    suhu       DECIMAL(4, 1) NULL
               COMMENT 'Suhu tubuh dalam derajat Celsius (NULL jika tidak diisi)',

    created_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
               ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    KEY idx_catatan_user_tanggal (user_id, tanggal),
    CONSTRAINT fk_catatan_users
        FOREIGN KEY (user_id) REFERENCES users (id)
        ON DELETE CASCADE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- (Opsional) Contoh akun uji — password: password123
-- Hasil hash dibuat via PHP, jangan pernah menulis password teks biasa.
-- Jalankan perintah berikut untuk membuat hash:
--   php -r "echo password_hash('password123', PASSWORD_DEFAULT), PHP_EOL;"
-- HAPUS baris INSERT ini sebelum produksi.
-- ---------------------------------------------------------------------
-- INSERT INTO users (nik, nama_lengkap, password)
-- VALUES ('1234567890123456', 'Contoh Pengguna', '<tempel-hash-di-sini>');
