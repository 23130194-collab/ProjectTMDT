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
        // Lấy danh sách sản phẩm từ DB
        List<Product> products = productDAO.getRecentProducts();
        List<Product> newProducts = productDAO.getNewestProducts(10);

        
        // Gắn vào request để truyền sang file giao diện
        request.setAttribute("products", products);
        request.setAttribute("newProducts", newProducts);


        // Chuyển hướng sang trang 01-trang-chu.jsp
        request.getRequestDispatcher("01-trang-chu.jsp").forward(request, response);
    }
}
