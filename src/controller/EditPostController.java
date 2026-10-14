package controller;

import dao.ProductDAO;
import model.Product;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/edit-post")
public class EditPostController extends HttpServlet {
    private ProductDAO productDAO = new ProductDAO();

    // GET: hiển thị trang sửa bài đăng (load dữ liệu bài đăng vào form)
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        User user = (User) session.getAttribute("user");
        String idStr = req.getParameter("id");

        if (idStr != null) {
            try {
                int productId = Integer.parseInt(idStr);
                Product product = productDAO.getProductById(productId);
                // Kiểm tra quyền sở hữu
                if (product != null && product.getUserId() == user.getId()) {
                    req.setAttribute("editProduct", product);
                    req.getRequestDispatcher("/03-dang-tin.jsp").forward(req, resp);
                    return;
                }
            } catch (NumberFormatException e) {
                // ignore
            }
        }
        resp.sendRedirect(req.getContextPath() + "/my-posts");
    }

    // POST: lưu thay đổi bài đăng
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        User user = (User) session.getAttribute("user");

        String idStr = req.getParameter("productId");
        String title = req.getParameter("title");
        String description = req.getParameter("description");
        String priceStr = req.getParameter("price");
        String categoryIdStr = req.getParameter("categoryId");

        if (idStr != null) {
            try {
                int productId = Integer.parseInt(idStr);
                Product existing = productDAO.getProductById(productId);

                // Kiểm tra quyền sở hữu
                if (existing != null && existing.getUserId() == user.getId()) {
                    existing.setTitle(title);
                    existing.setDescription(description);

                    double price = 0;
                    try {
                        if (priceStr != null) {
                            price = Double.parseDouble(priceStr.replace(".", "").replace(",", ""));
                        }
                    } catch (Exception e) {}
                    existing.setPrice(price);

                    int categoryId = existing.getCategoryId();
                    try {
                        if (categoryIdStr != null) {
                            categoryId = Integer.parseInt(categoryIdStr);
                        }
                    } catch (Exception e) {}
                    existing.setCategoryId(categoryId);
                    existing.setProvince(req.getParameter("province"));
                    existing.setWard(req.getParameter("ward"));
                    existing.setAddressDetail(req.getParameter("address_detail"));
                    existing.setDealType("give".equals(req.getParameter("deal_type")) ? "GIVE" : "SELL");
                    try {
                        existing.setDeliveryMethod(Integer.parseInt(req.getParameter("delivery_method")));
                    } catch (NumberFormatException ignored) {
                        // Keep the existing delivery method if the form omitted it.
                    }

                    boolean updated = productDAO.updateProduct(existing);
                    if (updated) {
                        session.setAttribute("profileMessage", "Đã cập nhật bài đăng thành công.");
                    } else {
                        session.setAttribute("profileMessage", "Không thể cập nhật bài đăng.");
                        session.setAttribute("profileMessageError", true);
                    }
                }
            } catch (NumberFormatException e) {
                session.setAttribute("profileMessage", "ID bài đăng không hợp lệ.");
                session.setAttribute("profileMessageError", true);
            }
        }
        resp.sendRedirect(req.getContextPath() + "/my-posts");
    }
}
