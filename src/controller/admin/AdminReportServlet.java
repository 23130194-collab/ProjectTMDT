package controller.admin;

import dao.ReportDAO;
import dao.ProductDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import util.DBContext;

@WebServlet("/admin/reports")
public class AdminReportServlet extends HttpServlet {

    private final ReportDAO reportDAO = new ReportDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String status = req.getParameter("status");
        req.setAttribute("reports", status != null && !status.isEmpty()
                ? reportDAO.getByStatus(status) : reportDAO.getAll());
        req.setAttribute("statusFilter", status);
        req.setAttribute("adminPage", "reports");
        req.getRequestDispatcher("/admin/admin-reports.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action    = req.getParameter("action");
        int reportId     = Integer.parseInt(req.getParameter("reportId"));
        String adminNote = req.getParameter("adminNote");
        int productId    = Integer.parseInt(req.getParameter("productId"));

        switch (action != null ? action : "") {
            case "ignore":
                reportDAO.updateStatus(reportId, "IGNORED", adminNote); break;
            case "hidePost":
                updateProductStatus(productId, "HIDDEN");
                reportDAO.updateStatus(reportId, "RESOLVED", adminNote); break;
            case "deletePost":
                updateProductStatus(productId, "DELETE");
                reportDAO.updateStatus(reportId, "RESOLVED", adminNote); break;
        }

        resp.sendRedirect(req.getContextPath() + "/admin/reports");
    }

    private void updateProductStatus(int productId, String status) {
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement("UPDATE products SET status=? WHERE id=?")) {
            ps.setString(1, status);
            ps.setInt(2, productId);
            ps.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
    }
}
