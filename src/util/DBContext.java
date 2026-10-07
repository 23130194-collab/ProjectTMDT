package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBContext {
    private static final String URL = "jdbc:mysql://localhost:3306/muangay_db?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC";
    
    private static final String USER = "root";
    private static final String PASS = ""; 

    public static Connection getConnection() {
        Connection conn = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(URL, USER, PASS);
        } catch (ClassNotFoundException e) {
            System.err.println("Không tìm thấy Driver MySQL: " + e.getMessage());
        } catch (SQLException e) {
            System.err.println("Lỗi kết nối CSDL: " + e.getMessage());
        }
        return conn;
    }

    public static void main(String[] args) {
        Connection conn = getConnection();
        if (conn != null) {
            System.out.println("Kết nối Database muangay_db THÀNH CÔNG!");
        } else {
            System.out.println("Kết nối THẤT BẠI! Vui lòng kiểm tra lại tài khoản, mật khẩu hoặc cổng 3306.");
        }
    }
}
