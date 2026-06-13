-- Sistem Reservasi Hotel - DDL (CREATE TABLE + Constraints)

-- Membuat Database baru
CREATE DATABASE IF NOT EXISTS hotel_reservasi;
-- Memanggil database yang akan digunakan
USE hotel_reservasi;

-- 1. TABEL TIPE_KAMAR
-- Membuat tabel dengan nama tipe_kamar
CREATE TABLE tipe_kamar (
    id_tipe       VARCHAR(5)    NOT NULL,
    nama_tipe     VARCHAR(50)   NOT NULL,
    kapasitas     TINYINT       NOT NULL CHECK (kapasitas > 0),
    deskripsi_tipe VARCHAR(200) NULL,
    harga_dasar   DECIMAL(12,2) NOT NULL CHECK (harga_dasar >= 0),
    CONSTRAINT pk_tipe_kamar PRIMARY KEY (id_tipe),
    CONSTRAINT uq_nama_tipe  UNIQUE (nama_tipe)
);

-- 2. TABEL KAMAR
CREATE TABLE kamar (
    id_kamar      VARCHAR(5)   NOT NULL,
    nomor_kamar   VARCHAR(10)  NOT NULL,
    lantai        TINYINT      NOT NULL CHECK (lantai > 0),
    status_kamar  ENUM('Tersedia','Terisi','Dipesan','Maintenance') NOT NULL DEFAULT 'Tersedia', -- jika kamar tsb tidak diisi, maka secara otomatis memberi status "tersedia"
    id_tipe       VARCHAR(5)   NOT NULL,
    CONSTRAINT pk_kamar        PRIMARY KEY (id_kamar),
    CONSTRAINT fk_kamar_tipe   FOREIGN KEY (id_tipe) REFERENCES tipe_kamar(id_tipe)
);

-- Membuat indeks untuk mempercepat pencarian berdasarkan status kamar
CREATE INDEX idx_kamar_status ON kamar(status_kamar);
CREATE INDEX idx_kamar_tipe   ON kamar(id_tipe);

-- 3. TABEL TAMU
CREATE TABLE tamu (
    id_tamu        VARCHAR(7)   NOT NULL,
    nama_tamu      VARCHAR(100) NOT NULL,
    alamat         VARCHAR(200) NULL,
    no_hp          VARCHAR(20)  NOT NULL,
    email          VARCHAR(100) NULL,
    jenis_identitas ENUM('KTP','SIM','Passport') NOT NULL DEFAULT 'KTP',
    no_identitas   VARCHAR(20)  NOT NULL,
    CONSTRAINT pk_tamu           PRIMARY KEY (id_tamu),
    CONSTRAINT uq_tamu_identitas UNIQUE (jenis_identitas, no_identitas),
    CONSTRAINT uq_tamu_email     UNIQUE (email)
);

CREATE INDEX idx_tamu_nama ON tamu(nama_tamu);

-- 4. TABEL PEGAWAI
CREATE TABLE pegawai (
    id_pegawai  VARCHAR(5)  NOT NULL,
    nama_pegawai VARCHAR(100) NOT NULL,
    jabatan     VARCHAR(50)  NOT NULL,
    no_hp       VARCHAR(20)  NOT NULL,
    CONSTRAINT pk_pegawai PRIMARY KEY (id_pegawai)
);

-- 5. TABEL FASILITAS
CREATE TABLE fasilitas (
    id_fasilitas       VARCHAR(5)   NOT NULL,
    nama_fasilitas     VARCHAR(100) NOT NULL,
    kategori           VARCHAR(50)  NOT NULL,
    deskripsi_fasilitas VARCHAR(200) NULL,
    biaya              DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (biaya >= 0),
    CONSTRAINT pk_fasilitas    PRIMARY KEY (id_fasilitas),
    CONSTRAINT uq_nama_fasilitas UNIQUE (nama_fasilitas)
);

-- 6. TABEL RESERVASI
CREATE TABLE reservasi (
    id_reservasi     VARCHAR(5)   NOT NULL,
    tanggal_pesan    DATE         NOT NULL,
    check_in         DATE         NOT NULL,
    check_out        DATE         NOT NULL,
    jumlah_tamu      TINYINT      NOT NULL CHECK (jumlah_tamu > 0),
    status_reservasi ENUM('Dipesan','Check-In','Selesai','Batal') NOT NULL DEFAULT 'Dipesan',
    id_tamu          VARCHAR(7)   NOT NULL,
    id_kamar         VARCHAR(5)   NOT NULL,
    CONSTRAINT pk_reservasi          PRIMARY KEY (id_reservasi),
    CONSTRAINT fk_reservasi_tamu     FOREIGN KEY (id_tamu)  REFERENCES tamu(id_tamu),
    CONSTRAINT fk_reservasi_kamar    FOREIGN KEY (id_kamar) REFERENCES kamar(id_kamar),
    CONSTRAINT chk_tanggal_reservasi CHECK (check_out > check_in)
);

CREATE INDEX idx_reservasi_tamu   ON reservasi(id_tamu);
CREATE INDEX idx_reservasi_kamar  ON reservasi(id_kamar);
CREATE INDEX idx_reservasi_status ON reservasi(status_reservasi);
CREATE INDEX idx_reservasi_checkin ON reservasi(check_in);

-- 7. TABEL PEMBAYARAN
CREATE TABLE pembayaran (
    id_pembayaran VARCHAR(7)    NOT NULL,
    tanggal_bayar DATE          NOT NULL,
    jumlah_bayar  DECIMAL(12,2) NOT NULL CHECK (jumlah_bayar > 0),
    metode_bayar  ENUM('Transfer','QRIS','Cash','Kartu Kredit') NOT NULL,
    status_bayar  ENUM('Lunas','Pending','Gagal','Refund') NOT NULL DEFAULT 'Pending',
    referensi     VARCHAR(20)   NULL,
    id_reservasi  VARCHAR(5)    NOT NULL,
    CONSTRAINT pk_pembayaran          PRIMARY KEY (id_pembayaran),
    CONSTRAINT fk_pembayaran_reservasi FOREIGN KEY (id_reservasi) REFERENCES reservasi(id_reservasi),
    CONSTRAINT uq_pembayaran_reservasi UNIQUE (id_reservasi)
);

CREATE INDEX idx_pembayaran_status ON pembayaran(status_bayar);

-- 8. TABEL CHECK_IN
CREATE TABLE check_in (
    id_checkin    VARCHAR(7)  NOT NULL,
    waktu_checkin DATETIME    NOT NULL,
    id_reservasi  VARCHAR(5)  NOT NULL,
    id_pegawai    VARCHAR(5)  NOT NULL,
    CONSTRAINT pk_checkin           PRIMARY KEY (id_checkin),
    CONSTRAINT fk_checkin_reservasi FOREIGN KEY (id_reservasi) REFERENCES reservasi(id_reservasi),
    CONSTRAINT fk_checkin_pegawai   FOREIGN KEY (id_pegawai)   REFERENCES pegawai(id_pegawai),
    CONSTRAINT uq_checkin_reservasi UNIQUE (id_reservasi)
);

-- 9. TABEL CHECK_OUT
CREATE TABLE check_out (
    id_checkout    VARCHAR(7)  NOT NULL,
    waktu_checkout DATETIME    NOT NULL,
    id_reservasi   VARCHAR(5)  NOT NULL,
    id_pegawai     VARCHAR(5)  NOT NULL,
    CONSTRAINT pk_checkout           PRIMARY KEY (id_checkout),
    CONSTRAINT fk_checkout_reservasi FOREIGN KEY (id_reservasi) REFERENCES reservasi(id_reservasi),
    CONSTRAINT fk_checkout_pegawai   FOREIGN KEY (id_pegawai)   REFERENCES pegawai(id_pegawai),
    CONSTRAINT uq_checkout_reservasi UNIQUE (id_reservasi)
);

-- 10. TABEL ULASAN
CREATE TABLE ulasan (
    id_ulasan      VARCHAR(5)   NOT NULL,
    tanggal_ulasan DATE         NOT NULL,
    rating         TINYINT      NOT NULL CHECK (rating BETWEEN 1 AND 5),
    komentar       VARCHAR(500) NULL,
    id_reservasi   VARCHAR(5)   NOT NULL,
    CONSTRAINT pk_ulasan           PRIMARY KEY (id_ulasan),
    CONSTRAINT fk_ulasan_reservasi FOREIGN KEY (id_reservasi) REFERENCES reservasi(id_reservasi),
    CONSTRAINT uq_ulasan_reservasi UNIQUE (id_reservasi)
);

CREATE INDEX idx_ulasan_rating ON ulasan(rating);

-- 11. TABEL AUDIT_LOG (untuk TRIGGER)
-- Untuk mencatat riwayat perubahan data yang terjadi pada tabel lain melalui trigger
CREATE TABLE audit_log (
    id_log       INT           NOT NULL AUTO_INCREMENT,
    nama_tabel   VARCHAR(50)   NOT NULL,
    operasi      ENUM('INSERT','UPDATE','DELETE') NOT NULL,
    id_record    VARCHAR(20)   NOT NULL,
    keterangan   VARCHAR(500)  NULL,
    waktu_log    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_audit_log PRIMARY KEY (id_log)
);