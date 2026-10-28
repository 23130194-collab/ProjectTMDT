package controller;

import dao.BoostPackageDAO;
import dao.ProductBoostDAO;
import dao.UserDao;
import model.BoostPackage;
import model.Product;
import model.ProductImage;
import model.User;
import service.ModerationService;
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

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.io.File;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

@WebServlet(name = "PostAdController", value = "/post-ad")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2, // 2MB
        maxFileSize = 1024 * 1024 * 10,      // 10MB
        maxRequestSize = 1024 * 1024 * 50    // 50MB
)
public class PostAdController extends HttpServlet {

    private static final String SANDBOX_URL = "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html";
    private static final ZoneId VIETNAM_ZONE = ZoneId.of("Asia/Ho_Chi_Minh");
    private static final DateTimeFormatter VNPAY_DATE = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");

    private final ProductService productService = new ProductService();
    private final ModerationService moderationService = new ModerationService();
    private final BoostPackageDAO boostPackageDAO = new BoostPackageDAO();
    private final ProductBoostDAO productBoostDAO = new ProductBoostDAO();
    private final UserDao userDao = new UserDao();
    private static final String UPLOAD_DIR = "assets/uploads";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        loadBoostData(request);
        request.getRequestDispatcher("03-dang-tin.jsp").forward(request, response);
    }

    private void loadBoostData(HttpServletRequest request) {
        try {
            List<BoostPackage> packages = boostPackageDAO.getAllActivePackages();
            request.setAttribute("boostPackages", packages);
        } catch (Exception ignored) {}

        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            User user = (User) session.getAttribute("user");
            int credits = userDao.getUserBumpCredits(user.getId());
            request.setAttribute("userBumpCredits", credits);
        } else {
            request.setAttribute("userBumpCredits", 0);
        }
    }

    private void putIfPresent(Map<String, String> map, String key, String value) {
        if (value != null && !value.trim().isEmpty() && !value.startsWith("-- Chọn")) {
            map.put(key, value.trim());
        }
    }

    private void populateFormAttributes(HttpServletRequest request, String title, String priceStr, String description,
                                        int categoryId, String dealType, int deliveryMethod,
                                        String province, String ward, String addressDetail,
                                        Map<String, String> specsMap) {
        request.setAttribute("formTitle", title);
        request.setAttribute("formPrice", priceStr);
        request.setAttribute("formDesc", description);
        request.setAttribute("formCatId", categoryId);
        request.setAttribute("formDealType", dealType);
        request.setAttribute("formDelivery", deliveryMethod);
        request.setAttribute("formProvince", province);
        request.setAttribute("formWard", ward);
        request.setAttribute("formAddressDetail", addressDetail);
        request.setAttribute("formSpecsJson", JsonUtil.mapToJson(specsMap));
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        // 0. Kiểm tra đăng nhập
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login?redirect=post-ad");
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
        } catch (Exception ignored) {}

        double price = 0;
        if (!"give".equals(dealType)) {
            try {
                if (priceStr != null) {
                    price = Double.parseDouble(priceStr.replace(".", "").replace(",", "").trim());
                }
            } catch (Exception ignored) {}
        }

        // Đóng gói thông số kỹ thuật (specifications) theo từng danh mục
        Map<String, String> specsMap = new LinkedHashMap<>();
        String conditionStatus = "GOOD";

        if (categoryId == 1) { // Điện Tử & Thiết Bị Số
            putIfPresent(specsMap, "Loại thiết bị", request.getParameter("spec_device_type"));
            putIfPresent(specsMap, "Hãng sản xuất", request.getParameter("spec_brand"));
            putIfPresent(specsMap, "Dòng máy", request.getParameter("spec_model"));
            putIfPresent(specsMap, "Tình trạng ngoại quan", request.getParameter("spec_condition"));
            putIfPresent(specsMap, "Dung lượng / RAM", request.getParameter("spec_capacity"));
            putIfPresent(specsMap, "Màu sắc", request.getParameter("spec_color"));
            putIfPresent(specsMap, "Tình trạng Pin", request.getParameter("spec_battery"));
            putIfPresent(specsMap, "Phụ kiện & Bảo hành", request.getParameter("spec_warranty"));

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
            putIfPresent(specsMap, "Số km đã đi (Odo)", request.getParameter("spec_odo"));
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
            putIfPresent(specsMap, "Tình trạng ngoại quan", request.getParameter("spec_appliance_condition"));
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

        String province = request.getParameter("province");
        String ward = request.getParameter("ward");
        String addressDetail = request.getParameter("address_detail");

        String deliveryMethodStr = request.getParameter("delivery_method");
        int deliveryMethod = 1;
        if (deliveryMethodStr != null) {
            try { deliveryMethod = Integer.parseInt(deliveryMethodStr); } catch (Exception ignored) {}
        }

        // 2. Kiểm duyệt tự động trước khi lưu: quét từ khóa cấm
        String combined = (title != null ? title : "") + " " + (description != null ? description : "");
        String violation = moderationService.findViolation(combined);
        if (violation != null) {
            request.setAttribute("moderationError", "Bài đăng chứa từ khóa không phù hợp: \"" + violation + "\". Vui lòng chỉnh sửa lại tiêu đề hoặc mô tả.");
            populateFormAttributes(request, title, priceStr, description, categoryId, dealType, deliveryMethod, province, ward, addressDetail, specsMap);
            loadBoostData(request);
            request.getRequestDispatcher("03-dang-tin.jsp").forward(request, response);
            return;
        }

        // 3. Xử lý & Kiểm tra Upload Ảnh
        String applicationPath = request.getServletContext().getRealPath("");
        String uploadFilePath = applicationPath + File.separator + UPLOAD_DIR.replace("/", File.separator);
        File fileSaveDir = new File(uploadFilePath);
        if (!fileSaveDir.exists()) fileSaveDir.mkdirs();

        File devSourceDir = resolveDevUploadDir(applicationPath);
        if (devSourceDir != null && !devSourceDir.exists()) devSourceDir.mkdirs();

        List<ProductImage> images = new ArrayList<>();
        boolean isFirst = true;

        Collection<Part> parts = request.getParts();
        for (Part part : parts) {
            if ("images".equals(part.getName()) && part.getSize() > 0) {
                String originalName = extractFileName(part);
                if (isAllowedImageFile(originalName)) {
                    String cleanName = sanitizeFileName(originalName);
                    String fileName = UUID.randomUUID().toString().substring(0, 8) + "_" + cleanName;

                    part.write(uploadFilePath + File.separator + fileName);

                    if (devSourceDir != null && devSourceDir.exists()) {
                        try {
                            Files.copy(
                                Paths.get(uploadFilePath + File.separator + fileName),
                                Paths.get(devSourceDir.getAbsolutePath() + File.separator + fileName),
                                StandardCopyOption.REPLACE_EXISTING
                            );
                        } catch (Exception ignored) {}
                    }

                    ProductImage img = new ProductImage();
                    img.setImageUrl(UPLOAD_DIR + "/" + fileName);
                    img.setPrimary(isFirst);
                    images.add(img);
                    isFirst = false;
                }
            }
        }

        // Kiểm tra bắt buộc ít nhất 1 ảnh
        if (images.isEmpty()) {
            request.setAttribute("imageError", "Vui lòng chọn ít nhất 1 hình ảnh chụp thực tế của sản phẩm (chấp nhận định dạng JPG, PNG, WEBP).");
            populateFormAttributes(request, title, priceStr, description, categoryId, dealType, deliveryMethod, province, ward, addressDetail, specsMap);
            loadBoostData(request);
            request.getRequestDispatcher("03-dang-tin.jsp").forward(request, response);
            return;
        }

        // 4. Tạo đối tượng Product
        Product product = new Product();
        product.setUserId(currentUser.getId());
        product.setCategoryId(categoryId);
        product.setTitle(title);
        product.setDescription(description);
        product.setPrice(price);
        product.setStatus("ACTIVE");
        product.setConditionStatus(conditionStatus);
        product.setSpecifications(specsJson);
        product.setProvince(province);
        product.setWard(ward);
        product.setAddressDetail(addressDetail);
        product.setDeliveryMethod(deliveryMethod);
        product.setDealType("give".equals(dealType) ? "GIVE" : "SELL");

        // 5. Lưu vào Database thông qua Service
        boolean success = productService.createProductWithImages(product, images);
        if (!success || product.getId() <= 0) {
            request.setAttribute("generalError", "Không thể lưu tin đăng vào hệ thống. Vui lòng kiểm tra lại thông tin.");
            populateFormAttributes(request, title, priceStr, description, categoryId, dealType, deliveryMethod, province, ward, addressDetail, specsMap);
            loadBoostData(request);
            request.getRequestDispatcher("03-dang-tin.jsp").forward(request, response);
            return;
        }

        // 6. Xử lý Gói Đẩy Tin (VIP Boost)
        String vipBoost = request.getParameter("vip_boost");

        // Trường hợp 1: Dùng 1 lượt đẩy có sẵn từ Ví lượt đẩy
        if ("use_bump".equals(vipBoost)) {
            int credits = userDao.getUserBumpCredits(currentUser.getId());
            if (credits > 0 && productBoostDAO.useAvailableBump(product.getId(), currentUser.getId())) {
                currentUser.setBumpCredits(userDao.getUserBumpCredits(currentUser.getId()));
                session.setAttribute("user", currentUser);
                response.sendRedirect(request.getContextPath() + "/home?message=post_boosted_success");
                return;
            }
        }

        // Trường hợp 2: Chọn gói VIP trả phí (ID gói > 0)
        if (vipBoost != null && vipBoost.matches("\\d+")) {
            int pkgId = Integer.parseInt(vipBoost);
            if (pkgId > 0) {
                BoostPackage pkg = boostPackageDAO.getPackageById(pkgId);
                if (pkg != null && pkg.isActive()) {
                    String tmnCode = config("VNPAY_TMN_CODE");
                    String hashSecret = config("VNPAY_HASH_SECRET");
                    String txnRef = "BST" + System.currentTimeMillis() + "_" + product.getId() + "_" + pkg.getId() + "_" + currentUser.getId();

                    // Nếu môi trường test hoặc chưa điền key VNPay, tự động kích hoạt chế độ mô phỏng
                    if (tmnCode.isEmpty() || hashSecret.isEmpty()) {
                        productBoostDAO.applyBoostPackage(product.getId(), currentUser.getId(), pkg, txnRef, pkg.getPrice());
                        currentUser.setBumpCredits(userDao.getUserBumpCredits(currentUser.getId()));
                        session.setAttribute("user", currentUser);
                        response.sendRedirect(request.getContextPath() + "/my-posts?message=post_and_boost_success");
                        return;
                    } else {
                        // Chuyển hướng sang VNPay Sandbox để thanh toán
                        String paymentUrl = buildVnPayPaymentUrl(request, currentUser, pkg, product.getId(), txnRef, tmnCode, hashSecret);
                        response.sendRedirect(paymentUrl);
                        return;
                    }
                }
            }
        }

        // Trường hợp 3: Tin thường miễn phí thành công
        response.sendRedirect(request.getContextPath() + "/home?message=post_success");
    }

    private File resolveDevUploadDir(String applicationPath) {
        String userDir = System.getProperty("user.dir");
        if (userDir != null) {
            File c1 = new File(userDir, "web" + File.separator + UPLOAD_DIR.replace("/", File.separator));
            if (c1.exists()) return c1;
            File c2 = new File(userDir, "ProjectTMDT" + File.separator + "web" + File.separator + UPLOAD_DIR.replace("/", File.separator));
            if (c2.exists()) return c2;
        }
        try {
            File current = new File(applicationPath);
            for (int i = 0; i < 4 && current != null; i++) {
                File checkWeb = new File(current, "web" + File.separator + UPLOAD_DIR.replace("/", File.separator));
                if (checkWeb.exists()) return checkWeb;
                current = current.getParentFile();
            }
        } catch (Exception ignored) {}
        return null;
    }

    private boolean isAllowedImageFile(String filename) {
        if (filename == null || filename.trim().isEmpty()) return false;
        String lower = filename.toLowerCase();
        return lower.endsWith(".jpg") || lower.endsWith(".jpeg") || lower.endsWith(".png")
                || lower.endsWith(".webp") || lower.endsWith(".gif") || lower.endsWith(".bmp");
    }

    private String sanitizeFileName(String filename) {
        if (filename == null) return "image.jpg";
        String clean = Paths.get(filename).getFileName().toString();
        clean = clean.replaceAll("[^a-zA-Z0-9._-]", "_");
        if (clean.length() > 50) {
            int extIdx = clean.lastIndexOf(".");
            String ext = extIdx > 0 ? clean.substring(extIdx) : "";
            clean = clean.substring(0, Math.min(30, clean.length())) + ext;
        }
        return clean.isEmpty() ? "image.jpg" : clean;
    }

    private String extractFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        if (contentDisp == null) return "";
        for (String item : contentDisp.split(";")) {
            if (item.trim().startsWith("filename")) {
                String fn = item.substring(item.indexOf("=") + 2, item.length() - 1);
                return Paths.get(fn).getFileName().toString();
            }
        }
        return "";
    }

    private String buildVnPayPaymentUrl(HttpServletRequest request, User user, BoostPackage pkg, int productId,
                                        String txnRef, String tmnCode, String hashSecret) {
        Map<String, String> params = new TreeMap<>();
        ZonedDateTime now = ZonedDateTime.now(VIETNAM_ZONE);
        params.put("vnp_Version", "2.1.0");
        params.put("vnp_Command", "pay");
        params.put("vnp_TmnCode", tmnCode);
        params.put("vnp_Amount", String.valueOf(Math.round(pkg.getPrice() * 100)));
        params.put("vnp_CurrCode", "VND");
        params.put("vnp_TxnRef", txnRef);
        String orderInfo = pkg.isBumpPackage()
                ? "Nap goi " + pkg.getBumpCount() + " luot day cho vi nguoi dung " + user.getId()
                : "Thanh toan goi " + pkg.getPackageType() + " cho san pham " + productId;
        params.put("vnp_OrderInfo", orderInfo);
        params.put("vnp_OrderType", "other");
        params.put("vnp_Locale", "vn");
        params.put("vnp_ReturnUrl", buildReturnUrl(request));
        params.put("vnp_IpAddr", clientIp(request));
        params.put("vnp_CreateDate", now.format(VNPAY_DATE));
        params.put("vnp_ExpireDate", now.plusMinutes(15).format(VNPAY_DATE));

        String hashData = buildHashData(params);
        return SANDBOX_URL + "?" + buildQuery(params) + "&vnp_SecureHash=" + hmacSha512(hashSecret, hashData);
    }

    private String buildReturnUrl(HttpServletRequest request) {
        String scheme = request.getScheme();
        String serverName = request.getServerName();
        int serverPort = request.getServerPort();
        String contextPath = request.getContextPath();

        StringBuilder url = new StringBuilder();
        url.append(scheme).append("://").append(serverName);
        if (("http".equals(scheme) && serverPort != 80) || ("https".equals(scheme) && serverPort != 443)) {
            url.append(":").append(serverPort);
        }
        url.append(contextPath).append("/boost-return");
        return url.toString();
    }

    private String clientIp(HttpServletRequest request) {
        String ip = request.getHeader("X-Forwarded-For");
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) ip = request.getRemoteAddr();
        if (ip != null && ip.contains(",")) ip = ip.split(",")[0].trim();
        return ip == null ? "127.0.0.1" : ip;
    }

    private String buildHashData(Map<String, String> params) {
        List<String> names = new ArrayList<>(params.keySet());
        Collections.sort(names);
        StringBuilder hashData = new StringBuilder();
        for (String name : names) {
            String value = params.get(name);
            if (value == null || value.isEmpty()) continue;
            if (hashData.length() > 0) hashData.append('&');
            hashData.append(name).append('=').append(encode(value));
        }
        return hashData.toString();
    }

    private String buildQuery(Map<String, String> params) {
        List<String> names = new ArrayList<>(params.keySet());
        Collections.sort(names);
        StringBuilder query = new StringBuilder();
        for (String name : names) {
            String value = params.get(name);
            if (value == null || value.isEmpty()) continue;
            if (query.length() > 0) query.append('&');
            query.append(encode(name)).append('=').append(encode(value));
        }
        return query.toString();
    }

    private String encode(String value) {
        return URLEncoder.encode(value, StandardCharsets.US_ASCII);
    }

    private String hmacSha512(String key, String data) {
        try {
            Mac hmac = Mac.getInstance("HmacSHA512");
            hmac.init(new SecretKeySpec(key.getBytes(StandardCharsets.UTF_8), "HmacSHA512"));
            byte[] digest = hmac.doFinal(data.getBytes(StandardCharsets.UTF_8));
            StringBuilder hex = new StringBuilder(digest.length * 2);
            for (byte b : digest) hex.append(String.format("%02x", b & 0xff));
            return hex.toString();
        } catch (Exception e) {
            return "";
        }
    }

    private String config(String name) {
        String value = System.getenv(name);
        if (value == null || value.trim().isEmpty()) value = System.getProperty(name, "");
        return value == null ? "" : value.trim();
    }
}
