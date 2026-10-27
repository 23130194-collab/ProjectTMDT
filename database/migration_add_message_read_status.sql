ALTER TABLE messages
    ADD COLUMN read_at TIMESTAMP NULL DEFAULT NULL;

-- Tin nhắn đã tồn tại được xem là đã đọc; các tin mới sẽ bắt đầu ở trạng thái chưa đọc.
UPDATE messages
SET read_at = created_at
WHERE read_at IS NULL;
