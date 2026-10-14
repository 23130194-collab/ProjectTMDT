package controller;

import model.Product;
import model.ProductImage;
import model.User;
import service.ProductService;
import util.JsonUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.ArrayList;
import java.util.Collection;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
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
        // Cho phép tất cả người dùng (kể cả chưa đăng nhập) vào trang đăng tin
        // Việc kiểm tra login chỉ xảy ra khi submit form (doPost)
        request.getRequestDispatcher("03-dang-tin.jsp").forward(request, response);
    }

    private void putIfPresent(Map<String, String> map, String key, String value) {
        if (value != null && !value.trim().isEmpty() && !value.startsWith("-- Chọn")) {
            map.put(key, value.trim());
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        // 0. Kiểm tra đăng nhập: lấy user từ session
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        User currentUser = (User) session.getAttribute("user");

        // 1. Lấy thông tin text từ Form
        String title = request.getParameter("title");
        String categoryIdStr = request.getParameter("categoryId"); 
        String priceStr = request.getParameter("price");
        String description = request.getParameter("description");
        String dealType = request.getParameter("deal_type"); // "sell" hoặc "give"

        int categoryId = 1;
        try {
            if (categoryIdStr != null) {
                if (categoryIdStr.matches("\\d+")) {
                    categoryId = Integer.parseInt(categoryIdStr);
                } else if (categoryIdStr.contains("Điện Tử")) {
                    categoryId = 1;
                } else if (categoryIdStr.contains("Xe Cộ")) {
                    categoryId = 2;
                } else if (categoryIdStr.contains("Điện Lạnh")) {
                    categoryId = 3;
                } else if (categoryIdStr.contains("Nội Thất")) {
                    categoryId = 4;
                }
            }
        } catch (Exception e) {}

        // Nếu chọn "Tặng miễn phí" thì price = 0, bỏ qua giá nhập vào
        double price = 0;
        if (!"give".equals(dealType)) {
            try {
                if (priceStr != null) {
                    price = Double.parseDouble(priceStr.replace(".", "").replace(",", ""));
                }
            } catch (Exception e) {}
        }

        // Đóng gói thông số kỹ thuật (specifications) theo từng danh mục
        Map<String, String> specsMap = new LinkedHashMap<>();
        String conditionStatus = "GOOD";

        if (categoryId == 1) { // Điện Tử & Thiết Bị Số
            putIfPresent(specsMap, "Loại thiết bị", request.getParameter("spec_device_type"));
            putIfPresent(specsMap, "Hãng sản xuất", request.getParameter("spec_brand"));
            putIfPresent(specsMap, "Dòng máy", request.getParameter("spec_model"));
            putIfPresent(specsMap, "Tình trạng", request.getParameter("spec_condition"));
            putIfPresent(specsMap, "Dung lượng / RAM", request.getParameter("spec_capacity"));
            putIfPresent(specsMap, "Màu sắc", request.getParameter("spec_color"));
            putIfPresent(specsMap, "Pin", request.getParameter("spec_battery"));
            putIfPresent(specsMap, "Bảo hành & Phụ kiện", request.getParameter("spec_warranty"));

            String cond = request.getParameter("spec_condition");
            if (cond != null) {
                if (cond.contains("100%")) conditionStatus = "NEW";
                else if (cond.contains("99%")) conditionStatus = "LIKE_NEW";
                else if (cond.contains("98%") || cond.contains("95%")) conditionStatus = "GOOD";
                else conditionStatus = "FAIR";
            }
        } else if (categoryId == 2) { // Xe Cộ & Phương Tiện
            putIfPresent(specsMap, "Loại phương tiện", request.getParameter("spec_vehicle_type"));
            putIfPresent(specsMap, "Hãng xe", request.getParameter("spec_vehicle_brand"));
            putIfPresent(specsMap, "Dòng xe / Đời xe", request.getParameter("spec_vehicle_model"));
            putIfPresent(specsMap, "Năm đăng ký", request.getParameter("spec_reg_year"));
            putIfPresent(specsMap, "Tình trạng giấy tờ", request.getParameter("spec_legal_status"));
            putIfPresent(specsMap, "Số km đã đi", request.getParameter("spec_odo"));
            putIfPresent(specsMap, "Dung tích động cơ", request.getParameter("spec_engine_capacity"));
            putIfPresent(specsMap, "Tình trạng máy móc", request.getParameter("spec_engine_condition"));

            String reg = request.getParameter("spec_reg_year");
            if (reg != null && (reg.contains("2026") || reg.contains("2025"))) {
                conditionStatus = "LIKE_NEW";
            } else {
                conditionStatus = "GOOD";
            }
        } else if (categoryId == 3) { // Điện Lạnh & Gia Dụng
            putIfPresent(specsMap, "Loại thiết bị", request.getParameter("spec_appliance_type"));
            putIfPresent(specsMap, "Thương hiệu", request.getParameter("spec_appliance_brand"));
            putIfPresent(specsMap, "Công suất / Dung tích", request.getParameter("spec_appliance_power"));
            putIfPresent(specsMap, "Tình trạng hoạt động", request.getParameter("spec_operation_status"));
            putIfPresent(specsMap, "Ngoại quan", request.getParameter("spec_appliance_condition"));
            putIfPresent(specsMap, "Chính sách hỗ trợ", request.getParameter("spec_appliance_support"));

            String cond = request.getParameter("spec_appliance_condition");
            if (cond != null && cond.contains("98%")) {
                conditionStatus = "LIKE_NEW";
            } else {
                conditionStatus = "GOOD";
            }
        } else if (categoryId == 4) { // Nội Thất & Đồ Gia Đình
            putIfPresent(specsMap, "Loại đồ dùng", request.getParameter("spec_furniture_type"));
            putIfPresent(specsMap, "Chất liệu chính", request.getParameter("spec_material"));
            putIfPresent(specsMap, "Kích thước", request.getParameter("spec_dimensions"));
            putIfPresent(specsMap, "Màu sắc", request.getParameter("spec_furniture_color"));
            putIfPresent(specsMap, "Tình trạng ngoại quan", request.getParameter("spec_furniture_condition"));
            putIfPresent(specsMap, "Tháo lắp & Vận chuyển", request.getParameter("spec_transport"));

            String cond = request.getParameter("spec_furniture_condition");
            if (cond != null && cond.contains("99%")) {
                conditionStatus = "LIKE_NEW";
            } else {
                conditionStatus = "GOOD";
            }
        }

        String specsJson = JsonUtil.mapToJson(specsMap);

        // 2. Lưu địa chỉ tin đăng thành các trường riêng để có thể lọc chính xác.
        String province = request.getParameter("province");
        String ward = request.getParameter("ward");
        String addressDetail = request.getParameter("address_detail");

        // 3. Tạo đối tượng Product
        Product product = new Product();
        product.setUserId(currentUser.getId()); // Lấy từ session
        product.setCategoryId(categoryId);
        product.setTitle(title);
        product.setDescription(description);
        product.setPrice(price);
        product.setConditionStatus(conditionStatus);
        product.setSpecifications(specsJson);
        product.setProvince(province);
        product.setWard(ward);
        product.setAddressDetail(addressDetail);
        product.setStatus("PENDING");

        String deliveryMethodStr = request.getParameter("delivery_method");
        int deliveryMethod = 1;
        if (deliveryMethodStr != null) {
            try { deliveryMethod = Integer.parseInt(deliveryMethodStr); } catch (Exception e) {}
        }
        product.setDeliveryMethod(deliveryMethod);
        product.setDealType("give".equals(dealType) ? "GIVE" : "SELL"); // Lưu loại giao dịch

        // 3. Xử lý Upload Ảnh
        String applicationPath = request.getServletContext().getRealPath("");
        String uploadFilePath = applicationPath + File.separator + UPLOAD_DIR;

        // Thư mục lưu vào mã nguồn (nếu có)
        String sourceFilePath = "e:" + File.separator + "ProjectTMDT" + File.separator + "web" + File.separator + UPLOAD_DIR.replace("/", File.separator);

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
