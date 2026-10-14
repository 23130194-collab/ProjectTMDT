package model;

import java.sql.Timestamp;

public class Product {
    private int id;
    private int deliveryMethod;
    private int userId;
    private int categoryId;
    private String title;
    private String description;
    private double price;
    private String conditionStatus;
    private String location;
    private String province;
    private String ward;
    private String addressDetail;
    private String status;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private String primaryImage;
    private boolean newProduct;
    private String specifications;
    private String dealType; // "SELL" hoặc "GIVE"

    public String getSpecifications() { return specifications; }
    public void setSpecifications(String specifications) { this.specifications = specifications; }

    public String getDealType() { return dealType; }
    public void setDealType(String dealType) { this.dealType = dealType; }

    public String getPrimaryImage() { return primaryImage; }
    public void setPrimaryImage(String primaryImage) { this.primaryImage = primaryImage; }
    public boolean isNewProduct() { return newProduct; }
    public void setNewProduct(boolean newProduct) { this.newProduct = newProduct; }

    public Product() {
    }

    public Product(int id, int userId, int categoryId, String title, String description, double price, String conditionStatus, String location, String status, Timestamp createdAt, Timestamp updatedAt) {
        this.id = id;
        this.userId = userId;
        this.categoryId = categoryId;
        this.title = title;
        this.description = description;
        this.price = price;
        this.conditionStatus = conditionStatus;
        this.location = location;
        this.status = status;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public int getDeliveryMethod() { return deliveryMethod; }
    public void setDeliveryMethod(int deliveryMethod) { this.deliveryMethod = deliveryMethod; }

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

    public int getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    public String getConditionStatus() {
        return conditionStatus;
    }

    public void setConditionStatus(String conditionStatus) {
        this.conditionStatus = conditionStatus;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public String getProvince() { return province; }
    public void setProvince(String province) { this.province = province; }
    public String getWard() { return ward; }
    public void setWard(String ward) { this.ward = ward; }
    public String getAddressDetail() { return addressDetail; }
    public void setAddressDetail(String addressDetail) { this.addressDetail = addressDetail; }

    public String getDisplayLocation() {
        StringBuilder display = new StringBuilder();
        appendLocationPart(display, addressDetail);
        appendLocationPart(display, ward);
        appendLocationPart(display, province);
        return display.length() > 0 ? display.toString() : (location == null ? "" : location);
    }

    private void appendLocationPart(StringBuilder display, String value) {
        if (value != null && !value.trim().isEmpty()) {
            if (display.length() > 0) display.append(", ");
            display.append(value.trim());
        }
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }
}
