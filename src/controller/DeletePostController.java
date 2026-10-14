package controller;

import dao.ProductDAO;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/delete-post")
public class DeletePostController extends HttpServlet {
    private ProductDAO productDAO = new ProductDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        User user = (User) session.getAttribute("user");
        String idStr = req.getParameter("productId");

        if (idStr != null) {
            try {
                int productId = Integer.parseInt(idStr);
                boolean deleted = productDAO.deleteProduct(productId, user.getId());
                if (deleted) {
                    session.setAttribute("profileMessage", "Đã xóa bài đăng thành công.");
                } else {
                    session.setAttribute("profileMessage", "Không thể xóa bài đăng. Bạn không phải chủ bài đăng hoặc bài đăng không tồn tại.");
                    session.setAttribute("profileMessageError", true);
                }
            } catch (NumberFormatException e) {
                session.setAttribute("profileMessage", "ID bài đăng không hợp lệ.");
                session.setAttribute("profileMessageError", true);
            }
        }
        resp.sendRedirect(req.getContextPath() + "/my-posts");
    }
}
