package dao;

import util.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class OrderDAO {

    public int countOrdersForUser(int userId) {
        String sql = "SELECT COUNT(*) FROM orders WHERE buyer_id = ? OR seller_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (SQLException | IllegalStateException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public List<OrderSummary> getOrderSummariesForUser(int userId) {
        List<OrderSummary> orders = new ArrayList<>();
        String sql = "SELECT o.id, o.product_id, o.buyer_id, o.seller_id, o.agreed_price, o.deposit_amount, o.status, o.created_at, " +
                "p.title AS product_title, p.price AS product_price, COALESCE(pi.image_url, 'assets/images/products/iphone-13-pro-max.jpg') AS product_image, " +
                "buyer.full_name AS buyer_name, seller.full_name AS seller_name " +
                "FROM orders o " +
                "JOIN products p ON p.id = o.product_id " +
                "JOIN users buyer ON buyer.id = o.buyer_id " +
                "JOIN users seller ON seller.id = o.seller_id " +
                "LEFT JOIN product_images pi ON pi.product_id = p.id AND pi.is_primary = 1 " +
                "WHERE o.buyer_id = ? OR o.seller_id = ? " +
                "ORDER BY o.created_at DESC, o.id DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    OrderSummary item = new OrderSummary();
                    item.id = rs.getInt("id");
                    item.productId = rs.getInt("product_id");
                    item.buyerId = rs.getInt("buyer_id");
                    item.sellerId = rs.getInt("seller_id");
                    item.agreedPrice = rs.getDouble("agreed_price");
                    item.depositAmount = rs.getDouble("deposit_amount");
                    item.status = rs.getString("status");
                    item.createdAt = rs.getTimestamp("created_at");
                    item.productTitle = rs.getString("product_title");
                    item.productPrice = rs.getDouble("product_price");
                    item.productImage = rs.getString("product_image");
                    item.buyerName = rs.getString("buyer_name");
                    item.sellerName = rs.getString("seller_name");
                    orders.add(item);
                }
            }
        } catch (SQLException | IllegalStateException e) {
            e.printStackTrace();
        }
        return orders;
    }

    public static class OrderSummary {
        public int id;
        public int productId;
        public int buyerId;
        public int sellerId;
        public double agreedPrice;
        public double depositAmount;
        public String status;
        public Timestamp createdAt;
        public String productTitle;
        public double productPrice;
        public String productImage;
        public String buyerName;
        public String sellerName;
    }
}
