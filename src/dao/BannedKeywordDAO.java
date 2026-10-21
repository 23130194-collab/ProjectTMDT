package dao;

import model.BannedKeyword;
import util.DBContext;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BannedKeywordDAO {

    public List<BannedKeyword> getAll() {
        List<BannedKeyword> list = new ArrayList<>();
        String sql = "SELECT * FROM banned_keywords ORDER BY created_at DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(map(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public List<BannedKeyword> getActive() {
        List<BannedKeyword> list = new ArrayList<>();
        String sql = "SELECT * FROM banned_keywords WHERE is_active = TRUE";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(map(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public boolean insert(BannedKeyword kw) {
        String sql = "INSERT INTO banned_keywords (keyword, is_regex, description, is_active) VALUES (?, ?, ?, TRUE)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, kw.getKeyword());
            ps.setBoolean(2, kw.isRegex());
            ps.setString(3, kw.getDescription());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    public boolean toggleActive(int id, boolean active) {
        String sql = "UPDATE banned_keywords SET is_active = ? WHERE id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, active);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    public boolean delete(int id) {
        String sql = "DELETE FROM banned_keywords WHERE id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    private BannedKeyword map(ResultSet rs) throws SQLException {
        BannedKeyword kw = new BannedKeyword();
        kw.setId(rs.getInt("id"));
        kw.setKeyword(rs.getString("keyword"));
        kw.setRegex(rs.getBoolean("is_regex"));
        kw.setDescription(rs.getString("description"));
        kw.setActive(rs.getBoolean("is_active"));
        kw.setCreatedAt(rs.getTimestamp("created_at"));
        return kw;
    }
}
