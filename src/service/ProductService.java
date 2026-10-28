package service;

import dao.ProductDAO;
import dao.ProductImageDAO;
import model.Product;
import model.ProductImage;

import java.util.List;

public class ProductService {
    private ProductDAO productDAO = new ProductDAO();
    private ProductImageDAO productImageDAO = new ProductImageDAO();
    private dao.ProductEmbeddingDAO productEmbeddingDAO = new dao.ProductEmbeddingDAO();

    // Hàm tạo sản phẩm và lưu kèm theo ảnh
    public boolean createProductWithImages(Product product, List<ProductImage> images) {
        // 1. Lưu sản phẩm trước để lấy ID
        int productId = productDAO.insertProduct(product);
        
        if (productId > 0) {
            product.setId(productId);
            // 2. Cập nhật productId cho từng ảnh
            for (ProductImage img : images) {
                img.setProductId(productId);
            }
            // 3. Lưu danh sách ảnh vào DB
            productImageDAO.insertImages(images);

            // 4. Tự động sinh Vector Embedding cho ảnh đại diện (Chạy nền không làm chậm luồng chính)
            if (images != null && !images.isEmpty()) {
                final int finalPid = productId;
                final String firstImgUrl = images.get(0).getImageUrl();
                new Thread(() -> {
                    try {
                        if (ClipEmbeddingService.isServiceAvailable()) {
                            // Giả sử ảnh nằm trong thư mục gốc web app hoặc đường dẫn
                            String localPath = "web/" + firstImgUrl;
                            java.io.File file = new java.io.File(localPath);
                            if (file.exists()) {
                                float[] vec = ClipEmbeddingService.getEmbeddingFromPath(file.getAbsolutePath());
                                if (vec.length > 0) {
                                    productEmbeddingDAO.saveEmbedding(finalPid, vec);
                                }
                            }
                        }
                    } catch (Exception ignored) {}
                }).start();
            }

            return true;
        }
        return false;
    }
}
