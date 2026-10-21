package dao;

import model.Review;
import util.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class ReviewDAO {

    /**
     * Kiểm tra xem người mua có quyền đánh giá đơn hàng này hay không.
     * Điều kiện:
     * 1. Đơn hàng tồn tại, buyer_id == reviewerId.
     * 2. Trạng thái đơn hàng phải là 'COMPLETED' (đã nhận hàng thành công).
     * 3. Mỗi đơn hàng chỉ được đánh giá 1 lần duy nhất.
     */
    public boolean canUserReviewOrder(int orderId, int reviewerId) {
        String sql = "SELECT o.buyer_id, o.status, " +
                "(SELECT COUNT(*) FROM reviews r WHERE r.order_id = o.id) AS review_count " +
                "FROM orders o WHERE o.id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int buyerId = rs.getInt("buyer_id");
                    String status = rs.getString("status");
                    int reviewCount = rs.getInt("review_count");

                    return buyerId == reviewerId &&
                            "COMPLETED".equalsIgnoreCase(status) &&
                            reviewCount == 0;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Kiểm tra đơn hàng đã được đánh giá hay chưa
     */
    public boolean hasReviewedOrder(int orderId) {
        String sql = "SELECT COUNT(*) FROM reviews WHERE order_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Lấy đánh giá của đơn hàng (nếu có)
     */
    public Review getReviewByOrderId(int orderId) {
        String sql = "SELECT * FROM reviews WHERE order_id = ? LIMIT 1";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new Review(
                            rs.getInt("id"),
                            rs.getInt("order_id"),
                            rs.getInt("reviewer_id"),
                            rs.getInt("reviewee_id"),
                            rs.getInt("rating"),
                            rs.getString("comment"),
                            rs.getTimestamp("created_at")
                    );
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Thêm đánh giá mới:
     * - Ràng buộc: đúng người mua, đơn đã hoàn tất, mỗi đơn 1 lần.
     * - Tự động cộng điểm uy tín cho người bán theo số sao.
     * - Gửi tin nhắn hệ thống vào phòng chat.
     */
    public boolean addReview(int orderId, int reviewerId, int rating, String comment) {
        if (!canUserReviewOrder(orderId, reviewerId)) {
            return false;
        }

        int cleanRating = Math.max(1, Math.min(5, rating));
        String cleanComment = comment != null ? comment.trim() : "";
        if (cleanComment.isEmpty()) {
            cleanComment = "Người mua không để lại nhận xét chữ.";
        }

        String selectOrderSql = "SELECT o.seller_id, o.product_id, p.title, buyer.full_name AS buyer_name " +
                "FROM orders o " +
                "JOIN products p ON o.product_id = p.id " +
                "JOIN users buyer ON o.buyer_id = buyer.id " +
                "WHERE o.id = ?";
        String insertReviewSql = "INSERT INTO reviews (order_id, reviewer_id, reviewee_id, rating, comment, created_at) " +
                "VALUES (?, ?, ?, ?, ?, CURRENT_TIMESTAMP)";
        String updateReputationSql = "UPDATE users SET reputation_score = COALESCE(reputation_score, 0) + ? WHERE id = ?";

        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try {
                int sellerId = 0;
                int productId = 0;
                String productTitle = "";
                String buyerName = "";

                try (PreparedStatement ps = conn.prepareStatement(selectOrderSql)) {
                    ps.setInt(1, orderId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            conn.rollback();
                            return false;
                        }
                        sellerId = rs.getInt("seller_id");
                        productId = rs.getInt("product_id");
                        productTitle = rs.getString("title");
                        buyerName = rs.getString("buyer_name");
                    }
                }

                try (PreparedStatement ps = conn.prepareStatement(insertReviewSql)) {
                    ps.setInt(1, orderId);
                    ps.setInt(2, reviewerId);
                    ps.setInt(3, sellerId);
                    ps.setInt(4, cleanRating);
                    ps.setString(5, cleanComment);
                    ps.executeUpdate();
                }

                // Cộng điểm uy tín: 5 sao cộng 5 điểm, 4 sao cộng 4 điểm...
                try (PreparedStatement ps = conn.prepareStatement(updateReputationSql)) {
                    ps.setInt(1, cleanRating);
                    ps.setInt(2, sellerId);
                    ps.executeUpdate();
                }

                // Gửi tin nhắn hệ thống vào chat
                sendSystemMessage(conn, productId, reviewerId, sellerId,
                        "Người mua " + buyerName + " đã đánh giá Người Bán " + cleanRating + " sao ★ cho đơn hàng #" + orderId +
                                " (\"" + productTitle + "\"): \"" + cleanComment + "\"");

                // Gửi thông báo cho Người Bán
                NotificationDAO notifDAO = new NotificationDAO();
                String shortComment = cleanComment.length() > 60 ? cleanComment.substring(0, 57) + "..." : cleanComment;
                String notifTitle = "Bạn nhận được đánh giá " + cleanRating + " sao ★ từ khách hàng";
                String notifMsg = buyerName + " đã đánh giá " + cleanRating + " sao cho đơn hàng #" + orderId +
                        " (\"" + productTitle + "\"): \"" + shortComment + "\"";
                notifDAO.createNotification(conn, sellerId, notifTitle, notifMsg, "REVIEW_RECEIVED", "my-posts?tab=reviews");

                conn.commit();
                return true;
            } catch (SQLException e) {
                conn.rollback();
                e.printStackTrace();
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Lấy danh sách toàn bộ đánh giá về người bán (revieweeId)
     */
    public List<ReviewDetail> getReviewsForSeller(int sellerId) {
        List<ReviewDetail> list = new ArrayList<>();
        String sql = "SELECT r.id, r.order_id, r.reviewer_id, r.reviewee_id, r.rating, r.comment, r.created_at, " +
                "reviewer.full_name AS reviewer_name, reviewer.avatar AS reviewer_avatar, " +
                "p.title AS product_title, p.price AS product_price " +
                "FROM reviews r " +
                "JOIN users reviewer ON r.reviewer_id = reviewer.id " +
                "JOIN orders o ON r.order_id = o.id " +
                "JOIN products p ON o.product_id = p.id " +
                "WHERE r.reviewee_id = ? " +
                "ORDER BY r.created_at DESC, r.id DESC";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, sellerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ReviewDetail item = new ReviewDetail();
                    item.id = rs.getInt("id");
                    item.orderId = rs.getInt("order_id");
                    item.reviewerId = rs.getInt("reviewer_id");
                    item.reviewerName = rs.getString("reviewer_name");
                    item.reviewerAvatar = rs.getString("reviewer_avatar");
                    item.revieweeId = rs.getInt("reviewee_id");
                    item.rating = rs.getInt("rating");
                    item.comment = rs.getString("comment");
                    item.createdAt = rs.getTimestamp("created_at");
                    item.productTitle = rs.getString("product_title");
                    item.productPrice = rs.getDouble("product_price");
                    list.add(item);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Thống kê đánh giá của người bán (điểm trung bình, số lượng sao)
     */
    public SellerRatingSummary getSellerRatingSummary(int sellerId) {
        SellerRatingSummary summary = new SellerRatingSummary();
        summary.sellerId = sellerId;

        String sql = "SELECT rating, COUNT(*) AS cnt FROM reviews WHERE reviewee_id = ? GROUP BY rating";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, sellerId);
            try (ResultSet rs = ps.executeQuery()) {
                int totalPoints = 0;
                int totalCount = 0;
                while (rs.next()) {
                    int r = rs.getInt("rating");
                    int cnt = rs.getInt("cnt");
                    totalCount += cnt;
                    totalPoints += (r * cnt);
                    if (r == 5) summary.count5Star = cnt;
                    else if (r == 4) summary.count4Star = cnt;
                    else if (r == 3) summary.count3Star = cnt;
                    else if (r == 2) summary.count2Star = cnt;
                    else if (r == 1) summary.count1Star = cnt;
                }
                summary.totalReviews = totalCount;
                summary.averageRating = totalCount > 0 ? (double) totalPoints / totalCount : 5.0; // mặc định 5.0 nếu chưa có
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return summary;
    }

    private void sendSystemMessage(Connection conn, int productId, int buyerId, int sellerId, String content) {
        String findConvSql = "SELECT id FROM conversations WHERE product_id = ? AND buyer_id = ? AND seller_id = ? LIMIT 1";
        String insertMsgSql = "INSERT INTO messages (conversation_id, sender_id, content, message_type) VALUES (?, ?, ?, 'SYSTEM')";
        try {
            int convId = 0;
            try (PreparedStatement ps = conn.prepareStatement(findConvSql)) {
                ps.setInt(1, productId);
                ps.setInt(2, buyerId);
                ps.setInt(3, sellerId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) convId = rs.getInt(1);
                }
            }
            if (convId > 0) {
                try (PreparedStatement ps = conn.prepareStatement(insertMsgSql)) {
                    ps.setInt(1, convId);
                    ps.setInt(2, buyerId);
                    ps.setString(3, content);
                    ps.executeUpdate();
                }
            }
        } catch (SQLException e) {
            System.err.println("[ReviewDAO] Không thể gửi tin nhắn hệ thống: " + e.getMessage());
        }
    }

    public static class ReviewDetail {
        public int id;
        public int orderId;
        public int reviewerId;
        public String reviewerName;
        public String reviewerAvatar;
        public int revieweeId;
        public int rating;
        public String comment;
        public Timestamp createdAt;
        public String productTitle;
        public double productPrice;
    }

    public static class SellerRatingSummary {
        public int sellerId;
        public double averageRating = 5.0;
        public int totalReviews = 0;
        public int count5Star = 0;
        public int count4Star = 0;
        public int count3Star = 0;
        public int count2Star = 0;
        public int count1Star = 0;
    }
}
