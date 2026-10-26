package model;

import java.sql.Timestamp;

public class ProductBoost {
    private int id;
    private int productId;
    private int userId;
    private int packageId;
    private String packageType; // "BUMP" hoặc "VIP_PIN"
    private double amountPaid;
    private Timestamp startTime;
    private Timestamp endTime;
    private int remainingBumps;
    private String vnpTxnRef;
    private String status; // "ACTIVE", "EXPIRED", "COMPLETED"
    private Timestamp createdAt;

    // Các trường tham chiếu tiện ích khi hiển thị
    private String packageName;
    private String productTitle;
    private String userFullName;
    private String badgeLabel;
    private String badgeColor;

    public ProductBoost() {}

    public boolean isCurrentlyActive() {
        if (!"ACTIVE".equalsIgnoreCase(status)) return false;
        if ("VIP_PIN".equalsIgnoreCase(packageType)) {
            return endTime != null && endTime.after(new java.util.Date());
        }
        return remainingBumps > 0;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public int getPackageId() { return packageId; }
    public void setPackageId(int packageId) { this.packageId = packageId; }

    public String getPackageType() { return packageType; }
    public void setPackageType(String packageType) { this.packageType = packageType; }

    public double getAmountPaid() { return amountPaid; }
    public void setAmountPaid(double amountPaid) { this.amountPaid = amountPaid; }

    public Timestamp getStartTime() { return startTime; }
    public void setStartTime(Timestamp startTime) { this.startTime = startTime; }

    public Timestamp getEndTime() { return endTime; }
    public void setEndTime(Timestamp endTime) { this.endTime = endTime; }

    public int getRemainingBumps() { return remainingBumps; }
    public void setRemainingBumps(int remainingBumps) { this.remainingBumps = remainingBumps; }

    public String getVnpTxnRef() { return vnpTxnRef; }
    public void setVnpTxnRef(String vnpTxnRef) { this.vnpTxnRef = vnpTxnRef; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getPackageName() { return packageName; }
    public void setPackageName(String packageName) { this.packageName = packageName; }

    public String getProductTitle() { return productTitle; }
    public void setProductTitle(String productTitle) { this.productTitle = productTitle; }

    public String getUserFullName() { return userFullName; }
    public void setUserFullName(String userFullName) { this.userFullName = userFullName; }

    public String getBadgeLabel() { return badgeLabel; }
    public void setBadgeLabel(String badgeLabel) { this.badgeLabel = badgeLabel; }

    public String getBadgeColor() { return badgeColor; }
    public void setBadgeColor(String badgeColor) { this.badgeColor = badgeColor; }
}
