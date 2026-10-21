package controller;

import dao.ProductDAO;
import dao.ProductImageDAO;
import model.Product;
import model.ProductImage;
import model.User;
import service.ModerationService;
import util.JsonUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

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
import jakarta.servlet.http.Part;

@WebServlet("/edit-post")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2, // 2MB
        maxFileSize = 1024 * 1024 * 10,      // 10MB
        maxRequestSize = 1024 * 1024 * 50    // 50MB
)
public class EditPostController extends HttpServlet {
    private ProductDAO productDAO = new ProductDAO();
    private ProductImageDAO productImageDAO = new ProductImageDAO();
    private ModerationService moderationService = new ModerationService();
    private static final String UPLOAD_DIR = "assets/uploads";

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
                    List<ProductImage> existingImages = productImageDAO.getImagesByProductId(productId);
                    req.setAttribute("editProduct", product);
                    req.setAttribute("editProductImages", existingImages);
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

                    // Cập nhật specifications và conditionStatus theo danh mục
                    Map<String, String> specsMap = new LinkedHashMap<>();
                    String conditionStatus = existing.getConditionStatus();

                    if (categoryId == 1) { // Điện Tử & Thiết Bị Số
                        putIfPresent(specsMap, "Loại thiết bị", req.getParameter("spec_device_type"));
                        putIfPresent(specsMap, "Hãng sản xuất", req.getParameter("spec_brand"));
                        putIfPresent(specsMap, "Dòng máy", req.getParameter("spec_model"));
                        putIfPresent(specsMap, "Tình trạng ngoại quan", req.getParameter("spec_condition"));
                        putIfPresent(specsMap, "Dung lượng / RAM", req.getParameter("spec_capacity"));
                        putIfPresent(specsMap, "Màu sắc", req.getParameter("spec_color"));
                        putIfPresent(specsMap, "Tình trạng Pin", req.getParameter("spec_battery"));
                        putIfPresent(specsMap, "Phụ kiện & Bảo hành", req.getParameter("spec_warranty"));
                        String cond = req.getParameter("spec_condition");
                        if (cond != null) {
                            if (cond.contains("100%")) conditionStatus = "NEW";
                            else if (cond.contains("99%")) conditionStatus = "LIKE_NEW";
                            else if (cond.contains("98%") || cond.contains("95%")) conditionStatus = "GOOD";
                            else conditionStatus = "FAIR";
                        }
                    } else if (categoryId == 2) { // Xe Cộ & Phương Tiện
                        putIfPresent(specsMap, "Loại phương tiện", req.getParameter("spec_vehicle_type"));
                        putIfPresent(specsMap, "Hãng xe", req.getParameter("spec_vehicle_brand"));
                        putIfPresent(specsMap, "Dòng xe / Đời xe", req.getParameter("spec_vehicle_model"));
                        putIfPresent(specsMap, "Năm đăng ký", req.getParameter("spec_reg_year"));
                        putIfPresent(specsMap, "Tình trạng giấy tờ", req.getParameter("spec_legal_status"));
                        putIfPresent(specsMap, "Số km đã đi (Odo)", req.getParameter("spec_odo"));
                        putIfPresent(specsMap, "Dung tích động cơ", req.getParameter("spec_engine_capacity"));
                        putIfPresent(specsMap, "Tình trạng máy móc", req.getParameter("spec_engine_condition"));
                        String reg = req.getParameter("spec_reg_year");
                        conditionStatus = (reg != null && (reg.contains("2026") || reg.contains("2025"))) ? "LIKE_NEW" : "GOOD";
                    } else if (categoryId == 3) { // Điện Lạnh & Gia Dụng
                        putIfPresent(specsMap, "Loại thiết bị", req.getParameter("spec_appliance_type"));
                        putIfPresent(specsMap, "Thương hiệu", req.getParameter("spec_appliance_brand"));
                        putIfPresent(specsMap, "Công suất / Dung tích", req.getParameter("spec_appliance_power"));
                        putIfPresent(specsMap, "Tình trạng hoạt động", req.getParameter("spec_operation_status"));
                        putIfPresent(specsMap, "Tình trạng ngoại quan", req.getParameter("spec_appliance_condition"));
                        putIfPresent(specsMap, "Chính sách hỗ trợ", req.getParameter("spec_appliance_support"));
                        String cond = req.getParameter("spec_appliance_condition");
                        conditionStatus = (cond != null && cond.contains("98%")) ? "LIKE_NEW" : "GOOD";
                    } else if (categoryId == 4) { // Nội Thất & Đồ Gia Đình
                        putIfPresent(specsMap, "Loại đồ dùng", req.getParameter("spec_furniture_type"));
                        putIfPresent(specsMap, "Chất liệu chính", req.getParameter("spec_material"));
                        putIfPresent(specsMap, "Kích thước", req.getParameter("spec_dimensions"));
                        putIfPresent(specsMap, "Màu sắc", req.getParameter("spec_furniture_color"));
                        putIfPresent(specsMap, "Tình trạng ngoại quan", req.getParameter("spec_furniture_condition"));
                        putIfPresent(specsMap, "Tháo lắp & Vận chuyển", req.getParameter("spec_transport"));
                        String cond = req.getParameter("spec_furniture_condition");
                        conditionStatus = (cond != null && cond.contains("99%")) ? "LIKE_NEW" : "GOOD";
                    }

                    // Chỉ ghi đè specs nếu form có gửi ít nhất 1 giá trị spec
                    if (!specsMap.isEmpty()) {
                        existing.setSpecifications(JsonUtil.mapToJson(specsMap));
                        existing.setConditionStatus(conditionStatus);
                    }

                    // Sau khi sửa, kiểm duyệt lại từ khóa cấm
                    String editTitle = existing.getTitle();
                    String editDescription = existing.getDescription();
                    String newStatus = moderationService.moderate(editTitle, editDescription);
                    existing.setStatus(newStatus);


                    boolean updated = productDAO.updateProduct(existing);
                    if (updated) {
                        // Xử lý ảnh: nếu user upload ảnh mới thì thay thế ảnh cũ
                        String applicationPath = req.getServletContext().getRealPath("");
                        String uploadFilePath = applicationPath + File.separator + UPLOAD_DIR.replace("/", File.separator);
                        String sourceFilePath = "e:" + File.separator + "ProjectTMDT" + File.separator + "web" + File.separator + UPLOAD_DIR.replace("/", File.separator);

                        new File(uploadFilePath).mkdirs();
                        new File(sourceFilePath).mkdirs();

                        List<ProductImage> newImages = new ArrayList<>();
                        boolean isFirst = true;
                        try {
                            Collection<Part> parts = req.getParts();
                            for (Part part : parts) {
                                if ("images".equals(part.getName()) && part.getSize() > 0) {
                                    String fileName = UUID.randomUUID() + "_" + extractFileName(part);
                                    part.write(uploadFilePath + File.separator + fileName);
                                    try {
                                        Files.copy(
                                            Paths.get(uploadFilePath + File.separator + fileName),
                                            Paths.get(sourceFilePath + File.separator + fileName),
                                            StandardCopyOption.REPLACE_EXISTING
                                        );
                                    } catch (Exception ignored) {}
                                    ProductImage img = new ProductImage();
                                    img.setProductId(productId);
                                    img.setImageUrl(UPLOAD_DIR + "/" + fileName);
                                    img.setPrimary(isFirst);
                                    newImages.add(img);
                                    isFirst = false;
                                }
                            }
                        } catch (Exception ignored) {}

                        if (!newImages.isEmpty()) {
                            // Xóa ảnh cũ trong DB (giữ file vật lý để an toàn), sau đó insert ảnh mới
                            productImageDAO.deleteImagesByProductId(productId);
                            productImageDAO.insertImages(newImages);
                        }
                        // Nếu không upload ảnh mới thì giữ nguyên ảnh cũ

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

    private void putIfPresent(Map<String, String> map, String key, String value) {
        if (value != null && !value.trim().isEmpty() && !value.startsWith("-- Chọn")) {
            map.put(key, value.trim());
        }
    }

    private String extractFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        if (contentDisp == null) return "upload";
        for (String s : contentDisp.split(";")) {
            if (s.trim().startsWith("filename")) {
                return s.substring(s.indexOf("=") + 2, s.length() - 1);
            }
        }
        return "upload";
    }
}
