-- Migration: Thêm cột specifications cho bảng products và đồng bộ 4 danh mục
USE muangay_db;

-- 1. Thêm cột specifications (JSON) lưu các thông số kỹ thuật động theo từng danh mục
ALTER TABLE products ADD COLUMN specifications JSON NULL AFTER condition_status;

-- 2. Đảm bảo 4 danh mục chuẩn khớp với giao diện trang chủ và đăng tin
INSERT INTO categories (id, name, icon) VALUES 
(1, 'Điện Tử & Thiết Bị Số', 'fa-laptop'),
(2, 'Xe Cộ & Phương Tiện', 'fa-motorcycle'),
(3, 'Điện Lạnh & Gia Dụng', 'fa-snowflake'),
(4, 'Nội Thất & Đồ Gia Đình', 'fa-couch')
ON DUPLICATE KEY UPDATE name = VALUES(name), icon = VALUES(icon);
