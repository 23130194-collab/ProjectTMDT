package controller;

import dao.OrderDAO;
import model.OrderSummary;
import model.User;
import service.GhnApiService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Random;

@WebServlet(name = "OrderActionServlet", urlPatterns = {"/order-action", "/ghn-simulator"})
public class OrderActionServlet extends HttpServlet {
    private final OrderDAO orderDAO = new OrderDAO();
    private final GhnApiService ghnApiService = new GhnApiService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String servletPath = request.getServletPath();
        if ("/ghn-simulator".equals(servletPath)) {
            handleGhnSimulator(request, response);
            return;
        }
        doPost(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        User currentUser = getSessionUser(request);
        if (currentUser == null) {
            sendResponse(request, response, false, "Vui lòng đăng nhập để thực hiện thao tác này.", null);
            return;
        }

        String action = request.getParameter("action");
        int orderId = parseInt(request.getParameter("orderId"));
        if (orderId <= 0) {
            sendResponse(request, response, false, "Mã đơn hàng không hợp lệ.", null);
            return;
        }

        OrderSummary order = orderDAO.getOrderSummaryById(orderId);
        if (order == null) {
            sendResponse(request, response, false, "Không tìm thấy thông tin đơn hàng.", null);
            return;
        }

        // Kiểm tra quyền: Người dùng phải là người mua hoặc người bán của đơn hàng
        boolean isBuyer = order.buyerId == currentUser.getId();
        boolean isSeller = order.sellerId == currentUser.getId();
        if (!isBuyer && !isSeller) {
            sendResponse(request, response, false, "Bạn không có quyền thao tác trên đơn hàng này.", null);
            return;
        }

        if ("confirm_delivery".equalsIgnoreCase(action)) {
            // Người bán xác nhận đã giao hàng trực tiếp
            if (!isSeller) {
                sendResponse(request, response, false, "Chỉ Người Bán mới có thể xác nhận đã giao hàng.", null);
                return;
            }
            boolean ok = orderDAO.confirmDirectDeliveryBySeller(orderId, currentUser.getId());
            if (ok) {
                sendResponse(request, response, true, "Xác nhận đã giao hàng thành công! Đang chờ người mua kiểm tra và xác nhận nhận hàng.", "05-quan-ly-don-hang.jsp?orderId=" + orderId);
            } else {
                sendResponse(request, response, false, "Không thể cập nhật trạng thái đơn hàng. Vui lòng thử lại.", null);
            }
        } else if ("confirm_receipt".equalsIgnoreCase(action)) {
            // Người mua xác nhận đã nhận hàng (Trực tiếp hoặc GHN)
            if (!isBuyer) {
                sendResponse(request, response, false, "Chỉ Người Mua mới có thể xác nhận đã nhận hàng.", null);
                return;
            }

            // KIỂM TRA ĐIỀU KIỆN QUY TRÌNH:
            if (order.deliveryMethod == 1) {
                // 1. Gặp mặt trực tiếp: Phải chờ người bán bấm "Xác nhận đã giao hàng" trước
                if (!order.sellerConfirmed) {
                    sendResponse(request, response, false,
                            "Bạn chưa thể xác nhận nhận hàng. Vui lòng gặp người bán tại điểm hẹn và chờ Người Bán bấm \"Xác nhận đã giao hàng\" trước!",
                            "05-quan-ly-don-hang.jsp?orderId=" + orderId);
                    return;
                }
            } else if (order.deliveryMethod == 2) {
                // 2. Giao tận nhà qua GHN: Phải chờ bưu tá giao hàng thành công (DA_GIAO) trước
                if (!"DA_GIAO".equalsIgnoreCase(order.shippingStatus)) {
                    sendResponse(request, response, false,
                            "Bạn chưa thể xác nhận nhận hàng. Đơn hàng GHN phải ở trạng thái \"Bưu tá đã giao hàng thành công\" thì bạn mới được bấm xác nhận!",
                            "05-quan-ly-don-hang.jsp?orderId=" + orderId);
                    return;
                }
            }

            boolean ok = orderDAO.confirmReceiptByBuyer(orderId, currentUser.getId());
            if (ok) {
                sendResponse(request, response, true, "Xác nhận nhận hàng thành công! Đơn hàng đã hoàn tất, tiền cọc đã được chuyển cho Người Bán.", "05-quan-ly-don-hang.jsp?orderId=" + orderId);
            } else {
                sendResponse(request, response, false, "Không thể cập nhật trạng thái đơn hàng. Vui lòng thử lại.", null);
            }
        } else if ("ghn_create".equalsIgnoreCase(action)) {
            // Người bán tạo đơn vận chuyển qua GHN
            if (!isSeller) {
                sendResponse(request, response, false, "Chỉ Người Bán mới có thể tạo vận đơn GHN.", null);
                return;
            }
            String note = request.getParameter("shippingNote");
            if (note == null || note.trim().isEmpty()) {
                note = "Cho xem hàng, không cho thử";
            }

            String trackingCode = request.getParameter("trackingCode");
            String createMode = request.getParameter("createMode"); // "sandbox_api" hoặc "simulator"

            // Nếu người dùng chọn gọi Sandbox API hoặc đã cấu hình Token
            if ("sandbox_api".equalsIgnoreCase(createMode) || (ghnApiService.isConfigured() && !"simulator".equalsIgnoreCase(createMode))) {
                try {
                    double codAmount = Math.max(0, order.agreedPrice - order.depositAmount);
                    trackingCode = ghnApiService.createOrder(
                            order.sellerName,
                            order.sellerPhone,
                            order.sellerAddress,
                            order.buyerName,
                            order.buyerPhone,
                            order.buyerAddress,
                            order.productTitle,
                            codAmount,
                            note
                    );
                } catch (Exception e) {
                    getServletContext().log("Lỗi gọi API GHN Sandbox: " + e.getMessage(), e);
                    sendResponse(request, response, false, "Lỗi tạo đơn qua GHN Sandbox API: " + e.getMessage(), "ghn-simulator?orderId=" + orderId);
                    return;
                }
            } else {
                if (trackingCode == null || trackingCode.trim().isEmpty()) {
                    trackingCode = generateGhnTrackingCode();
                }
            }

            boolean ok = orderDAO.createGhnShipment(orderId, currentUser.getId(), trackingCode, note);
            if (ok) {
                sendResponse(request, response, true, "Tạo đơn vận chuyển GHN thành công! Mã vận đơn: " + trackingCode, "05-quan-ly-don-hang.jsp?orderId=" + orderId);
            } else {
                sendResponse(request, response, false, "Không thể tạo vận đơn GHN. Vui lòng thử lại.", null);
            }
        } else if ("ghn_sync_status".equalsIgnoreCase(action)) {
            // Đồng bộ trạng thái đơn hàng trực tiếp từ GHN Sandbox API
            if (order.trackingCode == null || order.trackingCode.trim().isEmpty()) {
                sendResponse(request, response, false, "Đơn hàng này chưa có mã vận đơn GHN để đồng bộ.", null);
                return;
            }
            if (!ghnApiService.isConfigured()) {
                sendResponse(request, response, false, "Chưa cấu hình GHN API Token. Vui lòng kiểm tra GhnApiService.", "ghn-simulator?orderId=" + orderId);
                return;
            }
            try {
                GhnApiService.GhnDetailResult detail = ghnApiService.queryOrderShippingStatus(order.trackingCode);
                if (detail.success && detail.internalStatus != null) {
                    boolean statusChanged = !detail.internalStatus.equalsIgnoreCase(order.shippingStatus) ||
                            ("CANCELLED".equalsIgnoreCase(detail.internalStatus) && !"CANCELLED".equalsIgnoreCase(order.status));
                    boolean ok = orderDAO.updateGhnShippingStatus(orderId, detail.internalStatus, detail.cancelReason);
                    if (ok) {
                        String flashMsg = "CANCELLED".equalsIgnoreCase(detail.internalStatus)
                                ? "Đơn hàng #" + orderId + " đã bị HỦY trên GHN Express. Lý do: " + detail.cancelReason
                                : "Đã đồng bộ trạng thái mới từ GHN Sandbox: " + detail.statusDescription;
                        if ("true".equalsIgnoreCase(request.getParameter("ajax")) || "XMLHttpRequest".equalsIgnoreCase(request.getHeader("X-Requested-With"))) {
                            response.setContentType("application/json;charset=UTF-8");
                            response.getWriter().write("{\"success\":true,\"statusChanged\":" + statusChanged + ",\"newStatus\":\"" + detail.internalStatus + "\",\"message\":\"" + escapeJson(flashMsg) + "\"}");
                            return;
                        }
                        sendResponse(request, response, true, flashMsg, "05-quan-ly-don-hang.jsp?orderId=" + orderId);
                    } else {
                        sendResponse(request, response, false, "Không thể cập nhật database với trạng thái GHN mới.", null);
                    }
                } else {
                    sendResponse(request, response, false, "Lỗi tra cứu từ GHN Sandbox: " + (detail.errorMessage != null ? detail.errorMessage : "Không xác định"), null);
                }
            } catch (Exception e) {
                getServletContext().log("Lỗi đồng bộ GHN Sandbox API: " + e.getMessage(), e);
                sendResponse(request, response, false, "Lỗi kết nối GHN Sandbox: " + e.getMessage(), null);
            }
        } else if ("ghn_update_status".equalsIgnoreCase(action)) {
            // Cập nhật trạng thái GHN (Sandbox test) - Người mua không được phép tự cập nhật
            if (isBuyer) {
                sendResponse(request, response, false, "Người Mua không có quyền tự cập nhật trạng thái vận đơn GHN.", null);
                return;
            }
            String newStatus = request.getParameter("shippingStatus");
            if (newStatus == null || newStatus.trim().isEmpty()) {
                sendResponse(request, response, false, "Trạng thái vận chuyển không hợp lệ.", null);
                return;
            }
            String cancelReason = request.getParameter("cancelReason");
            if ("CANCELLED".equalsIgnoreCase(newStatus) && (cancelReason == null || cancelReason.trim().isEmpty())) {
                cancelReason = "Người bán đã chủ động hủy vận đơn giao hàng.";
            }
            boolean ok = orderDAO.updateGhnShippingStatus(orderId, newStatus, cancelReason);
            if (ok) {
                String flashMsg = "CANCELLED".equalsIgnoreCase(newStatus)
                        ? "Đã hủy đơn vận chuyển GHN thành công!"
                        : "Đã cập nhật trạng thái vận đơn GHN thành công!";
                sendResponse(request, response, true, flashMsg, "05-quan-ly-don-hang.jsp?orderId=" + orderId);
            } else {
                sendResponse(request, response, false, "Không thể cập nhật trạng thái GHN.", null);
            }
        } else {
            sendResponse(request, response, false, "Thao tác không được hỗ trợ.", null);
        }
    }

    private void handleGhnSimulator(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User currentUser = getSessionUser(request);
        if (currentUser == null) {
            response.sendRedirect("07-dang-nhap-xac-thuc.jsp");
            return;
        }

        int orderId = parseInt(request.getParameter("orderId"));
        OrderSummary order = orderId > 0 ? orderDAO.getOrderSummaryById(orderId) : null;
        if (order == null) {
            response.sendRedirect("05-quan-ly-don-hang.jsp");
            return;
        }

        // Tự động kiểm tra và đồng bộ trạng thái mới nhất từ GHN Sandbox nếu đã có mã vận đơn
        if (order.trackingCode != null && !order.trackingCode.trim().isEmpty() && ghnApiService.isConfigured()) {
            try {
                GhnApiService.GhnDetailResult detail = ghnApiService.queryOrderShippingStatus(order.trackingCode);
                if (detail.success && detail.internalStatus != null && !detail.internalStatus.equalsIgnoreCase(order.shippingStatus)) {
                    orderDAO.updateGhnShippingStatus(order.id, detail.internalStatus, detail.cancelReason);
                    order = orderDAO.getOrderSummaryById(order.id);
                }
            } catch (Exception e) {
                getServletContext().log("Không thể tự động đồng bộ GHN khi xem lộ trình: " + e.getMessage());
            }
        }

        request.setAttribute("order", order);
        request.setAttribute("currentUser", currentUser);
        request.setAttribute("suggestedTrackingCode", generateGhnTrackingCode());
        request.getRequestDispatcher("/ghn-simulator.jsp").forward(request, response);
    }

    private String generateGhnTrackingCode() {
        Random rand = new Random();
        int digits = 10000000 + rand.nextInt(90000000);
        return "GHN" + digits + "VN";
    }

    private User getSessionUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session != null && session.getAttribute("user") instanceof User ? (User) session.getAttribute("user") : null;
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
            if (redirectUrl != null) {
                HttpSession session = request.getSession(true);
                session.setAttribute("orderFlashMessage", message);
                session.setAttribute("orderFlashSuccess", success);
                response.sendRedirect(redirectUrl);
            } else {
                HttpSession session = request.getSession(true);
                session.setAttribute("orderFlashMessage", message);
                session.setAttribute("orderFlashSuccess", success);
                response.sendRedirect("05-quan-ly-don-hang.jsp");
            }
        }
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "");
    }
}
