package controller;

import dao.ProductDAO;
import dao.ProductImageDAO;
import model.Product;
import model.ProductImage;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet("/product-detail")
public class ProductDetailController extends HttpServlet {
    private ProductDAO productDAO = new ProductDAO();
    private ProductImageDAO productImageDAO = new ProductImageDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String idParam = req.getParameter("id");
        if (idParam != null && !idParam.isEmpty()) {
            try {
                int id = Integer.parseInt(idParam);
                Product product = productDAO.getProductById(id);
                if (product != null) {
                    List<ProductImage> images = productImageDAO.getImagesByProductId(id);
                    req.setAttribute("product", product);
                    req.setAttribute("images", images);
                    req.getRequestDispatcher("02-chi-tiet-san-pham.jsp").forward(req, resp);
                    return;
                }
            } catch (NumberFormatException e) {
                // Ignore and fallback
            }
        }
        // Fallback or not found
        resp.sendRedirect(req.getContextPath() + "/home");
    }
}