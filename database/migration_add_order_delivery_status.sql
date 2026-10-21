-- Migration: Thêm các cột quản lý trạng thái giao nhận và tích hợp GHN Demo cho bảng orders
USE muangay_db;

-- 1. Thêm cột delivery_method nếu chưa có
SET @add_col = IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'orders' AND COLUMN_NAME = 'delivery_method') = 0,
    'ALTER TABLE orders ADD COLUMN delivery_method TINYINT NOT NULL DEFAULT 1 AFTER deposit_amount',
    'SELECT ''delivery_method already exists'''
);
PREPARE stmt FROM @add_col;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 2. Thêm cột seller_confirmed (Người bán xác nhận đã giao hàng)
SET @add_col = IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'orders' AND COLUMN_NAME = 'seller_confirmed') = 0,
    'ALTER TABLE orders ADD COLUMN seller_confirmed BOOLEAN DEFAULT FALSE AFTER status',
    'SELECT ''seller_confirmed already exists'''
);
PREPARE stmt FROM @add_col;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 3. Thêm cột buyer_confirmed (Người mua xác nhận đã nhận hàng)
SET @add_col = IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'orders' AND COLUMN_NAME = 'buyer_confirmed') = 0,
    'ALTER TABLE orders ADD COLUMN buyer_confirmed BOOLEAN DEFAULT FALSE AFTER seller_confirmed',
    'SELECT ''buyer_confirmed already exists'''
);
PREPARE stmt FROM @add_col;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 4. Thêm cột thời gian xác nhận
SET @add_col = IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'orders' AND COLUMN_NAME = 'seller_confirmed_at') = 0,
    'ALTER TABLE orders ADD COLUMN seller_confirmed_at TIMESTAMP NULL AFTER buyer_confirmed',
    'SELECT ''seller_confirmed_at already exists'''
);
PREPARE stmt FROM @add_col;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @add_col = IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'orders' AND COLUMN_NAME = 'buyer_confirmed_at') = 0,
    'ALTER TABLE orders ADD COLUMN buyer_confirmed_at TIMESTAMP NULL AFTER seller_confirmed_at',
    'SELECT ''buyer_confirmed_at already exists'''
);
PREPARE stmt FROM @add_col;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 5. Thêm các cột phục vụ đơn vị vận chuyển bên thứ 3 (GHN Demo)
SET @add_col = IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'orders' AND COLUMN_NAME = 'tracking_code') = 0,
    'ALTER TABLE orders ADD COLUMN tracking_code VARCHAR(50) NULL AFTER buyer_confirmed_at',
    'SELECT ''tracking_code already exists'''
);
PREPARE stmt FROM @add_col;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @add_col = IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'orders' AND COLUMN_NAME = 'shipping_provider') = 0,
    'ALTER TABLE orders ADD COLUMN shipping_provider VARCHAR(50) DEFAULT ''GHN'' AFTER tracking_code',
    'SELECT ''shipping_provider already exists'''
);
PREPARE stmt FROM @add_col;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @add_col = IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'orders' AND COLUMN_NAME = 'shipping_status') = 0,
    'ALTER TABLE orders ADD COLUMN shipping_status VARCHAR(50) DEFAULT NULL AFTER shipping_provider',
    'SELECT ''shipping_status already exists'''
);
PREPARE stmt FROM @add_col;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @add_col = IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'orders' AND COLUMN_NAME = 'shipping_note') = 0,
    'ALTER TABLE orders ADD COLUMN shipping_note TEXT NULL AFTER shipping_status',
    'SELECT ''shipping_note already exists'''
);
PREPARE stmt FROM @add_col;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 6. Đồng bộ delivery_method từ products sang orders cho các đơn đã tạo
UPDATE orders o
JOIN products p ON o.product_id = p.id
SET o.delivery_method = COALESCE(p.delivery_method, 1);
