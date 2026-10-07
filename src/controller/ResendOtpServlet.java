package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import service.EmailService;

import java.io.IOException;
import java.security.SecureRandom;

@WebServlet(name = "ResendOtpServlet", value = "/resend-otp")
public class ResendOtpServlet extends HttpServlet {
    private static final long OTP_TTL_MILLIS = 5 * 60 * 1000;
    private final SecureRandom random = new SecureRandom();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String email = (String) session.getAttribute("registerOtpEmail");

        if (email == null || email.trim().isEmpty()) {
            session.setAttribute("authMessage", "Vui lòng nhập thông tin đăng ký rồi bấm gửi mã OTP.");
            response.sendRedirect(request.getContextPath() + "/07-dang-nhap-xac-thuc.jsp");
            return;
        }

        String otp = String.format("%06d", random.nextInt(1_000_000));
        session.setAttribute("registerOtp", otp);
        session.setAttribute("registerOtpExpiresAt", System.currentTimeMillis() + OTP_TTL_MILLIS);
        boolean sent = EmailService.sendOtpEmail(email, otp);
        session.setAttribute("authMessage", sent
                ? "Đã gửi lại mã OTP tới email của bạn."
                : "Chưa cấu hình SMTP nên mã OTP mới đang được in trong console server.");
        response.sendRedirect(request.getContextPath() + "/07-dang-nhap-xac-thuc.jsp");
    }
}
