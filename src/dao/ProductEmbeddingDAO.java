package dao;

import model.ProductEmbedding;
import util.DBContext;
import util.VectorUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ProductEmbeddingDAO {

    /**
     * Lưu hoặc cập nhật vector của sản phẩm vào MySQL
     */
    public boolean saveEmbedding(int productId, float[] vector) {
        if (vector == null || vector.length == 0) return false;

        String vectorJson = VectorUtil.floatArrayToJson(vector);
        String sql = "INSERT INTO product_embeddings (product_id, vector_data) VALUES (?, ?) " +
                     "ON DUPLICATE KEY UPDATE vector_data = VALUES(vector_data), created_at = CURRENT_TIMESTAMP";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            ps.setString(2, vectorJson);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Lấy danh sách toàn bộ vector của các sản phẩm đang có status = 'ACTIVE'
     */
    public List<ProductEmbedding> getAllActiveProductEmbeddings() {
        List<ProductEmbedding> list = new ArrayList<>();
        String sql = "SELECT pe.product_id, pe.vector_data " +
                     "FROM product_embeddings pe " +
                     "INNER JOIN products p ON pe.product_id = p.id " +
                     "WHERE p.status = 'ACTIVE'";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                int productId = rs.getInt("product_id");
                String vectorJson = rs.getString("vector_data");
                float[] vector = VectorUtil.jsonToFloatArray(vectorJson);

                if (vector != null && vector.length > 0) {
                    ProductEmbedding item = new ProductEmbedding(productId, vector);
                    list.add(item);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lấy các sản phẩm ACTIVE chưa có vector embedding để hỗ trợ đồng bộ dữ liệu cũ
     * Trả về Map<productId, primaryImageUrl>
     */
    public Map<Integer, String> getUnindexedActiveProducts() {
        Map<Integer, String> map = new HashMap<>();
        String sql = "SELECT p.id, pi.image_url " +
                     "FROM products p " +
                     "LEFT JOIN product_images pi ON p.id = pi.product_id AND pi.is_primary = 1 " +
                     "LEFT JOIN product_embeddings pe ON p.id = pe.product_id " +
                     "WHERE p.status = 'ACTIVE' AND pe.id IS NULL AND pi.image_url IS NOT NULL";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                map.put(rs.getInt("id"), rs.getString("image_url"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return map;
    }

    /**
     * Đếm tổng số sản phẩm đã được vector hóa
     */
    public int countIndexedProducts() {
        String sql = "SELECT COUNT(*) FROM product_embeddings";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
}
