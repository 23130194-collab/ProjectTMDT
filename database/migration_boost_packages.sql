-- ==============================================================================
-- Migration: Gói đẩy tin (Bump), Ghim tin VIP & Ví lượt đẩy chung cho MuaNgay
-- Ngày cập nhật: 2026-10-26
-- Hướng dẫn: Chạy script này trên MySQL / phpMyAdmin trong database `muangay_db`.
-- ==============================================================================

USE muangay_db;

-- ------------------------------------------------------------------------------
-- 1. Bảng định nghĩa các gói đẩy tin & ghim tin VIP do Admin quản lý
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS boost_packages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    package_type ENUM('BUMP', 'VIP_PIN') NOT NULL,
    price DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    duration_days INT NOT NULL DEFAULT 0,          -- Số ngày ghim VIP (0 nếu là gói BUMP)
    bump_count INT NOT NULL DEFAULT 0,             -- Số lượt đẩy tin (0 nếu là gói VIP_PIN)
    priority_level INT NOT NULL DEFAULT 1,         -- 0: thường, 1: Nổi bật, 2: VIP Kim cương
    badge_label VARCHAR(50) DEFAULT 'VIP',
    badge_color VARCHAR(50) DEFAULT 'amber',      -- amber, purple, blue, emerald, red
    description TEXT,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    sort_order INT NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------------------------
-- 2. Bảng theo dõi lịch sử và kích hoạt gói (gắn với bài đăng hoặc nạp ví chung)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS product_boosts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NULL,                           -- NULL nếu là giao dịch nạp vào Ví Lượt Đẩy chung
    user_id INT NOT NULL,
    package_id INT NOT NULL,
    package_type ENUM('BUMP', 'VIP_PIN') NOT NULL,
    amount_paid DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    start_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    end_time TIMESTAMP NULL,
    remaining_bumps INT NOT NULL DEFAULT 0,
    vnp_txn_ref VARCHAR(100) NULL,
    status ENUM('ACTIVE', 'EXPIRED', 'COMPLETED') DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    KEY idx_pb_product (product_id),
    KEY idx_pb_user (user_id),
    KEY idx_pb_package (package_id),
    KEY idx_pb_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Đảm bảo trường product_id cho phép NULL nếu bảng đã tồn tại từ phiên bản trước
ALTER TABLE product_boosts MODIFY product_id INT NULL;

-- ------------------------------------------------------------------------------
-- 3. Bổ sung trường `bump_credits` vào bảng `users` (Quản lý Ví Lượt Đẩy Chung)
-- ------------------------------------------------------------------------------
SET @dbname = DATABASE();
SET @tablename = "users";
SET @columnname = "bump_credits";
SET @preparedStatement = (SELECT IF(
  (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = @dbname AND TABLE_NAME = @tablename AND COLUMN_NAME = @columnname) > 0,
  "SELECT 1",
  "ALTER TABLE users ADD COLUMN bump_credits INT NOT NULL DEFAULT 0;"
));
PREPARE stmt FROM @preparedStatement;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ------------------------------------------------------------------------------
-- 4. Bổ sung các trường vào bảng `products` để tối ưu hóa truy vấn hiển thị & xếp hạng
-- ------------------------------------------------------------------------------
SET @tablename = "products";

-- Thêm is_pinned nếu chưa có
SET @columnname = "is_pinned";
SET @preparedStatement = (SELECT IF(
  (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = @dbname AND TABLE_NAME = @tablename AND COLUMN_NAME = @columnname) > 0,
  "SELECT 1",
  "ALTER TABLE products ADD COLUMN is_pinned TINYINT(1) NOT NULL DEFAULT 0;"
));
PREPARE stmt FROM @preparedStatement;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Thêm pinned_until nếu chưa có
SET @columnname = "pinned_until";
SET @preparedStatement = (SELECT IF(
  (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = @dbname AND TABLE_NAME = @tablename AND COLUMN_NAME = @columnname) > 0,
  "SELECT 1",
  "ALTER TABLE products ADD COLUMN pinned_until TIMESTAMP NULL;"
));
PREPARE stmt FROM @preparedStatement;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Thêm priority_level nếu chưa có
SET @columnname = "priority_level";
SET @preparedStatement = (SELECT IF(
  (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = @dbname AND TABLE_NAME = @tablename AND COLUMN_NAME = @columnname) > 0,
  "SELECT 1",
  "ALTER TABLE products ADD COLUMN priority_level INT NOT NULL DEFAULT 0;"
));
PREPARE stmt FROM @preparedStatement;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Thêm bumped_at nếu chưa có
SET @columnname = "bumped_at";
SET @preparedStatement = (SELECT IF(
  (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = @dbname AND TABLE_NAME = @tablename AND COLUMN_NAME = @columnname) > 0,
  "SELECT 1",
  "ALTER TABLE products ADD COLUMN bumped_at TIMESTAMP NULL;"
));
PREPARE stmt FROM @preparedStatement;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Thêm remaining_bumps nếu chưa có
SET @columnname = "remaining_bumps";
SET @preparedStatement = (SELECT IF(
  (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = @dbname AND TABLE_NAME = @tablename AND COLUMN_NAME = @columnname) > 0,
  "SELECT 1",
  "ALTER TABLE products ADD COLUMN remaining_bumps INT NOT NULL DEFAULT 0;"
));
PREPARE stmt FROM @preparedStatement;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ------------------------------------------------------------------------------
-- 5. Khởi tạo dữ liệu các gói Đẩy Tin (BUMP) và Ghim VIP (VIP_PIN) mặc định
-- ------------------------------------------------------------------------------
INSERT INTO boost_packages (id, name, package_type, price, duration_days, bump_count, priority_level, badge_label, badge_color, description, is_active, sort_order)
VALUES
(1, 'Đẩy Tin Nhanh (1 Lượt)', 'BUMP', 5000.00, 0, 1, 0, 'ĐẨY TIN', 'blue', 'Đưa tin đăng lên đầu danh mục ngay lập tức như bài vừa đăng.', 1, 1),
(2, 'Combo Đẩy Tin (5 Lượt)', 'BUMP', 20000.00, 0, 5, 0, 'COMBO 5 BUMP', 'emerald', 'Tiết kiệm 20%. Bạn có 5 lượt đẩy tin tùy ý bất kỳ lúc nào để đón đầu khung giờ vàng.', 1, 2),
(3, 'Gói VIP Nổi Bật (3 Ngày)', 'VIP_PIN', 30000.00, 3, 0, 1, '⭐ NỔI BẬT', 'amber', 'Ghim cố định ở đầu trang chủ & danh mục trong 3 ngày. Viền nổi bật thu hút lượt xem tối đa.', 1, 3),
(4, 'Gói VIP Kim Cương (7 Ngày)', 'VIP_PIN', 60000.00, 7, 0, 2, '👑 VIP KIM CƯƠNG', 'purple', 'Vị trí ưu tiên cao nhất trong 7 ngày, huy hiệu VIP sang trọng, tăng gấp 5 lần lượt tiếp cận.', 1, 4),
(5, 'Combo Tiết Kiệm (15 Lượt)', 'BUMP', 50000.00, 0, 15, 0, 'COMBO 15 BUMP', 'purple', 'Tiết kiệm 33%. 15 lượt đẩy sẵn trong ví tài khoản, đẩy tin thả ga đón mọi khung giờ vàng.', 1, 5)
ON DUPLICATE KEY UPDATE 
    name = VALUES(name), 
    price = VALUES(price), 
    duration_days = VALUES(duration_days),
    bump_count = VALUES(bump_count),
    priority_level = VALUES(priority_level),
    badge_label = VALUES(badge_label),
    badge_color = VALUES(badge_color),
    description = VALUES(description),
    is_active = VALUES(is_active),
    sort_order = VALUES(sort_order);

-- ------------------------------------------------------------------------------
-- 6. Ghi chú thuật toán sắp xếp hiển thị trên website (Đã tích hợp trong ProductDAO.java)
-- ------------------------------------------------------------------------------
-- Quy tắc sắp xếp công bằng (Fair Rotation):
-- 1. Ưu tiên 1: Tin VIP còn hạn (is_pinned = 1 AND pinned_until > NOW()) DESC
-- 2. Ưu tiên 2: Cấp VIP cao hơn đứng trước: Kim Cương (priority_level = 2) > Nổi Bật (priority_level = 1)
-- 3. Ưu tiên 3: CƠ CHẾ XOAY VÒNG CÔNG BẰNG: Nếu cùng cấp VIP, xoay vòng ngẫu nhiên RAND() mỗi lượt tải trang để chia đều lượt hiển thị (Impression).
-- 4. Ưu tiên 4: Tin thường & Tin vừa bấm Đẩy: Sắp xếp theo COALESCE(bumped_at, created_at) DESC (Ai vừa đẩy/đăng gần nhất thì đứng trước).
-- 5. Ưu tiên 5: id DESC
--
-- Ví dụ câu truy vấn chuẩn:
-- SELECT p.*, pi.image_url FROM products p
-- LEFT JOIN product_images pi ON p.id = pi.product_id AND pi.is_primary = 1
-- WHERE p.status = 'ACTIVE'
-- ORDER BY 
--     (p.is_pinned = 1 AND p.pinned_until > NOW()) DESC,
--     p.priority_level DESC,
--     CASE WHEN (p.is_pinned = 1 AND p.pinned_until > NOW()) THEN RAND() ELSE 0 END,
--     COALESCE(p.bumped_at, p.created_at) DESC,
--     p.id DESC;

