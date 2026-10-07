package controller;

import model.Product;
import model.ProductImage;
import service.ProductService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.UUID;

@WebServlet(name = "PostAdController", value = "/post-ad")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2, // 2MB
        maxFileSize = 1024 * 1024 * 10,      // 10MB
        maxRequestSize = 1024 * 1024 * 50    // 50MB
)
public class PostAdController extends HttpServlet {

    private ProductService productService = new ProductService();
    private static final String UPLOAD_DIR = "assets/uploads";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Nếu gõ trực tiếp URL /post-ad thì chuyển về trang đăng tin
        request.getRequestDispatcher("03-dang-tin.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        // 1. Lấy thông tin text từ Form
        String title = request.getParameter("title");
        String categoryIdStr = request.getParameter("categoryId"); 
        String priceStr = request.getParameter("price");
        String description = request.getParameter("description");

        int categoryId = 1;

        double price = 0;
        try {
            if(priceStr != null) price = Double.parseDouble(priceStr.replace(".", ""));
        } catch(Exception e) { }

        // 2. Tạo đối tượng Product
        Product product = new Product();
        product.setUserId(1);
        product.setCategoryId(categoryId);
        product.setTitle(title);
        product.setDescription(description);
        product.setPrice(price);
        product.setConditionStatus("GOOD");
        product.setLocation("TP. Hồ Chí Minh");
                product.setStatus("PENDING");

        String deliveryMethodStr = request.getParameter("delivery_method");
        int deliveryMethod = 1;
        if (deliveryMethodStr != null) {
            try { deliveryMethod = Integer.parseInt(deliveryMethodStr); } catch (Exception e) {}
        }
        product.setDeliveryMethod(deliveryMethod);

        // 3. Xử lý Upload Ảnh
        String applicationPath = request.getServletContext().getRealPath("");
        String uploadFilePath = applicationPath + File.separator + UPLOAD_DIR;

        // Thu muc luu vao ma nguon
        String sourceFilePath = "e:" + File.separator + "WebTMDT" + File.separator + "web" + File.separator + UPLOAD_DIR.replace("/", File.separator);

        File fileSaveDir = new File(uploadFilePath);
        if (!fileSaveDir.exists()) fileSaveDir.mkdirs();
        
        File sourceSaveDir = new File(sourceFilePath);
        if (!sourceSaveDir.exists()) sourceSaveDir.mkdirs();

        List<ProductImage> images = new ArrayList<>();
        boolean isFirst = true;

        Collection<Part> parts = request.getParts();
        for (Part part : parts) {
            if (part.getName().equals("images") && part.getSize() > 0) {
                String fileName = UUID.randomUUID().toString() + "_" + extractFileName(part);
                
                part.write(uploadFilePath + File.separator + fileName);
                
                try {
                    Files.copy(
                        Paths.get(uploadFilePath + File.separator + fileName),
                        Paths.get(sourceFilePath + File.separator + fileName),
                        StandardCopyOption.REPLACE_EXISTING
                    );
                } catch (Exception e) {}

                ProductImage img = new ProductImage();
                img.setImageUrl(UPLOAD_DIR + "/" + fileName);
                img.setPrimary(isFirst);
                images.add(img);
                isFirst = false;
            }
        }

        // 4. Lưu tất cả vào Database thông qua Service
        boolean success = productService.createProductWithImages(product, images);

        // 5. Chuyển hướng
        if (success) {
            response.sendRedirect("home?message=post_success");
        } else {
            response.sendRedirect("03-dang-tin.jsp?message=error");
        }
    }

    // Hàm phụ để trích xuất tên file thật từ chuỗi header
    private String extractFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] items = contentDisp.split(";");
        for (String s : items) {
            if (s.trim().startsWith("filename")) {
                return s.substring(s.indexOf("=") + 2, s.length() - 1);
            }
        }
        return "";
    }
}
