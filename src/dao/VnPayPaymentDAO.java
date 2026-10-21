package dao;

import util.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;

public class VnPayPaymentDAO {
    public void ensureTable() {
        String sql = "CREATE TABLE IF NOT EXISTS vnpay_payments (" +
                "id BIGINT AUTO_INCREMENT PRIMARY KEY," +
                "txn_ref VARCHAR(64) NOT NULL UNIQUE," +
                "conversation_id INT NOT NULL," +
                "buyer_id INT NOT NULL," +
                "seller_id INT NOT NULL," +
                "product_id INT NOT NULL," +
                "agreed_price DECIMAL(15,2) NOT NULL," +
                "deposit_amount DECIMAL(15,2) NOT NULL," +
                "status VARCHAR(20) NOT NULL DEFAULT 'PENDING'," +
                "vnp_transaction_no VARCHAR(100) NULL," +
                "response_code VARCHAR(10) NULL," +
                "order_id INT NULL," +
                "expires_at TIMESTAMP NOT NULL," +
                "created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP," +
                "paid_at TIMESTAMP NULL," +
                "INDEX idx_vnpay_payments_conversation (conversation_id)," +
                "INDEX idx_vnpay_payments_status_expiry (status, expires_at)" +
                ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";
        try (Connection conn = DBContext.getConnection(); Statement st = conn.createStatement()) {
            st.execute(sql);
        } catch (SQLException e) {
            throw new IllegalStateException("Không thể tạo bảng lưu giao dịch VNPay.", e);
        }
    }

    public void createPending(String txnRef, int conversationId, int buyerId, int sellerId, int productId,
                              double agreedPrice, double depositAmount, Timestamp expiresAt) throws SQLException {
        ensureTable();
        String activePaymentSql = "SELECT COUNT(*) FROM vnpay_payments WHERE conversation_id = ? " +
                "AND (status = 'PAID' OR (status = 'PENDING' AND expires_at > CURRENT_TIMESTAMP))";
        String lockProductSql = "SELECT p.status, NOT EXISTS (SELECT 1 FROM orders o WHERE o.product_id = p.id " +
                "AND o.status IN ('DEPOSITED', 'SHIPPING', 'COMPLETED')) AS is_available FROM products p WHERE p.id = ? FOR UPDATE";
        String lockSql = "SELECT id FROM conversations WHERE id = ? FOR UPDATE";
        String insertSql = "INSERT INTO vnpay_payments " +
                "(txn_ref, conversation_id, buyer_id, seller_id, product_id, agreed_price, deposit_amount, status, expires_at) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, 'PENDING', ?)";
        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement lockProduct = conn.prepareStatement(lockProductSql)) {
                    lockProduct.setInt(1, productId);
                    try (ResultSet rs = lockProduct.executeQuery()) {
                        if (!rs.next() || "DELETE".equalsIgnoreCase(rs.getString("status")) || "SOLD".equalsIgnoreCase(rs.getString("status")) || !rs.getBoolean("is_available")) {
                            throw new SQLException("Sản phẩm đã hết, không thể tạo giao dịch đặt cọc.");
                        }
                    }
                }
                try (PreparedStatement lock = conn.prepareStatement(lockSql)) {
                    lock.setInt(1, conversationId);
                    try (ResultSet rs = lock.executeQuery()) {
                        if (!rs.next()) throw new SQLException("Không tìm thấy hội thoại đặt cọc.");
                    }
                }
                try (PreparedStatement check = conn.prepareStatement(activePaymentSql)) {
                    check.setInt(1, conversationId);
                    try (ResultSet rs = check.executeQuery()) {
                        if (rs.next() && rs.getInt(1) > 0) {
                            throw new SQLException("Hội thoại đã có giao dịch cọc đang xử lý hoặc đã thanh toán.");
                        }
                    }
                }
                try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                    ps.setString(1, txnRef);
                    ps.setInt(2, conversationId);
                    ps.setInt(3, buyerId);
                    ps.setInt(4, sellerId);
                    ps.setInt(5, productId);
                    ps.setDouble(6, agreedPrice);
                    ps.setDouble(7, depositAmount);
                    ps.setTimestamp(8, expiresAt);
                    ps.executeUpdate();
                }
                conn.commit();
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    public CallbackResult processCallback(String txnRef, String transactionNo, String responseCode,
                                          String transactionStatus, long paidAmount) throws SQLException {
        ensureTable();
        String lookupProductSql = "SELECT product_id FROM vnpay_payments WHERE txn_ref = ?";
        String lockProductSql = "SELECT p.status, NOT EXISTS (SELECT 1 FROM orders o WHERE o.product_id = p.id " +
                "AND o.status IN ('DEPOSITED', 'SHIPPING', 'COMPLETED')) AS is_available FROM products p WHERE p.id = ? FOR UPDATE";
        String selectSql = "SELECT id, conversation_id, product_id, buyer_id, seller_id, agreed_price, deposit_amount, status, expires_at " +
                "FROM vnpay_payments WHERE txn_ref = ? FOR UPDATE";
        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try {
                int lockedProductId;
                try (PreparedStatement lookup = conn.prepareStatement(lookupProductSql)) {
                    lookup.setString(1, txnRef);
                    try (ResultSet rs = lookup.executeQuery()) {
                        if (!rs.next()) {
                            conn.rollback();
                            return new CallbackResult(false, "Không tìm thấy giao dịch.");
                        }
                        lockedProductId = rs.getInt("product_id");
                    }
                }
                String lockedProductStatus = null;
                boolean lockedProductAvailable = false;
                try (PreparedStatement lockProduct = conn.prepareStatement(lockProductSql)) {
                    lockProduct.setInt(1, lockedProductId);
                    try (ResultSet rs = lockProduct.executeQuery()) {
                        if (rs.next()) {
                            lockedProductStatus = rs.getString("status");
                            lockedProductAvailable = rs.getBoolean("is_available");
                        }
                    }
                }
                long paymentId;
                int conversationId;
                int productId;
                int buyerId;
                int sellerId;
                double agreedPrice;
                double depositAmount;
                String status;
                try (PreparedStatement select = conn.prepareStatement(selectSql)) {
                    select.setString(1, txnRef);
                    try (ResultSet rs = select.executeQuery()) {
                        if (!rs.next()) {
                            conn.rollback();
                            return new CallbackResult(false, "Không tìm thấy giao dịch.");
                        }
                        paymentId = rs.getLong("id");
                        conversationId = rs.getInt("conversation_id");
                        productId = rs.getInt("product_id");
                        buyerId = rs.getInt("buyer_id");
                        sellerId = rs.getInt("seller_id");
                        agreedPrice = rs.getDouble("agreed_price");
                        depositAmount = rs.getDouble("deposit_amount");
                        status = rs.getString("status");
                    }
                }
                if (productId != lockedProductId) {
                    conn.rollback();
                    return new CallbackResult(false, "Thông tin sản phẩm của giao dịch không hợp lệ.");
                }

                if (paidAmount != Math.round(depositAmount * 100)) {
                    conn.rollback();
                    return new CallbackResult(false, "Số tiền giao dịch không hợp lệ.");
                }
                if ("PAID".equals(status)) {
                    conn.commit();
                    return new CallbackResult(true, "Giao dịch đã được ghi nhận trước đó.");
                }
                if ("REFUND_REQUIRED".equals(status)) {
                    conn.commit();
                    return new CallbackResult(false, "Khoản thanh toán này cần được hoàn trả; vui lòng liên hệ người bán hoặc quản trị viên.");
                }
                boolean paid = "00".equals(responseCode) && "00".equals(transactionStatus);
                if (!"PENDING".equals(status)) {
                    if (paid && "CANCELLED".equals(status)) {
                        updatePayment(conn, paymentId, "REFUND_REQUIRED", transactionNo, responseCode, null);
                        addPaymentConflictMessage(conn, conversationId, buyerId);
                        conn.commit();
                        return new CallbackResult(false, "Sản phẩm đã được người khác đặt cọc. Khoản thanh toán này cần được hoàn trả; vui lòng liên hệ người bán hoặc quản trị viên.");
                    }
                    conn.rollback();
                    return new CallbackResult(false, "Giao dịch này đã bị hủy hoặc không còn hiệu lực.");
                }
                if (!paid) {
                    updatePayment(conn, paymentId, "FAILED", transactionNo, responseCode, null);
                    conn.commit();
                    return new CallbackResult(false, "Thanh toán chưa thành công.");
                }

                if ("DELETE".equalsIgnoreCase(lockedProductStatus) || "SOLD".equalsIgnoreCase(lockedProductStatus) || !lockedProductAvailable) {
                    updatePayment(conn, paymentId, "REFUND_REQUIRED", transactionNo, responseCode, null);
                    addPaymentConflictMessage(conn, conversationId, buyerId);
                    conn.commit();
                    return new CallbackResult(false, "Sản phẩm đã được người khác đặt cọc. Khoản thanh toán này cần được hoàn trả; vui lòng liên hệ người bán hoặc quản trị viên.");
                }

                int orderId = createDepositedOrder(conn, productId, buyerId, sellerId, agreedPrice, depositAmount);
                try (PreparedStatement markSold = conn.prepareStatement("UPDATE products SET status = 'SOLD' WHERE id = ? AND status NOT IN ('DELETE', 'SOLD')")) {
                    markSold.setInt(1, productId);
                    if (markSold.executeUpdate() != 1) {
                        throw new SQLException("Không khóa được sản phẩm sau khi nhận cọc.");
                    }
                }
                cancelOtherPendingPayments(conn, productId, paymentId);
                updatePayment(conn, paymentId, "PAID", transactionNo, responseCode, orderId);
                addPaymentSystemMessage(conn, conversationId, buyerId, depositAmount);
                conn.commit();
                return new CallbackResult(true, "Thanh toán đặt cọc thành công.");
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    private int createDepositedOrder(Connection conn, int productId, int buyerId, int sellerId,
                                     double agreedPrice, double depositAmount) throws SQLException {
        String sql = "INSERT INTO orders (product_id, buyer_id, seller_id, agreed_price, deposit_amount, status) " +
                "VALUES (?, ?, ?, ?, ?, 'DEPOSITED')";
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, productId);
            ps.setInt(2, buyerId);
            ps.setInt(3, sellerId);
            ps.setDouble(4, agreedPrice);
            ps.setDouble(5, depositAmount);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        }
        throw new SQLException("Không tạo được đơn hàng sau khi thanh toán thành công.");
    }

    private void addPaymentSystemMessage(Connection conn, int conversationId, int buyerId, double depositAmount)
            throws SQLException {
        String sql = "INSERT INTO messages (conversation_id, sender_id, content, message_type) VALUES (?, ?, ?, 'SYSTEM')";
        String content = "VNPay đã xác nhận thanh toán đặt cọc " +
                java.text.NumberFormat.getIntegerInstance(new java.util.Locale("vi", "VN")).format(Math.round(depositAmount)) +
                " đ. Đơn hàng đã chuyển sang trạng thái ĐÃ ĐẶT CỌC.";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, conversationId);
            ps.setInt(2, buyerId);
            ps.setString(3, content);
            ps.executeUpdate();
        }
    }

    private void addPaymentConflictMessage(Connection conn, int conversationId, int buyerId) throws SQLException {
        String sql = "INSERT INTO messages (conversation_id, sender_id, content, message_type) VALUES (?, ?, ?, 'SYSTEM')";
        String content = "Sản phẩm đã được khách hàng khác đặt cọc trước. Giao dịch thanh toán này không tạo đơn hàng; khoản tiền cần được hoàn trả. Vui lòng liên hệ người bán hoặc quản trị viên để được hỗ trợ.";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, conversationId);
            ps.setInt(2, buyerId);
            ps.setString(3, content);
            ps.executeUpdate();
        }
    }

    private void cancelOtherPendingPayments(Connection conn, int productId, long winningPaymentId) throws SQLException {
        String sql = "UPDATE vnpay_payments SET status = 'CANCELLED' WHERE product_id = ? AND id <> ? " +
                "AND status = 'PENDING' AND expires_at > CURRENT_TIMESTAMP";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            ps.setLong(2, winningPaymentId);
            ps.executeUpdate();
        }
    }

    private void updatePayment(Connection conn, long paymentId, String status, String transactionNo,
                               String responseCode, Integer orderId) throws SQLException {
        String sql = "UPDATE vnpay_payments SET status = ?, vnp_transaction_no = ?, response_code = ?, " +
                "order_id = ?, paid_at = CASE WHEN ? = 'PAID' THEN CURRENT_TIMESTAMP ELSE paid_at END WHERE id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setString(2, transactionNo);
            ps.setString(3, responseCode);
            if (orderId == null) ps.setNull(4, java.sql.Types.INTEGER); else ps.setInt(4, orderId);
            ps.setString(5, status);
            ps.setLong(6, paymentId);
            ps.executeUpdate();
        }
    }

    public static class CallbackResult {
        public final boolean successful;
        public final String message;

        public CallbackResult(boolean successful, String message) {
            this.successful = successful;
            this.message = message;
        }
    }
}
