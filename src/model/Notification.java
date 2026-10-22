package model;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;

public class Notification {
    private int id;
    private int userId;
    private String title;
    private String message;
    private String type; // ORDER_SHIPPING, REVIEW_RECEIVED, SYSTEM
    private String targetUrl;
    private boolean isRead;
    private Timestamp createdAt;

    public Notification() {
    }

    public Notification(int id, int userId, String title, String message, String type, String targetUrl, boolean isRead, Timestamp createdAt) {
        this.id = id;
        this.userId = userId;
        this.title = title;
        this.message = message;
        this.type = type;
        this.targetUrl = targetUrl;
        this.isRead = isRead;
        this.createdAt = createdAt;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getTargetUrl() {
        return targetUrl;
    }

    public void setTargetUrl(String targetUrl) {
        this.targetUrl = targetUrl;
    }

    public boolean isRead() {
        return isRead;
    }

    public void setRead(boolean read) {
        isRead = read;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    /**
     * Trả về định dạng thời gian tương đối thân thiện (VD: "Vừa xong", "5 phút trước", "2 giờ trước")
     */
    public String getTimeAgo() {
        if (createdAt == null) return "";
        long diff = System.currentTimeMillis() - createdAt.getTime();
        long seconds = diff / 1000;
        if (seconds < 60) return "Vừa xong";
        long minutes = seconds / 60;
        if (minutes < 60) return minutes + " phút trước";
        long hours = minutes / 60;
        if (hours < 24) return hours + " giờ trước";
        long days = hours / 24;
        if (days < 7) return days + " ngày trước";
        return new SimpleDateFormat("dd/MM/yyyy HH:mm").format(createdAt);
    }
}
