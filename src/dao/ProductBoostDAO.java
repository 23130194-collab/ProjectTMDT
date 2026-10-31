package dao;

import model.BoostPackage;
import model.ProductBoost;
import util.DBContext;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ProductBoostDAO {

    /**
     * Kích hoạt gói đẩy tin / ghim VIP sau khi thanh toán thành công
     */
    public boolean applyBoostPackage(Integer productId, int userId, BoostPackage pkg, String vnpTxnRef, double amountPaid) {
        String insertBoostSql = "INSERT INTO product_boosts (product_id, user_id, package_id, package_type, amount_paid, " +
                                "start_time, end_time, remaining_bumps, vnp_txn_ref, status) " +
                                "VALUES (?, ?, ?, ?, ?, NOW(), ?, ?, ?, 'ACTIVE')";

        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);

            try {
                Timestamp endTime = null;
                int bumpsAddedToWallet = 0;

                if (pkg.isVipPackage()) {
                    if (productId == null || productId <= 0) {
                        conn.rollback();
                        return false;
                    }

                    // Lấy pinned_until hiện tại nếu bài viết đang được ghim để cộng dồn thêm ngày
                    Timestamp currentPinnedUntil = null;
                    String checkSql = "SELECT pinned_until FROM products WHERE id = ? FOR UPDATE";
                    try (PreparedStatement psCheck = conn.prepareStatement(checkSql)) {
                        psCheck.setInt(1, productId);
                        try (ResultSet rs = psCheck.executeQuery()) {
                            if (rs.next()) {
                                currentPinnedUntil = rs.getTimestamp("pinned_until");
                            }
                        }
                    }

                    long baseTime = System.currentTimeMillis();
                    if (currentPinnedUntil != null && currentPinnedUntil.getTime() > baseTime) {
                        baseTime = currentPinnedUntil.getTime();
                    }
                    long extraMillis = (long) pkg.getDurationDays() * 24 * 60 * 60 * 1000;
                    endTime = new Timestamp(baseTime + extraMillis);

                    // Cập nhật bảng products
                    String updateProductSql = "UPDATE products SET is_pinned = 1, pinned_until = ?, " +
                                              "priority_level = GREATEST(priority_level, ?) WHERE id = ?";
                    try (PreparedStatement psProd = conn.prepareStatement(updateProductSql)) {
                        psProd.setTimestamp(1, endTime);
                        psProd.setInt(2, pkg.getPriorityLevel());
                        psProd.setInt(3, productId);
                        psProd.executeUpdate();
                    }
                } else if (pkg.isBumpPackage()) {
                    int totalBumps = pkg.getBumpCount();

                    if (productId != null && productId > 0) {
                        // Người dùng mua gói đẩy kèm một bài đăng cụ thể:
                        // 1. Đẩy bài đăng này lên đầu ngay lập tức 1 lần
                        String updateProductSql = "UPDATE products SET bumped_at = NOW() WHERE id = ? AND user_id = ?";
                        try (PreparedStatement psProd = conn.prepareStatement(updateProductSql)) {
                            psProd.setInt(1, productId);
                            psProd.setInt(2, userId);
                            psProd.executeUpdate();
                        }

                        // 2. Các lượt còn lại (totalBumps - 1) cộng vào Ví Lượt Đẩy Chung của người dùng
                        bumpsAddedToWallet = Math.max(0, totalBumps - 1);
                        if (bumpsAddedToWallet > 0) {
                            String updateWalletSql = "UPDATE users SET bump_credits = bump_credits + ? WHERE id = ?";
                            try (PreparedStatement psWallet = conn.prepareStatement(updateWalletSql)) {
                                psWallet.setInt(1, bumpsAddedToWallet);
                                psWallet.setInt(2, userId);
                                psWallet.executeUpdate();
                            }
                        }
                    } else {
                        // Người dùng nạp trực tiếp vào Ví Lượt Đẩy: Tất cả lượt được cộng vào tài khoản
                        bumpsAddedToWallet = totalBumps;
                        String updateWalletSql = "UPDATE users SET bump_credits = bump_credits + ? WHERE id = ?";
                        try (PreparedStatement psWallet = conn.prepareStatement(updateWalletSql)) {
                            psWallet.setInt(1, bumpsAddedToWallet);
                            psWallet.setInt(2, userId);
                            psWallet.executeUpdate();
                        }
                    }
                }

                // Ghi vào bảng product_boosts
                try (PreparedStatement psBoost = conn.prepareStatement(insertBoostSql)) {
                    if (productId != null && productId > 0) {
                        psBoost.setInt(1, productId);
                    } else {
                        psBoost.setNull(1, Types.INTEGER);
                    }
                    psBoost.setInt(2, userId);
                    psBoost.setInt(3, pkg.getId());
                    psBoost.setString(4, pkg.getPackageType());
                    psBoost.setDouble(5, amountPaid);
                    psBoost.setTimestamp(6, endTime);
                    psBoost.setInt(7, bumpsAddedToWallet);
                    psBoost.setString(8, vnpTxnRef);
                    psBoost.executeUpdate();
                }

                // Gửi thông báo hệ thống (In-App Notification) cho người dùng
                NotificationDAO notiDAO = new NotificationDAO();
                if (pkg.isVipPackage() && productId != null && productId > 0) {
                    String prodTitle = "tin đăng";
                    try (PreparedStatement psT = conn.prepareStatement("SELECT title FROM products WHERE id = ?")) {
                        psT.setInt(1, productId);
                        try (ResultSet rsT = psT.executeQuery()) {
                            if (rsT.next()) prodTitle = rsT.getString("title");
                        }
                    }
                    notiDAO.createNotification(conn, userId,
                        "👑 Kích hoạt VIP thành công",
                        "Tin đăng '" + prodTitle + "' đã được nâng cấp lên gói " + pkg.getName() + " thành công!",
                        "PROMOTION",
                        "product-detail?id=" + productId);
                } else if (pkg.isBumpPackage()) {
                    notiDAO.createNotification(conn, userId,
                        "🚀 Nạp Ví Lượt Đẩy thành công",
                        "Bạn đã nạp thành công " + pkg.getName() + ". Đã cộng " + bumpsAddedToWallet + " lượt đẩy vào ví tài khoản.",
                        "PROMOTION",
                        (productId != null && productId > 0) ? ("product-detail?id=" + productId) : "my-posts");
                }

                conn.commit();
                return true;
            } catch (SQLException e) {
                conn.rollback();
                e.printStackTrace();
                return false;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Người bán sử dụng 1 lượt đẩy tin từ Ví Lượt Đẩy Chung của tài khoản (có kiểm tra Cooldown 5 phút chống spam)
     */
    public boolean useAvailableBump(int productId, int userId) {
        String checkWalletSql = "SELECT bump_credits FROM users WHERE id = ? FOR UPDATE";
        String updateWalletSql = "UPDATE users SET bump_credits = bump_credits - 1 WHERE id = ? AND bump_credits > 0";
        String bumpProductSql = "UPDATE products SET bumped_at = NOW() WHERE id = ? AND user_id = ?";

        // Hỗ trợ dự phòng lượt đẩy cũ gắn trên từng sản phẩm (nếu có từ trước)
        String checkProductSql = "SELECT bumped_at, remaining_bumps FROM products WHERE id = ? AND user_id = ? FOR UPDATE";
        String updateProductBumpSql = "UPDATE products SET bumped_at = NOW(), remaining_bumps = remaining_bumps - 1 " +
                                      "WHERE id = ? AND user_id = ? AND remaining_bumps > 0";

        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try {
                // 0. Cooldown Anti-Spam: Kiểm tra xem bài đăng vừa được đẩy trong vòng 5 phút qua không
                Timestamp lastBumped = null;
                int prodBumps = 0;
                try (PreparedStatement psCheckProd = conn.prepareStatement(checkProductSql)) {
                    psCheckProd.setInt(1, productId);
                    psCheckProd.setInt(2, userId);
                    try (ResultSet rsProd = psCheckProd.executeQuery()) {
                        if (rsProd.next()) {
                            lastBumped = rsProd.getTimestamp("bumped_at");
                            prodBumps = rsProd.getInt("remaining_bumps");
                        } else {
                            conn.rollback();
                            return false;
                        }
                    }
                }

                if (lastBumped != null) {
                    long diffMillis = System.currentTimeMillis() - lastBumped.getTime();
                    long cooldownMillis = 5L * 60 * 1000; // 5 phút
                    if (diffMillis < cooldownMillis) {
                        conn.rollback();
                        return false; // Còn trong thời gian cooldown
                    }
                }

                // 1. Kiểm tra Ví lượt đẩy chung của tài khoản trước
                int walletCredits = 0;
                try (PreparedStatement ps = conn.prepareStatement(checkWalletSql)) {
                    ps.setInt(1, userId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            walletCredits = rs.getInt("bump_credits");
                        }
                    }
                }

                if (walletCredits > 0) {
                    // Trừ 1 lượt từ Ví chung
                    try (PreparedStatement psWallet = conn.prepareStatement(updateWalletSql)) {
                        psWallet.setInt(1, userId);
                        psWallet.executeUpdate();
                    }

                    // Đẩy tin bài đăng
                    try (PreparedStatement psBump = conn.prepareStatement(bumpProductSql)) {
                        psBump.setInt(1, productId);
                        psBump.setInt(2, userId);
                        psBump.executeUpdate();
                    }

                    // Gửi thông báo đẩy tin thành công
                    String prodTitle = "tin đăng";
                    try (PreparedStatement psT = conn.prepareStatement("SELECT title FROM products WHERE id = ?")) {
                        psT.setInt(1, productId);
                        try (ResultSet rsT = psT.executeQuery()) {
                            if (rsT.next()) prodTitle = rsT.getString("title");
                        }
                    }
                    new NotificationDAO().createNotification(conn, userId,
                        "🚀 Đẩy tin thành công",
                        "Tin đăng '" + prodTitle + "' đã được đưa lên đầu danh mục.",
                        "SYSTEM",
                        "product-detail?id=" + productId);

                    conn.commit();
                    return true;
                }

                // 2. Dự phòng: Kiểm tra lượt đẩy riêng trên sản phẩm (nếu có tồn từ phiên bản trước)
                prodBumps = 0;
                try (PreparedStatement psProd = conn.prepareStatement(checkProductSql)) {
                    psProd.setInt(1, productId);
                    psProd.setInt(2, userId);
                    try (ResultSet rs = psProd.executeQuery()) {
                        if (rs.next()) {
                            prodBumps = rs.getInt("remaining_bumps");
                        }
                    }
                }

                if (prodBumps > 0) {
                    try (PreparedStatement psUpdateProd = conn.prepareStatement(updateProductBumpSql)) {
                        psUpdateProd.setInt(1, productId);
                        psUpdateProd.setInt(2, userId);
                        psUpdateProd.executeUpdate();
                    }

                    // Gửi thông báo đẩy tin thành công
                    String prodTitle = "tin đăng";
                    try (PreparedStatement psT = conn.prepareStatement("SELECT title FROM products WHERE id = ?")) {
                        psT.setInt(1, productId);
                        try (ResultSet rsT = psT.executeQuery()) {
                            if (rsT.next()) prodTitle = rsT.getString("title");
                        }
                    }
                    new NotificationDAO().createNotification(conn, userId,
                        "🚀 Đẩy tin thành công",
                        "Tin đăng '" + prodTitle + "' đã được đưa lên đầu danh mục.",
                        "SYSTEM",
                        "product-detail?id=" + productId);

                    conn.commit();
                    return true;
                }

                // Hết lượt đẩy
                conn.rollback();
                return false;
            } catch (SQLException e) {
                conn.rollback();
                e.printStackTrace();
                return false;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Lấy toàn bộ lịch sử mua gói đẩy tin phục vụ Admin
     */
    public List<ProductBoost> getAllBoostHistoryForAdmin() {
        List<ProductBoost> list = new ArrayList<>();
        String sql = "SELECT pb.*, bp.name AS package_name, bp.badge_label, bp.badge_color, " +
                     "p.title AS product_title, u.full_name AS user_fullname " +
                     "FROM product_boosts pb " +
                     "LEFT JOIN boost_packages bp ON pb.package_id = bp.id " +
                     "LEFT JOIN products p ON pb.product_id = p.id " +
                     "LEFT JOIN users u ON pb.user_id = u.id " +
                     "ORDER BY pb.id DESC";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                ProductBoost b = new ProductBoost();
                b.setId(rs.getInt("id"));
                b.setProductId(rs.getInt("product_id"));
                b.setUserId(rs.getInt("user_id"));
                b.setPackageId(rs.getInt("package_id"));
                b.setPackageType(rs.getString("package_type"));
                b.setAmountPaid(rs.getDouble("amount_paid"));
                b.setStartTime(rs.getTimestamp("start_time"));
                b.setEndTime(rs.getTimestamp("end_time"));
                b.setRemainingBumps(rs.getInt("remaining_bumps"));
                b.setVnpTxnRef(rs.getString("vnp_txn_ref"));
                b.setStatus(rs.getString("status"));
                b.setCreatedAt(rs.getTimestamp("created_at"));
                b.setPackageName(rs.getString("package_name"));
                b.setBadgeLabel(rs.getString("badge_label"));
                b.setBadgeColor(rs.getString("badge_color"));
                b.setProductTitle(rs.getString("product_title"));
                b.setUserFullName(rs.getString("user_fullname"));
                list.add(b);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Thống kê tổng doanh thu từ dịch vụ Đẩy tin & Ghim VIP
     */
    public double getTotalBoostRevenue() {
        String sql = "SELECT COALESCE(SUM(amount_paid), 0) FROM product_boosts";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getDouble(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Đếm tổng số lượt mua gói
     */
    public int countTotalBoostOrders() {
        String sql = "SELECT COUNT(*) FROM product_boosts";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Lấy N giao dịch gói dịch vụ mới nhất cho Dashboard
     */
    public List<ProductBoost> getRecentBoostHistory(int limit) {
        List<ProductBoost> list = new ArrayList<>();
        int safeLimit = limit > 0 ? limit : 5;
        String sql = "SELECT pb.*, bp.name AS package_name, bp.badge_label, bp.badge_color, " +
                     "p.title AS product_title, u.full_name AS user_fullname " +
                     "FROM product_boosts pb " +
                     "LEFT JOIN boost_packages bp ON pb.package_id = bp.id " +
                     "LEFT JOIN products p ON pb.product_id = p.id " +
                     "LEFT JOIN users u ON pb.user_id = u.id " +
                     "ORDER BY pb.id DESC LIMIT ?";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, safeLimit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProductBoost b = new ProductBoost();
                    b.setId(rs.getInt("id"));
                    b.setProductId(rs.getInt("product_id"));
                    b.setUserId(rs.getInt("user_id"));
                    b.setPackageId(rs.getInt("package_id"));
                    b.setPackageType(rs.getString("package_type"));
                    b.setAmountPaid(rs.getDouble("amount_paid"));
                    b.setStartTime(rs.getTimestamp("start_time"));
                    b.setEndTime(rs.getTimestamp("end_time"));
                    b.setRemainingBumps(rs.getInt("remaining_bumps"));
                    b.setVnpTxnRef(rs.getString("vnp_txn_ref"));
                    b.setStatus(rs.getString("status"));
                    b.setCreatedAt(rs.getTimestamp("created_at"));
                    b.setPackageName(rs.getString("package_name"));
                    b.setBadgeLabel(rs.getString("badge_label"));
                    b.setBadgeColor(rs.getString("badge_color"));
                    b.setProductTitle(rs.getString("product_title"));
                    b.setUserFullName(rs.getString("user_fullname"));
                    list.add(b);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Đếm số lượng tin đăng hiện đang kích hoạt VIP còn hạn
     */
    public int getActiveVipCount() {
        String sql = "SELECT COUNT(*) FROM products WHERE is_pinned = 1 AND pinned_until > NOW()";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Doanh thu dịch vụ trong khoảng ngày [fromDate, toDate]
     */
    public double getRevenueBetween(String fromDate, String toDate) {
        String sql = "SELECT COALESCE(SUM(amount_paid), 0) FROM product_boosts " +
                     "WHERE created_at >= ? AND created_at < DATE_ADD(?, INTERVAL 1 DAY)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, fromDate);
            ps.setString(2, toDate);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Tự động quét và xử lý:
     * 1. Bài VIP đã hết hạn: gỡ is_pinned = 0, priority_level = 0, chuyển status = 'EXPIRED', gửi thông báo đã hoàn thành.
     * 2. Bài VIP sắp hết hạn trong 24h: gửi thông báo nhắc gia hạn để giữ vị trí VIP (không gửi trùng trong 24h).
     */
    public void scanAndProcessBoostExpiry() {
        try (Connection conn = DBContext.getConnection()) {
            NotificationDAO notiDAO = new NotificationDAO();

            // 1. Xử lý các bài VIP ĐÃ HẾT HẠN (pinned_until <= NOW())
            String expiredSql = "SELECT id, user_id, title FROM products WHERE is_pinned = 1 AND pinned_until <= NOW()";
            List<int[]> expiredList = new ArrayList<>();
            List<String> expiredTitles = new ArrayList<>();
            try (PreparedStatement ps = conn.prepareStatement(expiredSql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    expiredList.add(new int[]{rs.getInt("id"), rs.getInt("user_id")});
                    expiredTitles.add(rs.getString("title"));
                }
            }

            for (int i = 0; i < expiredList.size(); i++) {
                int prodId = expiredList.get(i)[0];
                int userId = expiredList.get(i)[1];
                String title = expiredTitles.get(i);

                // Cập nhật bảng products
                try (PreparedStatement psUp = conn.prepareStatement("UPDATE products SET is_pinned = 0, priority_level = 0 WHERE id = ?")) {
                    psUp.setInt(1, prodId);
                    psUp.executeUpdate();
                }

                // Cập nhật product_boosts
                try (PreparedStatement psBoost = conn.prepareStatement("UPDATE product_boosts SET status = 'EXPIRED' WHERE product_id = ? AND status = 'ACTIVE' AND end_time <= NOW()")) {
                    psBoost.setInt(1, prodId);
                    psBoost.executeUpdate();
                }

                // Gửi thông báo hết hạn
                notiDAO.createNotification(conn, userId,
                    "⌛ Gói VIP đã hoàn thành",
                    "Tin đăng '" + title + "' đã hoàn thành thời gian ghim VIP. Bạn có thể gia hạn bất kỳ lúc nào để tiếp tục ghim đầu trang!",
                    "SYSTEM",
                    "product-detail?id=" + prodId);
            }

            // 2. Xử lý các bài VIP SẮP HẾT HẠN trong vòng 24 giờ
            String expiringSql = "SELECT p.id, p.user_id, p.title, p.pinned_until FROM products p " +
                                 "WHERE p.is_pinned = 1 AND p.pinned_until > NOW() " +
                                 "AND p.pinned_until <= DATE_ADD(NOW(), INTERVAL 24 HOUR) " +
                                 "AND NOT EXISTS (" +
                                 "  SELECT 1 FROM notifications n WHERE n.user_id = p.user_id " +
                                 "  AND n.type = 'BOOST_EXPIRING' AND n.target_url = CONCAT('product-detail?id=', p.id) " +
                                 "  AND n.created_at >= DATE_SUB(NOW(), INTERVAL 24 HOUR)" +
                                 ")";

            try (PreparedStatement psExp = conn.prepareStatement(expiringSql);
                 ResultSet rsExp = psExp.executeQuery()) {
                while (rsExp.next()) {
                    int prodId = rsExp.getInt("id");
                    int userId = rsExp.getInt("user_id");
                    String title = rsExp.getString("title");
                    Timestamp pUntil = rsExp.getTimestamp("pinned_until");
                    String dateStr = pUntil != null ? new java.text.SimpleDateFormat("HH:mm dd/MM").format(pUntil) : "sớm";

                    notiDAO.createNotification(conn, userId,
                        "⏳ Gói VIP sắp hết hạn trong 24h",
                        "Tin đăng '" + title + "' sẽ hết hạn VIP vào lúc " + dateStr + ". Hãy gia hạn ngay hôm nay để duy trì vị trí ghim nổi bật!",
                        "BOOST_EXPIRING",
                        "product-detail?id=" + prodId);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}

