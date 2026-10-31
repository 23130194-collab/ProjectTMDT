package controller;

import dao.ProductDAO;
import model.Product;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "HomeController", value = "/home")
public class HomeController extends HttpServlet {

    private ProductDAO productDAO = new ProductDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        jakarta.servlet.http.HttpSession session = request.getSession();
        Integer catalogSeed = (Integer) session.getAttribute("catalogSeed");
        if (catalogSeed == null) {
            catalogSeed = Math.abs(new java.util.Random().nextInt(1000000) + 1);
            session.setAttribute("catalogSeed", catalogSeed);
        }

        int page = 1;
        int pageSize = 12; // 12 tin / trang (vừa vặn lưới 4 cột trên desktop, 2-3 cột trên tablet/mobile)
        String pageParam = request.getParameter("page");
        if (pageParam != null && !pageParam.trim().isEmpty()) {
            try {
                page = Math.max(1, Integer.parseInt(pageParam.trim()));
            } catch (NumberFormatException ignored) {}
        }

        // 1. Dành riêng banner carousel cho "Tin VIP Nổi Bật" (Ad Density Control)
        List<Product> vipProducts = productDAO.getActiveVipProducts(catalogSeed, 16);

        // 2. Tính toán phân trang với Seeded Random (The Pagination + RAND() Dilemma)
        int totalProducts = productDAO.countActiveProducts();
        int totalPages = (int) Math.ceil((double) totalProducts / pageSize);
        if (totalPages < 1) totalPages = 1;
        if (page > totalPages) page = totalPages;

        // Lấy danh sách sản phẩm phân trang nhất quán trong suốt phiên
        List<Product> products = productDAO.getPaginatedProducts(page, pageSize, catalogSeed);
        List<Product> newProducts = productDAO.getNewestProducts(10);

        request.setAttribute("vipProducts", vipProducts);
        request.setAttribute("products", products);
        request.setAttribute("newProducts", newProducts);
        request.setAttribute("categories", productDAO.getAllCategories());
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalProducts", totalProducts);

        // Chuyển hướng sang trang 01-trang-chu.jsp
        request.getRequestDispatcher("/01-trang-chu.jsp").forward(request, response);
    }
}
