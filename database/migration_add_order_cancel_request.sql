-- Migration: Them cac cot quan ly yeu cau huy don thoa thuan (Kich ban A) cho bang orders
USE muangay_db;

SET @add_col = IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'orders' AND COLUMN_NAME = 'cancel_requested') = 0,
    'ALTER TABLE orders ADD COLUMN cancel_requested BOOLEAN DEFAULT FALSE AFTER status',
    'SELECT ''cancel_requested already exists'''
);
PREPARE stmt FROM @add_col;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @add_col = IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'orders' AND COLUMN_NAME = 'cancel_reason') = 0,
    'ALTER TABLE orders ADD COLUMN cancel_reason VARCHAR(255) NULL AFTER cancel_requested',
    'SELECT ''cancel_reason already exists'''
);
PREPARE stmt FROM @add_col;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @add_col = IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'orders' AND COLUMN_NAME = 'cancel_requested_at') = 0,
    'ALTER TABLE orders ADD COLUMN cancel_requested_at TIMESTAMP NULL AFTER cancel_reason',
    'SELECT ''cancel_requested_at already exists'''
);
PREPARE stmt FROM @add_col;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
