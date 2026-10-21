package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import service.AuthService;
import service.EmailService;

import java.io.IOException;
import java.security.SecureRandom;

/**
 * API endpoint để gửi OTP đăng ký qua AJAX (không reload trang).
 * Nhận POST với tham số: email, fullName, password
 * Trả về JSON: {"success": true/false, "message": "..."}
 */
@WebServlet(name = "SendRegisterOtpServlet", value = "/send-register-otp")
public class SendRegisterOtpServlet extends HttpServlet {
    private static final long OTP_TTL_MILLIS = 5 * 60 * 1000;
    private static final String PENDING_REGISTER_PASSWORD = "pendingRegisterPassword";
    private final SecureRandom random = new SecureRandom();
    private final AuthService authService = new AuthService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        String email = request.getParameter("email");
        String fullName = request.getParameter("fullName");
        String password = request.getParameter("password");

        // Nếu password rỗng, thử lấy từ session (trường hợp gửi lại OTP)
        HttpSession session = request.getSession();
        if (password == null || password.trim().isEmpty()) {
            Object pending = session.getAttribute(PENDING_REGISTER_PASSWORD);
            if (pending instanceof String) {
                password = (String) pending;
            }
        }

        // Validate đầu vào cơ bản
        if (email == null || email.trim().isEmpty()) {
            response.getWriter().write("{\"success\":false,\"message\":\"Vui lòng nhập địa chỉ email.\"}");
            return;
        }
        if (fullName == null || fullName.trim().isEmpty()) {
            response.getWriter().write("{\"success\":false,\"message\":\"Vui lòng nhập họ và tên.\"}");
            return;
        }
        if (password == null || password.trim().isEmpty()) {
            response.getWriter().write("{\"success\":false,\"message\":\"Vui lòng nhập mật khẩu.\"}");
            return;
        }

        try {
            if (authService.emailExists(email.trim())) {
                response.getWriter().write("{\"success\":false,\"message\":\"Email này đã được đăng ký.\"}");
                return;
            }
        } catch (IllegalStateException e) {
            response.getWriter().write("{\"success\":false,\"message\":\"" + escapeJson(e.getMessage()) + "\"}");
            return;
        }

        String otp = String.format("%06d", random.nextInt(1_000_000));
        session.setAttribute("registerOtp", otp);
        session.setAttribute("registerOtpEmail", email.trim());
        session.setAttribute("registerOtpExpiresAt", System.currentTimeMillis() + OTP_TTL_MILLIS);
        // Lưu mật khẩu vào session để dùng khi xác thực OTP và tạo tài khoản
        session.setAttribute(PENDING_REGISTER_PASSWORD, password);

        boolean sent = EmailService.sendOtpEmail(email.trim(), otp);
        String message = sent
                ? "Đã gửi mã OTP tới email của bạn."
                : "Chưa cấu hình SMTP nên mã OTP đang được in trong console server.";

        response.getWriter().write("{\"success\":true,\"message\":\"" + escapeJson(message) + "\"}");
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\r", "")
                .replace("\n", "\\n");
    }
}
