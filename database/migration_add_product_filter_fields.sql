-- Run once on an existing database before deploying the category/free-gift filters.
-- delivery_method is added only when it is not already present.
SET @add_delivery_method = IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'products' AND COLUMN_NAME = 'delivery_method') = 0,
    'ALTER TABLE products ADD COLUMN delivery_method TINYINT NOT NULL DEFAULT 1',
    'SELECT ''delivery_method already exists'''
);
PREPARE stmt FROM @add_delivery_method;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @add_deal_type = IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'products' AND COLUMN_NAME = 'deal_type') = 0,
    'ALTER TABLE products ADD COLUMN deal_type ENUM(''SELL'', ''GIVE'') NOT NULL DEFAULT ''SELL''',
    'SELECT ''deal_type already exists'''
);
PREPARE stmt FROM @add_deal_type;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
