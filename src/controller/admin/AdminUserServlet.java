package controller.admin;

import dao.UserDao;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.UUID;

@WebServlet("/admin/users")
public class AdminUserServlet extends HttpServlet {

    private final UserDao userDAO = new UserDao();
    private static final int PAGE_SIZE = 20;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String keyword = req.getParameter("keyword");
        String status  = req.getParameter("status");
        int page = 1;
        try { page = Math.max(1, Integer.parseInt(req.getParameter("page"))); } catch (Exception e) {}

        int offset = (page - 1) * PAGE_SIZE;
        int total  = userDAO.countCustomersByFilter(status, keyword);
        int totalPages = (int) Math.ceil((double) total / PAGE_SIZE);
        List<User> users = userDAO.getCustomersPaging(PAGE_SIZE, offset, status, keyword);

        req.setAttribute("users", users);
        req.setAttribute("totalUsers", total);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("keyword", keyword);
        req.setAttribute("statusFilter", status);
        req.setAttribute("adminPage", "users");
        req.getRequestDispatcher("/admin/admin-users.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        String idStr  = req.getParameter("userId");
        if (idStr == null) { resp.sendRedirect(req.getContextPath() + "/admin/users"); return; }
        int userId;
        try { userId = Integer.parseInt(idStr); } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/admin/users"); return;
        }

        switch (action != null ? action : "") {
            case "lock":
                userDAO.updateUserStatus(userId, "LOCKED"); break;
            case "unlock":
                userDAO.updateUserStatus(userId, "ACTIVE"); break;
            case "makeAdmin":
                userDAO.updateRole(userId, 1); break;
            case "makeUser":
                userDAO.updateRole(userId, 0); break;
            case "resetPassword":
                String newPass = UUID.randomUUID().toString().substring(0, 8);
                // Hash bằng cùng cơ chế với hệ thống hiện tại (MD5 hoặc SHA)
                String hashed = hashPassword(newPass);
                resetPasswordById(userId, hashed);
                req.getSession().setAttribute("adminMsg", "Mật khẩu tạm thời: " + newPass);
                break;
        }
        resp.sendRedirect(req.getContextPath() + "/admin/users");
    }

    private void resetPasswordById(int userId, String hashed) {
        String sql = "UPDATE users SET password = ? WHERE id = ?";
        try (java.sql.Connection conn = util.DBContext.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, hashed);
            ps.setInt(2, userId);
            ps.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
    }

    private String hashPassword(String plain) {
        try {
            java.security.MessageDigest md = java.security.MessageDigest.getInstance("SHA-256");
            byte[] bytes = md.digest(plain.getBytes(java.nio.charset.StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte b : bytes) sb.append(String.format("%02x", b));
            return sb.toString();
        } catch (Exception e) { return plain; }
    }
}
