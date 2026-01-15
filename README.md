# 🐰 DompetKu

**DompetKu** adalah aplikasi pencatat keuangan pribadi yang dirancang dengan tampilan modern, sederhana, dan feminin. Aplikasi ini membantu pengguna melacak pemasukan dan pengeluaran sehari-hari dengan mudah, aman, dan menyenangkan.

![Logo DompetKu](assets/images/logo.png)

## 🌟 Fitur Utama

- **Pencatatan Mudah**: Catat pemasukan dan pengeluaran hanya dengan beberapa ketukan.
- **Keamanan PIN**: Data dilindungi dengan PIN 6 digit dan enkripsi.
- **Profil Personal**: Sapaan hangat dengan nama dan foto profil Anda sendiri.
- **Laporan Visual**: Grafik dan statistik yang mudah dipahami.
- **Manajemen Kategori**: Buat dan atur kategori sendiri sesuai kebutuhan.
- **Offline First**: Data tersimpan lokal di HP, tidak butuh internet.

---

## 📱 Panduan Menu & Navigasi

Aplikasi ini terdiri dari 4 menu utama di bagian bawah layar:

### 1. 🏠 Dashboard

Halaman utama yang menyajikan ringkasan cepat keuangan Anda.

- **Sapaan Personal**: Menampilkan nama dan foto profil Anda.
- **Kartu Saldo**: Menampilkan total saldo saat ini.
- **Akses Cepat**: Tombol "+" dan "-" untuk mencatat Pemasukan atau Pengeluaran baru.
- **Ringkasan Bulan Ini**: Total uang masuk dan keluar bulan ini.
- **Top Kategori**: Kategori dengan pengeluaran terbesar bulan ini.
- **Transaksi Terakhir**: Daftar log transaksi terbaru.

### 2. 🕒 Riwayat (History)

Daftar lengkap semua transaksi yang pernah Anda catat.

- **Filter Bulan**: Lihat riwayat transaksi bulan-bulan sebelumnya.
- **Hapus Transaksi**: Geser atau tekan ikon hapus jika ada kesalahan catat.

### 3. 📊 Laporan (Reports)

Analisis mendalam tentang keuangan Anda.

- **Pilih Periode**: Lihat laporan berdasarkan Bulan dan Tahun tertentu.
- **Grafik Lingkaran (Pie Chart)**: Visualisasi persentase pengeluaran/pemasukan.
- **Detail Kategori**: Daftar kategori diurutkan dari nominal terbesar ke terkecil, memudahkan Anda melihat pos pengeluaran terbesar.

### 4. ⚙️ Pengaturan (Settings)

Pusat kontrol aplikasi.

- **Akun**:
  - **Atur Profil**: Ubah nama panggilan dan foto profil Anda.
- **Kategori**:
  - **Kelola Kategori**: Tambah, Edit, atau Hapus kategori Pemasukan/Pengeluaran sesuai gaya hidup Anda.
- **Data**:
  - **Reset Data**: Menghapus semua transaksi (Hati-hati! Tidak bisa dibatalkan).
- **Keamanan**:
  - **PIN**: Aktifkan/Nonaktifkan PIN atau Ganti PIN.

---

## 🔒 Keamanan & Privasi

- **Keamanan PIN**: Menggunakan algoritma hashing SHA-256 untuk mengamankan akses aplikasi. Jika salah memasukkan PIN 3 kali, aplikasi akan terkunci selama 5 menit.
- **Penyimpanan Lokal**: Semua data keuangan tersimpan aman di dalam memori handphone Anda menggunakan database SQLite. Tidak ada data yang dikirim ke server internet (Kecuali Anda mem-backup manual file data).

---

## 🛠️ Informasi Teknis

- **Versi Aplikasi**: 1.0.0
- **Framework**: Flutter
- **Database**: SQLite (sqflite)
- **Minimum Android**: Android 5.0 (Lollipop)

---


