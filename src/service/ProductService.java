package service;

import dao.ProductDAO;
import dao.ProductImageDAO;
import model.Product;
import model.ProductImage;

import java.util.List;

public class ProductService {
    private ProductDAO productDAO = new ProductDAO();
    private ProductImageDAO productImageDAO = new ProductImageDAO();

    // Hàm tạo sản phẩm và lưu kèm theo ảnh
    public boolean createProductWithImages(Product product, List<ProductImage> images) {
        // 1. Lưu sản phẩm trước để lấy ID
        int productId = productDAO.insertProduct(product);
        
        if (productId > 0) {
            // 2. Cập nhật productId cho từng ảnh
            for (ProductImage img : images) {
                img.setProductId(productId);
            }
            // 3. Lưu danh sách ảnh vào DB
            productImageDAO.insertImages(images);
            return true;
        }
        return false;
    }
}
