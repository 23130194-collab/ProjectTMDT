package controller;

import dao.ReviewDAO;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;

@WebServlet(name = "ReviewServlet", urlPatterns = {"/submit-review"})
public class ReviewServlet extends HttpServlet {
    private final ReviewDAO reviewDAO = new ReviewDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        User currentUser = session != null ? (User) session.getAttribute("user") : null;

        if (currentUser == null) {
            sendResponse(request, response, false, "Vui lòng đăng nhập để đánh giá người bán.", "07-dang-nhap-xac-thuc.jsp");
            return;
        }

        int orderId = parseInt(request.getParameter("orderId"));
        int rating = parseInt(request.getParameter("rating"));
        String comment = request.getParameter("comment");

        if (orderId <= 0) {
            sendResponse(request, response, false, "Mã đơn hàng không hợp lệ.", "05-quan-ly-don-hang.jsp");
            return;
        }

        if (rating < 1 || rating > 5) {
            rating = 5; // Mặc định 5 sao nếu gửi không hợp lệ
        }

        // Kiểm duyệt từ khóa cấm trong nhận xét đánh giá
        service.ModerationService moderationService = new service.ModerationService();
        String violation = moderationService.findViolation(comment);
        if (violation != null) {
            sendResponse(request, response, false,
                    "Nội dung nhận xét chứa từ ngữ bị cấm: \"" + violation + "\". Vui lòng xóa bỏ từ này và gửi lại.",
                    "05-quan-ly-don-hang.jsp?orderId=" + orderId);
            return;
        }

        boolean success = reviewDAO.addReview(orderId, currentUser.getId(), rating, comment);
        if (success) {
            sendResponse(request, response, true,
                    "Cảm ơn bạn đã gửi đánh giá " + rating + " sao! Đánh giá đã được ghi nhận vào hồ sơ người bán.",
                    "05-quan-ly-don-hang.jsp?orderId=" + orderId);
        } else {
            sendResponse(request, response, false,
                    "Không thể gửi đánh giá. Lưu ý: Chỉ người mua của đơn hàng đã hoàn tất mới được đánh giá và mỗi đơn chỉ đánh giá 1 lần.",
                    "05-quan-ly-don-hang.jsp?orderId=" + orderId);
        }
    }

    private int parseInt(String value) {
        try {
            return value == null ? 0 : Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    private void sendResponse(HttpServletRequest request, HttpServletResponse response, boolean success, String message, String redirectUrl) throws IOException {
        String xRequestedWith = request.getHeader("X-Requested-With");
        boolean isAjax = "XMLHttpRequest".equalsIgnoreCase(xRequestedWith) || "application/json".equals(request.getContentType());

        if (isAjax) {
            response.setContentType("application/json;charset=UTF-8");
            response.setCharacterEncoding("UTF-8");
            PrintWriter out = response.getWriter();
            out.write("{\"success\":" + success + ",\"message\":\"" + escapeJson(message) + "\"" +
                    (redirectUrl != null ? ",\"redirectUrl\":\"" + escapeJson(redirectUrl) + "\"" : "") + "}");
        } else {
            HttpSession session = request.getSession(true);
            session.setAttribute("orderFlashMessage", message);
            session.setAttribute("orderFlashSuccess", success);
            response.sendRedirect(redirectUrl != null ? redirectUrl : "05-quan-ly-don-hang.jsp");
        }
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "");
    }
}
