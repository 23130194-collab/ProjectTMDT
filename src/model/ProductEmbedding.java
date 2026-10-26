package model;

import java.sql.Timestamp;

public class ProductEmbedding {
    private int id;
    private int productId;
    private float[] vector;
    private String vectorData;
    private Timestamp createdAt;
    private double similarityScore; // Dùng khi tính điểm tương đồng trong kết quả tìm kiếm

    public ProductEmbedding() {}

    public ProductEmbedding(int productId, float[] vector) {
        this.productId = productId;
        this.vector = vector;
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

    public float[] getVector() {
        return vector;
    }

    public void setVector(float[] vector) {
        this.vector = vector;
    }

    public String getVectorData() {
        return vectorData;
    }

    public void setVectorData(String vectorData) {
        this.vectorData = vectorData;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public double getSimilarityScore() {
        return similarityScore;
    }

    public void setSimilarityScore(double similarityScore) {
        this.similarityScore = similarityScore;
    }
}
