package controller.admin;

import dao.ProductDAO;
import dao.ReportDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import util.DBContext;

@WebServlet("/admin/dashboard")
public class AdminDashboardServlet extends HttpServlet {

    private final ProductDAO productDAO = new ProductDAO();
    private final ReportDAO reportDAO = new ReportDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // --- Thẻ số liệu tổng quan ---
        req.setAttribute("totalPosts",     countBySql("SELECT COUNT(*) FROM products"));
        req.setAttribute("pendingPosts",   countBySql("SELECT COUNT(*) FROM products WHERE status='PENDING'"));
        req.setAttribute("activePosts",    countBySql("SELECT COUNT(*) FROM products WHERE status='ACTIVE'"));
        req.setAttribute("rejectedPosts",  countBySql("SELECT COUNT(*) FROM products WHERE status='REJECTED'"));
        req.setAttribute("totalUsers",     countBySql("SELECT COUNT(*) FROM users WHERE role='USER'"));
        req.setAttribute("lockedUsers",    countBySql("SELECT COUNT(*) FROM users WHERE status='LOCKED'"));
        req.setAttribute("pendingReports", reportDAO.countPending());

        // --- Biểu đồ tin đăng 7 ngày gần nhất ---
        Map<String, Integer> chartData = new LinkedHashMap<>();
        String chartSql = "SELECT DATE(created_at) AS day, COUNT(*) AS cnt " +
                          "FROM products WHERE created_at >= CURDATE() - INTERVAL 6 DAY " +
                          "GROUP BY DATE(created_at) ORDER BY day ASC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(chartSql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) chartData.put(rs.getString("day"), rs.getInt("cnt"));
        } catch (Exception e) { e.printStackTrace(); }
        req.setAttribute("chartData", chartData);

        // --- Top 5 người đăng nhiều nhất ---
        List<Object[]> topUsers = new ArrayList<>();
        String topSql = "SELECT u.full_name, u.username, COUNT(p.id) AS cnt " +
                        "FROM products p JOIN users u ON p.user_id = u.id " +
                        "GROUP BY p.user_id ORDER BY cnt DESC LIMIT 5";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(topSql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) topUsers.add(new Object[]{
                rs.getString("full_name"), rs.getString("username"), rs.getInt("cnt")
            });
        } catch (Exception e) { e.printStackTrace(); }
        req.setAttribute("topUsers", topUsers);

        // --- Phân bổ theo danh mục ---
        List<Object[]> catStats = new ArrayList<>();
        String catSql = "SELECT c.name, COUNT(p.id) AS cnt FROM products p " +
                        "JOIN categories c ON p.category_id = c.id GROUP BY c.id ORDER BY cnt DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(catSql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) catStats.add(new Object[]{rs.getString("name"), rs.getInt("cnt")});
        } catch (Exception e) { e.printStackTrace(); }
        req.setAttribute("catStats", catStats);

        req.setAttribute("adminPage", "dashboard");
        req.getRequestDispatcher("/admin/admin-dashboard.jsp").forward(req, resp);
    }

    private int countBySql(String sql) {
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) { e.printStackTrace(); }
        return 0;
    }
}
