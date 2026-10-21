package model;

import java.sql.Timestamp;

public class Order {
    private int id;
    private int productId;
    private int buyerId;
    private int sellerId;
    private double agreedPrice;
    private double depositAmount;
    private int deliveryMethod; // 1: Hẹn gặp trực tiếp, 2: Giao tận nhà qua GHN
    private String status; // NEGOTIATING, DEPOSITED, SHIPPING, COMPLETED, CANCELLED, DISPUTED
    private boolean sellerConfirmed; // Người bán xác nhận đã giao hàng
    private boolean buyerConfirmed;  // Người mua xác nhận đã nhận hàng
    private Timestamp sellerConfirmedAt;
    private Timestamp buyerConfirmedAt;
    private String trackingCode;     // Mã vận đơn GHN (VD: GHN88291023VN)
    private String shippingProvider; // GHN
    private String shippingStatus;   // CHO_LAY_HANG, DANG_GIAO, DA_GIAO
    private String shippingNote;
    private Timestamp createdAt;

    public Order() {
    }

    public Order(int id, int productId, int buyerId, int sellerId, double agreedPrice, double depositAmount, String status, Timestamp createdAt) {
        this.id = id;
        this.productId = productId;
        this.buyerId = buyerId;
        this.sellerId = sellerId;
        this.agreedPrice = agreedPrice;
        this.depositAmount = depositAmount;
        this.status = status;
        this.createdAt = createdAt;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public int getBuyerId() {
        return buyerId;
    }

    public void setBuyerId(int buyerId) {
        this.buyerId = buyerId;
    }

    public int getSellerId() {
        return sellerId;
    }

    public void setSellerId(int sellerId) {
        this.sellerId = sellerId;
    }

    public double getAgreedPrice() {
        return agreedPrice;
    }

    public void setAgreedPrice(double agreedPrice) {
        this.agreedPrice = agreedPrice;
    }

    public double getDepositAmount() {
        return depositAmount;
    }

    public void setDepositAmount(double depositAmount) {
        this.depositAmount = depositAmount;
    }

    public int getDeliveryMethod() {
        return deliveryMethod;
    }

    public void setDeliveryMethod(int deliveryMethod) {
        this.deliveryMethod = deliveryMethod;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public boolean isSellerConfirmed() {
        return sellerConfirmed;
    }

    public void setSellerConfirmed(boolean sellerConfirmed) {
        this.sellerConfirmed = sellerConfirmed;
    }

    public boolean isBuyerConfirmed() {
        return buyerConfirmed;
    }

    public void setBuyerConfirmed(boolean buyerConfirmed) {
        this.buyerConfirmed = buyerConfirmed;
    }

    public Timestamp getSellerConfirmedAt() {
        return sellerConfirmedAt;
    }

    public void setSellerConfirmedAt(Timestamp sellerConfirmedAt) {
        this.sellerConfirmedAt = sellerConfirmedAt;
    }

    public Timestamp getBuyerConfirmedAt() {
        return buyerConfirmedAt;
    }

    public void setBuyerConfirmedAt(Timestamp buyerConfirmedAt) {
        this.buyerConfirmedAt = buyerConfirmedAt;
    }

    public String getTrackingCode() {
        return trackingCode;
    }

    public void setTrackingCode(String trackingCode) {
        this.trackingCode = trackingCode;
    }

    public String getShippingProvider() {
        return shippingProvider;
    }

    public void setShippingProvider(String shippingProvider) {
        this.shippingProvider = shippingProvider;
    }

    public String getShippingStatus() {
        return shippingStatus;
    }

    public void setShippingStatus(String shippingStatus) {
        this.shippingStatus = shippingStatus;
    }

    public String getShippingNote() {
        return shippingNote;
    }

    public void setShippingNote(String shippingNote) {
        this.shippingNote = shippingNote;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}