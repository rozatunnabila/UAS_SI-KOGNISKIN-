Anggota Kelompok:
1. Almira Sadida = 2408107010004
2. Kania
3. Rozatun Nabila = 2408107010010

# COGNISKIN

## Sistem Analisis Kondisi Kulit dan Rekomendasi Skincare

COGNISKIN adalah aplikasi berbasis web yang membantu pengguna memahami kondisi kulit melalui analisis wajah serta memberikan rekomendasi produk skincare yang sesuai dengan kebutuhan kulit masing-masing.

---

## Fitur Utama

### 🔍 Analisis Kulit
Melakukan scan wajah untuk membantu mengidentifikasi kondisi kulit pengguna.

### 🧴 Rekomendasi Skincare
Memberikan rekomendasi produk skincare berdasarkan hasil analisis kulit.

### 🧪 Analisis Ingredients
Menampilkan informasi kandungan skincare yang sesuai maupun yang perlu dihindari berdasarkan kondisi kulit.

### 📚 Informasi dan Tips Skincare
Menyediakan berbagai informasi dan edukasi mengenai perawatan kulit.

### 👤 Profil Pengguna
Mengelola data akun dan riwayat penggunaan sistem.

### ⭐ Testimoni
Memberikan dan melihat ulasan dari pengguna lain.

---

## Teknologi yang Digunakan

- HTML
- CSS
- JavaScript
- PHP
- MySQL

---

## Struktur Project

```text
kogniskin/
│
├── .vscode/
├── Scan_Wajah/
│   └── dataset/
├── images/
├── api.php
├── config.php
├── database.sql
└── index.html
```

---

## Database

Database digunakan untuk menyimpan data:

- Pengguna
- Hasil analisis kulit
- Data ingredient skincare
- Produk skincare
- Rekomendasi skincare
- Informasi dan tips
- Testimoni pengguna

File database tersedia pada:

```text
database.sql
```

---

## Metode Pengembangan

Metode pengembangan yang digunakan adalah **Waterfall (Traditional Systems Life Cycle)** yang terdiri dari:

1. Analisis Kebutuhan
2. Perancangan Sistem
3. Implementasi
4. Pengujian
5. Pemeliharaan

---

## Cara Menjalankan Project

### Clone Repository

```bash
git clone https://github.com/username/kogniskin.git
```

### Import Database

Import file berikut ke MySQL:

```text
database.sql
```

### Konfigurasi Database

Sesuaikan konfigurasi koneksi database pada file:

```php
config.php
```

### Jalankan Aplikasi

Gunakan web server seperti:

- XAMPP
- Laragon
- Apache + MySQL

Kemudian buka:

```text
http://localhost/kogniskin
```

---

## Preview

COGNISKIN membantu pengguna mengenali kondisi kulit, memahami kandungan skincare, serta memperoleh rekomendasi produk yang lebih personal berdasarkan hasil analisis wajah.
