package controller;

import dao.ChatDAO;
import model.User;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/chat-unread-count")
public class ChatUnreadCountServlet extends HttpServlet {
    private final ChatDAO chatDAO = new ChatDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");
        HttpSession session = request.getSession(false);
        User user = session != null && session.getAttribute("user") instanceof User
                ? (User) session.getAttribute("user") : null;
        if (user == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"success\":false,\"count\":0}");
            return;
        }
        int count = chatDAO.countUnreadMessages(user.getId());
        response.getWriter().write("{\"success\":true,\"count\":" + count + "}");
    }
}
