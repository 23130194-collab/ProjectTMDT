package controller.admin;

import dao.ProductBoostDAO;
import dao.ProductDAO;
import dao.ReportDAO;
import model.ProductBoost;
import util.DBContext;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;
import java.time.YearMonth;
import java.util.*;

@WebServlet("/admin/dashboard")
public class AdminDashboardServlet extends HttpServlet {

    private final ProductDAO productDAO = new ProductDAO();
    private final ReportDAO reportDAO = new ReportDAO();
    private final ProductBoostDAO productBoostDAO = new ProductBoostDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        LocalDate today = LocalDate.now();
        String range = req.getParameter("range");
        if (range == null || range.trim().isEmpty()) {
            range = "7days";
        }

        LocalDate fromDate;
        LocalDate toDate;

        switch (range) {
            case "30days":
                fromDate = today.minusDays(29);
                toDate = today;
                break;
            case "this_month":
                fromDate = today.withDayOfMonth(1);
                toDate = today;
                break;
            case "last_month":
                YearMonth prevMonth = YearMonth.from(today).minusMonths(1);
                fromDate = prevMonth.atDay(1);
                toDate = prevMonth.atEndOfMonth();
                break;
            case "custom":
                String fromStr = req.getParameter("from");
                String toStr = req.getParameter("to");
                try {
                    fromDate = (fromStr != null && !fromStr.isEmpty()) ? LocalDate.parse(fromStr) : today.minusDays(6);
                } catch (Exception e) {
                    fromDate = today.minusDays(6);
                }
                try {
                    toDate = (toStr != null && !toStr.isEmpty()) ? LocalDate.parse(toStr) : today;
                } catch (Exception e) {
                    toDate = today;
                }
                break;
            case "7days":
            default:
                range = "7days";
                fromDate = today.minusDays(6);
                toDate = today;
                break;
        }

        // Đảm bảo fromDate <= toDate
        if (fromDate.isAfter(toDate)) {
            LocalDate temp = fromDate;
            fromDate = toDate;
            toDate = temp;
        }

        // Giới hạn an toàn tối đa 365 ngày
        long diffDays = java.time.temporal.ChronoUnit.DAYS.between(fromDate, toDate);
        if (diffDays > 365) {
            fromDate = toDate.minusDays(365);
            diffDays = 365;
        }

        String fromDateStr = fromDate.toString();
        String toDateStr = toDate.toString();

        req.setAttribute("selectedRange", range);
        req.setAttribute("fromDate", fromDateStr);
        req.setAttribute("toDate", toDateStr);
        req.setAttribute("daysCount", diffDays + 1);

        // --- 1. THẺ SỐ LIỆU TOÀN THỜI GIAN (ALL-TIME STATE) ---
        int totalPosts = countBySql("SELECT COUNT(*) FROM products");
        int pendingPosts = countBySql("SELECT COUNT(*) FROM products WHERE status='PENDING'");
        int activePosts = countBySql("SELECT COUNT(*) FROM products WHERE status='ACTIVE'");
        int rejectedPosts = countBySql("SELECT COUNT(*) FROM products WHERE status='REJECTED'");
        int totalUsers = countBySql("SELECT COUNT(*) FROM users WHERE role='USER'");
        int lockedUsers = countBySql("SELECT COUNT(*) FROM users WHERE status='LOCKED'");
        int pendingReports = reportDAO.countPending();
        int activeVipPosts = productBoostDAO.getActiveVipCount();
        double allTimeRevenue = productBoostDAO.getTotalBoostRevenue();
        int totalBoostOrders = productBoostDAO.countTotalBoostOrders();

        req.setAttribute("totalPosts", totalPosts);
        req.setAttribute("pendingPosts", pendingPosts);
        req.setAttribute("activePosts", activePosts);
        req.setAttribute("rejectedPosts", rejectedPosts);
        req.setAttribute("totalUsers", totalUsers);
        req.setAttribute("lockedUsers", lockedUsers);
        req.setAttribute("pendingReports", pendingReports);
        req.setAttribute("activeVipPosts", activeVipPosts);
        req.setAttribute("allTimeRevenue", allTimeRevenue);
        req.setAttribute("totalBoostOrders", totalBoostOrders);

        // Tỷ lệ duyệt chuẩn: active / (active + rejected)
        double approvalRate = (activePosts + rejectedPosts) > 0 
                ? ((double) activePosts / (activePosts + rejectedPosts)) * 100 
                : 100.0;
        req.setAttribute("approvalRate", approvalRate);

        // --- 2. THỐNG KÊ TRONG KHOẢNG THỜI GIAN ĐƯỢC CHỌN (PERIOD METRICS) ---
        int periodPosts = countByParamSql(
                "SELECT COUNT(*) FROM products WHERE created_at >= ? AND created_at < DATE_ADD(?, INTERVAL 1 DAY)",
                fromDateStr, toDateStr
        );
        double periodRevenue = productBoostDAO.getRevenueBetween(fromDateStr, toDateStr);
        int periodBoostOrders = countByParamSql(
                "SELECT COUNT(*) FROM product_boosts WHERE created_at >= ? AND created_at < DATE_ADD(?, INTERVAL 1 DAY)",
                fromDateStr, toDateStr
        );

        req.setAttribute("periodPosts", periodPosts);
        req.setAttribute("periodRevenue", periodRevenue);
        req.setAttribute("periodBoostOrders", periodBoostOrders);

        // --- 3. BIỂU ĐỒ TIN ĐĂNG & DOANH THU (ZERO-FILLED CONTINUOUS TIMELINE) ---
        Map<String, Integer> postsChartData = new LinkedHashMap<>();
        Map<String, Double> revenueChartData = new LinkedHashMap<>();

        LocalDate curr = fromDate;
        while (!curr.isAfter(toDate)) {
            String key = curr.toString();
            postsChartData.put(key, 0);
            revenueChartData.put(key, 0.0);
            curr = curr.plusDays(1);
        }

        // Lấy số lượng bài đăng theo ngày trong kỳ
        String postChartSql = "SELECT DATE(created_at) AS day, COUNT(*) AS cnt " +
                              "FROM products " +
                              "WHERE created_at >= ? AND created_at < DATE_ADD(?, INTERVAL 1 DAY) " +
                              "GROUP BY DATE(created_at)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(postChartSql)) {
            ps.setString(1, fromDateStr);
            ps.setString(2, toDateStr);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String d = rs.getString("day");
                    if (postsChartData.containsKey(d)) {
                        postsChartData.put(d, rs.getInt("cnt"));
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        req.setAttribute("postsChartData", postsChartData);

        // Lấy doanh thu dịch vụ theo ngày trong kỳ
        String revChartSql = "SELECT DATE(created_at) AS day, COALESCE(SUM(amount_paid), 0) AS rev " +
                             "FROM product_boosts " +
                             "WHERE created_at >= ? AND created_at < DATE_ADD(?, INTERVAL 1 DAY) " +
                             "GROUP BY DATE(created_at)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(revChartSql)) {
            ps.setString(1, fromDateStr);
            ps.setString(2, toDateStr);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String d = rs.getString("day");
                    if (revenueChartData.containsKey(d)) {
                        revenueChartData.put(d, rs.getDouble("rev"));
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        req.setAttribute("revenueChartData", revenueChartData);

        // --- 4. TOP 5 NGƯỜI ĐĂNG TRONG KHOẢNG THỜI GIAN ĐÃ CHỌN ---
        List<Object[]> topUsers = new ArrayList<>();
        String topSql = "SELECT u.full_name, u.username, COUNT(p.id) AS cnt " +
                        "FROM products p JOIN users u ON p.user_id = u.id " +
                        "WHERE p.created_at >= ? AND p.created_at < DATE_ADD(?, INTERVAL 1 DAY) " +
                        "GROUP BY p.user_id ORDER BY cnt DESC LIMIT 5";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(topSql)) {
            ps.setString(1, fromDateStr);
            ps.setString(2, toDateStr);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    topUsers.add(new Object[]{
                        rs.getString("full_name"), rs.getString("username"), rs.getInt("cnt")
                    });
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        req.setAttribute("topUsers", topUsers);

        // --- 5. PHÂN BỔ THEO DANH MỤC TRONG KHOẢNG THỜI GIAN ĐÃ CHỌN ---
        List<Object[]> catStats = new ArrayList<>();
        String catSql = "SELECT c.name, COUNT(p.id) AS cnt " +
                        "FROM products p JOIN categories c ON p.category_id = c.id " +
                        "WHERE p.created_at >= ? AND p.created_at < DATE_ADD(?, INTERVAL 1 DAY) " +
                        "GROUP BY c.id ORDER BY cnt DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(catSql)) {
            ps.setString(1, fromDateStr);
            ps.setString(2, toDateStr);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    catStats.add(new Object[]{rs.getString("name"), rs.getInt("cnt")});
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        req.setAttribute("catStats", catStats);

        // --- 6. GIAO DỊCH GÓI DỊCH VỤ MỚI NHẤT (RECENT ACTIVITY FEED) ---
        List<ProductBoost> recentBoosts = productBoostDAO.getRecentBoostHistory(5);
        req.setAttribute("recentBoosts", recentBoosts);

        req.setAttribute("adminPage", "dashboard");
        req.getRequestDispatcher("/admin/admin-dashboard.jsp").forward(req, resp);
    }

    private int countBySql(String sql) {
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    private int countByParamSql(String sql, String p1, String p2) {
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, p1);
            ps.setString(2, p2);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }
}
