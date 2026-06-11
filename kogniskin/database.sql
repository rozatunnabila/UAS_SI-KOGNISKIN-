-- ==========================================
-- DATABASE KOGNISKIN - UPDATE LENGKAP
-- Tambahan: kolom photo_url di reviews
--           kolom image_url di products
-- COPY SEMUA INI KE SQL phpMyAdmin, KLIK GO
-- ==========================================

SET FOREIGN_KEY_CHECKS = 0;

DROP DATABASE IF EXISTS kogniskin_db;
CREATE DATABASE kogniskin_db;
USE kogniskin_db;

-- ==========================================
-- TABEL UTAMA
-- ==========================================

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    skin_type VARCHAR(50) DEFAULT NULL,
    issues TEXT DEFAULT NULL,
    skin_quiz_date DATE DEFAULT NULL,
    join_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ingredients (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    best_for TEXT
);

CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    brand VARCHAR(50),
    category VARCHAR(50),
    price VARCHAR(50),
    image_icon VARCHAR(50),
    image_url VARCHAR(500) DEFAULT NULL,   -- ← KOLOM BARU: URL gambar produk
    rating DECIMAL(2,1),
    reviews_count INT DEFAULT 0,
    description TEXT,
    ingredients TEXT,
    skin_types TEXT,
    match_percent INT DEFAULT 80
);

CREATE TABLE product_ingredients (
    product_id INT NOT NULL,
    ingredient_id INT NOT NULL,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (ingredient_id) REFERENCES ingredients(id) ON DELETE CASCADE,
    PRIMARY KEY (product_id, ingredient_id)
);

CREATE TABLE reviews (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    username VARCHAR(50) NOT NULL,
    avatar VARCHAR(50) DEFAULT '#C4785A',
    skin_type VARCHAR(50) DEFAULT NULL,
    issues TEXT DEFAULT NULL,
    product_id INT NOT NULL,
    product_name VARCHAR(100),
    rating INT CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT NOT NULL,
    photo_url LONGTEXT DEFAULT NULL,       -- ← KOLOM BARU: foto base64 atau URL foto
    review_date DATE DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE skin_data (
    id INT AUTO_INCREMENT PRIMARY KEY,
    skin_type VARCHAR(50) UNIQUE NOT NULL,
    total_count INT DEFAULT 0,
    issues_data JSON DEFAULT NULL
);

-- ==========================================
-- DATASET BAHAN AKTIF (INGREDIENTS)
-- ==========================================

INSERT INTO ingredients (id, name, description, best_for) VALUES
(1, 'Niacinamide', 'Mengontrol minyak, mengecilkan pori, mencerahkan', 'Kulit Berminyak, Jerawat, Pori Besar'),
(2, 'Salicylic Acid', 'Membersihkan pori, mengobati jerawat', 'Kulit Berminyak, Jerawat, Komedo'),
(3, 'Hyaluronic Acid', 'Melembapkan, mengunci kelembapan', 'Kulit Kering, Dehidrasi'),
(4, 'Ceramide', 'Memperkuat skin barrier', 'Kulit Kering, Sensitif'),
(5, 'Centella Asiatica', 'Menenangkan, anti-inflamasi', 'Kulit Sensitif, Kemerahan'),
(6, 'AHA', 'Eksfoliasi, mencerahkan', 'Kulit Kombinasi, Kusam'),
(7, 'Retinol', 'Anti-aging, regenerasi sel', 'Kulit Normal, Keriput'),
(8, 'Vitamin C', 'Mencerahkan, antioksidan', 'Kulit Normal, Kusam'),
(9, 'Tea Tree Oil', 'Antibakteri, mengobati jerawat', 'Kulit Berminyak, Jerawat'),
(10, 'Zinc PCA', 'Mengontrol sebum', 'Kulit Berminyak, Jerawat'),
(11, 'Glycerin', 'Melembapkan', 'Kulit Kering, Dehidrasi'),
(12, 'Aloe Vera', 'Menyejukkan, melembapkan', 'Kulit Sensitif, Kemerahan'),
(13, 'Bakuchiol', 'Anti-aging alami', 'Kulit Sensitif, Keriput'),
(14, 'Witch Hazel', 'Mengecilkan pori', 'Kulit Berminyak, Pori Besar'),
(15, 'Peptide', 'Mengencangkan kulit', 'Kulit Normal, Keriput'),
(16, 'Panthenol', 'Melembapkan, memperbaiki kulit', 'Semua Jenis Kulit'),
(17, 'Squalane', 'Melembapkan ringan', 'Kulit Kering, Sensitif'),
(18, 'Green Tea Extract', 'Antioksidan, menenangkan', 'Kulit Berminyak, Sensitif');

-- ==========================================
-- DATASET PRODUK LENGKAP (12 PRODUK)
-- image_url: isi path gambar produkmu, contoh: images/products/serum1.jpg
-- Kalau belum ada gambar, kosongkan saja (NULL) — akan pakai emoji otomatis
-- ==========================================

INSERT INTO products (id, name, brand, category, price, image_icon, image_url, rating, reviews_count, description, ingredients, skin_types, match_percent) VALUES
(1,  'PureGlow Niacinamide Serum',       'KogniSkin', 'serum',       'Rp 89.000',  '🧼', NULL, 4.8, 234, 'Serum dengan Niacinamide untuk kontrol minyak dan mengecilkan pori',          'Niacinamide, Zinc PCA',                    'Kulit Berminyak, Kulit Kombinasi',             94),
(2,  'Ravioli Love Ceramide Cream',      'KogniSkin', 'moisturizer', 'Rp 145.000', '🧴', NULL, 4.9, 178, 'Moisturizer dengan Ceramide untuk kulit kering dan sensitif',                'Ceramide, Hyaluronic Acid, Glycerin',       'Kulit Kering, Kulit Normal, Kulit Sensitif',   96),
(3,  'LavaCrest Salicylic Serum',        'KogniSkin', 'serum',       'Rp 199.000', '✨', NULL, 4.7, 312, 'Serum Salicylic Acid untuk jerawat dan komedo',                              'Salicylic Acid, Niacinamide, Tea Tree Oil', 'Kulit Berminyak, Kulit Kombinasi',             92),
(4,  'Morning Dew Sunscreen',            'KogniSkin', 'sunscreen',   'Rp 125.000', '☀️', NULL, 4.6, 445, 'Sunscreen dengan Vitamin E untuk semua jenis kulit',                         'Vitamin E, Zinc Oxide, Panthenol',          'Semua Jenis Kulit',                            88),
(5,  'Calming Centella Toner',           'KogniSkin', 'toner',       'Rp 79.000',  '💧', NULL, 4.8, 267, 'Toner Centella untuk kulit sensitif dan kemerahan',                          'Centella Asiatica, Aloe Vera, Glycerin',    'Kulit Sensitif, Kulit Kering',                 91),
(6,  'Retinol Renewal Night Serum',      'KogniSkin', 'serum',       'Rp 235.000', '🌟', NULL, 4.5, 189, 'Retinol serum untuk anti-aging dan regenerasi sel',                          'Retinol, Bakuchiol, Peptide',               'Kulit Normal, Kulit Kombinasi',                86),
(7,  'Hydrating Hyaluronic Serum',       'KogniSkin', 'serum',       'Rp 175.000', '💙', NULL, 4.7, 156, 'Hyaluronic Acid serum untuk hidrasi intensif',                               'Hyaluronic Acid, Glycerin, Squalane',       'Kulit Kering, Kulit Normal',                   93),
(8,  'Pore Tightening Witch Hazel Toner','KogniSkin', 'toner',       'Rp 89.000',  '🔵', NULL, 4.4, 98,  'Toner Witch Hazel untuk mengecilkan pori',                                   'Witch Hazel, Niacinamide',                  'Kulit Berminyak, Kulit Kombinasi',             89),
(9,  'Vitamin C Brightening Serum',      'KogniSkin', 'serum',       'Rp 189.000', '🍊', NULL, 4.7, 203, 'Vitamin C serum untuk mencerahkan dan antioksidan',                          'Vitamin C, Hyaluronic Acid, Green Tea Extract', 'Kulit Normal, Kulit Kering',               90),
(10, 'Tea Tree Acne Spot Treatment',     'KogniSkin', 'serum',       'Rp 69.000',  '🌿', NULL, 4.6, 156, 'Tea Tree Oil untuk spot treatment jerawat',                                  'Tea Tree Oil, Salicylic Acid',              'Kulit Berminyak',                              88),
(11, 'AHA Glow Toner',                   'KogniSkin', 'toner',       'Rp 99.000',  '✨', NULL, 4.5, 134, 'AHA toner untuk eksfoliasi dan mencerahkan',                                 'Glycolic Acid, Niacinamide',                'Kulit Kombinasi, Kulit Normal',                87),
(12, 'Barrier Repair Moisturizer',       'KogniSkin', 'moisturizer', 'Rp 159.000', '🛡️', NULL, 4.8, 189, 'Moisturizer dengan Ceramide untuk perbaiki skin barrier',                    'Ceramide, Centella Asiatica, Panthenol',    'Kulit Sensitif, Kulit Kering',                 92);

-- ==========================================
-- CARA MENAMBAH GAMBAR PRODUK:
-- Taruh foto produk di folder: images/products/
-- Lalu update kolom image_url, contoh:
-- UPDATE products SET image_url = 'images/products/niacinamide_serum.jpg' WHERE id = 1;
-- UPDATE products SET image_url = 'images/products/ceramide_cream.jpg' WHERE id = 2;
-- dst...
-- ==========================================

-- ==========================================
-- HUBUNGKAN PRODUK DENGAN BAHAN AKTIF
-- ==========================================

INSERT INTO product_ingredients VALUES
(1,1),(1,10),
(2,4),(2,3),(2,11),
(3,2),(3,1),(3,9),
(4,16),
(5,5),(5,12),(5,11),
(6,7),(6,13),(6,15),
(7,3),(7,11),(7,17),
(8,14),(8,1),
(9,8),(9,3),(9,18),
(10,9),(10,2),
(11,6),(11,1),
(12,4),(12,5),(12,16);

-- ==========================================
-- STATISTIK & DEMO USER
-- ==========================================

INSERT INTO skin_data (skin_type, total_count, issues_data) VALUES
('Kulit Kering',     42, '{"kusam":18,"dehidrasi":28,"iritasi":8}'),
('Kulit Berminyak',  67, '{"jerawat":45,"pori":38,"kilap":55}'),
('Kulit Kombinasi',  89, '{"jerawat":30,"pori":40,"kusam":25}'),
('Kulit Sensitif',   35, '{"kemerahan":28,"iritasi":25,"gatal":15}'),
('Kulit Normal',     14, '{"kusam":5,"dehidrasi":4,"jerawat":3}');

INSERT INTO users (id, username, email, password, join_date) VALUES
(1, 'demo_user', 'demo@kogniskin.com', MD5('password123'), CURDATE());

-- Review demo — photo_url kosong dulu, user nanti bisa tambah via form
INSERT INTO reviews (user_id, username, avatar, skin_type, issues, product_id, product_name, rating, review_text, review_date, photo_url) VALUES
(1, 'Sarah M',    '#C4785A', 'Kulit Kombinasi', 'Jerawat,Pori Besar', 3,  'LavaCrest Salicylic Serum',      5, 'Setelah 2 minggu pakai, pori-pori mengecil dan jerawat berkurang drastis!',              CURDATE(), NULL),
(1, 'Jessica W',  '#7C9A7E', 'Kulit Kering',    'Kusam,Dehidrasi',    2,  'Ravioli Love Ceramide Cream',    5, 'Moisturizer terbaik untuk kulit kering! Lembab sepanjang hari tanpa lengket.',          CURDATE(), NULL),
(1, 'Amanda K',   '#C9A96E', 'Kulit Berminyak', 'Jerawat,Berminyak',  1,  'PureGlow Niacinamide Serum',     5, 'Niacinamide serum ini membantu kontrol minyak dan mengecilkan pori!',                  CURDATE(), NULL),
(1, 'Rania A',    '#A598C4', 'Kulit Sensitif',  'Kemerahan,Iritasi',  5,  'Calming Centella Toner',         5, 'Toner ini sangat menenangkan! Kulitku yang sensitif jadi tidak mudah merah.',           CURDATE(), NULL),
(1, 'Mega D',     '#5A7AC4', 'Kulit Normal',    'Kusam',              9,  'Vitamin C Brightening Serum',    4, 'Wajah jadi lebih cerah dan glowing setelah pakai serum ini!',                          CURDATE(), NULL);

SET FOREIGN_KEY_CHECKS = 1;

SELECT '✅ DATABASE BERHASIL DIBUAT!' AS Status;
SELECT COUNT(*) AS Total_Ingredients FROM ingredients;
SELECT COUNT(*) AS Total_Products FROM products;
SELECT COUNT(*) AS Total_Reviews FROM reviews;