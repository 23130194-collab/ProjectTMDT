package controller.admin;

import dao.ProductDAO;
import model.Product;

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
import java.util.List;
import util.DBContext;

@WebServlet("/admin/posts")
public class AdminPostServlet extends HttpServlet {

    private static final int PAGE_SIZE = 20;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String statusFilter = req.getParameter("status");   // PENDING/ACTIVE/REJECTED/HIDDEN/
        String keyword      = req.getParameter("keyword");
        String catIdStr     = req.getParameter("catId");
        int page = 1;
        try { page = Integer.parseInt(req.getParameter("page")); } catch (Exception e) {}
        if (page < 1) page = 1;
        int offset = (page - 1) * PAGE_SIZE;

        // Build query
        StringBuilder where = new StringBuilder("WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (statusFilter != null && !statusFilter.isEmpty()) {
            where.append("AND p.status = ? ");
            params.add(statusFilter);
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            where.append("AND (p.title LIKE ? OR u.full_name LIKE ?) ");
            params.add("%" + keyword.trim() + "%");
            params.add("%" + keyword.trim() + "%");
        }
        if (catIdStr != null && !catIdStr.isEmpty()) {
            where.append("AND p.category_id = ? ");
            try { params.add(Integer.parseInt(catIdStr)); } catch (Exception e) {}
        }

        String baseSql = "FROM products p LEFT JOIN users u ON p.user_id = u.id LEFT JOIN categories c ON p.category_id = c.id " + where;
        int total = countAdminPosts("SELECT COUNT(*) " + baseSql, params);
        int totalPages = (int) Math.ceil((double) total / PAGE_SIZE);

        String selectSql = "SELECT p.*, u.full_name AS owner_name, c.name AS cat_name " + baseSql +
                           "ORDER BY p.created_at DESC LIMIT " + PAGE_SIZE + " OFFSET " + offset;

        List<Object[]> posts = new ArrayList<>();
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(selectSql)) {
            bindParams(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    posts.add(new Object[]{
                        rs.getInt("id"), rs.getString("title"), rs.getString("status"),
                        rs.getLong("price"), rs.getString("owner_name"),
                        rs.getString("cat_name"), rs.getTimestamp("created_at")
                    });
                }
            }
        } catch (Exception e) { e.printStackTrace(); }

        req.setAttribute("posts", posts);
        req.setAttribute("totalPosts", total);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("statusFilter", statusFilter);
        req.setAttribute("keyword", keyword);
        req.setAttribute("catIdFilter", catIdStr);
        req.setAttribute("categories", new ProductDAO().getAllCategories());
        req.setAttribute("adminPage", "posts");
        req.getRequestDispatcher("/admin/admin-posts.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action    = req.getParameter("action");
        String idStr     = req.getParameter("productId");
        String reason    = req.getParameter("reason");

        if (idStr == null) { resp.sendRedirect(req.getContextPath() + "/admin/posts"); return; }
        int productId;
        try { productId = Integer.parseInt(idStr); } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/admin/posts"); return;
        }

        String newStatus = null;
        if ("approve".equals(action))  newStatus = "ACTIVE";
        else if ("reject".equals(action))  newStatus = "REJECTED";
        else if ("hide".equals(action))    newStatus = "HIDDEN";
        else if ("unhide".equals(action))  newStatus = "ACTIVE";
        else if ("delete".equals(action))  newStatus = "DELETE";


        if (newStatus != null) {
            String sql = "UPDATE products SET status = ? WHERE id = ?";
            try (Connection conn = DBContext.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, newStatus);
                ps.setInt(2, productId);
                ps.executeUpdate();
            } catch (Exception e) { e.printStackTrace(); }
        }

        // Redirect back with same filters
        String redirect = req.getContextPath() + "/admin/posts";
        String referer = req.getParameter("referer");
        if (referer != null && !referer.isEmpty()) redirect += "?" + referer;
        resp.sendRedirect(redirect);
    }

    private int countAdminPosts(String sql, List<Object> params) {
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            bindParams(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return 0;
    }

    private void bindParams(PreparedStatement ps, List<Object> params) throws Exception {
        for (int i = 0; i < params.size(); i++) {
            Object p = params.get(i);
            if (p instanceof Integer) ps.setInt(i + 1, (Integer) p);
            else ps.setString(i + 1, String.valueOf(p));
        }
    }
}
