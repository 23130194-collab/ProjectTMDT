package model;

import java.sql.Timestamp;

public class BannedKeyword {
    private int id;
    private String keyword;
    private boolean isRegex;
    private String description;
    private boolean isActive;
    private Timestamp createdAt;

    public BannedKeyword() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getKeyword() { return keyword; }
    public void setKeyword(String keyword) { this.keyword = keyword; }
    public boolean isRegex() { return isRegex; }
    public void setRegex(boolean regex) { isRegex = regex; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
