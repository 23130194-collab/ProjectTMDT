package dao;

import model.User;
import util.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class UserDao {

    public User getUserById(int id) {
        String sql = "SELECT * FROM users WHERE id = ?";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    public User getUserByEmail(String email) {
        if (email == null || email.trim().isEmpty()) {
            return null;
        }

        String sql = "SELECT * FROM users WHERE email = ?";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email.trim());

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    public User getUserByAccount(String account) {
        if (account == null || account.trim().isEmpty()) {
            return null;
        }

        String sql = "SELECT * FROM users WHERE email = ? OR phone = ? OR username = ?";
        String normalizedAccount = account.trim();

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, normalizedAccount);
            ps.setString(2, normalizedAccount);
            ps.setString(3, normalizedAccount);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    public boolean usernameExists(String username) {
        String sql = "SELECT COUNT(*) FROM users WHERE username = ?";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return true;
    }

    public void insertUser(String fullName, String email, String password) {
        String username = buildUniqueUsername(email, fullName);
        String sql = "INSERT INTO users(username, password, full_name, email, role, status) VALUES (?, ?, ?, ?, 'USER', 'ACTIVE')";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, password);
            ps.setString(3, fullName.trim());
            ps.setString(4, email.trim());
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("Không thể tạo tài khoản.", e);
        }
    }

    public void updatePassword(String email, String password) {
        String sql = "UPDATE users SET password = ? WHERE email = ?";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, password);
            ps.setString(2, email);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("Không thể cập nhật mật khẩu.", e);
        }
    }

    public void updateUser(User user) {
        String sql = "UPDATE users SET full_name = ?, email = ?, phone = ?, avatar = ?, status = ? WHERE id = ?";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, user.getFullName());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPhone());
            ps.setString(4, user.getAvatar());
            ps.setString(5, user.getStatus());
            ps.setInt(6, user.getId());
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public boolean isProfileEmailTaken(String email, int userId) {
        return isProfileValueTaken("email", email, userId);
    }

    public boolean isProfilePhoneTaken(String phone, int userId) {
        return isProfileValueTaken("phone", phone, userId);
    }

    private boolean isProfileValueTaken(String column, String value, int userId) {
        String sql = "SELECT COUNT(*) FROM users WHERE id <> ? AND " + column + " = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, value);
            try (ResultSet rs = ps.executeQuery()) { return rs.next() && rs.getInt(1) > 0; }
        } catch (SQLException e) {
            throw new RuntimeException("Không thể kiểm tra thông tin liên hệ.", e);
        }
    }

    public void updateProfile(User user) {
        String sql = "UPDATE users SET full_name = ?, email = ?, phone = ?, province = ?, ward = ?, address_detail = ? WHERE id = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, user.getFullName());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPhone());
            ps.setString(4, user.getProvince());
            ps.setString(5, user.getWard());
            ps.setString(6, user.getAddressDetail());
            ps.setInt(7, user.getId());
            if (ps.executeUpdate() == 0) throw new SQLException("Không tìm thấy tài khoản cần cập nhật.");
        } catch (SQLException e) {
            throw new RuntimeException("Không thể cập nhật hồ sơ.", e);
        }
    }

    public void updateUserStatus(int userId, String newStatus) {
        String sql = "UPDATE users SET status = ? WHERE id = ?";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, normalizeStatus(newStatus));
            ps.setInt(2, userId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public String getUserStatus(int userId) {
        String sql = "SELECT status FROM users WHERE id = ?";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("status");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    public int countCustomersByFilter(String status, String keyword) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM users WHERE 1=1");
        List<Object> params = new ArrayList<>();

        boolean isAdmin = "admin".equalsIgnoreCase(status);
        boolean hasStatus = status != null && !"all".equalsIgnoreCase(status) && !isAdmin;
        boolean hasKeyword = keyword != null && !keyword.trim().isEmpty();

        if (isAdmin) {
            sql.append(" AND role = 'ADMIN'");
        } else {
            sql.append(" AND role = 'USER'");
            if (hasStatus) {
                sql.append(" AND status = ?");
                params.add(normalizeStatus(status));
            }
        }

        if (hasKeyword) {
            sql.append(" AND (full_name LIKE ? OR email LIKE ?)");
            String likeKeyword = "%" + keyword.trim() + "%";
            params.add(likeKeyword);
            params.add(likeKeyword);
        }

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            bindParams(ps, params);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return 0;
    }

    public List<User> getCustomersPaging(int limit, int offset, String status, String keyword) {
        StringBuilder sql = new StringBuilder("SELECT * FROM users WHERE 1=1");
        List<Object> params = new ArrayList<>();

        boolean isAdmin = "admin".equalsIgnoreCase(status);
        boolean hasStatus = status != null && !"all".equalsIgnoreCase(status) && !isAdmin;
        boolean hasKeyword = keyword != null && !keyword.trim().isEmpty();

        if (isAdmin) {
            sql.append(" AND role = 'ADMIN'");
        } else {
            sql.append(" AND role = 'USER'");
            if (hasStatus) {
                sql.append(" AND status = ?");
                params.add(normalizeStatus(status));
            }
        }

        if (hasKeyword) {
            sql.append(" AND (full_name LIKE ? OR email LIKE ?)");
            String likeKeyword = "%" + keyword.trim() + "%";
            params.add(likeKeyword);
            params.add(likeKeyword);
        }

        sql.append(" ORDER BY created_at DESC LIMIT ? OFFSET ?");
        params.add(limit);
        params.add(offset);

        List<User> users = new ArrayList<>();

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            bindParams(ps, params);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    users.add(mapUser(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return users;
    }

    public int getTotalCustomersCount() {
        return countUsersBySql("SELECT COUNT(*) FROM users WHERE role = 'USER' AND status = 'ACTIVE'");
    }

    public int getNewCustomersThisMonth() {
        return countUsersBySql("SELECT COUNT(*) FROM users WHERE role = 'USER' AND status = 'ACTIVE' AND MONTH(created_at) = MONTH(CURDATE()) AND YEAR(created_at) = YEAR(CURDATE())");
    }

    public void createUser(User user) {
        String email = user.getEmail();
        String fullName = user.getFullName() != null ? user.getFullName() : user.getUsername();
        if (fullName == null || fullName.trim().isEmpty()) {
            fullName = email;
        }

        String username = buildUniqueUsername(email, fullName);
        String sql = "INSERT INTO users(username, password, full_name, email, role, status, avatar) VALUES (?, '', ?, ?, 'USER', 'ACTIVE', ?)";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, fullName);
            ps.setString(3, email);
            ps.setString(4, user.getAvatar());
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("Không thể tạo tài khoản.", e);
        }
    }

    public void insertUserByAdmin(String fullName, String email, String password) {
        insertUser(fullName, email, password);
    }

    public int getRoleById(int userId) {
        String role = null;
        String sql = "SELECT role FROM users WHERE id = ?";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    role = rs.getString("role");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return "ADMIN".equalsIgnoreCase(role) ? 1 : 0;
    }

    public boolean updateRole(int userId, int newRole) {
        String sql = "UPDATE users SET role = ? WHERE id = ?";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newRole == 1 ? "ADMIN" : "USER");
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    private User mapUser(ResultSet rs) throws SQLException {
        User user = new User();
        user.setId(rs.getInt("id"));
        user.setUsername(rs.getString("username"));
        user.setPassword(rs.getString("password"));
        user.setFullName(rs.getString("full_name"));
        user.setEmail(rs.getString("email"));
        user.setPhone(rs.getString("phone"));
        user.setProvince(rs.getString("province"));
        user.setWard(rs.getString("ward"));
        user.setAddressDetail(rs.getString("address_detail"));
        user.setAvatar(rs.getString("avatar"));
        user.setRole(rs.getString("role"));
        user.setReputationScore(rs.getInt("reputation_score"));
        user.setStatus(rs.getString("status"));
        user.setCreatedAt(rs.getTimestamp("created_at"));
        return user;
    }

    private String buildUniqueUsername(String email, String fullName) {
        String base;

        if (email != null && email.contains("@")) {
            base = email.substring(0, email.indexOf('@'));
        } else {
            base = fullName == null ? "user" : fullName;
        }

        base = base.toLowerCase()
                .replaceAll("[^a-z0-9]+", "")
                .trim();

        if (base.isEmpty()) {
            base = "user";
        }

        String username = base;
        int suffix = 1;
        while (usernameExists(username)) {
            username = base + suffix;
            suffix++;
        }

        return username;
    }

    private String normalizeStatus(String status) {
        if ("locked".equalsIgnoreCase(status)) {
            return "LOCKED";
        }
        return "ACTIVE";
    }

    private int countUsersBySql(String sql) {
        try (Connection conn = DBContext.getConnection();
             Statement statement = conn.createStatement();
             ResultSet rs = statement.executeQuery(sql)) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return 0;
    }

    private void bindParams(PreparedStatement ps, List<Object> params) throws SQLException {
        for (int i = 0; i < params.size(); i++) {
            Object param = params.get(i);
            if (param instanceof Integer) {
                ps.setInt(i + 1, (Integer) param);
            } else if (param instanceof Timestamp) {
                ps.setTimestamp(i + 1, (Timestamp) param);
            } else {
                ps.setString(i + 1, String.valueOf(param));
            }
        }
    }
}
