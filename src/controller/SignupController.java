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

@WebServlet(name = "SignupController", value = "/signup")
public class SignupController extends HttpServlet {
    private static final long OTP_TTL_MILLIS = 5 * 60 * 1000;
    private static final String PENDING_REGISTER_PASSWORD = "pendingRegisterPassword";
    private final AuthService authService = new AuthService();
    private final SecureRandom random = new SecureRandom();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/07-dang-nhap-xac-thuc.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String otp = request.getParameter("otp");
        String action = request.getParameter("action");
        HttpSession session = request.getSession();
        String registerPassword = resolveRegisterPassword(session, password);

        String error = validateRegister(fullName, email, registerPassword);
        if (error != null) {
            request.setAttribute("registerError", error);
            request.setAttribute("registerNameValue", fullName);
            request.setAttribute("registerEmailValue", email);
            request.setAttribute("showRegisterOtp", session.getAttribute("registerOtpEmail") != null);
            request.setAttribute("activeAuthTab", "register");
            request.getRequestDispatcher("/07-dang-nhap-xac-thuc.jsp").forward(request, response);
            return;
        }

        try {
            if (authService.emailExists(email)) {
                request.setAttribute("registerError", "Email này đã được đăng ký.");
                request.setAttribute("registerNameValue", fullName);
                request.setAttribute("registerEmailValue", email);
                request.setAttribute("showRegisterOtp", session.getAttribute("registerOtpEmail") != null);
                request.setAttribute("activeAuthTab", "register");
                request.getRequestDispatcher("/07-dang-nhap-xac-thuc.jsp").forward(request, response);
                return;
            }
        } catch (IllegalStateException e) {
            request.setAttribute("registerError", e.getMessage());
            request.setAttribute("registerNameValue", fullName);
            request.setAttribute("registerEmailValue", email);
            request.setAttribute("showRegisterOtp", session.getAttribute("registerOtpEmail") != null);
            request.setAttribute("activeAuthTab", "register");
            request.getRequestDispatcher("/07-dang-nhap-xac-thuc.jsp").forward(request, response);
            return;
        }

        if ("sendOtp".equals(action)) {
            String newOtp = generateOtp();
            session.setAttribute("registerOtp", newOtp);
            session.setAttribute("registerOtpEmail", email.trim());
            session.setAttribute("registerOtpExpiresAt", System.currentTimeMillis() + OTP_TTL_MILLIS);
            session.setAttribute(PENDING_REGISTER_PASSWORD, registerPassword);

            boolean sent = service.EmailService.sendOtpEmail(email.trim(), newOtp);
            session.setAttribute("authMessage", sent
                    ? "Đã gửi mã OTP tới email của bạn."
                    : "Chưa cấu hình SMTP nên mã OTP đang được in trong console server.");
            request.setAttribute("registerNameValue", fullName);
            request.setAttribute("registerEmailValue", email);
            request.setAttribute("showRegisterOtp", true);
            request.setAttribute("activeAuthTab", "register");
            request.getRequestDispatcher("/07-dang-nhap-xac-thuc.jsp").forward(request, response);
            return;
        }

        if (!isRegisterOtpValid(session, email, otp)) {
            request.setAttribute("registerError", "Mã OTP không đúng hoặc đã hết hạn. Vui lòng gửi lại mã.");
            request.setAttribute("registerNameValue", fullName);
            request.setAttribute("registerEmailValue", email);
            request.setAttribute("showRegisterOtp", true);
            request.setAttribute("activeAuthTab", "register");
            request.getRequestDispatcher("/07-dang-nhap-xac-thuc.jsp").forward(request, response);
            return;
        }

        authService.register(fullName, email, registerPassword);
        User user = authService.checkLogin(email, registerPassword);

        session.removeAttribute("registerOtp");
        session.removeAttribute("registerOtpEmail");
        session.removeAttribute("registerOtpExpiresAt");
        session.removeAttribute(PENDING_REGISTER_PASSWORD);
        session.setAttribute("user", user);
        session.setAttribute("authMessage", "Tạo tài khoản thành công!");
        response.sendRedirect(request.getContextPath() + "/08-ho-so-ca-nhan.jsp");
    }

    private String resolveRegisterPassword(HttpSession session, String submittedPassword) {
        if (submittedPassword != null && !submittedPassword.trim().isEmpty()) {
            return submittedPassword;
        }

        Object pendingPassword = session.getAttribute(PENDING_REGISTER_PASSWORD);
        return pendingPassword instanceof String ? (String) pendingPassword : submittedPassword;
    }

    private String validateRegister(String fullName, String email, String password) {
        if (fullName == null || fullName.trim().isEmpty()) {
            return "Vui lòng nhập họ và tên.";
        }

        if (fullName.trim().length() > 100) {
            return "Họ và tên không được vượt quá 100 ký tự.";
        }

        if (!fullName.trim().matches("^[\\p{L}\\s'-]+$")) {
            return "Họ và tên không được chứa số hoặc ký tự đặc biệt.";
        }

        if (!DataValidator.isEmailValid(email)) {
            return "Định dạng email không hợp lệ.";
        }

        if (!DataValidator.isPasswordValid(password)) {
            return DataValidator.getPasswordRuleMessage();
        }

        return null;
    }

    private String generateOtp() {
        return String.format("%06d", random.nextInt(1_000_000));
    }

    private boolean isRegisterOtpValid(HttpSession session, String email, String otp) {
        String expectedOtp = (String) session.getAttribute("registerOtp");
        String expectedEmail = (String) session.getAttribute("registerOtpEmail");
        Long expiresAt = (Long) session.getAttribute("registerOtpExpiresAt");

        return expectedOtp != null
                && expectedEmail != null
                && expiresAt != null
                && System.currentTimeMillis() <= expiresAt
                && expectedEmail.equalsIgnoreCase(email.trim())
                && expectedOtp.equals(otp != null ? otp.trim() : "");
    }
}
