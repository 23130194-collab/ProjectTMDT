package dao;

import model.Product;
import model.Category;
import util.DBContext;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ProductDAO {

    public List<Category> getAllCategories() {
        List<Category> categories = new ArrayList<>();
        String sql = "SELECT id, name, icon FROM categories ORDER BY id";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                categories.add(new Category(rs.getInt("id"), rs.getString("name"), rs.getString("icon")));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return categories;
    }

    // Hàm thêm sản phẩm mới vào Database, trả về ID của sản phẩm vừa tạo
    public int insertProduct(Product product) {
        String sql = "INSERT INTO products (user_id, category_id, title, description, price, condition_status, specifications, province, ward, address_detail, status, delivery_method, deal_type) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        int generatedId = 0;

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, product.getUserId());
            ps.setInt(2, product.getCategoryId());
            ps.setString(3, product.getTitle());
            ps.setString(4, product.getDescription());
            ps.setDouble(5, product.getPrice());
            ps.setString(6, product.getConditionStatus());
            ps.setString(7, product.getSpecifications());
            ps.setString(8, product.getProvince());
            ps.setString(9, product.getWard());
            ps.setString(10, product.getAddressDetail());
            ps.setString(11, product.getStatus());
            ps.setInt(12, product.getDeliveryMethod());
            ps.setString(13, product.getDealType());

            ps.executeUpdate();

            ResultSet rs = ps.getGeneratedKeys();
            if (rs.next()) {
                generatedId = rs.getInt(1);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return generatedId;
    }

    // Helper trích xuất Product từ ResultSet bao gồm cả các trường VIP / Đẩy tin
    private Product mapResultSetToProduct(ResultSet rs) throws SQLException {
        Product p = new Product();
        p.setId(rs.getInt("id"));
        p.setUserId(rs.getInt("user_id"));
        p.setCategoryId(rs.getInt("category_id"));
        p.setDealType(rs.getString("deal_type"));
        p.setTitle(rs.getString("title"));
        p.setDescription(rs.getString("description"));
        p.setPrice(rs.getDouble("price"));
        p.setConditionStatus(rs.getString("condition_status"));
        p.setLocation(rs.getString("location"));
        p.setProvince(rs.getString("province"));
        p.setWard(rs.getString("ward"));
        p.setAddressDetail(rs.getString("address_detail"));
        p.setStatus(rs.getString("status"));
        p.setCreatedAt(rs.getTimestamp("created_at"));
        p.setNewProduct(isNewProduct(p.getCreatedAt()));
        p.setDeliveryMethod(rs.getInt("delivery_method"));
        p.setSpecifications(rs.getString("specifications"));
        p.setPrimaryImage(rs.getString("image_url"));

        // Boost & VIP fields
        boolean isPinned = rs.getBoolean("is_pinned");
        Timestamp pinnedUntil = rs.getTimestamp("pinned_until");
        int priority = rs.getInt("priority_level");
        p.setPinned(isPinned);
        p.setPinnedUntil(pinnedUntil);
        p.setPriorityLevel(priority);
        p.setBumpedAt(rs.getTimestamp("bumped_at"));
        p.setRemainingBumps(rs.getInt("remaining_bumps"));

        // Xác định huy hiệu hiển thị nếu còn hạn VIP
        if (isPinned && pinnedUntil != null && pinnedUntil.after(new java.util.Date())) {
            if (priority >= 2) {
                p.setBadgeLabel("👑 VIP KIM CƯƠNG");
                p.setBadgeColor("purple");
            } else {
                p.setBadgeLabel("⭐ NỔI BẬT");
                p.setBadgeColor("amber");
            }
        }

        return p;
    }

    // Hàm lấy danh sách sản phẩm để hiển thị trang chủ — CHỈ bài ACTIVE, ưu tiên VIP (xoay vòng ngẫu nhiên công bằng) và Đẩy tin
    public List<Product> getRecentProducts() {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT p.*, pi.image_url FROM products p " +
                     "LEFT JOIN product_images pi ON p.id = pi.product_id AND pi.is_primary = 1 " +
                     "WHERE p.status = 'ACTIVE' " +
                     "ORDER BY (p.is_pinned = 1 AND p.pinned_until > NOW()) DESC, " +
                     "p.priority_level DESC, " +
                     "CASE WHEN (p.is_pinned = 1 AND p.pinned_until > NOW()) THEN RAND() ELSE 0 END, " +
                     "COALESCE(p.bumped_at, p.created_at) DESC, p.id DESC";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapResultSetToProduct(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // Hàm lấy tối đa các sản phẩm mới nhất — CHỈ bài ACTIVE, ưu tiên VIP (xoay vòng ngẫu nhiên công bằng) và Đẩy tin
    public List<Product> getNewestProducts(int limit) {
        List<Product> list = new ArrayList<>();
        int safeLimit = limit > 0 ? Math.min(limit, 20) : 10;
        String sql = "SELECT p.*, pi.image_url FROM products p " +
                     "LEFT JOIN product_images pi ON p.id = pi.product_id AND pi.is_primary = 1 " +
                     "WHERE p.status = 'ACTIVE' " +
                     "ORDER BY (p.is_pinned = 1 AND p.pinned_until > NOW()) DESC, " +
                     "p.priority_level DESC, " +
                     "CASE WHEN (p.is_pinned = 1 AND p.pinned_until > NOW()) THEN RAND() ELSE 0 END, " +
                     "COALESCE(p.bumped_at, p.created_at) DESC, p.id DESC LIMIT ?";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, safeLimit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToProduct(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // Tìm kiếm sản phẩm theo từ khóa — CHỈ bài ACTIVE, ưu tiên VIP (xoay vòng ngẫu nhiên công bằng) và Đẩy tin
    public List<Product> searchProducts(String keyword) {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT p.*, pi.image_url FROM products p " +
                     "LEFT JOIN product_images pi ON p.id = pi.product_id AND pi.is_primary = 1 " +
                     "WHERE p.status = 'ACTIVE' AND (p.title LIKE ? OR p.description LIKE ?) " +
                     "ORDER BY (p.is_pinned = 1 AND p.pinned_until > NOW()) DESC, " +
                     "p.priority_level DESC, " +
                     "CASE WHEN (p.is_pinned = 1 AND p.pinned_until > NOW()) THEN RAND() ELSE 0 END, " +
                     "COALESCE(p.bumped_at, p.created_at) DESC, p.id DESC";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            String pattern = "%" + keyword + "%";
            ps.setString(1, pattern);
            ps.setString(2, pattern);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToProduct(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // Gợi ý tìm kiếm — CHỈ bài ACTIVE
    public List<Product> getProductSuggestions(String keyword) {
        List<Product> suggestions = new ArrayList<>();
        String sql = "SELECT title, price FROM products WHERE status = 'ACTIVE' AND title LIKE ? ORDER BY id DESC LIMIT 5";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, "%" + keyword + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product product = new Product();
                    product.setTitle(rs.getString("title"));
                    product.setPrice(rs.getDouble("price"));
                    suggestions.add(product);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return suggestions;
    }

    // Lấy chi tiết 1 sản phẩm theo ID (dùng cho trang detail, admin, owner)
    // Controller sẽ kiểm tra quyền xem nếu status != ACTIVE
    public Product getProductById(int id) {
        String sql = "SELECT p.*, pi.image_url, CASE WHEN p.status NOT IN ('DELETE', 'SOLD') AND EXISTS " +
                     "(SELECT 1 FROM orders o WHERE o.product_id = p.id " +
                     "AND o.status IN ('DEPOSITED', 'SHIPPING', 'COMPLETED')) THEN 'SOLD' ELSE p.status END AS current_status " +
                     "FROM products p " +
                     "LEFT JOIN product_images pi ON p.id = pi.product_id AND pi.is_primary = 1 " +
                     "WHERE p.id = ? AND p.status <> 'DELETE'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Product p = mapResultSetToProduct(rs);
                    p.setStatus(rs.getString("current_status"));
                    return p;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    private boolean isNewProduct(Timestamp createdAt) {
        if (createdAt == null) return false;
        long twoDaysMillis = 2L * 24 * 60 * 60 * 1000;
        return System.currentTimeMillis() - createdAt.getTime() <= twoDaysMillis;
    }

    // Lấy danh sách bài đăng theo userId (trang hồ sơ cá nhân — hiện tất cả kể cả REJECTED)
    public List<Product> getProductsByUserId(int userId) {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT p.*, pi.image_url FROM products p " +
                     "LEFT JOIN product_images pi ON p.id = pi.product_id AND pi.is_primary = 1 " +
                     "WHERE p.user_id = ? AND p.status <> 'DELETE' ORDER BY p.created_at DESC";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToProduct(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // Cập nhật trạng thái bài đăng (ACTIVE, SOLD, HIDDEN...)
    public boolean updateProductStatus(int productId, int userId, String newStatus) {
        String sql = "UPDATE products SET status = ? WHERE id = ? AND user_id = ? AND status <> 'DELETE' " +
                     "AND NOT (status = 'SOLD' AND ? = 'ACTIVE')";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            ps.setInt(2, productId);
            ps.setInt(3, userId);
            ps.setString(4, newStatus);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Xóa bài đăng (chỉ chủ sở hữu mới được xóa — soft delete)
    public boolean deleteProduct(int productId, int userId) {
        String sql = "UPDATE products SET status = 'DELETE' WHERE id = ? AND user_id = ? AND status <> 'DELETE'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Cập nhật thông tin bài đăng (sửa bài)
    public boolean updateProduct(Product product) {
        String sql = "UPDATE products SET title = ?, description = ?, price = ?, category_id = ?, " +
                     "condition_status = ?, specifications = ?, province = ?, ward = ?, address_detail = ?, delivery_method = ?, deal_type = ?, " +
                     "status = CASE WHEN status IN ('DELETE', 'SOLD') THEN status ELSE ? END " +
                     "WHERE id = ? AND user_id = ? AND status <> 'DELETE'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, product.getTitle());
            ps.setString(2, product.getDescription());
            ps.setDouble(3, product.getPrice());
            ps.setInt(4, product.getCategoryId());
            ps.setString(5, product.getConditionStatus());
            ps.setString(6, product.getSpecifications());
            ps.setString(7, product.getProvince());
            ps.setString(8, product.getWard());
            ps.setString(9, product.getAddressDetail());
            ps.setInt(10, product.getDeliveryMethod());
            ps.setString(11, product.getDealType());
            ps.setString(12, product.getStatus());
            ps.setInt(13, product.getId());
            ps.setInt(14, product.getUserId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
