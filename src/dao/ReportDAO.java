package dao;

import model.Report;
import util.DBContext;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ReportDAO {

    public List<Report> getAll() {
        List<Report> list = new ArrayList<>();
        String sql = "SELECT r.*, u.full_name AS reporter_name, p.title AS product_title " +
                     "FROM reports r " +
                     "JOIN users u ON r.reporter_id = u.id " +
                     "JOIN products p ON r.product_id = p.id " +
                     "ORDER BY r.created_at DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(map(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public List<Report> getByStatus(String status) {
        List<Report> list = new ArrayList<>();
        String sql = "SELECT r.*, u.full_name AS reporter_name, p.title AS product_title " +
                     "FROM reports r " +
                     "JOIN users u ON r.reporter_id = u.id " +
                     "JOIN products p ON r.product_id = p.id " +
                     "WHERE r.status = ? ORDER BY r.created_at DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public int countPending() {
        String sql = "SELECT COUNT(*) FROM reports WHERE status = 'PENDING'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    public boolean insert(int reporterId, int productId, String reason) {
        String sql = "INSERT INTO reports (reporter_id, product_id, reason) VALUES (?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, reporterId);
            ps.setInt(2, productId);
            ps.setString(3, reason);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    public boolean updateStatus(int id, String status, String adminNote) {
        String sql = "UPDATE reports SET status = ?, admin_note = ? WHERE id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setString(2, adminNote);
            ps.setInt(3, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    private Report map(ResultSet rs) throws SQLException {
        Report r = new Report();
        r.setId(rs.getInt("id"));
        r.setReporterId(rs.getInt("reporter_id"));
        r.setProductId(rs.getInt("product_id"));
        r.setReason(rs.getString("reason"));
        r.setStatus(rs.getString("status"));
        r.setAdminNote(rs.getString("admin_note"));
        r.setCreatedAt(rs.getTimestamp("created_at"));
        r.setReporterName(rs.getString("reporter_name"));
        r.setProductTitle(rs.getString("product_title"));
        return r;
    }
}
