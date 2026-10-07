package controller;

import model.User;
import service.AuthService;
import util.DataValidator;
import util.MD5;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
@WebServlet(name = "ChangePasswordServlet", value = "/change-password")
public class ChangePasswordServlet extends HttpServlet {
    private static final String PROFILE_PAGE = "/08-ho-so-ca-nhan.jsp";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        User userInSession = (User) session.getAttribute("user");

        if (userInSession == null) {
            response.sendRedirect(request.getContextPath() + "/07-dang-nhap-xac-thuc.jsp");
            return;
        }

        String oldPassword = request.getParameter("oldPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        if (isBlank(oldPassword)) {
            forwardWithError(request, response, "oldPassword_error", "Vui lòng nhập mật khẩu hiện tại.");
            return;
        }

        if (isBlank(newPassword)) {
            forwardWithError(request, response, "newPassword_error", "Vui lòng nhập mật khẩu mới.");
            return;
        }

        if (isBlank(confirmPassword)) {
            forwardWithError(request, response, "confirmPassword_error", "Vui lòng nhập lại mật khẩu mới.");
            return;
        }

        AuthService authService = new AuthService();
        User userFromDb = authService.getUserByEmail(userInSession.getEmail());

        if (userFromDb == null || !matchesPassword(userFromDb.getPassword(), oldPassword)) {
            forwardWithError(request, response, "oldPassword_error", "Mật khẩu hiện tại không chính xác.");
            return;
        }

        if (!DataValidator.isPasswordValid(newPassword)) {
            forwardWithError(request, response, "newPassword_error", DataValidator.getPasswordRuleMessage());
            return;
        }

        if (matchesPassword(userFromDb.getPassword(), newPassword)) {
            forwardWithError(request, response, "newPassword_error", "Mật khẩu mới không được trùng với mật khẩu hiện tại.");
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            forwardWithError(request, response, "confirmPassword_error", "Mật khẩu xác nhận không khớp.");
            return;
        }

        authService.updatePassword(userInSession.getEmail(), newPassword);

        User updatedUser = authService.getUserByEmail(userInSession.getEmail());
        session.setAttribute("user", updatedUser);

        session.setAttribute("changePassSuccess", "Đổi mật khẩu thành công!");
        response.sendRedirect(request.getContextPath() + PROFILE_PAGE);
    }

    private boolean matchesPassword(String storedPassword, String rawPassword) {
        if (storedPassword == null || rawPassword == null) {
            return false;
        }

        return storedPassword.equals(MD5.hash(rawPassword)) || storedPassword.equals(rawPassword);
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    private void forwardWithError(HttpServletRequest request, HttpServletResponse response, String attributeName, String message)
            throws ServletException, IOException {
        request.setAttribute(attributeName, message);
        request.getRequestDispatcher(PROFILE_PAGE).forward(request, response);
    }
}
