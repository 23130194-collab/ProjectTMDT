package dao;

import model.Product;
import util.DBContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class FavoriteDAO {
    public boolean add(int userId, int productId) {
        String sql = "INSERT IGNORE INTO favorites (user_id, product_id) SELECT ?, p.id FROM products p WHERE p.id = ? AND p.status <> 'DELETE'";
        try (Connection c = DBContext.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1,userId); ps.setInt(2,productId); return ps.executeUpdate() > 0 || contains(userId,productId);
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }
    public boolean remove(int userId, int productId) {
        try (Connection c=DBContext.getConnection(); PreparedStatement ps=c.prepareStatement("DELETE FROM favorites WHERE user_id=? AND product_id=?")) {
            ps.setInt(1,userId); ps.setInt(2,productId); return ps.executeUpdate()>0;
        } catch(SQLException e){e.printStackTrace();return false;}
    }
    public boolean clearSold(int userId) {
        String sql="DELETE f FROM favorites f JOIN products p ON p.id=f.product_id LEFT JOIN orders o ON o.product_id=p.id AND o.status IN ('DEPOSITED','SHIPPING','COMPLETED') WHERE f.user_id=? AND (p.status='SOLD' OR o.id IS NOT NULL)";
        try(Connection c=DBContext.getConnection();PreparedStatement ps=c.prepareStatement(sql)){ps.setInt(1,userId);ps.executeUpdate();return true;}catch(SQLException e){e.printStackTrace();return false;}
    }
    public boolean contains(int userId,int productId) {
        try(Connection c=DBContext.getConnection();PreparedStatement ps=c.prepareStatement("SELECT 1 FROM favorites WHERE user_id=? AND product_id=?")){ps.setInt(1,userId);ps.setInt(2,productId);try(ResultSet r=ps.executeQuery()){return r.next();}}catch(SQLException e){e.printStackTrace();return false;}
    }
    public List<Product> list(int userId) {
        List<Product> out=new ArrayList<>();
        String sql="SELECT p.*,pi.image_url,CASE WHEN p.status='SOLD' OR EXISTS(SELECT 1 FROM orders o WHERE o.product_id=p.id AND o.status IN ('DEPOSITED','SHIPPING','COMPLETED')) THEN 'SOLD' ELSE p.status END current_status FROM favorites f JOIN products p ON p.id=f.product_id LEFT JOIN product_images pi ON pi.product_id=p.id AND pi.is_primary=1 WHERE f.user_id=? AND p.status<>'DELETE' ORDER BY f.created_at DESC";
        try(Connection c=DBContext.getConnection();PreparedStatement ps=c.prepareStatement(sql)){ps.setInt(1,userId);try(ResultSet r=ps.executeQuery()){while(r.next()){Product p=new Product();p.setId(r.getInt("id"));p.setTitle(r.getString("title"));p.setPrice(r.getDouble("price"));p.setStatus(r.getString("current_status"));p.setPrimaryImage(r.getString("image_url"));p.setDealType(r.getString("deal_type"));out.add(p);}}}catch(SQLException e){e.printStackTrace();}return out;
    }
}
