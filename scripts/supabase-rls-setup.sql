-- =============================================
-- SETUP ROW LEVEL SECURITY (RLS) POLICIES
-- =============================================

-- DISABLE RLS untuk development (bisa diaktifkan nanti untuk production)
-- Jika Anda ingin keamanan lebih ketat, uncomment bagian RLS di bawah

ALTER TABLE users DISABLE ROW LEVEL SECURITY;
ALTER TABLE umkm DISABLE ROW LEVEL SECURITY;
ALTER TABLE warga DISABLE ROW LEVEL SECURITY;
ALTER TABLE keuangan DISABLE ROW LEVEL SECURITY;
ALTER TABLE surat DISABLE ROW LEVEL SECURITY;

-- UNTUK DEVELOPMENT: DISABLE RLS (lebih mudah untuk testing)
-- ALTER TABLE users DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE umkm DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE warga DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE keuangan DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE surat DISABLE ROW LEVEL SECURITY;

-- Grant permissions to authenticated users
GRANT ALL ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO authenticated;

-- Grant permissions to anon users (for login)
GRANT SELECT ON users TO anon;

-- Jika ingin mengaktifkan RLS nanti, uncomment baris di bawah:
-- ALTER TABLE users ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE umkm ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE warga ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE keuangan ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE surat ENABLE ROW LEVEL SECURITY;

-- Contoh RLS policies (untuk nanti jika diperlukan):
-- CREATE POLICY "Users can view own data" ON users FOR SELECT USING (auth.uid() = id);
-- CREATE POLICY "Admins can view all data" ON users FOR ALL USING (
--   EXISTS (
--     SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
--   )
-- );

-- =============================================
-- JIKA INGIN MENGAKTIFKAN RLS NANTI (UNTUK PRODUCTION)
-- Uncomment script di bawah ini:
-- =============================================

/*
-- Enable RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE umkm ENABLE ROW LEVEL SECURITY;
ALTER TABLE warga ENABLE ROW LEVEL SECURITY;
ALTER TABLE keuangan ENABLE ROW LEVEL SECURITY;
ALTER TABLE surat ENABLE ROW LEVEL SECURITY;

-- Policy untuk users table
CREATE POLICY "Users can view all users" ON users FOR SELECT USING (true);
CREATE POLICY "Users can insert users" ON users FOR INSERT WITH CHECK (true);
CREATE POLICY "Users can update users" ON users FOR UPDATE USING (true);
CREATE POLICY "Users can delete users" ON users FOR DELETE USING (true);

-- Policy untuk umkm table
CREATE POLICY "Users can view all umkm" ON umkm FOR SELECT USING (true);
CREATE POLICY "Users can insert umkm" ON umkm FOR INSERT WITH CHECK (true);
CREATE POLICY "Users can update umkm" ON umkm FOR UPDATE USING (true);
CREATE POLICY "Users can delete umkm" ON umkm FOR DELETE USING (true);

-- Policy untuk warga table
CREATE POLICY "Users can view all warga" ON warga FOR SELECT USING (true);
CREATE POLICY "Users can insert warga" ON warga FOR INSERT WITH CHECK (true);
CREATE POLICY "Users can update warga" ON warga FOR UPDATE USING (true);
CREATE POLICY "Users can delete warga" ON warga FOR DELETE USING (true);

-- Policy untuk keuangan table
CREATE POLICY "Users can view all keuangan" ON keuangan FOR SELECT USING (true);
CREATE POLICY "Users can insert keuangan" ON keuangan FOR INSERT WITH CHECK (true);
CREATE POLICY "Users can update keuangan" ON keuangan FOR UPDATE USING (true);
CREATE POLICY "Users can delete keuangan" ON keuangan FOR DELETE USING (true);

-- Policy untuk surat table
CREATE POLICY "Users can view all surat" ON surat FOR SELECT USING (true);
CREATE POLICY "Users can insert surat" ON surat FOR INSERT WITH CHECK (true);
CREATE POLICY "Users can update surat" ON surat FOR UPDATE USING (true);
CREATE POLICY "Users can delete surat" ON surat FOR DELETE USING (true);
*/
