package dao;

import model.ChatConversation;
import model.Message;
import model.User;
import util.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class ChatDAO {

    public User getFallbackUser() {
        String sql = "SELECT * FROM users WHERE role = 'USER' ORDER BY id LIMIT 1";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return mapUser(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public void ensureStarterConversations(int currentUserId) {
        if (countConversationsForUser(currentUserId) > 0) {
            return;
        }

        try (Connection conn = DBContext.getConnection()) {
            createBuyerStarterConversation(conn, currentUserId);
            createSellerStarterConversation(conn, currentUserId);
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public int countConversationsForUser(int userId) {
        String sql = "SELECT COUNT(*) FROM conversations WHERE buyer_id = ? OR seller_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int countUnreadMessages(int userId) {
        String sql = "SELECT COUNT(*) FROM messages m JOIN conversations c ON c.id = m.conversation_id " +
                "WHERE (c.buyer_id = ? OR c.seller_id = ?) AND m.sender_id <> ? " +
                "AND m.read_at IS NULL AND m.message_type IN ('TEXT', 'PROPOSAL')";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, userId);
            ps.setInt(3, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    public void markConversationMessagesRead(int conversationId, int userId) {
        String sql = "UPDATE messages m JOIN conversations c ON c.id = m.conversation_id " +
                "SET m.read_at = CURRENT_TIMESTAMP WHERE m.conversation_id = ? " +
                "AND (c.buyer_id = ? OR c.seller_id = ?) AND m.sender_id <> ? " +
                "AND m.message_type IN ('TEXT', 'PROPOSAL') AND m.read_at IS NULL";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, conversationId);
            ps.setInt(2, userId);
            ps.setInt(3, userId);
            ps.setInt(4, userId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public int getProductOwnerId(int productId) {
        String sql = "SELECT user_id FROM products WHERE id = ? LIMIT 1";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt("user_id") : 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    public int findLatestSellerConversationForProduct(int productId, int sellerId) {
        String sql = "SELECT c.id FROM conversations c " +
                "LEFT JOIN messages lm ON lm.id = (SELECT m.id FROM messages m WHERE m.conversation_id = c.id ORDER BY m.created_at DESC, m.id DESC LIMIT 1) " +
                "WHERE c.product_id = ? AND c.seller_id = ? " +
                "ORDER BY COALESCE(lm.created_at, c.created_at) DESC, c.id DESC LIMIT 1";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            ps.setInt(2, sellerId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt("id") : 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    public int findOrCreateConversationForProduct(int productId, int buyerId) {
        String productSql = "SELECT p.user_id, p.status, NOT EXISTS (SELECT 1 FROM orders o WHERE o.product_id = p.id " +
                "AND o.status IN ('DEPOSITED', 'SHIPPING', 'COMPLETED')) AS is_available FROM products p WHERE p.id = ? LIMIT 1";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement productPs = conn.prepareStatement(productSql)) {
            productPs.setInt(1, productId);
            try (ResultSet rs = productPs.executeQuery()) {
                if (!rs.next()) {
                    return 0;
                }
                int sellerId = rs.getInt("user_id");
                if (sellerId == buyerId) {
                    return 0;
                }
                String productStatus = rs.getString("status");
                if ("DELETE".equalsIgnoreCase(productStatus) || "SOLD".equalsIgnoreCase(productStatus) || !rs.getBoolean("is_available")) {
                    String existingSql = "SELECT id FROM conversations WHERE product_id = ? AND buyer_id = ? AND seller_id = ? LIMIT 1";
                    try (PreparedStatement existing = conn.prepareStatement(existingSql)) {
                        existing.setInt(1, productId);
                        existing.setInt(2, buyerId);
                        existing.setInt(3, sellerId);
                        try (ResultSet existingRs = existing.executeQuery()) {
                            return existingRs.next() ? existingRs.getInt("id") : 0;
                        }
                    }
                }
                return findOrCreateConversation(conn, productId, buyerId, sellerId);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    /** Opens the conversation belonging to the active/completed order for either participant. */
    public int findOrCreateConversationForProductOrder(int productId, int userId) {
        String sql = "SELECT buyer_id, seller_id FROM orders WHERE product_id = ? " +
                "AND status IN ('DEPOSITED', 'SHIPPING', 'COMPLETED') " +
                "AND (buyer_id = ? OR seller_id = ?) ORDER BY created_at DESC, id DESC LIMIT 1";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            ps.setInt(2, userId);
            ps.setInt(3, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return 0;
                int buyerId = rs.getInt("buyer_id");
                int sellerId = rs.getInt("seller_id");
                if (buyerId == userId || sellerId == userId) {
                    return findOrCreateConversation(conn, productId, buyerId, sellerId);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public List<ChatConversation> getConversations(int userId, String role) {
        List<ChatConversation> conversations = new ArrayList<>();
        boolean buyerRole = "buyer".equalsIgnoreCase(role);
        String userColumn = buyerRole ? "c.buyer_id" : "c.seller_id";
        String partnerJoin = buyerRole ? "c.seller_id" : "c.buyer_id";
        String partnerLabel = buyerRole ? "Người Bán" : "Khách Mua";

        String sql = "SELECT c.id, c.product_id, c.buyer_id, c.seller_id, " +
                "partner.id AS partner_id, partner.full_name AS partner_name, " +
                "COALESCE(partner.ward, partner.province, p.location, 'Đang cập nhật') AS partner_location, " +
                "p.title, p.price, p.delivery_method, CASE WHEN p.status NOT IN ('DELETE', 'SOLD') AND EXISTS (SELECT 1 FROM orders o WHERE o.product_id = p.id AND o.status IN ('DEPOSITED', 'SHIPPING', 'COMPLETED')) THEN 'SOLD' ELSE p.status END AS product_status, COALESCE(pi.image_url, 'assets/images/products/iphone-13-pro-max.jpg') AS product_image, " +
                "lm.content AS last_message, lm.message_type AS last_message_type, " +
                "(SELECT mp.proposed_price FROM messages mp WHERE mp.conversation_id = c.id AND mp.message_type = 'PROPOSAL' " +
                "ORDER BY mp.created_at DESC, mp.id DESC LIMIT 1) AS last_proposed_price, " +
                "COALESCE(lm.created_at, c.created_at) AS last_message_at " +
                "FROM conversations c " +
                "JOIN products p ON p.id = c.product_id " +
                "JOIN users partner ON partner.id = " + partnerJoin + " " +
                "LEFT JOIN product_images pi ON pi.product_id = p.id AND pi.is_primary = 1 " +
                "LEFT JOIN messages lm ON lm.id = (SELECT m.id FROM messages m WHERE m.conversation_id = c.id ORDER BY m.created_at DESC, m.id DESC LIMIT 1) " +
                "WHERE " + userColumn + " = ? " +
                "ORDER BY last_message_at DESC, c.id DESC";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ChatConversation item = new ChatConversation();
                    item.setId(rs.getInt("id"));
                    item.setProductId(rs.getInt("product_id"));
                    item.setBuyerId(rs.getInt("buyer_id"));
                    item.setSellerId(rs.getInt("seller_id"));
                    item.setPartnerId(rs.getInt("partner_id"));
                    item.setPartnerName(rs.getString("partner_name"));
                    item.setPartnerRoleLabel(partnerLabel);
                    item.setPartnerLocation(rs.getString("partner_location"));
                    item.setProductTitle(rs.getString("title"));
                    item.setProductPrice(rs.getDouble("price"));
                    item.setDeliveryMethod(rs.getInt("delivery_method"));
                    item.setProductStatus(rs.getString("product_status"));
                    item.setProductImage(rs.getString("product_image"));
                    item.setLastMessage(rs.getString("last_message"));
                    item.setLastMessageType(rs.getString("last_message_type"));
                    item.setLastProposedPrice(rs.getDouble("last_proposed_price"));
                    item.setLastMessageAt(rs.getTimestamp("last_message_at"));
                    conversations.add(item);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return conversations;
    }

    public ChatConversation getConversation(int conversationId, int userId) {
        String role = isBuyer(conversationId, userId) ? "buyer" : "seller";
        for (ChatConversation item : getConversations(userId, role)) {
            if (item.getId() == conversationId) {
                return item;
            }
        }
        return null;
    }

    public List<Message> getMessages(int conversationId, int userId) {
        List<Message> messages = new ArrayList<>();
        if (!canAccessConversation(conversationId, userId)) {
            return messages;
        }

        String sql = "SELECT * FROM messages WHERE conversation_id = ? ORDER BY created_at ASC, id ASC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, conversationId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    messages.add(mapMessage(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return messages;
    }

    public Message addMessage(int conversationId, int senderId, String content, String messageType, double proposedPrice) {
        if (!canAccessConversation(conversationId, senderId)) {
            return null;
        }

        String safeType = normalizeMessageType(messageType);
        String sql = "INSERT INTO messages (conversation_id, sender_id, content, message_type, proposed_price) VALUES (?, ?, ?, ?, ?)";
        if ("PROPOSAL".equals(safeType)) {
            try (Connection conn = DBContext.getConnection()) {
                conn.setAutoCommit(false);
                try {
                    String lockSql = "SELECT p.status, p.price, NOT EXISTS (SELECT 1 FROM orders o WHERE o.product_id = p.id " +
                            "AND o.status IN ('DEPOSITED', 'SHIPPING', 'COMPLETED')) AS is_available FROM conversations c JOIN products p ON p.id = c.product_id " +
                            "WHERE c.id = ? FOR UPDATE";
                    try (PreparedStatement lock = conn.prepareStatement(lockSql)) {
                        lock.setInt(1, conversationId);
                        try (ResultSet rs = lock.executeQuery()) {
                            if (!rs.next() || "DELETE".equalsIgnoreCase(rs.getString("status")) || "SOLD".equalsIgnoreCase(rs.getString("status")) || !rs.getBoolean("is_available") || rs.getDouble("price") <= 0) {
                                conn.rollback();
                                return null;
                            }
                        }
                    }
                    int messageId = insertMessage(conn, sql, conversationId, senderId, content, safeType, proposedPrice);
                    conn.commit();
                    return messageId > 0 ? getMessageById(messageId) : null;
                } catch (SQLException e) {
                    conn.rollback();
                    throw e;
                } finally {
                    conn.setAutoCommit(true);
                }
            } catch (SQLException e) {
                e.printStackTrace();
                return null;
            }
        }
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            bindMessage(ps, conversationId, senderId, content, safeType, proposedPrice);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return getMessageById(keys.getInt(1));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    private void createBuyerStarterConversation(Connection conn, int currentUserId) throws SQLException {
        String sql = "SELECT p.id, p.user_id, p.title, p.price FROM products p WHERE p.user_id <> ? ORDER BY p.id DESC LIMIT 1";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, currentUserId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int conversationId = findOrCreateConversation(conn, rs.getInt("id"), currentUserId, rs.getInt("user_id"));
                    seedBuyerMessages(conn, conversationId, currentUserId, rs.getInt("user_id"), rs.getString("title"), rs.getDouble("price"));
                }
            }
        }
    }

    private void createSellerStarterConversation(Connection conn, int currentUserId) throws SQLException {
        String sql = "SELECT p.id, p.title, p.price, u.id AS buyer_id FROM products p " +
                "JOIN users u ON u.id <> p.user_id " +
                "WHERE p.user_id = ? ORDER BY p.id DESC, u.id LIMIT 1";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, currentUserId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int conversationId = findOrCreateConversation(conn, rs.getInt("id"), rs.getInt("buyer_id"), currentUserId);
                    seedSellerMessages(conn, conversationId, rs.getInt("buyer_id"), currentUserId, rs.getString("title"), rs.getDouble("price"));
                }
            }
        }
    }

    private int findOrCreateConversation(Connection conn, int productId, int buyerId, int sellerId) throws SQLException {
        String findSql = "SELECT id FROM conversations WHERE product_id = ? AND buyer_id = ? AND seller_id = ? LIMIT 1";
        try (PreparedStatement find = conn.prepareStatement(findSql)) {
            find.setInt(1, productId);
            find.setInt(2, buyerId);
            find.setInt(3, sellerId);
            try (ResultSet rs = find.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("id");
                }
            }
        }

        String insertSql = "INSERT INTO conversations (product_id, buyer_id, seller_id) VALUES (?, ?, ?)";
        try (PreparedStatement insert = conn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS)) {
            insert.setInt(1, productId);
            insert.setInt(2, buyerId);
            insert.setInt(3, sellerId);
            insert.executeUpdate();
            try (ResultSet keys = insert.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getInt(1);
                }
            }
        }
        throw new SQLException("Không thể tạo hội thoại.");
    }

    private void seedBuyerMessages(Connection conn, int conversationId, int buyerId, int sellerId, String title, double price) throws SQLException {
        if (countMessages(conn, conversationId) > 0) {
            return;
        }
        insertSeedMessage(conn, conversationId, buyerId, "Chào anh/chị, " + title + " hiện còn không ạ? Em muốn xem và trao đổi thêm.", "TEXT", 0);
        insertSeedMessage(conn, conversationId, sellerId, "Sản phẩm vẫn còn bạn nhé. Bạn có thể nhắn thời gian muốn xem, mình giữ lịch cho bạn.", "TEXT", 0);
        if (price > 0) {
            insertSeedMessage(conn, conversationId, buyerId, "Em gửi đề xuất trả giá để hai bên chốt nhanh trên sàn ạ.", "PROPOSAL", Math.max(0, price - 500000));
        }
    }

    private void seedSellerMessages(Connection conn, int conversationId, int buyerId, int sellerId, String title, double price) throws SQLException {
        if (countMessages(conn, conversationId) > 0) {
            return;
        }
        insertSeedMessage(conn, conversationId, buyerId, "Chào anh/chị, em quan tâm " + title + ". Chiều nay em qua xem được không?", "TEXT", 0);
        insertSeedMessage(conn, conversationId, sellerId, "Được bạn nhé, hàng còn và đúng mô tả. Bạn nhắn trước khi qua giúp mình.", "TEXT", 0);
        if (price > 0) {
            insertSeedMessage(conn, conversationId, buyerId, "Em xin phép gửi mức giá đề xuất, nếu hợp lý mình chốt trên MuaNgay nhé.", "PROPOSAL", Math.max(0, price - 300000));
        }
    }

    private void insertSeedMessage(Connection conn, int conversationId, int senderId, String content, String type, double proposedPrice) throws SQLException {
        String sql = "INSERT INTO messages (conversation_id, sender_id, content, message_type, proposed_price) VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, conversationId);
            ps.setInt(2, senderId);
            ps.setString(3, content);
            ps.setString(4, type);
            if ("PROPOSAL".equals(type) && proposedPrice > 0) {
                ps.setDouble(5, proposedPrice);
            } else {
                ps.setNull(5, java.sql.Types.DECIMAL);
            }
            ps.executeUpdate();
        }
    }

    private int countMessages(Connection conn, int conversationId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM messages WHERE conversation_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, conversationId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    private boolean canAccessConversation(int conversationId, int userId) {
        String sql = "SELECT COUNT(*) FROM conversations WHERE id = ? AND (buyer_id = ? OR seller_id = ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, conversationId);
            ps.setInt(2, userId);
            ps.setInt(3, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean canSendOffer(int conversationId) {
        String sql = "SELECT p.price FROM conversations c JOIN products p ON p.id = c.product_id WHERE c.id = ? AND p.status NOT IN ('DELETE', 'SOLD') " +
                "AND NOT EXISTS (SELECT 1 FROM orders o WHERE o.product_id = p.id AND o.status IN ('DEPOSITED', 'SHIPPING', 'COMPLETED')) LIMIT 1";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, conversationId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getDouble("price") > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean isProductActiveForConversation(int conversationId) {
        String sql = "SELECT 1 FROM conversations c JOIN products p ON p.id = c.product_id WHERE c.id = ? AND p.status NOT IN ('DELETE', 'SOLD') " +
                "AND NOT EXISTS (SELECT 1 FROM orders o WHERE o.product_id = p.id AND o.status IN ('DEPOSITED', 'SHIPPING', 'COMPLETED')) LIMIT 1";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, conversationId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    private int insertMessage(Connection conn, String sql, int conversationId, int senderId, String content,
                              String messageType, double proposedPrice) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            bindMessage(ps, conversationId, senderId, content, messageType, proposedPrice);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                return keys.next() ? keys.getInt(1) : 0;
            }
        }
    }

    private void bindMessage(PreparedStatement ps, int conversationId, int senderId, String content,
                             String messageType, double proposedPrice) throws SQLException {
        ps.setInt(1, conversationId);
        ps.setInt(2, senderId);
        ps.setString(3, content);
        ps.setString(4, messageType);
        if ("PROPOSAL".equals(messageType) && proposedPrice > 0) ps.setDouble(5, proposedPrice);
        else ps.setNull(5, java.sql.Types.DECIMAL);
    }

    private boolean isBuyer(int conversationId, int userId) {
        String sql = "SELECT COUNT(*) FROM conversations WHERE id = ? AND buyer_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, conversationId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    private Message getMessageById(int id) throws SQLException {
        String sql = "SELECT * FROM messages WHERE id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapMessage(rs);
                }
            }
        }
        return null;
    }

    private Message mapMessage(ResultSet rs) throws SQLException {
        Message message = new Message();
        message.setId(rs.getInt("id"));
        message.setConversationId(rs.getInt("conversation_id"));
        message.setSenderId(rs.getInt("sender_id"));
        message.setContent(rs.getString("content"));
        message.setMessageType(rs.getString("message_type"));
        message.setProposedPrice(rs.getDouble("proposed_price"));
        message.setCreatedAt(rs.getTimestamp("created_at"));
        return message;
    }

    private User mapUser(ResultSet rs) throws SQLException {
        User user = new User();
        user.setId(rs.getInt("id"));
        user.setUsername(rs.getString("username"));
        user.setFullName(rs.getString("full_name"));
        user.setEmail(rs.getString("email"));
        user.setPhone(rs.getString("phone"));
        user.setProvince(rs.getString("province"));
        user.setWard(rs.getString("ward"));
        user.setAddressDetail(rs.getString("address_detail"));
        user.setAvatar(rs.getString("avatar"));
        user.setRole(rs.getString("role"));
        user.setReputationScore(rs.getInt("reputation_score"));
        user.setStatus(rs.getString("status"));
        user.setCreatedAt(rs.getTimestamp("created_at"));
        return user;
    }

    private String normalizeMessageType(String messageType) {
        if ("PROPOSAL".equalsIgnoreCase(messageType)) {
            return "PROPOSAL";
        }
        if ("SYSTEM".equalsIgnoreCase(messageType)) {
            return "SYSTEM";
        }
        return "TEXT";
    }
}
