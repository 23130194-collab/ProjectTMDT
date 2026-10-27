package controller;

import dao.ChatDAO;
import dao.UserDao;
import dao.VnPayPaymentDAO;
import model.ChatConversation;
import model.Message;
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
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.Instant;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import java.util.UUID;

@WebServlet(urlPatterns = {"/vnpay-create", "/vnpay-return", "/vnpay-ipn"})
public class VnPayPaymentServlet extends HttpServlet {
    private static final String SANDBOX_URL = "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html";
    private static final ZoneId VIETNAM_ZONE = ZoneId.of("Asia/Ho_Chi_Minh");
    private static final DateTimeFormatter VNPAY_DATE = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");

    private final ChatDAO chatDAO = new ChatDAO();
    private final VnPayPaymentDAO paymentDAO = new VnPayPaymentDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        User buyer = getSessionUser(request);
        if (buyer == null) {
            response.sendRedirect("07-dang-nhap-xac-thuc.jsp");
            return;
        }

        String tmnCode = config("VNPAY_TMN_CODE");
        String hashSecret = config("VNPAY_HASH_SECRET");
        if (tmnCode.isEmpty() || hashSecret.isEmpty()) {
            showResult(request, response, false, "Chưa cấu hình VNPAY_TMN_CODE và VNPAY_HASH_SECRET cho môi trường Sandbox.");
            return;
        }

        if ("BALANCE".equalsIgnoreCase(request.getParameter("paymentType"))) {
            startBalancePayment(request, response, buyer, tmnCode, hashSecret);
            return;
        }

        int conversationId = parseInt(request.getParameter("conversationId"));
        ChatConversation conversation = conversationId > 0 ? chatDAO.getConversation(conversationId, buyer.getId()) : null;
        if (conversation == null || conversation.getBuyerId() != buyer.getId()) {
            showResult(request, response, false, "Không tìm thấy hội thoại đặt cọc hợp lệ.");
            return;
        }

        // Bắt buộc phải có địa chỉ nhận hàng nếu đơn hàng giao qua GHN (deliveryMethod == 2)
        if (conversation.getDeliveryMethod() == 2) {
            try {
                User freshBuyer = new UserDao().getUserById(buyer.getId());
                if (freshBuyer != null) {
                    buyer = freshBuyer;
                    request.getSession().setAttribute("user", freshBuyer);
                }
            } catch (Exception ignored) {
            }
            boolean hasAddress = buyer.getProvince() != null && !buyer.getProvince().trim().isEmpty()
                    && buyer.getWard() != null && !buyer.getWard().trim().isEmpty()
                    && buyer.getAddressDetail() != null && !buyer.getAddressDetail().trim().isEmpty()
                    && buyer.getPhone() != null && !buyer.getPhone().trim().isEmpty();
            if (!hasAddress) {
                showResult(request, response, false,
                        "Đơn hàng giao qua Giao Hàng Nhanh (GHN) bắt buộc phải có địa chỉ nhận hàng và số điện thoại. Vui lòng cập nhật thông tin trong Hồ sơ cá nhân trước khi thanh toán đặt cọc.");
                return;
            }
        }

        OfferTerms terms = resolveOfferTerms(conversation, buyer.getId());
        if (!terms.valid) {
            showResult(request, response, false, terms.message);
            return;
        }

        double depositAmount = calculateDeposit(terms.agreedPrice);
        if (depositAmount <= 0) {
            showResult(request, response, false, "Sản phẩm này không có số tiền đặt cọc hợp lệ.");
            return;
        }

        String paymentType = "FULL".equalsIgnoreCase(request.getParameter("paymentType")) ? "FULL" : "DEPOSIT";
        double chargeAmount = "FULL".equals(paymentType) ? terms.agreedPrice : depositAmount;
        String txnRef = "MN" + System.currentTimeMillis() + UUID.randomUUID().toString().replace("-", "").substring(0, 8);
        Timestamp expiresAt = new Timestamp(terms.expiresAt);
        try {
            paymentDAO.createPending(txnRef, conversation.getId(), buyer.getId(), conversation.getSellerId(),
                    conversation.getProductId(), terms.agreedPrice, depositAmount, expiresAt, paymentType);
        } catch (SQLException | IllegalStateException e) {
            getServletContext().log("Không lưu được giao dịch đặt cọc VNPay.", e);
            String message = e.getMessage() != null && (e.getMessage().startsWith("Hội thoại đã có giao dịch") ||
                    e.getMessage().startsWith("Sản phẩm đã hết"))
                    ? e.getMessage() : "Không thể tạo giao dịch đặt cọc. Vui lòng thử lại.";
            showResult(request, response, false, message);
            return;
        }

        Map<String, String> params = new TreeMap<>();
        ZonedDateTime now = ZonedDateTime.now(VIETNAM_ZONE);
        params.put("vnp_Version", "2.1.0");
        params.put("vnp_Command", "pay");
        params.put("vnp_TmnCode", tmnCode);
        params.put("vnp_Amount", String.valueOf(Math.round(chargeAmount * 100)));
        params.put("vnp_CurrCode", "VND");
        params.put("vnp_TxnRef", txnRef);
        params.put("vnp_OrderInfo", ("FULL".equals(paymentType) ? "Thanh toan toan bo san pham " : "Dat coc giu san pham ") + conversation.getProductId());
        params.put("vnp_OrderType", "other");
        params.put("vnp_Locale", "vn");
        params.put("vnp_ReturnUrl", returnUrl(request));
        params.put("vnp_IpAddr", clientIp(request));
        params.put("vnp_CreateDate", now.format(VNPAY_DATE));
        params.put("vnp_ExpireDate", Instant.ofEpochMilli(terms.expiresAt).atZone(VIETNAM_ZONE).format(VNPAY_DATE));

        String hashData = buildHashData(params);
        String paymentUrl = SANDBOX_URL + "?" + buildQuery(params) + "&vnp_SecureHash=" + hmacSha512(hashSecret, hashData);
        response.sendRedirect(paymentUrl);
    }

    private void startBalancePayment(HttpServletRequest request, HttpServletResponse response, User buyer,
                                     String tmnCode, String hashSecret) throws IOException, ServletException {
        int orderId = parseInt(request.getParameter("orderId"));
        model.OrderSummary order = new dao.OrderDAO().getOrderSummaryById(orderId);
        if (order == null || order.buyerId != buyer.getId()) {
            showResult(request, response, false, "Không tìm thấy đơn hàng cần thanh toán."); return;
        }
        double remaining = order.agreedPrice - order.depositAmount;
        if (remaining <= 0) { showResult(request, response, false, "Đơn hàng không còn khoản tiền cần thanh toán."); return; }
        long gatewayExpiry = Math.min(order.balanceExpiresAt == null ? 0 : order.balanceExpiresAt.getTime(), System.currentTimeMillis() + 15 * 60 * 1000L);
        if (gatewayExpiry <= System.currentTimeMillis()) { showResult(request, response, false, "Đã hết 24 giờ thanh toán phần còn lại; đơn hàng sẽ được hủy."); return; }
        String txnRef = "MN" + System.currentTimeMillis() + UUID.randomUUID().toString().replace("-", "").substring(0, 8);
        try {
            paymentDAO.createPendingBalance(txnRef, order.id, buyer.getId(), new Timestamp(gatewayExpiry));
        } catch (SQLException | IllegalStateException e) {
            showResult(request, response, false, e.getMessage() == null ? "Không thể tạo giao dịch thanh toán." : e.getMessage()); return;
        }
        Map<String, String> params = new TreeMap<>();
        ZonedDateTime now = ZonedDateTime.now(VIETNAM_ZONE);
        params.put("vnp_Version", "2.1.0"); params.put("vnp_Command", "pay"); params.put("vnp_TmnCode", tmnCode);
        params.put("vnp_Amount", String.valueOf(Math.round(remaining * 100))); params.put("vnp_CurrCode", "VND");
        params.put("vnp_TxnRef", txnRef); params.put("vnp_OrderInfo", "Thanh toan phan con lai don hang " + order.id);
        params.put("vnp_OrderType", "other"); params.put("vnp_Locale", "vn"); params.put("vnp_ReturnUrl", returnUrl(request));
        params.put("vnp_IpAddr", clientIp(request)); params.put("vnp_CreateDate", now.format(VNPAY_DATE));
        params.put("vnp_ExpireDate", Instant.ofEpochMilli(gatewayExpiry).atZone(VIETNAM_ZONE).format(VNPAY_DATE));
        response.sendRedirect(SANDBOX_URL + "?" + buildQuery(params) + "&vnp_SecureHash=" + hmacSha512(hashSecret, buildHashData(params)));
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        if ("BALANCE".equalsIgnoreCase(request.getParameter("paymentType")) && parseInt(request.getParameter("orderId")) > 0) {
            doPost(request, response);
            return;
        }
        String path = request.getServletPath();
        if ("/vnpay-ipn".equals(path)) {
            handleIpn(request, response);
            return;
        }
        handleReturn(request, response);
    }

    private void handleIpn(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");
        Map<String, String> params = getParameters(request);
        if (!validSignature(params) || !config("VNPAY_TMN_CODE").equals(params.get("vnp_TmnCode"))) {
            response.getWriter().write("{\"RspCode\":\"97\",\"Message\":\"Invalid signature\"}");
            return;
        }
        VnPayPaymentDAO.CallbackResult result = processCallback(params);
        String code;
        if (result.successful || "Thanh toán chưa thành công.".equals(result.message)) code = "00";
        else if (result.message.startsWith("Không tìm thấy")) code = "01";
        else if (result.message.startsWith("Số tiền")) code = "04";
        else code = "99";
        response.getWriter().write("{\"RspCode\":\"" + code + "\",\"Message\":\"" + jsonEscape(result.message) + "\"}");
    }

    private void handleReturn(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Map<String, String> params = getParameters(request);
        boolean verified = validSignature(params) && config("VNPAY_TMN_CODE").equals(params.get("vnp_TmnCode"));
        VnPayPaymentDAO.CallbackResult result = verified
                ? processCallback(params)
                : new VnPayPaymentDAO.CallbackResult(false, "Không xác minh được chữ ký trả về từ VNPay.");
        if (verified && result.successful && "DEPOSIT".equalsIgnoreCase(result.paymentType) && result.orderId > 0) {
            User sessionBuyer = getSessionUser(request);
            model.OrderSummary order = new dao.OrderDAO().getOrderSummaryById(result.orderId);
            if (sessionBuyer != null && order != null && order.buyerId == sessionBuyer.getId() && "PENDING".equalsIgnoreCase(order.balancePaymentMethod)) {
                request.setAttribute("balanceChoiceOrderId", result.orderId);
                request.setAttribute("paymentMessage", result.message);
                request.getRequestDispatcher("/payment-choice.jsp").forward(request, response);
                return;
            }
        }
        showResult(request, response, verified && result.successful, result.message);
    }

    private VnPayPaymentDAO.CallbackResult processCallback(Map<String, String> params) {
        String txnRef = params.get("vnp_TxnRef");
        long amount = parseLong(params.get("vnp_Amount"));
        if (txnRef == null || amount <= 0) {
            return new VnPayPaymentDAO.CallbackResult(false, "Dữ liệu giao dịch không hợp lệ.");
        }
        try {
            return paymentDAO.processCallback(txnRef, params.get("vnp_TransactionNo"),
                    params.get("vnp_ResponseCode"), params.get("vnp_TransactionStatus"), amount);
        } catch (SQLException | IllegalStateException e) {
            getServletContext().log("Lỗi xử lý kết quả giao dịch VNPay.", e);
            return new VnPayPaymentDAO.CallbackResult(false, "Không thể cập nhật kết quả thanh toán lúc này.");
        }
    }

    private OfferTerms resolveOfferTerms(ChatConversation conversation, int buyerId) {
        List<Message> messages = chatDAO.getMessages(conversation.getId(), buyerId);
        Message proposal = null;
        int proposalIndex = -1;
        for (int i = 0; i < messages.size(); i++) {
            if ("PROPOSAL".equalsIgnoreCase(messages.get(i).getMessageType())) {
                proposal = messages.get(i);
                proposalIndex = i;
            }
        }

        long now = System.currentTimeMillis();
        if (proposal == null) {
            return new OfferTerms(true, "", conversation.getProductPrice(), now + 15 * 60 * 1000L);
        }

        Message sellerResponse = null;
        for (int i = proposalIndex + 1; i < messages.size(); i++) {
            Message message = messages.get(i);
            if (message.getSenderId() == conversation.getSellerId() && !"PROPOSAL".equalsIgnoreCase(message.getMessageType())) {
                sellerResponse = message;
                break;
            }
        }
        if (sellerResponse == null) {
            return new OfferTerms(false, "Người bán chưa phản hồi mức giá. Hãy chờ người bán đồng ý trước khi đặt cọc.", 0, 0);
        }

        String answer = sellerResponse.getContent() == null ? "" : sellerResponse.getContent().toLowerCase(java.util.Locale.ROOT);
        if (answer.contains("không đồng ý") || answer.contains("không phù hợp") || answer.contains("chưa phù hợp") ||
                answer.contains("thương lượng thêm") || answer.contains("từ chối") || answer.contains("đề xuất lại")) {
            return new OfferTerms(false, "Người bán chưa đồng ý với mức giá. Vui lòng gửi đề xuất trả giá mới.", 0, 0);
        }
        if (!(answer.contains("đồng ý") || answer.contains("chốt") || answer.contains("ok") || answer.contains("okay"))) {
            return new OfferTerms(false, "Người bán chưa đồng ý mức giá đề xuất.", 0, 0);
        }

        return new OfferTerms(true, "", proposal.getProposedPrice(), now + 15 * 60 * 1000L);
    }

    private boolean validSignature(Map<String, String> params) {
        String supplied = params.get("vnp_SecureHash");
        String secret = config("VNPAY_HASH_SECRET");
        if (supplied == null || secret.isEmpty()) return false;
        Map<String, String> hashParams = new TreeMap<>(params);
        hashParams.remove("vnp_SecureHash");
        hashParams.remove("vnp_SecureHashType");
        String expected = hmacSha512(secret, buildHashData(hashParams));
        return MessageDigest.isEqual(expected.toLowerCase(java.util.Locale.ROOT).getBytes(StandardCharsets.US_ASCII),
                supplied.toLowerCase(java.util.Locale.ROOT).getBytes(StandardCharsets.US_ASCII));
    }

    private Map<String, String> getParameters(HttpServletRequest request) {
        Map<String, String> params = new TreeMap<>();
        for (Map.Entry<String, String[]> entry : request.getParameterMap().entrySet()) {
            String[] values = entry.getValue();
            if (values != null && values.length > 0) params.put(entry.getKey(), values[0]);
        }
        return params;
    }

    private String buildHashData(Map<String, String> params) {
        List<String> names = new ArrayList<>(params.keySet());
        Collections.sort(names);
        StringBuilder hashData = new StringBuilder();
        for (String name : names) {
            String value = params.get(name);
            if (value == null || value.isEmpty()) continue;
            if (hashData.length() > 0) hashData.append('&');
            // VNPay v2.1.0 Java sample hashes the plain parameter name and URL-encoded value.
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
            throw new IllegalStateException("Không tạo được chữ ký VNPay.", e);
        }
    }

    private String returnUrl(HttpServletRequest request) {
        String configured = config("VNPAY_RETURN_URL");
        if (!configured.isEmpty()) return configured;
        StringBuilder url = new StringBuilder(request.getScheme()).append("://").append(request.getServerName());
        int port = request.getServerPort();
        if (("http".equalsIgnoreCase(request.getScheme()) && port != 80) ||
                ("https".equalsIgnoreCase(request.getScheme()) && port != 443)) url.append(':').append(port);
        return url.append(request.getContextPath()).append("/vnpay-return").toString();
    }

    private String clientIp(HttpServletRequest request) {
        String ip = request.getRemoteAddr();
        return ip == null || ip.trim().isEmpty() ? "127.0.0.1" : ip;
    }

    private void showResult(HttpServletRequest request, HttpServletResponse response, boolean successful, String message)
            throws ServletException, IOException {
        request.setAttribute("paymentSuccessful", successful);
        request.setAttribute("paymentMessage", message);
        request.getRequestDispatcher("/vnpay-result.jsp").forward(request, response);
    }

    private User getSessionUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session != null && session.getAttribute("user") instanceof User ? (User) session.getAttribute("user") : null;
    }

    private int parseInt(String value) {
        try { return value == null ? 0 : Integer.parseInt(value.trim()); }
        catch (NumberFormatException e) { return 0; }
    }

    private double calculateDeposit(double price) {
        if (price <= 0) return 0;
        if (price > 100_000) return Math.round(price * 0.10);
        if (price >= 10_000 && price <= 50_000) return Math.round(price);
        return Math.round(price * 0.50);
    }

    private long parseLong(String value) {
        try { return value == null ? 0 : Long.parseLong(value.trim()); }
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

    private static class OfferTerms {
        final boolean valid;
        final String message;
        final double agreedPrice;
        final long expiresAt;

        OfferTerms(boolean valid, String message, double agreedPrice, long expiresAt) {
            this.valid = valid;
            this.message = message;
            this.agreedPrice = agreedPrice;
            this.expiresAt = expiresAt;
        }
    }
}
