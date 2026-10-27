package controller;

import dao.BoostPackageDAO;
import dao.ProductBoostDAO;
import dao.ProductDAO;
import model.BoostPackage;
import model.Product;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.time.ZonedDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.*;

@WebServlet(name = "BoostServiceServlet", urlPatterns = {"/boost-service", "/boost-return"})
public class BoostServiceServlet extends HttpServlet {
    private static final String SANDBOX_URL = "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html";
    private static final ZoneId VIETNAM_ZONE = ZoneId.of("Asia/Ho_Chi_Minh");
    private static final DateTimeFormatter VNPAY_DATE = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");

    private final BoostPackageDAO boostPackageDAO = new BoostPackageDAO();
    private final ProductBoostDAO productBoostDAO = new ProductBoostDAO();
    private final ProductDAO productDAO = new ProductDAO();
    private final dao.UserDao userDao = new dao.UserDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String path = request.getServletPath();
        if ("/boost-return".equals(path)) {
            handleVnPayReturn(request, response);
            return;
        }

        String action = request.getParameter("action");
        response.setContentType("application/json;charset=UTF-8");

        if ("packages".equals(action)) {
            // Lấy danh sách gói đang hoạt động dạng JSON
            List<BoostPackage> list = boostPackageDAO.getAllActivePackages();
            StringBuilder json = new StringBuilder("[");
            for (int i = 0; i < list.size(); i++) {
                BoostPackage p = list.get(i);
                if (i > 0) json.append(",");
                json.append(String.format(
                    "{\"id\":%d,\"name\":\"%s\",\"type\":\"%s\",\"price\":%.0f,\"days\":%d,\"bumps\":%d,\"priority\":%d,\"badge\":\"%s\",\"color\":\"%s\",\"desc\":\"%s\"}",
                    p.getId(), jsonEscape(p.getName()), p.getPackageType(), p.getPrice(), p.getDurationDays(),
                    p.getBumpCount(), p.getPriorityLevel(), jsonEscape(p.getBadgeLabel()),
                    jsonEscape(p.getBadgeColor()), jsonEscape(p.getDescription())
                ));
            }
            json.append("]");
            response.getWriter().write(json.toString());
            return;
        }

        response.getWriter().write("{\"status\":\"ok\"}");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"status\":\"error\",\"message\":\"Vui lòng đăng nhập để thực hiện.\"}");
            return;
        }

        String action = request.getParameter("action");
        int productId = parseInt(request.getParameter("productId"));

        // HÀNH ĐỘNG 1: Dùng lượt đẩy tin có sẵn từ Ví Lượt Đẩy
        if ("use_bump".equals(action)) {
            Product product = productDAO.getProductById(productId);
            if (product == null || product.getUserId() != user.getId()) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                response.getWriter().write("{\"status\":\"error\",\"message\":\"Không tìm thấy bài đăng hoặc bạn không phải chủ sở hữu bài viết này.\"}");
                return;
            }

            // 1. Chỉ bài đăng ACTIVE mới được phép đẩy
            if (!"ACTIVE".equalsIgnoreCase(product.getStatus())) {
                response.getWriter().write("{\"status\":\"error\",\"message\":\"Chỉ bài đăng đang hoạt động (ACTIVE) mới có thể sử dụng lượt đẩy tin.\"}");
                return;
            }

            // 2. Cooldown Protection: Tránh spam bấm nhầm làm lãng phí lượt đẩy (giãn cách tối thiểu 5 phút)
            java.sql.Timestamp lastBumped = product.getBumpedAt();
            if (lastBumped != null) {
                long diffMillis = System.currentTimeMillis() - lastBumped.getTime();
                long cooldownMillis = 5L * 60 * 1000; // 5 phút
                if (diffMillis < cooldownMillis) {
                    long remainingSeconds = (cooldownMillis - diffMillis) / 1000;
                    long remainingMinutes = (remainingSeconds + 59) / 60;
                    response.getWriter().write(String.format("{\"status\":\"cooldown\",\"message\":\"Bài đăng của bạn vừa được đẩy cách đây ít phút và đang ở đầu danh sách. Vui lòng quay lại sau %d phút nữa để tránh lãng phí lượt đẩy!\"}", remainingMinutes));
                    return;
                }
            }

            int walletCredits = userDao.getUserBumpCredits(user.getId());
            if (walletCredits <= 0 && product.getRemainingBumps() <= 0) {
                response.getWriter().write("{\"status\":\"no_credits\",\"message\":\"Ví lượt đẩy của bạn đã hết. Vui lòng nạp thêm lượt đẩy để tiếp tục.\"}");
                return;
            }

            boolean ok = productBoostDAO.useAvailableBump(productId, user.getId());
            if (ok) {
                int newCredits = userDao.getUserBumpCredits(user.getId());
                user.setBumpCredits(newCredits);
                session.setAttribute("user", user);
                response.getWriter().write(String.format("{\"status\":\"success\",\"message\":\"Đẩy tin thành công! Tin đăng của bạn đã nhảy lên đầu danh mục.\",\"remainingCredits\":%d}", newCredits));
            } else {
                response.getWriter().write("{\"status\":\"error\",\"message\":\"Không thể thực hiện đẩy tin. Vui lòng thử lại sau.\"}");
            }
            return;
        }

        // HÀNH ĐỘNG 2: Mua gói đẩy tin (Nạp Ví Lượt Đẩy) hoặc Ghim VIP bài đăng
        if ("buy".equals(action)) {
            int packageId = parseInt(request.getParameter("packageId"));
            BoostPackage pkg = boostPackageDAO.getPackageById(packageId);
            if (pkg == null || !pkg.isActive()) {
                response.getWriter().write("{\"status\":\"error\",\"message\":\"Gói dịch vụ không tồn tại hoặc đã tạm dừng.\"}");
                return;
            }

            Product product = null;
            if (productId > 0) {
                product = productDAO.getProductById(productId);
                if (product == null || product.getUserId() != user.getId()) {
                    response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                    response.getWriter().write("{\"status\":\"error\",\"message\":\"Không tìm thấy bài đăng hoặc bạn không phải chủ sở hữu bài viết này.\"}");
                    return;
                }

                // Nếu là gói VIP thì bắt buộc bài đăng phải đang ACTIVE
                if (pkg.isVipPackage() && !"ACTIVE".equalsIgnoreCase(product.getStatus())) {
                    response.getWriter().write("{\"status\":\"error\",\"message\":\"Chỉ bài đăng đang hoạt động (ACTIVE) mới có thể nâng cấp gói VIP.\"}");
                    return;
                }
            } else if (pkg.isVipPackage()) {
                response.getWriter().write("{\"status\":\"error\",\"message\":\"Gói Ghim VIP yêu cầu chọn một bài đăng cụ thể để áp dụng.\"}");
                return;
            }

            String isTestMode = request.getParameter("test_mode");
            String tmnCode = config("VNPAY_TMN_CODE");
            String hashSecret = config("VNPAY_HASH_SECRET");

            // Tạo mã giao dịch tham chiếu: BST<timestamp>_<productId>_<packageId>_<userId>
            String txnRef = "BST" + System.currentTimeMillis() + "_" + productId + "_" + pkg.getId() + "_" + user.getId();

            // Nếu người dùng chọn kích hoạt test nhanh hoặc chưa cấu hình VNPay key trong môi trường local
            if ("true".equalsIgnoreCase(isTestMode) || (tmnCode.isEmpty() && hashSecret.isEmpty())) {
                boolean ok = productBoostDAO.applyBoostPackage(productId > 0 ? productId : null, user.getId(), pkg, txnRef, pkg.getPrice());
                if (ok) {
                    int newCredits = userDao.getUserBumpCredits(user.getId());
                    user.setBumpCredits(newCredits);
                    session.setAttribute("user", user);

                    String successMsg;
                    if (pkg.isBumpPackage()) {
                        successMsg = (productId > 0)
                            ? String.format("Đẩy bài đăng lên đầu thành công! Đã cộng thêm %d lượt đẩy vào Ví Lượt Đẩy của bạn.", Math.max(0, pkg.getBumpCount() - 1))
                            : String.format("Nạp thành công %d lượt đẩy vào Ví Lượt Đẩy chung của bạn!", pkg.getBumpCount());
                    } else {
                        successMsg = String.format("Kích hoạt gói '%s' thành công cho bài đăng!", pkg.getName());
                    }

                    response.getWriter().write(String.format("{\"status\":\"success\",\"test_activated\":true,\"message\":\"%s (Chế độ mô phỏng Test)\",\"remainingCredits\":%d}", jsonEscape(successMsg), newCredits));
                } else {
                    response.getWriter().write("{\"status\":\"error\",\"message\":\"Lỗi kích hoạt gói dịch vụ.\"}");
                }
                return;
            }

            // Tạo link thanh toán VNPay Sandbox chính thức
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
            String paymentUrl = SANDBOX_URL + "?" + buildQuery(params) + "&vnp_SecureHash=" + hmacSha512(hashSecret, hashData);

            response.getWriter().write(String.format("{\"status\":\"success\",\"payment_url\":\"%s\"}", jsonEscape(paymentUrl)));
            return;
        }

        response.getWriter().write("{\"status\":\"error\",\"message\":\"Hành động không hợp lệ.\"}");
    }

    // Xử lý khi VNPay redirect người dùng về sau khi thanh toán
    private void handleVnPayReturn(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Map<String, String> params = getParameters(request);
        String vnpResponseCode = params.get("vnp_ResponseCode");
        String txnRef = params.get("vnp_TxnRef");
        HttpSession session = request.getSession();

        if ("00".equals(vnpResponseCode) && txnRef != null && txnRef.startsWith("BST")) {
            // Giải mã txnRef: BST<timestamp>_<productId>_<packageId>_<userId>
            try {
                String[] parts = txnRef.split("_");
                if (parts.length >= 4) {
                    int productId = Integer.parseInt(parts[1]);
                    int packageId = Integer.parseInt(parts[2]);
                    int userId = Integer.parseInt(parts[3]);
                    BoostPackage pkg = boostPackageDAO.getPackageById(packageId);

                    if (pkg != null) {
                        productBoostDAO.applyBoostPackage(productId > 0 ? productId : null, userId, pkg, txnRef, pkg.getPrice());

                        User sessionUser = (session != null) ? (User) session.getAttribute("user") : null;
                        if (sessionUser != null && sessionUser.getId() == userId) {
                            sessionUser.setBumpCredits(userDao.getUserBumpCredits(userId));
                            session.setAttribute("user", sessionUser);
                        }

                        session.setAttribute("boostFlashSuccess", true);
                        if (pkg.isBumpPackage()) {
                            session.setAttribute("boostFlashMessage", "Chúc mừng! Bạn đã nạp thành công " + pkg.getBumpCount() + " lượt đẩy vào Ví Lượt Đẩy.");
                        } else {
                            session.setAttribute("boostFlashMessage", "Chúc mừng! Bạn đã thanh toán thành công gói " + pkg.getName() + " cho tin đăng #" + productId);
                        }
                        response.sendRedirect(request.getContextPath() + "/my-posts");
                        return;
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        session.setAttribute("boostFlashSuccess", false);
        session.setAttribute("boostFlashMessage", "Giao dịch thanh toán gói đẩy tin không thành công hoặc đã bị hủy.");
        response.sendRedirect(request.getContextPath() + "/my-posts");
    }

    // Helper VNPay
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

    private Map<String, String> getParameters(HttpServletRequest request) {
        Map<String, String> params = new TreeMap<>();
        for (Map.Entry<String, String[]> entry : request.getParameterMap().entrySet()) {
            String[] values = entry.getValue();
            if (values != null && values.length > 0) params.put(entry.getKey(), values[0]);
        }
        return params;
    }

    private int parseInt(String value) {
        try { return value == null ? 0 : Integer.parseInt(value.trim()); }
        catch (NumberFormatException e) { return 0; }
    }

    private String config(String name) {
        String value = System.getenv(name);
        if (value == null || value.trim().isEmpty()) value = System.getProperty(name, "");
        return value == null ? "" : value.trim();
    }

    private String jsonEscape(String value) {
        return value == null ? "" : value.replace("\\", "\\\\").replace("\"", "\\\"")
                .replace("\r", " ").replace("\n", " ");
    }
}
