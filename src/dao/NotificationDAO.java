package dao;

import model.Notification;
import util.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class NotificationDAO {

    public NotificationDAO() {
    }

    /**
     * Tạo thông báo mới cho người dùng
     */
    public boolean createNotification(int userId, String title, String message, String type, String targetUrl) {
        String sql = "INSERT INTO notifications (user_id, title, message, type, target_url, is_read, created_at) " +
                "VALUES (?, ?, ?, ?, ?, 0, NOW())";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, title);
            ps.setString(3, message);
            ps.setString(4, type);
            ps.setString(5, targetUrl);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[NotificationDAO] Lỗi tạo thông báo: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Tạo thông báo dùng chung connection (bên trong transaction)
     */
    public boolean createNotification(Connection conn, int userId, String title, String message, String type, String targetUrl) {
        String sql = "INSERT INTO notifications (user_id, title, message, type, target_url, is_read, created_at) " +
                "VALUES (?, ?, ?, ?, ?, 0, NOW())";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, title);
            ps.setString(3, message);
            ps.setString(4, type);
            ps.setString(5, targetUrl);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[NotificationDAO] Lỗi tạo thông báo (tx): " + e.getMessage());
        }
        return false;
    }

    /**
     * Lấy danh sách thông báo của người dùng (giới hạn số lượng mới nhất)
     */
    public List<Notification> getNotificationsForUser(int userId, int limit) {
        List<Notification> list = new ArrayList<>();
        int max = limit > 0 ? limit : 20;
        String sql = "SELECT id, user_id, title, message, type, target_url, is_read, created_at " +
                "FROM notifications WHERE user_id = ? ORDER BY created_at DESC, id DESC LIMIT ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, max);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Notification n = new Notification(
                            rs.getInt("id"),
                            rs.getInt("user_id"),
                            rs.getString("title"),
                            rs.getString("message"),
                            rs.getString("type"),
                            rs.getString("target_url"),
                            rs.getBoolean("is_read"),
                            rs.getTimestamp("created_at")
                    );
                    list.add(n);
                }
            }
        } catch (SQLException e) {
            System.err.println("[NotificationDAO] Lỗi lấy danh sách thông báo: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Đếm số lượng thông báo chưa đọc của người dùng
     */
    public int countUnreadNotifications(int userId) {
        String sql = "SELECT COUNT(*) FROM notifications WHERE user_id = ? AND is_read = 0";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            System.err.println("[NotificationDAO] Lỗi đếm thông báo chưa đọc: " + e.getMessage());
        }
        return 0;
    }

    /**
     * Đánh dấu 1 thông báo là đã đọc
     */
    public boolean markAsRead(int notificationId, int userId) {
        String sql = "UPDATE notifications SET is_read = 1 WHERE id = ? AND user_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, notificationId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[NotificationDAO] Lỗi đánh dấu đã đọc: " + e.getMessage());
        }
        return false;
    }

    /**
     * Đánh dấu tất cả thông báo của người dùng là đã đọc
     */
    public boolean markAllAsRead(int userId) {
        String sql = "UPDATE notifications SET is_read = 1 WHERE user_id = ? AND is_read = 0";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[NotificationDAO] Lỗi đánh dấu tất cả đã đọc: " + e.getMessage());
        }
        return false;
    }
}
