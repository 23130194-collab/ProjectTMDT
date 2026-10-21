package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBContext {
    private static final String URL = "jdbc:mysql://localhost:8889/muangay_db?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC";
    
    private static final String USER = "root";
    private static final String PASS = "root";

    public static Connection getConnection() {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            return DriverManager.getConnection(URL, USER, PASS);
        } catch (ClassNotFoundException e) {
            throw new IllegalStateException("Không tìm thấy Driver MySQL.", e);
        } catch (SQLException e) {
            throw new IllegalStateException("Không thể kết nối CSDL. Vui lòng kiểm tra MySQL, database muangay_db, user root và mật khẩu.", e);
        }
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
