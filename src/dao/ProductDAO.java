package dao;

import model.Product;
import util.DBContext;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ProductDAO {

    // Hàm thêm sản phẩm mới vào Database, trả về ID của sản phẩm vừa tạo
    public int insertProduct(Product product) {
        String sql = "INSERT INTO products (user_id, category_id, title, description, price, condition_status, location, status, delivery_method) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        int generatedId = 0;
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
             
            ps.setInt(1, product.getUserId());
            ps.setInt(2, product.getCategoryId());
            ps.setString(3, product.getTitle());
            ps.setString(4, product.getDescription());
            ps.setDouble(5, product.getPrice());
            ps.setString(6, product.getConditionStatus());
            ps.setString(7, product.getLocation());
            ps.setString(8, product.getStatus()); // 'PENDING'
            ps.setInt(9, product.getDeliveryMethod());
            
            ps.executeUpdate();
            
            // Lấy ID tự tăng vừa được tạo ra
            ResultSet rs = ps.getGeneratedKeys();
            if (rs.next()) {
                generatedId = rs.getInt(1);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return generatedId;
    }

    // Hàm lấy danh sách tất cả sản phẩm mới nhất (kèm ảnh bìa) để hiển thị lên trang chủ
    public List<Product> getRecentProducts() {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT p.*, pi.image_url FROM products p " +
                     "LEFT JOIN product_images pi ON p.id = pi.product_id AND pi.is_primary = 1 " +
                     "ORDER BY p.id DESC"; // Lấy tin mới nhất
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
             
            while (rs.next()) {
                Product p = new Product();
                p.setId(rs.getInt("id"));
                p.setUserId(rs.getInt("user_id"));
                p.setCategoryId(rs.getInt("category_id"));
                p.setTitle(rs.getString("title"));
                p.setDescription(rs.getString("description"));
                p.setPrice(rs.getDouble("price"));
                p.setConditionStatus(rs.getString("condition_status"));
                p.setLocation(rs.getString("location"));
                p.setStatus(rs.getString("status"));
                p.setCreatedAt(rs.getTimestamp("created_at"));
                p.setDeliveryMethod(rs.getInt("delivery_method"));
                p.setPrimaryImage(rs.getString("image_url")); // Set link ảnh
                list.add(p);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public Product getProductById(int id) {
        String sql = "SELECT * FROM products WHERE id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Product p = new Product();
                    p.setId(rs.getInt("id"));
                    p.setUserId(rs.getInt("user_id"));
                    p.setCategoryId(rs.getInt("category_id"));
                    p.setTitle(rs.getString("title"));
                    p.setDescription(rs.getString("description"));
                    p.setPrice(rs.getDouble("price"));
                    p.setConditionStatus(rs.getString("condition_status"));
                    p.setLocation(rs.getString("location"));
                    p.setStatus(rs.getString("status"));
                    p.setCreatedAt(rs.getTimestamp("created_at"));
                    p.setDeliveryMethod(rs.getInt("delivery_method"));
                    return p;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
}