package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import service.AuthService;
import service.GoogleOAuthService;
import service.GoogleOAuthService.GoogleUserInfo;

import java.io.IOException;
import java.util.UUID;

@WebServlet(name = "LoginGoogle", value = "/login-google")
public class LoginGoogle extends HttpServlet {

    private final AuthService authService = new AuthService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();

        String code = request.getParameter("code");
        String error = request.getParameter("error");

        // 1. Trường hợp người dùng hủy / Google báo lỗi
        if (error != null) {
            session.setAttribute("authMessage", "Đăng nhập Google không thành công: " + error);
            response.sendRedirect(request.getContextPath() + "/07-dang-nhap-xac-thuc.jsp");
            return;
        }

        // 2. Chưa có code -> Bắt đầu luồng OAuth: chuyển hướng sang Google
        if (code == null || code.trim().isEmpty()) {
            String state = UUID.randomUUID().toString();
            session.setAttribute("oauth_state", state);

            String authUrl = GoogleOAuthService.buildAuthorizationUrl(state);
            response.sendRedirect(authUrl);
            return;
        }

        // 3. Đã có code -> Google gọi lại (Callback)
        String state = request.getParameter("state");
        String sessionState = (String) session.getAttribute("oauth_state");
        session.removeAttribute("oauth_state"); // dùng 1 lần

        if (sessionState == null || !sessionState.equals(state)) {
            session.setAttribute("authMessage", "Yêu cầu không hợp lệ hoặc đã hết hạn (CSRF detected). Vui lòng thử lại.");
            response.sendRedirect(request.getContextPath() + "/07-dang-nhap-xac-thuc.jsp");
            return;
        }

        try {
            // Đổi authorization code lấy access token
            String accessToken = GoogleOAuthService.exchangeCodeForAccessToken(code);

            // Lấy thông tin user từ Google
            GoogleUserInfo userInfo = GoogleOAuthService.getUserInfo(accessToken);

            if (userInfo.getEmail() == null || userInfo.getEmail().trim().isEmpty()) {
                session.setAttribute("authMessage", "Không thể lấy email từ tài khoản Google của bạn.");
                response.sendRedirect(request.getContextPath() + "/07-dang-nhap-xac-thuc.jsp");
                return;
            }

            // Tìm hoặc tạo tài khoản mới từ thông tin Google
            User user = authService.findOrCreateGoogleUser(
                    userInfo.getEmail(),
                    userInfo.getName(),
                    userInfo.getPicture()
            );

            // Kiểm tra trạng thái tài khoản
            if (authService.isLocked(user)) {
                session.setAttribute("authMessage", "Tài khoản của bạn đã bị khóa. Vui lòng liên hệ hỗ trợ.");
                response.sendRedirect(request.getContextPath() + "/07-dang-nhap-xac-thuc.jsp");
                return;
            }

            // Đăng nhập thành công -> lưu session
            session.setAttribute("currentUser", user);
            session.setAttribute("successMessage", "Đăng nhập bằng Google thành công! Xin chào " + user.getFullName());

            response.sendRedirect(request.getContextPath() + "/home");

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("authMessage", "Đăng nhập Google thất bại: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/07-dang-nhap-xac-thuc.jsp");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
