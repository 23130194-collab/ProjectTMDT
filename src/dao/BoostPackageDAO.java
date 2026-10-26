package dao;

import model.BoostPackage;
import util.DBContext;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BoostPackageDAO {

    // Lấy tất cả các gói đang hoạt động để người bán chọn mua
    public List<BoostPackage> getAllActivePackages() {
        List<BoostPackage> list = new ArrayList<>();
        String sql = "SELECT * FROM boost_packages WHERE is_active = 1 ORDER BY sort_order ASC, id ASC";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapResultSetToPackage(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // Lấy gói theo ID
    public BoostPackage getPackageById(int id) {
        String sql = "SELECT * FROM boost_packages WHERE id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToPackage(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // Lấy toàn bộ danh sách gói cho Admin quản lý
    public List<BoostPackage> getAllPackagesForAdmin() {
        List<BoostPackage> list = new ArrayList<>();
        String sql = "SELECT * FROM boost_packages ORDER BY sort_order ASC, id ASC";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapResultSetToPackage(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // Admin thêm gói mới
    public boolean insertPackage(BoostPackage pkg) {
        String sql = "INSERT INTO boost_packages (name, package_type, price, duration_days, bump_count, " +
                     "priority_level, badge_label, badge_color, description, is_active, sort_order) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, pkg.getName());
            ps.setString(2, pkg.getPackageType());
            ps.setDouble(3, pkg.getPrice());
            ps.setInt(4, pkg.getDurationDays());
            ps.setInt(5, pkg.getBumpCount());
            ps.setInt(6, pkg.getPriorityLevel());
            ps.setString(7, pkg.getBadgeLabel());
            ps.setString(8, pkg.getBadgeColor());
            ps.setString(9, pkg.getDescription());
            ps.setBoolean(10, pkg.isActive());
            ps.setInt(11, pkg.getSortOrder());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Admin chỉnh sửa gói
    public boolean updatePackage(BoostPackage pkg) {
        String sql = "UPDATE boost_packages SET name = ?, package_type = ?, price = ?, duration_days = ?, " +
                     "bump_count = ?, priority_level = ?, badge_label = ?, badge_color = ?, description = ?, " +
                     "is_active = ?, sort_order = ? WHERE id = ?";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, pkg.getName());
            ps.setString(2, pkg.getPackageType());
            ps.setDouble(3, pkg.getPrice());
            ps.setInt(4, pkg.getDurationDays());
            ps.setInt(5, pkg.getBumpCount());
            ps.setInt(6, pkg.getPriorityLevel());
            ps.setString(7, pkg.getBadgeLabel());
            ps.setString(8, pkg.getBadgeColor());
            ps.setString(9, pkg.getDescription());
            ps.setBoolean(10, pkg.isActive());
            ps.setInt(11, pkg.getSortOrder());
            ps.setInt(12, pkg.getId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Admin bật/tắt kích hoạt gói
    public boolean togglePackageStatus(int id, boolean active) {
        String sql = "UPDATE boost_packages SET is_active = ? WHERE id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setBoolean(1, active);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Helper map ResultSet
    private BoostPackage mapResultSetToPackage(ResultSet rs) throws SQLException {
        BoostPackage p = new BoostPackage();
        p.setId(rs.getInt("id"));
        p.setName(rs.getString("name"));
        p.setPackageType(rs.getString("package_type"));
        p.setPrice(rs.getDouble("price"));
        p.setDurationDays(rs.getInt("duration_days"));
        p.setBumpCount(rs.getInt("bump_count"));
        p.setPriorityLevel(rs.getInt("priority_level"));
        p.setBadgeLabel(rs.getString("badge_label"));
        p.setBadgeColor(rs.getString("badge_color"));
        p.setDescription(rs.getString("description"));
        p.setActive(rs.getBoolean("is_active"));
        p.setSortOrder(rs.getInt("sort_order"));
        p.setCreatedAt(rs.getTimestamp("created_at"));
        p.setUpdatedAt(rs.getTimestamp("updated_at"));
        return p;
    }
}
