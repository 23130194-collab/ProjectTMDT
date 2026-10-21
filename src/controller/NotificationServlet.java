package controller;

import dao.NotificationDAO;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;

@WebServlet(name = "NotificationServlet", urlPatterns = {"/mark-notification-read", "/notifications-api"})
public class NotificationServlet extends HttpServlet {
    private final NotificationDAO notificationDAO = new NotificationDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        processRequest(request, response);
    }

    private void processRequest(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession(false);
        User currentUser = session != null ? (User) session.getAttribute("user") : null;
        if (currentUser == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.write("{\"success\":false,\"message\":\"Chưa đăng nhập\"}");
            return;
        }

        String action = request.getParameter("action");
        String idParam = request.getParameter("id");

        boolean success = false;
        if ("read_all".equalsIgnoreCase(action)) {
            success = notificationDAO.markAllAsRead(currentUser.getId());
        } else if (idParam != null && !idParam.trim().isEmpty()) {
            try {
                int notifId = Integer.parseInt(idParam.trim());
                success = notificationDAO.markAsRead(notifId, currentUser.getId());
            } catch (NumberFormatException e) {
                success = false;
            }
        }

        int unreadCount = notificationDAO.countUnreadNotifications(currentUser.getId());
        out.write("{\"success\":" + success + ",\"unreadCount\":" + unreadCount + "}");
    }
}
