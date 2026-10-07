package dao;

import model.ProductImage;
import util.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.List;
import java.util.ArrayList;
import java.sql.ResultSet;

public class ProductImageDAO {

    // Hàm thêm danh sách hình ảnh vào Database
    public void insertImages(List<ProductImage> images) {
        String sql = "INSERT INTO product_images (product_id, image_url, is_primary) VALUES (?, ?, ?)";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
             
            for (ProductImage img : images) {
                ps.setInt(1, img.getProductId());
                ps.setString(2, img.getImageUrl());
                ps.setBoolean(3, img.isPrimary());
                ps.addBatch();
            }
            
            ps.executeBatch();
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public List<ProductImage> getImagesByProductId(int productId) {
        List<ProductImage> list = new ArrayList<>();
        String sql = "SELECT * FROM product_images WHERE product_id = ? ORDER BY is_primary DESC, id ASC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProductImage img = new ProductImage();
                    img.setId(rs.getInt("id"));
                    img.setProductId(rs.getInt("product_id"));
                    img.setImageUrl(rs.getString("image_url"));
                    img.setPrimary(rs.getBoolean("is_primary"));
                    list.add(img);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}
