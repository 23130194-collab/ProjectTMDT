-- Run once on an existing database to store searchable address components.
-- Keep `location` for displaying legacy listings that have not been re-saved.
ALTER TABLE products
    ADD COLUMN province VARCHAR(100) NULL AFTER location,
    ADD COLUMN ward VARCHAR(150) NULL AFTER province,
    ADD COLUMN address_detail VARCHAR(255) NULL AFTER ward,
    ADD INDEX idx_products_province_ward (province, ward);

-- Older listings were written as `address detail, district, province`.
-- Split that known format from the right so old records can participate in filters.
UPDATE products
SET province = TRIM(SUBSTRING_INDEX(location, ', ', -1)),
    ward = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(location, ', ', -2), ', ', 1)),
    address_detail = NULLIF(TRIM(SUBSTRING(location, 1,
        LENGTH(location) - LENGTH(SUBSTRING_INDEX(location, ', ', -2)) - 2)), '')
WHERE location LIKE '%, %, %';

-- For legacy values with only two parts, retain the first part as the area and
-- the last part as the province. Single-part values are treated as province names.
UPDATE products
SET province = TRIM(SUBSTRING_INDEX(location, ', ', -1)),
    ward = TRIM(SUBSTRING_INDEX(location, ', ', 1))
WHERE location LIKE '%, %' AND location NOT LIKE '%, %, %';

UPDATE products
SET province = TRIM(location)
WHERE location IS NOT NULL AND TRIM(location) <> '' AND location NOT LIKE '%, %';
