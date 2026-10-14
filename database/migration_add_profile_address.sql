-- Run once on an existing muangay_db database.
USE muangay_db;

ALTER TABLE users
    ADD COLUMN province VARCHAR(100) NULL,
    ADD COLUMN ward VARCHAR(150) NULL,
    ADD COLUMN address_detail VARCHAR(255) NULL;
