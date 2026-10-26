package service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;

/**
 * Service kết nối trực tiếp đến GHN Sandbox API (https://5sao.ghn.dev)
 * Hỗ trợ tạo đơn vận chuyển test và đồng bộ trạng thái đơn hàng theo thời gian thực.
 */
public class GhnApiService {

    // Base URL Sandbox mới nhất của GHN (5sao.ghn.dev)
    private static final String GHN_BASE_URL = "https://dev-online-gateway.ghn.vn/shiip/public-api/v2";

    private static String cachedToken = "";
    private static String cachedShopId = "";

    static {
        loadConfig();
    }

    private static void loadConfig() {
        // 1. Đọc từ classpath (src/ghn.properties khi build vào WEB-INF/classes)
        try (InputStream in = GhnApiService.class.getClassLoader().getResourceAsStream("ghn.properties")) {
            if (in != null) {
                Properties props = new Properties();
                props.load(in);
                if (props.getProperty("ghn.sandbox.token") != null) {
                    cachedToken = props.getProperty("ghn.sandbox.token").trim();
                }
                if (props.getProperty("ghn.sandbox.shop_id") != null) {
                    cachedShopId = props.getProperty("ghn.sandbox.shop_id").trim();
                }
            }
        } catch (Exception ignored) {
        }

        // 2. Thử đọc trực tiếp file src/ghn.properties nếu chạy từ working directory
        if (cachedToken.isEmpty() || cachedShopId.isEmpty()) {
            File f = new File("src/ghn.properties");
            if (f.exists()) {
                try (FileInputStream fis = new FileInputStream(f)) {
                    Properties props = new Properties();
                    props.load(fis);
                    if (cachedToken.isEmpty() && props.getProperty("ghn.sandbox.token") != null) {
                        cachedToken = props.getProperty("ghn.sandbox.token").trim();
                    }
                    if (cachedShopId.isEmpty() && props.getProperty("ghn.sandbox.shop_id") != null) {
                        cachedShopId = props.getProperty("ghn.sandbox.shop_id").trim();
                    }
                } catch (Exception ignored) {
                }
            }
        }

        // 3. Fallback đọc từ biến môi trường (Environment Variables) hoặc System Property
        if (cachedToken.isEmpty()) {
            String env = System.getenv("GHN_SANDBOX_TOKEN");
            if (env != null && !env.trim().isEmpty()) {
                cachedToken = env.trim();
            } else {
                String prop = System.getProperty("ghn.sandbox.token");
                if (prop != null && !prop.trim().isEmpty()) {
                    cachedToken = prop.trim();
                }
            }
        }

        if (cachedShopId.isEmpty()) {
            String env = System.getenv("GHN_SANDBOX_SHOP_ID");
            if (env != null && !env.trim().isEmpty()) {
                cachedShopId = env.trim();
            } else {
                String prop = System.getProperty("ghn.sandbox.shop_id");
                if (prop != null && !prop.trim().isEmpty()) {
                    cachedShopId = prop.trim();
                }
            }
        }
    }

    private final HttpClient httpClient;
    private final ObjectMapper objectMapper;

    public GhnApiService() {
        this.httpClient = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(15))
                .build();
        this.objectMapper = new ObjectMapper();
    }

    public String getToken() {
        if (cachedToken == null || cachedToken.trim().isEmpty()) {
            loadConfig();
        }
        return cachedToken != null ? cachedToken.trim() : "";
    }

    public String getShopId() {
        if (cachedShopId == null || cachedShopId.trim().isEmpty()) {
            loadConfig();
        }
        return cachedShopId != null ? cachedShopId.trim() : "";
    }

    public boolean isConfigured() {
        String token = getToken();
        return token != null && !token.isEmpty() && !token.contains("YOUR_GHN_SANDBOX_TOKEN") && !token.equalsIgnoreCase("PASTE_YOUR_TOKEN_HERE");
    }

    /**
     * Tạo vận đơn trên GHN Sandbox
     * @return Mã vận đơn (order_code) do GHN cấp
     */
    public String createOrder(String fromName, String fromPhone, String fromAddress,
                              String toName, String toPhone, String toAddress,
                              String productTitle, double codAmount, String note) throws Exception {
        if (!isConfigured()) {
            throw new IllegalStateException("Chưa cấu hình GHN API Token. Vui lòng kiểm tra GhnApiService.");
        }

        String url = GHN_BASE_URL + "/shipping-order/create";

        String senderName = (fromName != null && !fromName.trim().isEmpty()) ? fromName.trim() : "Shop MuaNgay";
        String senderPhone = sanitizePhone(fromPhone);
        String senderAddress = (fromAddress != null && !fromAddress.trim().isEmpty()) ? fromAddress.trim() : "102 Trần Lộc, Hà Nội";

        // Chuẩn hóa số điện thoại người nhận (yêu cầu 10 chữ số)
        String phone = sanitizePhone(toPhone);
        String receiverName = (toName != null && !toName.trim().isEmpty()) ? toName.trim() : "Khách Mua MuaNgay";
        String fullAddress = (toAddress != null && !toAddress.trim().isEmpty()) ? toAddress.trim() : "123 Đường Nguyễn Huệ, Phường Bến Nghé, Quận 1, TP. Hồ Chí Minh";
        String shippingNote = (note != null && !note.trim().isEmpty()) ? note.trim() : "Cho xem hàng, không cho thử";

        Map<String, Object> payload = new HashMap<>();
        payload.put("payment_type_id", 2); // 2: Người nhận thanh toán phí vận chuyển
        payload.put("note", shippingNote);
        payload.put("required_note", "CHOXEMHANGKHONGTHU");

        // Địa chỉ gửi (Kho Người Bán) - bắt buộc có from_district_id/from_ward_code để không bị FROM_ADDRESS_CONVERT_FAIL
        payload.put("from_name", senderName);
        payload.put("from_phone", senderPhone);
        payload.put("from_address", senderAddress);
        payload.put("from_district_id", 1442);
        payload.put("from_ward_code", "20101");

        // Địa chỉ nhận (Người Mua)
        payload.put("to_name", receiverName);
        payload.put("to_phone", phone);
        payload.put("to_address", fullAddress);
        payload.put("to_district_id", 1442);
        payload.put("to_ward_code", "20101");

        payload.put("cod_amount", (int) Math.max(0, Math.round(codAmount)));
        payload.put("content", (productTitle != null && !productTitle.trim().isEmpty()) ? productTitle.trim() : "Giao dịch MuaNgay");
        payload.put("weight", 250); // gram
        payload.put("length", 15);  // cm
        payload.put("width", 15);
        payload.put("height", 10);
        payload.put("service_type_id", 2); // Dịch vụ chuyển phát chuẩn

        List<Map<String, Object>> items = new ArrayList<>();
        Map<String, Object> item = new HashMap<>();
        item.put("name", (productTitle != null && !productTitle.trim().isEmpty()) ? productTitle.trim() : "Sản phẩm MuaNgay");
        item.put("quantity", 1);
        item.put("price", (int) Math.max(0, Math.round(codAmount)));
        items.add(item);
        payload.put("items", items);

        String jsonPayload = objectMapper.writeValueAsString(payload);

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .header("Content-Type", "application/json")
                .header("Token", getToken())
                .header("ShopId", getShopId())
                .POST(HttpRequest.BodyPublishers.ofString(jsonPayload))
                .build();

        HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
        JsonNode root = objectMapper.readTree(response.body());

        int code = root.path("code").asInt();
        if (code == 200) {
            JsonNode data = root.path("data");
            return data.path("order_code").asText();
        } else {
            String errorMsg = root.path("code_message_value").asText();
            if (errorMsg == null || errorMsg.trim().isEmpty()) {
                errorMsg = root.path("message_display").asText();
            }
            if (errorMsg == null || errorMsg.trim().isEmpty()) {
                errorMsg = root.path("message").asText();
            }
            throw new RuntimeException("GHN Sandbox Error (" + code + "): " + errorMsg);
        }
    }

    public String createOrder(String toName, String toPhone, String toAddress,
                              String productTitle, double codAmount, String note) throws Exception {
        return createOrder("Shop MuaNgay", "0337710175", "102 Trần Lộc, Hà Nội",
                toName, toPhone, toAddress, productTitle, codAmount, note);
    }

    /**
     * Tra cứu trạng thái đơn hàng từ GHN Sandbox
     * @return Mã trạng thái nội bộ: 'CHO_LAY_HANG', 'DANG_GIAO', 'DA_GIAO', 'CANCELLED'
     */
    public GhnDetailResult queryOrderShippingStatus(String orderCode) throws Exception {
        if (!isConfigured()) {
            throw new IllegalStateException("Chưa cấu hình GHN API Token.");
        }
        if (orderCode == null || orderCode.trim().isEmpty()) {
            throw new IllegalArgumentException("Mã vận đơn không hợp lệ.");
        }

        String url = GHN_BASE_URL + "/shipping-order/detail";
        Map<String, String> payload = Map.of("order_code", orderCode.trim());
        String jsonPayload = objectMapper.writeValueAsString(payload);

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .header("Content-Type", "application/json")
                .header("Token", getToken())
                .POST(HttpRequest.BodyPublishers.ofString(jsonPayload))
                .build();

        HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
        JsonNode root = objectMapper.readTree(response.body());

        int code = root.path("code").asInt();
        if (code == 200) {
            JsonNode data = root.path("data");
            String rawStatus = data.path("status").asText();
            String mappedStatus = mapGhnStatusToInternal(rawStatus);
            String statusName = getStatusDescription(mappedStatus, rawStatus);

            String cancelReason = null;
            if ("CANCELLED".equalsIgnoreCase(mappedStatus)) {
                // Kiểm tra trong mảng log của GHN trước (nơi GHN lưu lý do hủy thật sự khi người bán chọn trên 5sao.ghn.dev)
                if (data.has("log") && data.path("log").isArray()) {
                    JsonNode logArr = data.path("log");
                    for (int i = logArr.size() - 1; i >= 0; i--) {
                        JsonNode logItem = logArr.get(i);
                        if ("cancel".equalsIgnoreCase(logItem.path("status").asText()) &&
                                logItem.hasNonNull("reason") && !logItem.path("reason").asText().trim().isEmpty()) {
                            cancelReason = logItem.path("reason").asText().trim();
                            break;
                        }
                    }
                }

                if (cancelReason == null || cancelReason.trim().isEmpty()) {
                    if (data.hasNonNull("cancel_reason") && !data.path("cancel_reason").asText().trim().isEmpty()) {
                        cancelReason = data.path("cancel_reason").asText().trim();
                    } else if (data.hasNonNull("reason") && !data.path("reason").asText().trim().isEmpty()) {
                        cancelReason = data.path("reason").asText().trim();
                    } else {
                        cancelReason = "Người bán đã thao tác hủy vận đơn trên cổng GHN Express.";
                    }
                }
            }
            return new GhnDetailResult(true, mappedStatus, rawStatus, statusName, cancelReason, null);
        } else {
            String errorMsg = root.path("message_display").asText();
            if (errorMsg == null || errorMsg.trim().isEmpty()) {
                errorMsg = root.path("message").asText();
            }
            return new GhnDetailResult(false, null, null, null, null, errorMsg);
        }
    }

    /**
     * Ánh xạ trạng thái GHN sang trạng thái chuẩn của hệ thống:
     * CHO_LAY_HANG, DANG_GIAO, DA_GIAO, CANCELLED
     */
    public String mapGhnStatusToInternal(String ghnStatus) {
        if (ghnStatus == null) return "CHO_LAY_HANG";
        switch (ghnStatus.toLowerCase().trim()) {
            case "ready_to_pick":
            case "picking":
            case "storing":
                return "CHO_LAY_HANG";
            case "transporting":
            case "sorting":
            case "delivering":
            case "money_collect_delivering":
                return "DANG_GIAO";
            case "delivered":
                return "DA_GIAO";
            case "cancel":
            case "returned":
            case "damage":
            case "lost":
                return "CANCELLED";
            default:
                return "DANG_GIAO";
        }
    }

    public String getStatusDescription(String internalStatus, String rawGhnStatus) {
        if ("CHO_LAY_HANG".equalsIgnoreCase(internalStatus)) {
            return "Chờ bưu tá GHN đến lấy hàng (Mã GHN: " + rawGhnStatus + ")";
        } else if ("DANG_GIAO".equalsIgnoreCase(internalStatus)) {
            return "Bưu tá GHN đang đi giao đến người mua (Mã GHN: " + rawGhnStatus + ")";
        } else if ("DA_GIAO".equalsIgnoreCase(internalStatus)) {
            return "Bưu tá GHN đã giao hàng thành công (Mã GHN: " + rawGhnStatus + ")";
        } else if ("CANCELLED".equalsIgnoreCase(internalStatus)) {
            return "Đơn vận chuyển đã hủy/hoàn trả (Mã GHN: " + rawGhnStatus + ")";
        }
        return "Đang xử lý vận chuyển (" + rawGhnStatus + ")";
    }

    private String sanitizePhone(String phone) {
        if (phone == null) return "0987654321";
        String clean = phone.replaceAll("[^0-9]", "");
        if (clean.length() == 10 && clean.startsWith("0")) {
            return clean;
        }
        return "0987654321";
    }

    public static class GhnDetailResult {
        public final boolean success;
        public final String internalStatus;
        public final String rawGhnStatus;
        public final String statusDescription;
        public final String cancelReason;
        public final String errorMessage;

        public GhnDetailResult(boolean success, String internalStatus, String rawGhnStatus, String statusDescription, String cancelReason, String errorMessage) {
            this.success = success;
            this.internalStatus = internalStatus;
            this.rawGhnStatus = rawGhnStatus;
            this.statusDescription = statusDescription;
            this.cancelReason = cancelReason;
            this.errorMessage = errorMessage;
        }
    }
}
