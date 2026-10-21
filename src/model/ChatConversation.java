package model;

import java.sql.Timestamp;

public class ChatConversation {
    private int id;
    private int productId;
    private int buyerId;
    private int sellerId;
    private int partnerId;
    private String partnerName;
    private String partnerRoleLabel;
    private String partnerLocation;
    private String productTitle;
    private double productPrice;
    private String productImage;
    private String productStatus;
    private String lastMessage;
    private String lastMessageType;
    private double lastProposedPrice;
    private Timestamp lastMessageAt;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }

    public int getBuyerId() { return buyerId; }
    public void setBuyerId(int buyerId) { this.buyerId = buyerId; }

    public int getSellerId() { return sellerId; }
    public void setSellerId(int sellerId) { this.sellerId = sellerId; }

    public int getPartnerId() { return partnerId; }
    public void setPartnerId(int partnerId) { this.partnerId = partnerId; }

    public String getPartnerName() { return partnerName; }
    public void setPartnerName(String partnerName) { this.partnerName = partnerName; }

    public String getPartnerRoleLabel() { return partnerRoleLabel; }
    public void setPartnerRoleLabel(String partnerRoleLabel) { this.partnerRoleLabel = partnerRoleLabel; }

    public String getPartnerLocation() { return partnerLocation; }
    public void setPartnerLocation(String partnerLocation) { this.partnerLocation = partnerLocation; }

    public String getProductTitle() { return productTitle; }
    public void setProductTitle(String productTitle) { this.productTitle = productTitle; }

    public double getProductPrice() { return productPrice; }
    public void setProductPrice(double productPrice) { this.productPrice = productPrice; }

    public String getProductImage() { return productImage; }
    public void setProductImage(String productImage) { this.productImage = productImage; }

    public String getProductStatus() { return productStatus; }
    public void setProductStatus(String productStatus) { this.productStatus = productStatus; }

    public String getLastMessage() { return lastMessage; }
    public void setLastMessage(String lastMessage) { this.lastMessage = lastMessage; }

    public String getLastMessageType() { return lastMessageType; }
    public void setLastMessageType(String lastMessageType) { this.lastMessageType = lastMessageType; }

    public double getLastProposedPrice() { return lastProposedPrice; }
    public void setLastProposedPrice(double lastProposedPrice) { this.lastProposedPrice = lastProposedPrice; }

    public Timestamp getLastMessageAt() { return lastMessageAt; }
    public void setLastMessageAt(Timestamp lastMessageAt) { this.lastMessageAt = lastMessageAt; }
}
