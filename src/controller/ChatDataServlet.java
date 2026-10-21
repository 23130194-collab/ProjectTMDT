package controller;

import dao.ChatDAO;
import model.ChatConversation;
import model.Message;
import model.User;

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
import java.sql.Timestamp;
import java.text.NumberFormat;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Locale;
import java.util.UUID;

@WebServlet(name = "ChatDataServlet", value = "/chat-data")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 5 * 1024 * 1024,
        maxRequestSize = 6 * 1024 * 1024
)
public class ChatDataServlet extends HttpServlet {
    private final ChatDAO chatDAO = new ChatDAO();
    private final NumberFormat moneyFormat = NumberFormat.getInstance(new Locale("vi", "VN"));
    private final ZoneId vietnamZone = ZoneId.of("Asia/Ho_Chi_Minh");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        User currentUser = resolveCurrentUser(request);
        if (currentUser == null) {
            response.getWriter().write("{\"success\":false,\"message\":\"Chưa có dữ liệu người dùng để mở chat.\"}");
            return;
        }

        String role = normalizeRole(request.getParameter("role"));
        int selectedId = parseInt(request.getParameter("conversationId"), 0);
        int productId = parseInt(request.getParameter("productId"), 0);
        if (selectedId <= 0 && productId > 0) {
            selectedId = chatDAO.findOrCreateConversationForProduct(productId, currentUser.getId());
            if (selectedId > 0) {
                role = "buyer";
            }
        }

        List<ChatConversation> buyerConversations = chatDAO.getConversations(currentUser.getId(), "buyer");
        List<ChatConversation> sellerConversations = chatDAO.getConversations(currentUser.getId(), "seller");

        if (selectedId <= 0) {
            List<ChatConversation> selectedList = "seller".equals(role) ? sellerConversations : buyerConversations;
            if (selectedList.isEmpty() && "seller".equals(role)) {
                role = "buyer";
                selectedList = buyerConversations;
            }
            if (selectedList.isEmpty() && "buyer".equals(role)) {
                role = "seller";
                selectedList = sellerConversations;
            }
            if (!selectedList.isEmpty()) {
                selectedId = selectedList.get(0).getId();
            }
        }

        ChatConversation selected = selectedId > 0 ? chatDAO.getConversation(selectedId, currentUser.getId()) : null;
        List<Message> messages = selected != null ? chatDAO.getMessages(selected.getId(), currentUser.getId()) : java.util.Collections.emptyList();

        StringBuilder json = new StringBuilder();
        json.append("{\"success\":true");
        json.append(",\"currentUser\":").append(userJson(currentUser));
        json.append(",\"activeRole\":\"").append(escapeJson(role)).append("\"");
        json.append(",\"selectedConversationId\":").append(selected != null ? selected.getId() : 0);
        json.append(",\"buyerConversations\":").append(conversationsJson(buyerConversations));
        json.append(",\"sellerConversations\":").append(conversationsJson(sellerConversations));
        json.append(",\"selectedConversation\":").append(selected != null ? conversationJson(selected) : "null");
        json.append(",\"messages\":").append(messagesJson(messages, currentUser.getId()));
        json.append("}");
        response.getWriter().write(json.toString());
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        User currentUser = resolveCurrentUser(request);
        if (currentUser == null) {
            response.getWriter().write("{\"success\":false,\"message\":\"Bạn cần đăng nhập để gửi tin nhắn.\"}");
            return;
        }

        int conversationId = parseInt(request.getParameter("conversationId"), 0);
        String type = request.getParameter("messageType");
        String content = request.getParameter("content");
        double proposedPrice = parseDouble(request.getParameter("proposedPrice"), 0);

        if ("IMAGE".equalsIgnoreCase(type)) {
            content = saveChatImage(request);
            type = "TEXT";
        }

        if (conversationId <= 0 || content == null || content.trim().isEmpty()) {
            response.getWriter().write("{\"success\":false,\"message\":\"Thiếu nội dung hoặc hội thoại.\"}");
            return;
        }

        if ("PROPOSAL".equalsIgnoreCase(type)) {
            if (!chatDAO.isProductActiveForConversation(conversationId)) {
                response.getWriter().write("{\"success\":false,\"message\":\"Sản phẩm đã hết, không thể tiếp tục trả giá.\"}");
                return;
            }
            if (!chatDAO.canSendOffer(conversationId)) {
                response.getWriter().write("{\"success\":false,\"message\":\"Tin tặng miễn phí không hỗ trợ đề xuất trả giá.\"}");
                return;
            }
        }

        Message saved = chatDAO.addMessage(conversationId, currentUser.getId(), content.trim(), type, proposedPrice);
        if (saved == null) {
            response.getWriter().write("{\"success\":false,\"message\":\"Không thể lưu tin nhắn.\"}");
            return;
        }

        response.getWriter().write("{\"success\":true,\"message\":" + messageJson(saved, currentUser.getId()) + "}");
    }

    private String saveChatImage(HttpServletRequest request) throws IOException, ServletException {
        Part imagePart = request.getPart("imageFile");
        if (imagePart == null || imagePart.getSize() <= 0) {
            return null;
        }

        String submittedName = imagePart.getSubmittedFileName();
        String extension = getSafeImageExtension(submittedName, imagePart.getContentType());
        if (extension == null) {
            throw new ServletException("Chỉ hỗ trợ file ảnh JPG, PNG, GIF hoặc WEBP.");
        }

        String uploadRelativeDir = "assets/uploads/chat";
        String realUploadDir = getServletContext().getRealPath("/" + uploadRelativeDir);
        if (realUploadDir == null) {
            throw new ServletException("Không xác định được thư mục upload ảnh chat.");
        }

        File uploadDir = new File(realUploadDir);
        if (!uploadDir.exists() && !uploadDir.mkdirs()) {
            throw new ServletException("Không thể tạo thư mục upload ảnh chat.");
        }

        String fileName = "chat-" + System.currentTimeMillis() + "-" + UUID.randomUUID() + extension;
        File target = new File(uploadDir, fileName);
        imagePart.write(target.getAbsolutePath());
        return "IMAGE::" + uploadRelativeDir + "/" + fileName;
    }

    private String getSafeImageExtension(String fileName, String contentType) {
        String lowerName = fileName == null ? "" : fileName.toLowerCase(Locale.ROOT);
        String lowerType = contentType == null ? "" : contentType.toLowerCase(Locale.ROOT);
        if (lowerName.endsWith(".jpg") || lowerName.endsWith(".jpeg") || "image/jpeg".equals(lowerType)) {
            return ".jpg";
        }
        if (lowerName.endsWith(".png") || "image/png".equals(lowerType)) {
            return ".png";
        }
        if (lowerName.endsWith(".gif") || "image/gif".equals(lowerType)) {
            return ".gif";
        }
        if (lowerName.endsWith(".webp") || "image/webp".equals(lowerType)) {
            return ".webp";
        }
        return null;
    }

    private User resolveCurrentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("user") instanceof User) {
            return (User) session.getAttribute("user");
        }
        return null;
    }

    private String conversationsJson(List<ChatConversation> conversations) {
        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < conversations.size(); i++) {
            if (i > 0) {
                json.append(",");
            }
            json.append(conversationJson(conversations.get(i)));
        }
        json.append("]");
        return json.toString();
    }

    private String conversationJson(ChatConversation item) {
        StringBuilder json = new StringBuilder();
        double dealPrice = item.getLastProposedPrice() > 0 ? item.getLastProposedPrice() : item.getProductPrice();
        double deposit = calculateDeposit(dealPrice);
        json.append("{");
        appendField(json, "id", item.getId()).append(",");
        appendField(json, "productId", item.getProductId()).append(",");
        appendField(json, "buyerId", item.getBuyerId()).append(",");
        appendField(json, "sellerId", item.getSellerId()).append(",");
        appendField(json, "partnerId", item.getPartnerId()).append(",");
        appendField(json, "partnerName", item.getPartnerName()).append(",");
        appendField(json, "partnerRoleLabel", item.getPartnerRoleLabel()).append(",");
        appendField(json, "partnerLocation", item.getPartnerLocation()).append(",");
        appendField(json, "partnerInitials", initials(item.getPartnerName())).append(",");
        appendField(json, "targetName", safe(item.getPartnerName()) + " (" + safe(item.getPartnerRoleLabel()) + ")").append(",");
        appendField(json, "targetStatus", "Đang trực tuyến • " + safe(item.getPartnerLocation())).append(",");
        appendField(json, "productTitle", item.getProductTitle()).append(",");
        appendField(json, "productPrice", item.getProductPrice()).append(",");
        appendField(json, "deliveryMethod", item.getDeliveryMethod()).append(",");
        appendField(json, "productPriceText", formatMoney(item.getProductPrice())).append(",");
        appendField(json, "dealPrice", dealPrice).append(",");
        appendField(json, "dealPriceText", formatMoney(dealPrice)).append(",");
        appendField(json, "depositAmount", deposit).append(",");
        appendField(json, "depositText", formatMoney(deposit)).append(",");
        appendField(json, "cashRemainText", formatMoney(Math.max(0, dealPrice - deposit))).append(",");
        appendField(json, "productImage", safeImage(item.getProductImage())).append(",");
        appendField(json, "productStatus", item.getProductStatus()).append(",");
        appendField(json, "lastMessage", item.getLastMessage() == null ? "Bắt đầu trao đổi với đối tác" : item.getLastMessage()).append(",");
        appendField(json, "lastMessageType", item.getLastMessageType()).append(",");
        appendField(json, "lastProposedPrice", item.getLastProposedPrice()).append(",");
        appendField(json, "lastProposedPriceText", item.getLastProposedPrice() > 0 ? formatMoney(item.getLastProposedPrice()) : "").append(",");
        appendField(json, "lastTimeText", formatShortTime(item.getLastMessageAt()));
        json.append("}");
        return json.toString();
    }

    private String messagesJson(List<Message> messages, int currentUserId) {
        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < messages.size(); i++) {
            if (i > 0) {
                json.append(",");
            }
            json.append(messageJson(messages.get(i), currentUserId));
        }
        json.append("]");
        return json.toString();
    }

    private String messageJson(Message message, int currentUserId) {
        StringBuilder json = new StringBuilder();
        json.append("{");
        appendField(json, "id", message.getId()).append(",");
        appendField(json, "conversationId", message.getConversationId()).append(",");
        appendField(json, "senderId", message.getSenderId()).append(",");
        appendField(json, "mine", message.getSenderId() == currentUserId).append(",");
        appendField(json, "content", message.getContent()).append(",");
        appendField(json, "messageType", message.getMessageType()).append(",");
        appendField(json, "proposedPrice", message.getProposedPrice()).append(",");
        appendField(json, "proposedPriceText", message.getProposedPrice() > 0 ? formatMoney(message.getProposedPrice()) : "").append(",");
        appendField(json, "createdAtMs", message.getCreatedAt() == null ? 0L : message.getCreatedAt().getTime()).append(",");
        appendField(json, "timeText", formatShortTime(message.getCreatedAt()));
        json.append("}");
        return json.toString();
    }

    private String userJson(User user) {
        StringBuilder json = new StringBuilder();
        json.append("{");
        appendField(json, "id", user.getId()).append(",");
        appendField(json, "fullName", user.getFullName()).append(",");
        appendField(json, "initials", initials(user.getFullName()));
        json.append("}");
        return json.toString();
    }

    private StringBuilder appendField(StringBuilder json, String key, String value) {
        json.append("\"").append(escapeJson(key)).append("\":\"").append(escapeJson(value)).append("\"");
        return json;
    }

    private StringBuilder appendField(StringBuilder json, String key, int value) {
        json.append("\"").append(escapeJson(key)).append("\":").append(value);
        return json;
    }

    private StringBuilder appendField(StringBuilder json, String key, long value) {
        json.append("\"").append(escapeJson(key)).append("\":").append(value);
        return json;
    }

    private StringBuilder appendField(StringBuilder json, String key, double value) {
        json.append("\"").append(escapeJson(key)).append("\":").append(Double.isNaN(value) ? "0" : String.valueOf(value));
        return json;
    }

    private StringBuilder appendField(StringBuilder json, String key, boolean value) {
        json.append("\"").append(escapeJson(key)).append("\":").append(value);
        return json;
    }

    private double calculateDeposit(double price) {
        if (price <= 0) {
            return 0;
        }
        if (price > 100_000) {
            return Math.round(price * 0.10);
        }
        if (price >= 10_000 && price <= 50_000) {
            return Math.round(price);
        }
        return Math.round(price * 0.50);
    }

    private String formatMoney(double amount) {
        return moneyFormat.format(Math.round(amount)) + " đ";
    }

    private String formatShortTime(Timestamp timestamp) {
        if (timestamp == null) {
            return "";
        }
        LocalDate date = timestamp.toInstant().atZone(vietnamZone).toLocalDate();
        LocalDate today = LocalDate.now(vietnamZone);
        if (date.equals(today)) {
            return timestamp.toInstant().atZone(vietnamZone).format(DateTimeFormatter.ofPattern("HH:mm"));
        }
        if (date.equals(today.minusDays(1))) {
            return "Hôm qua";
        }
        return timestamp.toInstant().atZone(vietnamZone).format(DateTimeFormatter.ofPattern("dd/MM"));
    }

    private String initials(String name) {
        if (name == null || name.trim().isEmpty()) {
            return "MN";
        }
        String[] parts = name.trim().split("\\s+");
        String first = parts[0].substring(0, 1);
        String last = parts.length > 1 ? parts[parts.length - 1].substring(0, 1) : "";
        return (first + last).toUpperCase(new Locale("vi", "VN"));
    }

    private String normalizeRole(String role) {
        return "seller".equalsIgnoreCase(role) ? "seller" : "buyer";
    }

    private String safe(String value) {
        return value == null || value.trim().isEmpty() ? "Đang cập nhật" : value.trim();
    }

    private String safeImage(String image) {
        return image == null || image.trim().isEmpty() ? "assets/images/products/iphone-13-pro-max.jpg" : image.trim();
    }

    private int parseInt(String value, int fallback) {
        try {
            return value == null ? fallback : Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            return fallback;
        }
    }

    private double parseDouble(String value, double fallback) {
        try {
            return value == null ? fallback : Double.parseDouble(value.trim());
        } catch (NumberFormatException e) {
            return fallback;
        }
    }

    private String escapeJson(String value) {
        if (value == null) {
            return "";
        }
        return value.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "");
    }
}
