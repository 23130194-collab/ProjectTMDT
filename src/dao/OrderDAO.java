package dao;

import model.OrderSummary;
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
                "COALESCE(o.delivery_method, p.delivery_method, 1) AS final_delivery_method, " +
                "COALESCE(o.seller_confirmed, 0) AS seller_confirmed, " +
                "COALESCE(o.buyer_confirmed, 0) AS buyer_confirmed, " +
                "o.seller_confirmed_at, o.buyer_confirmed_at, " +
                "o.tracking_code, COALESCE(o.shipping_provider, 'GHN') AS shipping_provider, " +
                "o.shipping_status, o.shipping_note, " +
                "p.title AS product_title, p.price AS product_price, " +
                "COALESCE(p.address_detail, p.location) AS product_address, " +
                "p.province AS product_province, p.ward AS product_ward, " +
                "COALESCE(pi.image_url, 'assets/images/products/iphone-13-pro-max.jpg') AS product_image, " +
                "buyer.full_name AS buyer_name, buyer.phone AS buyer_phone, " +
                "buyer.address_detail AS buyer_address, buyer.ward AS buyer_ward, buyer.province AS buyer_province, " +
                "seller.full_name AS seller_name, seller.phone AS seller_phone, " +
                "seller.address_detail AS seller_address, seller.ward AS seller_ward, seller.province AS seller_province " +
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
                    orders.add(mapResultSetToOrderSummary(rs));
                }
            }
        } catch (SQLException | IllegalStateException e) {
            e.printStackTrace();
        }
        return orders;
    }

    public OrderSummary getOrderSummaryById(int orderId) {
        String sql = "SELECT o.id, o.product_id, o.buyer_id, o.seller_id, o.agreed_price, o.deposit_amount, o.status, o.created_at, " +
                "COALESCE(o.delivery_method, p.delivery_method, 1) AS final_delivery_method, " +
                "COALESCE(o.seller_confirmed, 0) AS seller_confirmed, " +
                "COALESCE(o.buyer_confirmed, 0) AS buyer_confirmed, " +
                "o.seller_confirmed_at, o.buyer_confirmed_at, " +
                "o.tracking_code, COALESCE(o.shipping_provider, 'GHN') AS shipping_provider, " +
                "o.shipping_status, o.shipping_note, " +
                "p.title AS product_title, p.price AS product_price, " +
                "COALESCE(p.address_detail, p.location) AS product_address, " +
                "p.province AS product_province, p.ward AS product_ward, " +
                "COALESCE(pi.image_url, 'assets/images/products/iphone-13-pro-max.jpg') AS product_image, " +
                "buyer.full_name AS buyer_name, buyer.phone AS buyer_phone, " +
                "buyer.address_detail AS buyer_address, buyer.ward AS buyer_ward, buyer.province AS buyer_province, " +
                "seller.full_name AS seller_name, seller.phone AS seller_phone, " +
                "seller.address_detail AS seller_address, seller.ward AS seller_ward, seller.province AS seller_province " +
                "FROM orders o " +
                "JOIN products p ON p.id = o.product_id " +
                "JOIN users buyer ON buyer.id = o.buyer_id " +
                "JOIN users seller ON seller.id = o.seller_id " +
                "LEFT JOIN product_images pi ON pi.product_id = p.id AND pi.is_primary = 1 " +
                "WHERE o.id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToOrderSummary(rs);
                }
            }
        } catch (SQLException | IllegalStateException e) {
            e.printStackTrace();
        }
        return null;
    }

    private OrderSummary mapResultSetToOrderSummary(ResultSet rs) throws SQLException {
        OrderSummary item = new OrderSummary();
        item.id = rs.getInt("id");
        item.productId = rs.getInt("product_id");
        item.buyerId = rs.getInt("buyer_id");
        item.sellerId = rs.getInt("seller_id");
        item.agreedPrice = rs.getDouble("agreed_price");
        item.depositAmount = rs.getDouble("deposit_amount");
        item.status = rs.getString("status");
        item.createdAt = rs.getTimestamp("created_at");

        item.deliveryMethod = rs.getInt("final_delivery_method");
        item.sellerConfirmed = rs.getBoolean("seller_confirmed");
        item.buyerConfirmed = rs.getBoolean("buyer_confirmed");
        item.sellerConfirmedAt = rs.getTimestamp("seller_confirmed_at");
        item.buyerConfirmedAt = rs.getTimestamp("buyer_confirmed_at");
        item.trackingCode = rs.getString("tracking_code");
        item.shippingProvider = rs.getString("shipping_provider");
        item.shippingStatus = rs.getString("shipping_status");
        item.shippingNote = rs.getString("shipping_note");

        item.productTitle = rs.getString("product_title");
        item.productPrice = rs.getDouble("product_price");
        item.productImage = rs.getString("product_image");
        item.productAddress = rs.getString("product_address");
        item.productProvince = rs.getString("product_province");
        item.productWard = rs.getString("product_ward");

        item.buyerName = rs.getString("buyer_name");
        item.buyerPhone = rs.getString("buyer_phone");
        item.buyerAddress = buildFullAddress(rs.getString("buyer_address"), rs.getString("buyer_ward"), rs.getString("buyer_province"));

        item.sellerName = rs.getString("seller_name");
        item.sellerPhone = rs.getString("seller_phone");
        item.sellerAddress = buildFullAddress(rs.getString("seller_address"), rs.getString("seller_ward"), rs.getString("seller_province"));

        return item;
    }

    private String buildFullAddress(String detail, String ward, String province) {
        StringBuilder sb = new StringBuilder();
        if (detail != null && !detail.trim().isEmpty()) sb.append(detail.trim());
        if (ward != null && !ward.trim().isEmpty()) {
            if (sb.length() > 0) sb.append(", ");
            sb.append(ward.trim());
        }
        if (province != null && !province.trim().isEmpty()) {
            if (sb.length() > 0) sb.append(", ");
            sb.append(province.trim());
        }
        return sb.length() > 0 ? sb.toString() : "Chưa cập nhật địa chỉ";
    }

    /**
     * Người bán xác nhận đã giao hàng (Gặp mặt trực tiếp)
     */
    public boolean confirmDirectDeliveryBySeller(int orderId, int sellerId) {
        String selectSql = "SELECT o.buyer_id, o.seller_id, o.product_id, o.buyer_confirmed, o.status, p.title " +
                "FROM orders o JOIN products p ON o.product_id = p.id WHERE o.id = ?";
        String updateSql = "UPDATE orders SET seller_confirmed = 1, seller_confirmed_at = CURRENT_TIMESTAMP, " +
                "status = CASE WHEN buyer_confirmed = 1 THEN 'COMPLETED' ELSE 'SHIPPING' END " +
                "WHERE id = ? AND seller_id = ?";

        try (Connection conn = DBContext.getConnection()) {
            int buyerId = 0;
            int productId = 0;
            boolean buyerConfirmed = false;
            String productTitle = "";

            try (PreparedStatement ps = conn.prepareStatement(selectSql)) {
                ps.setInt(1, orderId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) return false;
                    if (rs.getInt("seller_id") != sellerId) return false;
                    buyerId = rs.getInt("buyer_id");
                    productId = rs.getInt("product_id");
                    buyerConfirmed = rs.getBoolean("buyer_confirmed");
                    productTitle = rs.getString("title");
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                ps.setInt(1, orderId);
                ps.setInt(2, sellerId);
                int rows = ps.executeUpdate();
                if (rows > 0) {
                    // Thêm tin nhắn hệ thống vào chat
                    String msg = buyerConfirmed
                            ? "Người bán đã xác nhận đã giao hàng trực tiếp. Cả hai bên đã xác nhận! Đơn hàng #" + orderId + " (" + productTitle + ") đã HOÀN TẤT THÀNH CÔNG."
                            : "Người bán đã xác nhận đã giao hàng trực tiếp cho đơn #" + orderId + " (" + productTitle + "). Đang chờ người mua xác nhận đã nhận hàng.";
                    sendSystemMessage(conn, productId, buyerId, sellerId, msg);

                    // Gửi thông báo cho Người Mua
                    NotificationDAO notifDAO = new NotificationDAO();
                    String targetUrl = "05-quan-ly-don-hang.jsp?orderId=" + orderId;
                    if (buyerConfirmed) {
                        notifDAO.createNotification(conn, buyerId,
                                "Đơn hàng #" + orderId + " đã hoàn tất",
                                "Người bán đã xác nhận bàn giao hàng. Đơn hàng \"" + productTitle + "\" đã hoàn tất. Bạn có thể gửi đánh giá cho người bán ngay!",
                                "ORDER_SHIPPING", targetUrl);
                    } else {
                        notifDAO.createNotification(conn, buyerId,
                                "Người bán đã xác nhận giao hàng",
                                "Người bán đã xác nhận đã giao hàng trực tiếp đơn #" + orderId + " (\"" + productTitle + "\"). Vui lòng kiểm tra và xác nhận đã nhận hàng.",
                                "ORDER_SHIPPING", targetUrl);
                    }

                    return true;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Người mua xác nhận đã nhận hàng (áp dụng cho cả Giao trực tiếp và GHN)
     */
    public boolean confirmReceiptByBuyer(int orderId, int buyerId) {
        String selectSql = "SELECT o.seller_id, o.buyer_id, o.product_id, o.deposit_amount, o.delivery_method, " +
                "o.seller_confirmed, o.shipping_status, p.title " +
                "FROM orders o JOIN products p ON o.product_id = p.id WHERE o.id = ?";
        String updateSql = "UPDATE orders SET buyer_confirmed = 1, buyer_confirmed_at = CURRENT_TIMESTAMP, " +
                "status = 'COMPLETED', shipping_status = 'DA_GIAO' " +
                "WHERE id = ? AND buyer_id = ?";

        try (Connection conn = DBContext.getConnection()) {
            int sellerId = 0;
            int productId = 0;
            int deliveryMethod = 1;
            boolean sellerConfirmed = false;
            String shippingStatus = "";
            String productTitle = "";

            try (PreparedStatement ps = conn.prepareStatement(selectSql)) {
                ps.setInt(1, orderId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) return false;
                    if (rs.getInt("buyer_id") != buyerId) return false;
                    sellerId = rs.getInt("seller_id");
                    productId = rs.getInt("product_id");
                    deliveryMethod = rs.getInt("delivery_method");
                    sellerConfirmed = rs.getBoolean("seller_confirmed");
                    shippingStatus = rs.getString("shipping_status");
                    productTitle = rs.getString("title");
                }
            }

            // QUY TẮC BẢO ĐẢM GIAO NHẬN:
            // 1. Gặp mặt trực tiếp: Người bán phải bấm xác nhận đã giao hàng trước
            if (deliveryMethod == 1 && !sellerConfirmed) {
                System.err.println("[OrderDAO] Người mua không thể xác nhận: Người bán chưa bấm xác nhận đã giao hàng trực tiếp (orderId=" + orderId + ")");
                return false;
            }
            // 2. Giao GHN Express: Bưu tá GHN phải có trạng thái DA_GIAO (giao thành công) trước
            if (deliveryMethod == 2 && !"DA_GIAO".equalsIgnoreCase(shippingStatus)) {
                System.err.println("[OrderDAO] Người mua không thể xác nhận: Bưu tá GHN chưa giao hàng thành công (orderId=" + orderId + ", status=" + shippingStatus + ")");
                return false;
            }

            try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                ps.setInt(1, orderId);
                ps.setInt(2, buyerId);
                int rows = ps.executeUpdate();
                if (rows > 0) {
                    String methodText = deliveryMethod == 2 ? "qua bưu tá GHN" : "tại điểm hẹn trực tiếp";
                    String msg = "Người mua đã xác nhận ĐÃ NHẬN HÀNG " + methodText + " cho đơn #" + orderId + " (" + productTitle + "). " +
                            "Giao dịch hoàn tất thành công! Tiền cọc giữ an toàn đã được giải ngân cho Người bán.";
                    sendSystemMessage(conn, productId, buyerId, sellerId, msg);

                    // Gửi thông báo cho Người Mua
                    NotificationDAO notifDAO = new NotificationDAO();
                    notifDAO.createNotification(conn, buyerId,
                            "Đơn hàng #" + orderId + " hoàn tất thành công",
                            "Bạn đã xác nhận nhận hàng thành công đơn #" + orderId + " (\"" + productTitle + "\"). Hãy dành 1 phút đánh giá người bán nhé!",
                            "ORDER_SHIPPING", "05-quan-ly-don-hang.jsp?orderId=" + orderId);

                    return true;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Người bán tạo đơn vận chuyển qua GHN Demo
     */
    public boolean createGhnShipment(int orderId, int sellerId, String trackingCode, String note) {
        String selectSql = "SELECT o.buyer_id, o.seller_id, o.product_id, p.title FROM orders o " +
                "JOIN products p ON o.product_id = p.id WHERE o.id = ?";
        String updateSql = "UPDATE orders SET delivery_method = 2, tracking_code = ?, shipping_provider = 'GHN', " +
                "shipping_status = 'CHO_LAY_HANG', shipping_note = ?, seller_confirmed = 1, " +
                "seller_confirmed_at = CURRENT_TIMESTAMP, status = 'SHIPPING' " +
                "WHERE id = ? AND seller_id = ?";

        try (Connection conn = DBContext.getConnection()) {
            int buyerId = 0;
            int productId = 0;
            String productTitle = "";

            try (PreparedStatement ps = conn.prepareStatement(selectSql)) {
                ps.setInt(1, orderId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) return false;
                    if (rs.getInt("seller_id") != sellerId) return false;
                    buyerId = rs.getInt("buyer_id");
                    productId = rs.getInt("product_id");
                    productTitle = rs.getString("title");
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                ps.setString(1, trackingCode);
                ps.setString(2, note);
                ps.setInt(3, orderId);
                ps.setInt(4, sellerId);
                int rows = ps.executeUpdate();
                if (rows > 0) {
                    String msg = "GHN Express: Người bán đã tạo đơn vận chuyển GHN thành công! " +
                            "Mã vận đơn: " + trackingCode + " cho sản phẩm '" + productTitle + "'. " +
                            "Shipper GHN đang tiếp nhận và đến lấy hàng.";
                    sendSystemMessage(conn, productId, buyerId, sellerId, msg);

                    // Gửi thông báo cho Người Mua
                    NotificationDAO notifDAO = new NotificationDAO();
                    notifDAO.createNotification(conn, buyerId,
                            "Đơn hàng #" + orderId + " đã được gửi qua GHN",
                            "Người bán đã tạo đơn vận chuyển GHN Express cho \"" + productTitle + "\". Mã vận đơn: " + trackingCode + ". Bưu tá đang đến lấy hàng.",
                            "ORDER_SHIPPING", "05-quan-ly-don-hang.jsp?orderId=" + orderId);

                    return true;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Cập nhật trạng thái GHN (Sandbox Simulator)
     * newStatus: 'CHO_LAY_HANG', 'DANG_GIAO', 'DA_GIAO'
     */
    public boolean updateGhnShippingStatus(int orderId, String newStatus) {
        String selectSql = "SELECT o.buyer_id, o.seller_id, o.product_id, o.tracking_code, p.title " +
                "FROM orders o JOIN products p ON o.product_id = p.id WHERE o.id = ?";
        String updateSql = "UPDATE orders SET shipping_status = ? WHERE id = ?";

        try (Connection conn = DBContext.getConnection()) {
            int buyerId = 0;
            int sellerId = 0;
            int productId = 0;
            String trackingCode = "";
            String productTitle = "";

            try (PreparedStatement ps = conn.prepareStatement(selectSql)) {
                ps.setInt(1, orderId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) return false;
                    buyerId = rs.getInt("buyer_id");
                    sellerId = rs.getInt("seller_id");
                    productId = rs.getInt("product_id");
                    trackingCode = rs.getString("tracking_code");
                    productTitle = rs.getString("title");
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                ps.setString(1, newStatus);
                ps.setInt(2, orderId);
                int rows = ps.executeUpdate();
                if (rows > 0) {
                    String statusDesc = "Đang vận chuyển";
                    String notifTitle = "Cập nhật đơn hàng GHN #" + orderId;
                    String notifMsg = "";

                    if ("CHO_LAY_HANG".equalsIgnoreCase(newStatus)) {
                        statusDesc = "Chờ bưu tá GHN đến lấy hàng";
                        notifTitle = "GHN tiếp nhận đơn hàng #" + orderId;
                        notifMsg = "Đơn hàng \"" + productTitle + "\" (vận đơn " + trackingCode + ") đang chờ bưu tá GHN đến lấy hàng.";
                    } else if ("DANG_GIAO".equalsIgnoreCase(newStatus)) {
                        statusDesc = "Bưu tá GHN đang đi giao đến người mua";
                        notifTitle = "Bưu tá đang giao hàng cho bạn";
                        notifMsg = "Bưu tá GHN đang trên đường giao gói hàng \"" + productTitle + "\" (vận đơn " + trackingCode + ") đến bạn.";
                    } else if ("DA_GIAO".equalsIgnoreCase(newStatus)) {
                        statusDesc = "Bưu tá GHN đã giao hàng thành công tới người mua";
                        notifTitle = "GHN đã giao hàng thành công";
                        notifMsg = "Bưu tá GHN đã giao thành công đơn hàng \"" + productTitle + "\" (vận đơn " + trackingCode + "). Vui lòng kiểm tra và bấm xác nhận nhận hàng.";
                    }

                    String msg = "Cập nhật vận đơn GHN (" + trackingCode + "): " + statusDesc + " (Sản phẩm: " + productTitle + ").";
                    sendSystemMessage(conn, productId, buyerId, sellerId, msg);

                    // Gửi thông báo cho Người Mua
                    NotificationDAO notifDAO = new NotificationDAO();
                    notifDAO.createNotification(conn, buyerId, notifTitle, notifMsg,
                            "ORDER_SHIPPING", "05-quan-ly-don-hang.jsp?orderId=" + orderId);

                    return true;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
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
                    ps.setInt(2, sellerId); // sender id
                    ps.setString(3, content);
                    ps.executeUpdate();
                }
            }
        } catch (SQLException e) {
            System.err.println("[OrderDAO] Không thể gửi tin nhắn hệ thống: " + e.getMessage());
        }
    }
}
