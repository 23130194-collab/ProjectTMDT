package model;

import java.sql.Timestamp;

public class BoostPackage {
    private int id;
    private String name;
    private String packageType; // "BUMP" hoặc "VIP_PIN"
    private double price;
    private int durationDays;
    private int bumpCount;
    private int priorityLevel;
    private String badgeLabel;
    private String badgeColor;
    private String description;
    private boolean active;
    private int sortOrder;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public BoostPackage() {}

    public BoostPackage(int id, String name, String packageType, double price, int durationDays,
                        int bumpCount, int priorityLevel, String badgeLabel, String badgeColor,
                        String description, boolean active, int sortOrder) {
        this.id = id;
        this.name = name;
        this.packageType = packageType;
        this.price = price;
        this.durationDays = durationDays;
        this.bumpCount = bumpCount;
        this.priorityLevel = priorityLevel;
        this.badgeLabel = badgeLabel;
        this.badgeColor = badgeColor;
        this.description = description;
        this.active = active;
        this.sortOrder = sortOrder;
    }

    public boolean isVipPackage() {
        return "VIP_PIN".equalsIgnoreCase(packageType);
    }

    public boolean isBumpPackage() {
        return "BUMP".equalsIgnoreCase(packageType);
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getPackageType() { return packageType; }
    public void setPackageType(String packageType) { this.packageType = packageType; }

    public double getPrice() { return price; }
    public void setPrice(double price) { this.price = price; }

    public int getDurationDays() { return durationDays; }
    public void setDurationDays(int durationDays) { this.durationDays = durationDays; }

    public int getBumpCount() { return bumpCount; }
    public void setBumpCount(int bumpCount) { this.bumpCount = bumpCount; }

    public int getPriorityLevel() { return priorityLevel; }
    public void setPriorityLevel(int priorityLevel) { this.priorityLevel = priorityLevel; }

    public String getBadgeLabel() { return badgeLabel; }
    public void setBadgeLabel(String badgeLabel) { this.badgeLabel = badgeLabel; }

    public String getBadgeColor() { return badgeColor; }
    public void setBadgeColor(String badgeColor) { this.badgeColor = badgeColor; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }

    public int getSortOrder() { return sortOrder; }
    public void setSortOrder(int sortOrder) { this.sortOrder = sortOrder; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
}
