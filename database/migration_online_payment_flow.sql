-- Migration idempotent cho database hiện có. Chọn đúng database trước khi chạy.
USE muangay_db;

CREATE TABLE IF NOT EXISTS vnpay_payments (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  txn_ref VARCHAR(64) NOT NULL UNIQUE,
  conversation_id INT NOT NULL,
  buyer_id INT NOT NULL,
  seller_id INT NOT NULL,
  product_id INT NOT NULL,
  agreed_price DECIMAL(15,2) NOT NULL,
  deposit_amount DECIMAL(15,2) NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
  vnp_transaction_no VARCHAR(100) NULL,
  response_code VARCHAR(10) NULL,
  order_id INT NULL,
  expires_at TIMESTAMP NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  paid_at TIMESTAMP NULL,
  INDEX idx_vnpay_payments_conversation (conversation_id),
  INDEX idx_vnpay_payments_status_expiry (status, expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


SET @ddl = IF((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='orders' AND column_name='total_paid')=0,
  'ALTER TABLE orders ADD COLUMN total_paid DECIMAL(15,2) NOT NULL DEFAULT 0', 'SELECT 1');
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @ddl = IF((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='orders' AND column_name='balance_payment_method')=0,
  'ALTER TABLE orders ADD COLUMN balance_payment_method VARCHAR(20) NOT NULL DEFAULT ''PENDING''', 'SELECT 1');
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @ddl = IF((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='orders' AND column_name='balance_expires_at')=0,
  'ALTER TABLE orders ADD COLUMN balance_expires_at TIMESTAMP NULL', 'SELECT 1');
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @ddl = IF((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='orders' AND column_name='balance_paid_at')=0,
  'ALTER TABLE orders ADD COLUMN balance_paid_at TIMESTAMP NULL', 'SELECT 1');
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @ddl = IF((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='vnpay_payments' AND column_name='payment_type')=0,
  'ALTER TABLE vnpay_payments ADD COLUMN payment_type VARCHAR(20) NOT NULL DEFAULT ''DEPOSIT'' AFTER deposit_amount', 'SELECT 1');
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

UPDATE orders SET total_paid=deposit_amount WHERE total_paid=0 AND deposit_amount>0;


SET @ddl = IF((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='orders' AND column_name='payment_status')=0,
  'ALTER TABLE orders ADD COLUMN payment_status VARCHAR(20) NOT NULL DEFAULT ''UNPAID''', 'SELECT 1');
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

UPDATE orders SET payment_status=CASE WHEN total_paid>=agreed_price THEN 'PAID' WHEN total_paid>0 THEN 'PARTIALLY_PAID' ELSE 'UNPAID' END WHERE payment_status='UNPAID' AND total_paid>0;
