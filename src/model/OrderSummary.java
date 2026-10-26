package model;

import java.sql.Timestamp;

public class OrderSummary {
    public int id;
    public int productId;
    public int buyerId;
    public int sellerId;
    public double agreedPrice;
    public double depositAmount;
    public String status;
    public Timestamp createdAt;

    public int deliveryMethod; // 1: Trực tiếp, 2: GHN
    public boolean sellerConfirmed;
    public boolean buyerConfirmed;
    public Timestamp sellerConfirmedAt;
    public Timestamp buyerConfirmedAt;
    public String trackingCode;
    public String shippingProvider;
    public String shippingStatus;
    public String shippingNote;

    public boolean cancelRequested;
    public String cancelReason;
    public Timestamp cancelRequestedAt;

    public String productTitle;
    public double productPrice;
    public String productImage;
    public String productAddress;
    public String productProvince;
    public String productWard;

    public String buyerName;
    public String buyerPhone;
    public String buyerAddress;

    public String sellerName;
    public String sellerPhone;
    public String sellerAddress;

    public OrderSummary() {
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

    public int getDeliveryMethod() {
        return deliveryMethod;
    }

    public void setDeliveryMethod(int deliveryMethod) {
        this.deliveryMethod = deliveryMethod;
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

    public String getProductTitle() {
        return productTitle;
    }

    public void setProductTitle(String productTitle) {
        this.productTitle = productTitle;
    }

    public double getProductPrice() {
        return productPrice;
    }

    public void setProductPrice(double productPrice) {
        this.productPrice = productPrice;
    }

    public String getProductImage() {
        return productImage;
    }

    public void setProductImage(String productImage) {
        this.productImage = productImage;
    }

    public String getProductAddress() {
        return productAddress;
    }

    public void setProductAddress(String productAddress) {
        this.productAddress = productAddress;
    }

    public String getProductProvince() {
        return productProvince;
    }

    public void setProductProvince(String productProvince) {
        this.productProvince = productProvince;
    }

    public String getProductWard() {
        return productWard;
    }

    public void setProductWard(String productWard) {
        this.productWard = productWard;
    }

    public String getBuyerName() {
        return buyerName;
    }

    public void setBuyerName(String buyerName) {
        this.buyerName = buyerName;
    }

    public String getBuyerPhone() {
        return buyerPhone;
    }

    public void setBuyerPhone(String buyerPhone) {
        this.buyerPhone = buyerPhone;
    }

    public String getBuyerAddress() {
        return buyerAddress;
    }

    public void setBuyerAddress(String buyerAddress) {
        this.buyerAddress = buyerAddress;
    }

    public String getSellerName() {
        return sellerName;
    }

    public void setSellerName(String sellerName) {
        this.sellerName = sellerName;
    }

    public String getSellerPhone() {
        return sellerPhone;
    }

    public void setSellerPhone(String sellerPhone) {
        this.sellerPhone = sellerPhone;
    }

    public String getSellerAddress() {
        return sellerAddress;
    }

    public void setSellerAddress(String sellerAddress) {
        this.sellerAddress = sellerAddress;
    }

    public boolean isCancelRequested() {
        return cancelRequested;
    }

    public void setCancelRequested(boolean cancelRequested) {
        this.cancelRequested = cancelRequested;
    }

    public String getCancelReason() {
        return cancelReason;
    }

    public void setCancelReason(String cancelReason) {
        this.cancelReason = cancelReason;
    }

    public Timestamp getCancelRequestedAt() {
        return cancelRequestedAt;
    }

    public void setCancelRequestedAt(Timestamp cancelRequestedAt) {
        this.cancelRequestedAt = cancelRequestedAt;
    }
}
