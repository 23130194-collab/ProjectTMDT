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
                "payment_type VARCHAR(20) NOT NULL DEFAULT 'DEPOSIT'," +
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
            try { st.executeUpdate("ALTER TABLE vnpay_payments ADD COLUMN payment_type VARCHAR(20) NOT NULL DEFAULT 'DEPOSIT' AFTER deposit_amount"); } catch (SQLException ignored) {}
            try { st.executeUpdate("ALTER TABLE vnpay_payments ADD COLUMN order_id INT NULL"); } catch (SQLException ignored) {}
            try { st.executeUpdate("ALTER TABLE orders ADD COLUMN balance_payment_method VARCHAR(20) NOT NULL DEFAULT 'PENDING'"); } catch (SQLException ignored) {}
            try { st.executeUpdate("ALTER TABLE orders ADD COLUMN payment_status VARCHAR(20) NOT NULL DEFAULT 'UNPAID'"); } catch (SQLException ignored) {}
            try { st.executeUpdate("ALTER TABLE orders ADD COLUMN balance_expires_at TIMESTAMP NULL"); } catch (SQLException ignored) {}
            try { st.executeUpdate("ALTER TABLE orders ADD COLUMN balance_paid_at TIMESTAMP NULL"); } catch (SQLException ignored) {}
            try { st.executeUpdate("ALTER TABLE orders ADD COLUMN total_paid DECIMAL(15,2) NOT NULL DEFAULT 0"); } catch (SQLException ignored) {}
        } catch (SQLException e) {
            throw new IllegalStateException("Không thể tạo bảng lưu giao dịch VNPay.", e);
        }
    }

    public void createPending(String txnRef, int conversationId, int buyerId, int sellerId, int productId,
                              double agreedPrice, double depositAmount, Timestamp expiresAt) throws SQLException {
        createPending(txnRef, conversationId, buyerId, sellerId, productId, agreedPrice, depositAmount, expiresAt, "DEPOSIT");
    }

    public void createPendingBalance(String txnRef, int orderId, int buyerId, Timestamp expiresAt) throws SQLException {
        ensureTable();
        String sql = "INSERT INTO vnpay_payments (txn_ref, conversation_id, buyer_id, seller_id, product_id, agreed_price, deposit_amount, payment_type, status, order_id, expires_at) " +
                "SELECT ?, c.id, o.buyer_id, o.seller_id, o.product_id, o.agreed_price, o.agreed_price - o.deposit_amount, 'BALANCE', 'PENDING', o.id, ? " +
                "FROM orders o JOIN conversations c ON c.product_id=o.product_id AND c.buyer_id=o.buyer_id AND c.seller_id=o.seller_id " +
                "WHERE o.id=? AND o.buyer_id=? AND o.status IN ('DEPOSITED','SHIPPING') AND o.balance_payment_method='TRANSFER' AND o.balance_expires_at>CURRENT_TIMESTAMP AND o.total_paid<o.agreed_price ORDER BY c.id DESC LIMIT 1";
        try (Connection c = DBContext.getConnection()) {
            c.setAutoCommit(false);
            try {
                try (PreparedStatement cancelOld = c.prepareStatement("UPDATE vnpay_payments SET status='CANCELLED' WHERE order_id=? AND payment_type='BALANCE' AND status='PENDING'")) {
                    cancelOld.setInt(1, orderId); cancelOld.executeUpdate();
                }
                try (PreparedStatement ps = c.prepareStatement(sql)) {
                    ps.setString(1, txnRef); ps.setTimestamp(2, expiresAt); ps.setInt(3, orderId); ps.setInt(4, buyerId);
                    if (ps.executeUpdate() != 1) throw new SQLException("Đơn hàng không còn trong thời hạn thanh toán chuyển khoản.");
                }
                c.commit();
            } catch (SQLException e) { c.rollback(); throw e; }
            finally { c.setAutoCommit(true); }
        }
    }

    public void createPending(String txnRef, int conversationId, int buyerId, int sellerId, int productId,
                              double agreedPrice, double depositAmount, Timestamp expiresAt, String paymentType) throws SQLException {
        ensureTable();
        String activePaymentSql = "SELECT COUNT(*) FROM vnpay_payments WHERE conversation_id = ? " +
                "AND (status = 'PAID' OR (status = 'PENDING' AND expires_at > CURRENT_TIMESTAMP))";
        String lockProductSql = "SELECT p.status, NOT EXISTS (SELECT 1 FROM orders o WHERE o.product_id = p.id " +
                "AND o.status IN ('DEPOSITED', 'SHIPPING', 'COMPLETED')) AS is_available FROM products p WHERE p.id = ? FOR UPDATE";
        String lockSql = "SELECT id FROM conversations WHERE id = ? FOR UPDATE";
        String insertSql = "INSERT INTO vnpay_payments " +
                "(txn_ref, conversation_id, buyer_id, seller_id, product_id, agreed_price, deposit_amount, payment_type, status, expires_at) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'PENDING', ?)";
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
                    ps.setString(8, paymentType);
                    ps.setTimestamp(9, expiresAt);
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
        String selectSql = "SELECT id, conversation_id, product_id, buyer_id, seller_id, agreed_price, deposit_amount, payment_type, order_id, status, expires_at " +
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
                String paymentType;
                int existingOrderId;
                String status;
                Timestamp paymentExpiresAt;
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
                        paymentType = rs.getString("payment_type");
                        existingOrderId = rs.getInt("order_id");
                        status = rs.getString("status");
                        paymentExpiresAt = rs.getTimestamp("expires_at");
                    }
                }
                if (productId != lockedProductId) {
                    conn.rollback();
                    return new CallbackResult(false, "Thông tin sản phẩm của giao dịch không hợp lệ.");
                }

                double expectedAmount = "FULL".equalsIgnoreCase(paymentType) ? agreedPrice : depositAmount;
                if (paidAmount != Math.round(expectedAmount * 100)) {
                    conn.rollback();
                    return new CallbackResult(false, "Số tiền giao dịch không hợp lệ.");
                }
                if ("PAID".equals(status)) {
                    conn.commit();
                    return new CallbackResult(true, "Giao dịch đã được ghi nhận trước đó.", existingOrderId, paymentType);
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
                if (paymentExpiresAt == null || paymentExpiresAt.getTime() <= System.currentTimeMillis()) {
                    updatePayment(conn, paymentId, "REFUND_REQUIRED", transactionNo, responseCode, existingOrderId > 0 ? existingOrderId : null);
                    conn.commit();
                    return new CallbackResult(false, "Thanh toán đến sau thời hạn. Khoản tiền cần được hoàn trả; vui lòng liên hệ quản trị viên.");
                }

                if ("BALANCE".equalsIgnoreCase(paymentType)) {
                    try (PreparedStatement settle = conn.prepareStatement(
                            "UPDATE orders SET total_paid = agreed_price, payment_status='PAID', balance_paid_at = CURRENT_TIMESTAMP, status = 'DEPOSITED' " +
                                    "WHERE id = ? AND buyer_id = ? AND balance_payment_method = 'TRANSFER' AND balance_expires_at > CURRENT_TIMESTAMP AND status IN ('DEPOSITED','SHIPPING')")) {
                        settle.setInt(1, existingOrderId);
                        settle.setInt(2, buyerId);
                        if (settle.executeUpdate() != 1) {
                            updatePayment(conn, paymentId, "REFUND_REQUIRED", transactionNo, responseCode, existingOrderId);
                            conn.commit();
                            return new CallbackResult(false, "Đơn hàng đã hết hạn hoặc không còn đủ điều kiện thanh toán; khoản tiền cần được hoàn trả.");
                        }
                    }
                    updatePayment(conn, paymentId, "PAID", transactionNo, responseCode, existingOrderId);
                    try (PreparedStatement cancelDuplicates = conn.prepareStatement("UPDATE vnpay_payments SET status='CANCELLED' WHERE order_id=? AND id<>? AND payment_type='BALANCE' AND status='PENDING'")) {
                        cancelDuplicates.setInt(1, existingOrderId);
                        cancelDuplicates.setLong(2, paymentId);
                        cancelDuplicates.executeUpdate();
                    }
                    conn.commit();
                    return new CallbackResult(true, "Thanh toán phần còn lại thành công.", existingOrderId, paymentType);
                }

                if ("DELETE".equalsIgnoreCase(lockedProductStatus) || "SOLD".equalsIgnoreCase(lockedProductStatus) || !lockedProductAvailable) {
                    updatePayment(conn, paymentId, "REFUND_REQUIRED", transactionNo, responseCode, null);
                    addPaymentConflictMessage(conn, conversationId, buyerId);
                    conn.commit();
                    return new CallbackResult(false, "Sản phẩm đã được người khác đặt cọc. Khoản thanh toán này cần được hoàn trả; vui lòng liên hệ người bán hoặc quản trị viên.");
                }

                int orderId = createDepositedOrder(conn, productId, buyerId, sellerId, agreedPrice,
                        "FULL".equalsIgnoreCase(paymentType) ? 0 : depositAmount,
                        "FULL".equalsIgnoreCase(paymentType));
                try (PreparedStatement markSold = conn.prepareStatement("UPDATE products SET status = 'SOLD' WHERE id = ? AND status NOT IN ('DELETE', 'SOLD')")) {
                    markSold.setInt(1, productId);
                    if (markSold.executeUpdate() != 1) {
                        throw new SQLException("Không khóa được sản phẩm sau khi nhận cọc.");
                    }
                }
                cancelOtherPendingPayments(conn, productId, paymentId);
                updatePayment(conn, paymentId, "PAID", transactionNo, responseCode, orderId);
                boolean paidInFull = "FULL".equalsIgnoreCase(paymentType);
                addPaymentSystemMessage(conn, conversationId, buyerId, paidInFull ? agreedPrice : depositAmount, paidInFull);
                sendOrderPlacedNotifications(conn, orderId, productId, buyerId, sellerId, paidInFull ? agreedPrice : depositAmount);
                conn.commit();
                return new CallbackResult(true, "FULL".equalsIgnoreCase(paymentType) ? "Thanh toán toàn bộ thành công." : "Thanh toán đặt cọc thành công.", orderId, paymentType);
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    public void expireUnpaidBalanceOrders() {
        ensureTable();
        String sql = "UPDATE orders SET status='CANCELLED' WHERE status IN ('DEPOSITED','SHIPPING') AND balance_payment_method='TRANSFER' AND total_paid<agreed_price AND balance_expires_at<=CURRENT_TIMESTAMP";
        String cancelPending = "UPDATE vnpay_payments vp JOIN orders o ON o.id=vp.order_id SET vp.status='CANCELLED' WHERE vp.payment_type='BALANCE' AND vp.status='PENDING' AND o.status='CANCELLED' AND o.balance_expires_at<=CURRENT_TIMESTAMP";
        String reopen = "UPDATE products p JOIN orders o ON o.product_id=p.id SET p.status='ACTIVE' WHERE o.status='CANCELLED' AND o.balance_payment_method='TRANSFER' AND o.balance_expires_at<=CURRENT_TIMESTAMP AND p.status='SOLD' AND NOT EXISTS (SELECT 1 FROM orders active_o WHERE active_o.product_id=p.id AND active_o.id<>o.id AND active_o.status IN ('DEPOSITED','SHIPPING','COMPLETED'))";
        try (Connection c=DBContext.getConnection(); Statement st=c.createStatement()) {
            c.setAutoCommit(false);
            java.util.List<int[]> expired = new java.util.ArrayList<>();
            try (PreparedStatement find=c.prepareStatement("SELECT id,buyer_id FROM orders WHERE status IN ('DEPOSITED','SHIPPING') AND balance_payment_method='TRANSFER' AND total_paid<agreed_price AND balance_expires_at<=CURRENT_TIMESTAMP"); ResultSet rs=find.executeQuery()) {
                while (rs.next()) expired.add(new int[]{rs.getInt("id"), rs.getInt("buyer_id")});
            }
            st.executeUpdate(sql); st.executeUpdate(cancelPending); st.executeUpdate(reopen);
            NotificationDAO notifications = new NotificationDAO();
            for (int[] order : expired) {
                notifications.createNotification(c, order[1], "Đơn hàng đã tự hủy do quá hạn thanh toán",
                        "Đơn hàng #" + order[0] + " đã bị hủy vì quá 24 giờ chưa thanh toán phần còn lại. Khoản tiền cọc không được hoàn lại.",
                        "ORDER_CANCELLED", "05-quan-ly-don-hang.jsp?orderId=" + order[0]);
            }
            c.commit();
        } catch (SQLException | IllegalStateException e) { e.printStackTrace(); }
    }

    private int createDepositedOrder(Connection conn, int productId, int buyerId, int sellerId,
                                     double agreedPrice, double depositAmount, boolean paidInFull) throws SQLException {
        String sql = "INSERT INTO orders (product_id, buyer_id, seller_id, agreed_price, deposit_amount, total_paid, balance_payment_method, payment_status, delivery_method, status) " +
                "SELECT ?, ?, ?, ?, ?, ?, ?, ?, COALESCE(delivery_method, 1), 'DEPOSITED' FROM products WHERE id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, productId);
            ps.setInt(2, buyerId);
            ps.setInt(3, sellerId);
            ps.setDouble(4, agreedPrice);
            ps.setDouble(5, depositAmount);
            ps.setDouble(6, paidInFull ? agreedPrice : depositAmount);
            ps.setString(7, paidInFull ? "PAID" : "PENDING");
            ps.setString(8, paidInFull ? "PAID" : "PARTIALLY_PAID");
            ps.setInt(9, productId);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        }
        throw new SQLException("Không tạo được đơn hàng sau khi thanh toán thành công.");
    }

    private void addPaymentSystemMessage(Connection conn, int conversationId, int buyerId, double depositAmount, boolean paidInFull)
            throws SQLException {
        String sql = "INSERT INTO messages (conversation_id, sender_id, content, message_type) VALUES (?, ?, ?, 'SYSTEM')";
        String content = "VNPay đã xác nhận thanh toán " + (paidInFull ? "toàn bộ " : "đặt cọc ") +
                java.text.NumberFormat.getIntegerInstance(new java.util.Locale("vi", "VN")).format(Math.round(depositAmount)) +
                " đ. Đơn hàng đã chuyển sang trạng thái " + (paidInFull ? "ĐÃ THANH TOÁN." : "ĐÃ ĐẶT CỌC.");
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, conversationId);
            ps.setInt(2, buyerId);
            ps.setString(3, content);
            ps.executeUpdate();
        }
    }

    private void sendOrderPlacedNotifications(Connection conn, int orderId, int productId, int buyerId, int sellerId, double depositAmount) {
        try {
            String productTitle = "Sản phẩm #" + productId;
            String getProductSql = "SELECT title FROM products WHERE id = ?";
            try (PreparedStatement ps = conn.prepareStatement(getProductSql)) {
                ps.setInt(1, productId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next() && rs.getString("title") != null) {
                        productTitle = rs.getString("title");
                    }
                }
            }
            String buyerName = "Người mua #" + buyerId;
            String getBuyerSql = "SELECT full_name FROM users WHERE id = ?";
            try (PreparedStatement ps = conn.prepareStatement(getBuyerSql)) {
                ps.setInt(1, buyerId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next() && rs.getString("full_name") != null && !rs.getString("full_name").trim().isEmpty()) {
                        buyerName = rs.getString("full_name").trim();
                    }
                }
            }

            String formattedDeposit = java.text.NumberFormat.getIntegerInstance(new java.util.Locale("vi", "VN")).format(Math.round(depositAmount)) + " đ";
            String targetUrl = "05-quan-ly-don-hang.jsp?orderId=" + orderId;

            NotificationDAO notifDAO = new NotificationDAO();
            // 1. Thông báo cho Người Mua
            notifDAO.createNotification(conn, buyerId,
                    "Thanh toán thành công đơn hàng #" + orderId,
                    "Bạn đã thanh toán " + formattedDeposit + " cho sản phẩm \"" + productTitle + "\". Đơn hàng đã được tạo.",
                    "ORDER_PLACED",
                    targetUrl);

            // 2. Thông báo cho Người Bán
            notifDAO.createNotification(conn, sellerId,
                    "Đơn hàng mới #" + orderId,
                    buyerName + " đã thanh toán " + formattedDeposit + " cho sản phẩm \"" + productTitle + "\". Vui lòng chuẩn bị và giao hàng cho người mua.",
                    "NEW_ORDER",
                    targetUrl);
        } catch (Exception e) {
            System.err.println("[VnPayPaymentDAO] Lỗi gửi thông báo đặt hàng: " + e.getMessage());
            e.printStackTrace();
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
        public final int orderId;
        public final String paymentType;

        public CallbackResult(boolean successful, String message) {
            this(successful, message, 0, null);
        }

        public CallbackResult(boolean successful, String message, int orderId, String paymentType) {
            this.successful = successful;
            this.message = message;
            this.orderId = orderId;
            this.paymentType = paymentType;
        }
    }
}
