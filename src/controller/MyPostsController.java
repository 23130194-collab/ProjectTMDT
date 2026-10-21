package controller;

import dao.OrderDAO;
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
import java.util.List;

@WebServlet("/my-posts")
public class MyPostsController extends HttpServlet {
    private ProductDAO productDAO = new ProductDAO();
    private OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        User user = (User) session.getAttribute("user");
        List<Product> myPosts = productDAO.getProductsByUserId(user.getId());
        req.setAttribute("myPosts", myPosts);

        // Load đơn hàng bán để hiển thị thống kê doanh thu
        List<OrderDAO.OrderSummary> allOrders = orderDAO.getOrderSummariesForUser(user.getId());
        // Lấy đơn mà user là người bán
        List<OrderDAO.OrderSummary> sellerOrders = allOrders.stream()
                .filter(o -> o.sellerId == user.getId())
                .collect(java.util.stream.Collectors.toList());
        req.setAttribute("sellerOrders", sellerOrders);

        // Lấy đơn mà user là người mua cho tab Lịch sử mua hàng
        List<OrderDAO.OrderSummary> buyerOrders = allOrders.stream()
                .filter(o -> o.buyerId == user.getId())
                .collect(java.util.stream.Collectors.toList());
        req.setAttribute("buyerOrders", buyerOrders);

        // Đếm số giao dịch thành công (COMPLETED) của user
        int successfulOrdersCount = (int) allOrders.stream()
                .filter(o -> "COMPLETED".equalsIgnoreCase(o.status))
                .count();
        req.setAttribute("successfulOrdersCount", successfulOrdersCount);

        req.getRequestDispatcher("/08-ho-so-ca-nhan.jsp").forward(req, resp);
    }
}

