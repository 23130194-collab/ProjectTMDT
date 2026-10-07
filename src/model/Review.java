package model;

import java.sql.Timestamp;

public class Review {
    private int id;
    private int orderId;
    private int reviewerId;
    private int revieweeId;
    private int rating;
    private String comment;
    private Timestamp createdAt;

    public Review() {
    }

    public Review(int id, int orderId, int reviewerId, int revieweeId, int rating, String comment, Timestamp createdAt) {
        this.id = id;
        this.orderId = orderId;
        this.reviewerId = reviewerId;
        this.revieweeId = revieweeId;
        this.rating = rating;
        this.comment = comment;
        this.createdAt = createdAt;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getOrderId() {
        return orderId;
    }

    public void setOrderId(int orderId) {
        this.orderId = orderId;
    }

    public int getReviewerId() {
        return reviewerId;
    }

    public void setReviewerId(int reviewerId) {
        this.reviewerId = reviewerId;
    }

    public int getRevieweeId() {
        return revieweeId;
    }

    public void setRevieweeId(int revieweeId) {
        this.revieweeId = revieweeId;
    }

    public int getRating() {
        return rating;
    }

    public void setRating(int rating) {
        this.rating = rating;
    }

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}