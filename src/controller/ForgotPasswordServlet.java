package controller;

import model.User;
import service.AuthService;
import util.DataValidator;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.security.SecureRandom;

@WebServlet(name = "ForgotPasswordServlet", value = "/forgot-password")
public class ForgotPasswordServlet extends HttpServlet {
    private static final long OTP_TTL_MILLIS = 5 * 60 * 1000;
    private final AuthService authService = new AuthService();
    private final SecureRandom random = new SecureRandom();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("/07-dang-nhap-xac-thuc.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String email = request.getParameter("email");
        String action = request.getParameter("action");

        if ("reset".equals(action)) {
            resetPassword(request, response);
            return;
        }

        if (!DataValidator.isEmailValid(email)) {
            request.setAttribute("forgotError", "Vui lòng nhập đúng email đã đăng ký.");
            request.setAttribute("forgotEmailValue", email);
            request.getRequestDispatcher("/07-dang-nhap-xac-thuc.jsp").forward(request, response);
            return;
        }

        User user;
        try {
            user = authService.getUserByEmail(email);
        } catch (IllegalStateException e) {
            request.setAttribute("forgotError", e.getMessage());
            request.setAttribute("forgotEmailValue", email);
            request.getRequestDispatcher("/07-dang-nhap-xac-thuc.jsp").forward(request, response);
            return;
        }
        if (user == null) {
            request.setAttribute("forgotError", "Email không tồn tại trong hệ thống.");
            request.setAttribute("forgotEmailValue", email);
            request.getRequestDispatcher("/07-dang-nhap-xac-thuc.jsp").forward(request, response);
            return;
        }

        if (authService.isLocked(user)) {
            request.setAttribute("forgotError", "Tài khoản của bạn đang bị khóa. Vui lòng liên hệ Admin.");
            request.setAttribute("forgotEmailValue", email);
            request.getRequestDispatcher("/07-dang-nhap-xac-thuc.jsp").forward(request, response);
            return;
        }

        HttpSession session = request.getSession();
        String otp = generateOtp();
        session.setAttribute("resetOtp", otp);
        session.setAttribute("resetOtpEmail", email.trim());
        session.setAttribute("resetOtpExpiresAt", System.currentTimeMillis() + OTP_TTL_MILLIS);

        boolean sent = service.EmailService.sendPasswordResetOtpEmail(email.trim(), otp);
        session.setAttribute("authMessage", sent
                ? "Đã gửi mã OTP đặt lại mật khẩu tới email của bạn."
                : "Chưa cấu hình SMTP nên mã OTP đặt lại mật khẩu đang được in trong console server.");
        request.setAttribute("forgotEmailValue", email);
        request.setAttribute("showResetPasswordForm", true);
        request.getRequestDispatcher("/07-dang-nhap-xac-thuc.jsp").forward(request, response);
    }

    private void resetPassword(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String email = request.getParameter("email");
        String otp = request.getParameter("otp");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        if (!isResetOtpValid(session, email, otp)) {
            request.setAttribute("forgotError", "Mã OTP không đúng hoặc đã hết hạn. Vui lòng gửi lại mã.");
            request.setAttribute("forgotEmailValue", email);
            request.setAttribute("showResetPasswordForm", true);
            request.getRequestDispatcher("/07-dang-nhap-xac-thuc.jsp").forward(request, response);
            return;
        }

        if (!DataValidator.isPasswordValid(password)) {
            request.setAttribute("forgotError", DataValidator.getPasswordRuleMessage());
            request.setAttribute("forgotEmailValue", email);
            request.setAttribute("showResetPasswordForm", true);
            request.getRequestDispatcher("/07-dang-nhap-xac-thuc.jsp").forward(request, response);
            return;
        }

        if (!password.equals(confirmPassword)) {
            request.setAttribute("forgotError", "Mật khẩu xác nhận không khớp.");
            request.setAttribute("forgotEmailValue", email);
            request.setAttribute("showResetPasswordForm", true);
            request.getRequestDispatcher("/07-dang-nhap-xac-thuc.jsp").forward(request, response);
            return;
        }

        authService.updatePassword(email, password);
        session.removeAttribute("resetOtp");
        session.removeAttribute("resetOtpEmail");
        session.removeAttribute("resetOtpExpiresAt");
        session.setAttribute("authMessage", "Đổi mật khẩu thành công. Bạn có thể đăng nhập bằng mật khẩu mới.");
        response.sendRedirect(request.getContextPath() + "/07-dang-nhap-xac-thuc.jsp");
    }

    private String generateOtp() {
        return String.format("%06d", random.nextInt(1_000_000));
    }

    private boolean isResetOtpValid(HttpSession session, String email, String otp) {
        String expectedOtp = (String) session.getAttribute("resetOtp");
        String expectedEmail = (String) session.getAttribute("resetOtpEmail");
        Long expiresAt = (Long) session.getAttribute("resetOtpExpiresAt");

        return expectedOtp != null
                && expectedEmail != null
                && expiresAt != null
                && System.currentTimeMillis() <= expiresAt
                && email != null
                && expectedEmail.equalsIgnoreCase(email.trim())
                && expectedOtp.equals(otp != null ? otp.trim() : "");
    }
}
