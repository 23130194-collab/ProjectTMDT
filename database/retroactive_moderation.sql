-- ============================================================
-- Retroactive moderation: tự động REJECT các bài cũ vi phạm
-- Chạy trong MySQL Workbench / phpMyAdmin / HeidiSQL
-- ============================================================

-- 1. Xem trước: liệt kê các bài có tiêu đề chứa từ khóa cấm
SELECT p.id, p.title, p.status, p.created_at
FROM products p
WHERE p.status = 'ACTIVE'
  AND (
    LOWER(p.title) LIKE '%ma túy%' OR LOWER(p.title) LIKE '%cần sa%'
    OR LOWER(p.title) LIKE '%heroin%' OR LOWER(p.title) LIKE '%vũ khí%'
    OR LOWER(p.title) LIKE '%súng%'   OR LOWER(p.title) LIKE '%đạn%'
    OR LOWER(p.title) LIKE '%chất nổ%' OR LOWER(p.title) LIKE '%hàng giả%'
    OR LOWER(p.title) LIKE '%hàng nhái%' OR LOWER(p.title) LIKE '%đánh bạc%'
    OR LOWER(p.title) LIKE '%cờ bạc%' OR LOWER(p.title) LIKE '%mại dâm%'
    OR LOWER(p.title) LIKE '%khiêu dâm%' OR LOWER(p.title) LIKE '%chửi tây%'
    OR LOWER(p.title) LIKE '%đ.m%'    OR LOWER(p.title) LIKE '%d.m%'
    OR LOWER(p.title) LIKE '% cc %'   OR p.title = 'cc'
    OR LOWER(p.description) LIKE '%ma túy%' OR LOWER(p.description) LIKE '%heroin%'
    OR LOWER(p.description) LIKE '%vũ khí%' OR LOWER(p.description) LIKE '%mại dâm%'
  );

-- 2. Thực thi: đổi trạng thái sang REJECTED
UPDATE products p
SET p.status = 'REJECTED'
WHERE p.status IN ('ACTIVE', 'PENDING')
  AND (
    LOWER(p.title) LIKE '%ma túy%' OR LOWER(p.title) LIKE '%cần sa%'
    OR LOWER(p.title) LIKE '%heroin%' OR LOWER(p.title) LIKE '%vũ khí%'
    OR LOWER(p.title) LIKE '%súng%'   OR LOWER(p.title) LIKE '%đạn%'
    OR LOWER(p.title) LIKE '%chất nổ%' OR LOWER(p.title) LIKE '%hàng giả%'
    OR LOWER(p.title) LIKE '%hàng nhái%' OR LOWER(p.title) LIKE '%đánh bạc%'
    OR LOWER(p.title) LIKE '%cờ bạc%' OR LOWER(p.title) LIKE '%mại dâm%'
    OR LOWER(p.title) LIKE '%khiêu dâm%' OR LOWER(p.title) LIKE '%đ.m%'
    OR LOWER(p.title) LIKE '% cc %'   OR p.title = 'cc'
    OR LOWER(p.description) LIKE '%ma túy%' OR LOWER(p.description) LIKE '%heroin%'
    OR LOWER(p.description) LIKE '%vũ khí%' OR LOWER(p.description) LIKE '%mại dâm%'
  );

-- 3. Xác nhận kết quả
SELECT status, COUNT(*) as total FROM products GROUP BY status;
