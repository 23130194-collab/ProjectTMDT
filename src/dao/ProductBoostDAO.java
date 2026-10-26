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
     * Người bán sử dụng 1 lượt đẩy tin từ Ví Lượt Đẩy Chung của tài khoản
     */
    public boolean useAvailableBump(int productId, int userId) {
        String checkWalletSql = "SELECT bump_credits FROM users WHERE id = ? FOR UPDATE";
        String updateWalletSql = "UPDATE users SET bump_credits = bump_credits - 1 WHERE id = ? AND bump_credits > 0";
        String bumpProductSql = "UPDATE products SET bumped_at = NOW() WHERE id = ? AND user_id = ?";

        // Hỗ trợ dự phòng lượt đẩy cũ gắn trên từng sản phẩm (nếu có từ trước)
        String checkProductSql = "SELECT remaining_bumps FROM products WHERE id = ? AND user_id = ? FOR UPDATE";
        String updateProductBumpSql = "UPDATE products SET bumped_at = NOW(), remaining_bumps = remaining_bumps - 1 " +
                                      "WHERE id = ? AND user_id = ? AND remaining_bumps > 0";

        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try {
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

                    conn.commit();
                    return true;
                }

                // 2. Dự phòng: Kiểm tra lượt đẩy riêng trên sản phẩm (nếu có tồn từ phiên bản trước)
                int prodBumps = 0;
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
}
