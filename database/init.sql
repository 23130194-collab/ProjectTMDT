-- Xóa database nếu đã tồn tại và tạo mới
DROP DATABASE IF EXISTS muangay_db;
CREATE DATABASE muangay_db DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE muangay_db;

-- 1. Bảng Users (Người dùng & Admin)
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20) UNIQUE,
    avatar VARCHAR(255),
    role ENUM('USER', 'ADMIN') DEFAULT 'USER',
    reputation_score INT DEFAULT 0, -- Điểm uy tín
    status ENUM('ACTIVE', 'LOCKED') DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Bảng Categories (Danh mục sản phẩm)
CREATE TABLE categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    icon VARCHAR(255)
);

-- 3. Bảng Products (Tin đăng / Sản phẩm)
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL, -- Người bán
    category_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(15, 2) NOT NULL,
    condition_status ENUM('NEW', 'LIKE_NEW', 'GOOD', 'FAIR') DEFAULT 'GOOD', -- Mới, Cũ như mới, Cũ...
    location VARCHAR(100), -- Khu vực (VD: TP.HCM)
    status ENUM('PENDING', 'ACTIVE', 'SOLD', 'HIDDEN', 'REJECTED') DEFAULT 'PENDING', -- PENDING chờ duyệt
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (category_id) REFERENCES categories(id)
);

-- 4. Bảng Product_Images (Hình ảnh của sản phẩm)
CREATE TABLE product_images (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    image_url VARCHAR(255) NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE, -- Hình ảnh làm thumbnail
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- 5. Bảng Orders (Đơn hàng / Giao dịch)
CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    buyer_id INT NOT NULL,
    seller_id INT NOT NULL,
    agreed_price DECIMAL(15, 2) NOT NULL, -- Giá chốt cuối cùng
    deposit_amount DECIMAL(15, 2) DEFAULT 0, -- Tiền cọc (VietQR)
    status ENUM('NEGOTIATING', 'DEPOSITED', 'SHIPPING', 'COMPLETED', 'CANCELLED', 'DISPUTED') DEFAULT 'NEGOTIATING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (buyer_id) REFERENCES users(id),
    FOREIGN KEY (seller_id) REFERENCES users(id)
);

-- 6. Bảng Conversations (Phiên Chat giữa 2 người về 1 sản phẩm)
CREATE TABLE conversations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    buyer_id INT NOT NULL,
    seller_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (buyer_id) REFERENCES users(id),
    FOREIGN KEY (seller_id) REFERENCES users(id)
);

-- 7. Bảng Messages (Chi tiết tin nhắn trong phòng chat)
CREATE TABLE messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    conversation_id INT NOT NULL,
    sender_id INT NOT NULL,
    content TEXT,
    message_type ENUM('TEXT', 'PROPOSAL', 'SYSTEM') DEFAULT 'TEXT', -- Loại tin nhắn (chữ / báo giá / hệ thống báo)
    proposed_price DECIMAL(15,2), -- Chỉ dùng nếu type là PROPOSAL
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (conversation_id) REFERENCES conversations(id),
    FOREIGN KEY (sender_id) REFERENCES users(id)
);

-- 8. Bảng Reviews (Đánh giá)
CREATE TABLE reviews (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    reviewer_id INT NOT NULL,
    reviewee_id INT NOT NULL,
    rating INT CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (reviewer_id) REFERENCES users(id),
    FOREIGN KEY (reviewee_id) REFERENCES users(id)
);

-- ==========================================
-- DỮ LIỆU MẪU (DUMMY DATA) ĐỂ TEST TRANG CHỦ
-- ==========================================

INSERT INTO users (username, password, full_name, email, phone, role) VALUES 
('nguyenvantuan', '123456', 'Nguyễn Văn Tuấn', 'tuan@gmail.com', '0901234567', 'USER'),
('tranbaongoc', '123456', 'Trần Bảo Ngọc', 'ngoc@gmail.com', '0912345678', 'USER'),
('admin', 'admin123', 'Quản Trị Viên', 'admin@muangay.vn', '0999999999', 'ADMIN');

INSERT INTO categories (name, icon) VALUES 
('Điện thoại', 'fa-mobile-alt'),
('Máy tính / Laptop', 'fa-laptop'),
('Xe cộ', 'fa-motorcycle');

INSERT INTO products (user_id, category_id, title, description, price, condition_status, location, status) VALUES 
(1, 1, 'iPhone 15 Pro Max 256GB Titan Tự Nhiên', 'Máy đẹp 99%, pin 100%, còn BH Apple 6 tháng.', 25000000, 'LIKE_NEW', 'TP. Hồ Chí Minh', 'ACTIVE'),
(2, 2, 'Macbook Pro M2 16GB 512GB', 'Lên đời cần pass lại, máy dùng kỹ móp xước nhẹ.', 28500000, 'GOOD', 'Hà Nội', 'ACTIVE');

INSERT INTO product_images (product_id, image_url, is_primary) VALUES 
(1, 'assets/images/products/iphone-13-pro-max.jpg', TRUE),
(2, 'assets/images/products/macbook-pro.jpg', TRUE);
