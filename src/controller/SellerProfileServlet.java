package controller;

import dao.OrderDAO;
import dao.ProductDAO;
import dao.ReviewDAO;
import dao.UserDao;
import model.OrderSummary;
import model.Product;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet(name = "SellerProfileServlet", urlPatterns = {"/seller-profile", "/profile"})
public class SellerProfileServlet extends HttpServlet {
    private final UserDao userDao = new UserDao();
    private final ProductDAO productDAO = new ProductDAO();
    private final ReviewDAO reviewDAO = new ReviewDAO();
    private final OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            idParam = request.getParameter("userId");
        }

        int sellerId = parseInt(idParam);
        if (sellerId <= 0) {
            // Nếu không truyền ID, kiểm tra xem có đang đăng nhập không -> nếu có thì tới /my-posts
            HttpSession session = request.getSession(false);
            if (session != null && session.getAttribute("user") instanceof User) {
                sellerId = ((User) session.getAttribute("user")).getId();
            } else {
                response.sendRedirect("01-trang-chu.jsp");
                return;
            }
        }

        User seller = userDao.getUserById(sellerId);
        if (seller == null) {
            response.sendRedirect("01-trang-chu.jsp");
            return;
        }

        // Lấy danh sách sản phẩm của người bán (chỉ hiển thị ACTIVE hoặc SOLD cho khách xem)
        List<Product> allProducts = productDAO.getProductsByUserId(sellerId);
        List<Product> publicProducts = allProducts.stream()
                .filter(p -> "ACTIVE".equalsIgnoreCase(p.getStatus()) || "SOLD".equalsIgnoreCase(p.getStatus()))
                .collect(Collectors.toList());

        // Lấy danh sách đánh giá từ người mua
        List<ReviewDAO.ReviewDetail> reviews = reviewDAO.getReviewsForSeller(sellerId);
        ReviewDAO.SellerRatingSummary ratingSummary = reviewDAO.getSellerRatingSummary(sellerId);

        final int targetSellerId = sellerId;
        // Đếm số đơn giao dịch thành công của người bán
        List<OrderSummary> orders = orderDAO.getOrderSummariesForUser(sellerId);
        int completedSalesCount = (int) orders.stream()
                .filter(o -> o.sellerId == targetSellerId && "COMPLETED".equalsIgnoreCase(o.status))
                .count();

        request.setAttribute("seller", seller);
        request.setAttribute("sellerProducts", publicProducts);
        request.setAttribute("sellerReviews", reviews);
        request.setAttribute("sellerRatingSummary", ratingSummary);
        request.setAttribute("completedSalesCount", completedSalesCount);

        request.getRequestDispatcher("/seller-profile.jsp").forward(request, response);
    }

    private int parseInt(String value) {
        try {
            return value == null ? 0 : Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            return 0;
        }
    }
}
