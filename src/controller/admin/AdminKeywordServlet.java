package controller.admin;

import dao.BannedKeywordDAO;
import model.BannedKeyword;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/admin/keywords")
public class AdminKeywordServlet extends HttpServlet {

    private final BannedKeywordDAO dao = new BannedKeywordDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        List<BannedKeyword> keywords = dao.getAll();
        req.setAttribute("keywords", keywords);
        req.setAttribute("adminPage", "keywords");
        req.getRequestDispatcher("/admin/admin-keywords.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");

        if ("add".equals(action)) {
            String kw   = req.getParameter("keyword");
            String desc = req.getParameter("description");
            boolean isRegex = "true".equals(req.getParameter("isRegex"));
            if (kw != null && !kw.trim().isEmpty()) {
                BannedKeyword bk = new BannedKeyword();
                bk.setKeyword(kw.trim());
                bk.setDescription(desc != null ? desc.trim() : "");
                bk.setRegex(isRegex);
                dao.insert(bk);
            }
        } else if ("toggle".equals(action)) {
            int id = Integer.parseInt(req.getParameter("id"));
            boolean active = "true".equals(req.getParameter("active"));
            dao.toggleActive(id, active);
        } else if ("delete".equals(action)) {
            int id = Integer.parseInt(req.getParameter("id"));
            dao.delete(id);
        }

        resp.sendRedirect(req.getContextPath() + "/admin/keywords");
    }
}
