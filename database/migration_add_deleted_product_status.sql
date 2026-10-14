-- Chay mot lan trong Navicat tren database muangay_db.
-- Them trang thai DELETE de xoa mem tin dang, giu lai ban ghi trong products.
USE muangay_db;

ALTER TABLE products
MODIFY COLUMN status ENUM('PENDING', 'ACTIVE', 'SOLD', 'HIDDEN', 'REJECTED', 'DELETE') DEFAULT 'PENDING';
