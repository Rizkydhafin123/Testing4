-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Drop existing tables if they exist (untuk clean setup)
DROP TABLE IF EXISTS umkm CASCADE;
DROP TABLE IF EXISTS warga CASCADE;
DROP TABLE IF EXISTS surat CASCADE;
DROP TABLE IF EXISTS keuangan CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- Create users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    username VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL DEFAULT 'user',
    rt VARCHAR(10),
    rw VARCHAR(10),
    is_first_login BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create warga table
CREATE TABLE warga (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nama VARCHAR(255) NOT NULL,
    nik VARCHAR(20) UNIQUE NOT NULL,
    tempat_lahir VARCHAR(100),
    tanggal_lahir DATE,
    jenis_kelamin VARCHAR(10),
    alamat TEXT,
    rt VARCHAR(10),
    rw VARCHAR(10),
    agama VARCHAR(50),
    status_perkawinan VARCHAR(50),
    pekerjaan VARCHAR(100),
    kewarganegaraan VARCHAR(50) DEFAULT 'WNI',
    no_hp VARCHAR(20),
    email VARCHAR(100),
    status VARCHAR(50) DEFAULT 'aktif',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE
);

-- Create surat table
CREATE TABLE surat (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nomor_surat VARCHAR(100) UNIQUE NOT NULL,
    jenis_surat VARCHAR(100) NOT NULL,
    nama_pemohon VARCHAR(255) NOT NULL,
    nik_pemohon VARCHAR(20) NOT NULL,
    keperluan TEXT,
    tanggal_surat DATE NOT NULL DEFAULT CURRENT_DATE,
    status VARCHAR(50) DEFAULT 'draft',
    keterangan TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE
);

-- Create keuangan table
CREATE TABLE keuangan (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tanggal DATE NOT NULL DEFAULT CURRENT_DATE,
    jenis VARCHAR(50) NOT NULL, -- 'pemasukan' atau 'pengeluaran'
    kategori VARCHAR(100) NOT NULL,
    deskripsi TEXT NOT NULL,
    jumlah DECIMAL(15,2) NOT NULL,
    bukti_transaksi VARCHAR(255),
    status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE
);

-- Create umkm table
CREATE TABLE umkm (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nama_usaha VARCHAR(255) NOT NULL,
    pemilik VARCHAR(255) NOT NULL,
    nik_pemilik VARCHAR(20),
    no_hp VARCHAR(20),
    alamat_usaha TEXT,
    jenis_usaha VARCHAR(100) NOT NULL,
    kategori_usaha VARCHAR(100),
    deskripsi_usaha TEXT,
    produk TEXT,
    kapasitas_produksi INTEGER,
    satuan_produksi VARCHAR(50),
    periode_operasi INTEGER,
    satuan_periode VARCHAR(50),
    hari_kerja_per_minggu INTEGER,
    total_produksi INTEGER,
    rab DECIMAL(15,2),
    biaya_tetap DECIMAL(15,2),
    biaya_variabel DECIMAL(15,2),
    modal_awal DECIMAL(15,2),
    target_pendapatan DECIMAL(15,2),
    jumlah_karyawan INTEGER,
    status VARCHAR(50) DEFAULT 'aktif',
    tanggal_daftar DATE DEFAULT CURRENT_DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE
);

-- Create indexes for better performance
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_warga_nik ON warga(nik);
CREATE INDEX idx_warga_rt_rw ON warga(rt, rw);
CREATE INDEX idx_surat_status ON surat(status);
CREATE INDEX idx_keuangan_jenis ON keuangan(jenis);
CREATE INDEX idx_keuangan_tanggal ON keuangan(tanggal);
CREATE INDEX idx_umkm_status ON umkm(status);
CREATE INDEX idx_umkm_user_id ON umkm(user_id);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_warga_updated_at BEFORE UPDATE ON warga FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_surat_updated_at BEFORE UPDATE ON surat FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_keuangan_updated_at BEFORE UPDATE ON keuangan FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_umkm_updated_at BEFORE UPDATE ON umkm FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
