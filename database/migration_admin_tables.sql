-- Migration: Thêm bảng banned_keywords và reports cho chức năng Admin
-- Chạy file này một lần trên database muangay_db

USE muangay_db;

-- Bảng từ khóa cấm (cho chức năng kiểm duyệt tự động)
CREATE TABLE IF NOT EXISTS banned_keywords (
    id INT AUTO_INCREMENT PRIMARY KEY,
    keyword VARCHAR(500) NOT NULL,
    is_regex BOOLEAN DEFAULT FALSE,
    description VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng báo cáo vi phạm từ người dùng
CREATE TABLE IF NOT EXISTS reports (
    id INT AUTO_INCREMENT PRIMARY KEY,
    reporter_id INT NOT NULL,
    product_id INT NOT NULL,
    reason VARCHAR(500) NOT NULL,
    status ENUM('PENDING','RESOLVED','IGNORED') DEFAULT 'PENDING',
    admin_note VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (reporter_id) REFERENCES users(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- Dữ liệu mẫu từ khóa cấm
INSERT INTO banned_keywords (keyword, is_regex, description, is_active) VALUES
('ma túy',           FALSE, 'Chất cấm - ma túy',                       TRUE),
('cần sa',           FALSE, 'Chất cấm - cần sa',                       TRUE),
('heroin',           FALSE, 'Chất cấm - heroin',                       TRUE),
('vũ khí',           FALSE, 'Vật phẩm nguy hiểm - vũ khí',            TRUE),
('súng',             FALSE, 'Vật phẩm nguy hiểm - súng',              TRUE),
('đạn',              FALSE, 'Vật phẩm nguy hiểm - đạn',               TRUE),
('chất nổ',          FALSE, 'Vật phẩm nguy hiểm - chất nổ',           TRUE),
('hàng giả',         FALSE, 'Vi phạm thương mại - hàng giả',          TRUE),
('hàng nhái',        FALSE, 'Vi phạm thương mại - hàng nhái',         TRUE),
('đánh bạc',         FALSE, 'Vi phạm pháp luật - đánh bạc',           TRUE),
('cờ bạc',           FALSE, 'Vi phạm pháp luật - cờ bạc',             TRUE),
('mại dâm',          FALSE, 'Vi phạm đạo đức - mại dâm',              TRUE),
('khiêu dâm',        FALSE, 'Nội dung phản cảm - khiêu dâm',          TRUE),
('chửi bậy',         FALSE, 'Ngôn từ tục tĩu',                        TRUE),
('đ.m',              FALSE, 'Ngôn từ tục tĩu viết tắt',               TRUE),
('cc',               FALSE, 'Ngôn từ tục tĩu viết tắt',               TRUE);
