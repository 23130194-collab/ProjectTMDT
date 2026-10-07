package controller;

import model.User;
import service.AuthService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(name = "LoginController", value = "/login")
public class LoginController extends HttpServlet {
    private final AuthService authService = new AuthService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("/07-dang-nhap-xac-thuc.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String account = request.getParameter("account");
        String password = request.getParameter("password");

        if (account == null || account.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            request.setAttribute("loginError", "Vui lòng nhập email/số điện thoại và mật khẩu.");
            request.setAttribute("accountValue", account);
            request.getRequestDispatcher("/07-dang-nhap-xac-thuc.jsp").forward(request, response);
            return;
        }

        User user;
        try {
            user = authService.checkLogin(account, password);
        } catch (IllegalStateException e) {
            request.setAttribute("loginError", e.getMessage());
            request.setAttribute("accountValue", account);
            request.getRequestDispatcher("/07-dang-nhap-xac-thuc.jsp").forward(request, response);
            return;
        }

        if (user == null) {
            User existingUser = authService.getUserByAccount(account);
            String message = existingUser != null && authService.isLocked(existingUser)
                    ? "Tài khoản của bạn đã bị khóa. Vui lòng liên hệ Admin!"
                    : "Email, số điện thoại hoặc mật khẩu không hợp lệ.";

            request.setAttribute("loginError", message);
            request.setAttribute("accountValue", account);
            request.getRequestDispatcher("/07-dang-nhap-xac-thuc.jsp").forward(request, response);
            return;
        }

        HttpSession session = request.getSession();
        session.setAttribute("user", user);
        session.setAttribute("authMessage", "Đăng nhập thành công! Chào mừng bạn quay lại.");

        if ("ADMIN".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/06-quan-tri-admin.jsp");
        } else {
            response.sendRedirect(request.getContextPath() + "/08-ho-so-ca-nhan.jsp");
        }
    }
}
