package controller;

import service.AuthService;
import util.DataValidator;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
@WebServlet(name = "ResetPasswordServlet", value = "/reset-password")
public class ResetPasswordServlet extends HttpServlet {
    private AuthService authService;

    @Override
    public void init() throws ServletException {
        super.init();
        this.authService = new AuthService();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String email = (String) session.getAttribute("user_can_reset_password");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        if (email == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        if (!DataValidator.isPasswordValid(password)) {
            request.setAttribute("error", DataValidator.getPasswordRuleMessage());
            request.getRequestDispatcher("/matKhauMoi.jsp").forward(request, response);
            return;
        }

        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Mật khẩu xác nhận không khớp.");
            request.getRequestDispatcher("/matKhauMoi.jsp").forward(request, response);
            return;
        }

        authService.updatePassword(email, password);

        session.removeAttribute("user_can_reset_password");
        session.setAttribute("successMessage", "Đổi mật khẩu thành công! Vui lòng đăng nhập lại.");
        response.sendRedirect(request.getContextPath() + "/login");
    }
}
