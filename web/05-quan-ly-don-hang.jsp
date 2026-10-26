<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%@ page import="dao.OrderDAO" %>
<%@ page import="model.OrderSummary" %>
<%@ page import="dao.ReviewDAO" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Locale" %>
<%!
  private String h(String value) {
    if (value == null) {
      return "";
    }
    return value
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;")
            .replace("'", "&#39;");
  }

  private String orderStatusText(String status) {
    if ("DEPOSITED".equalsIgnoreCase(status) || "DEPOSIT_CONFIRMED".equalsIgnoreCase(status)) return "Đang giữ cọc";
    if ("DEPOSIT_PENDING".equalsIgnoreCase(status)) return "Chờ xác nhận cọc";
    if ("SHIPPING".equalsIgnoreCase(status)) return "Đang giao hàng / kiểm tra";
    if ("COMPLETED".equalsIgnoreCase(status)) return "Đã hoàn tất";
    if ("CANCELLED".equalsIgnoreCase(status) || "CANCELED".equalsIgnoreCase(status)) return "Đã hủy";
    if ("DISPUTED".equalsIgnoreCase(status)) return "Đang khiếu nại";
    return "Đang thương lượng";
  }

  private String orderBadgeClass(String status) {
    if ("COMPLETED".equalsIgnoreCase(status)) return "text-xs text-green-700 font-bold bg-green-50 px-3 py-1 rounded-full border border-green-200";
    if ("CANCELLED".equalsIgnoreCase(status) || "DISPUTED".equalsIgnoreCase(status)) return "text-xs text-red-700 font-bold bg-red-50 px-3 py-1 rounded-full border border-red-200";
    if ("SHIPPING".equalsIgnoreCase(status)) return "text-xs text-blue-700 font-bold bg-blue-50 px-3 py-1 rounded-full border border-blue-200";
    return "text-xs text-amber-700 font-bold bg-amber-50 px-3 py-1 rounded-full border border-amber-200";
  }
%>
<%
  User ordersCurrentUser = (User) session.getAttribute("user");
  boolean ordersLoggedIn = ordersCurrentUser != null;
  OrderDAO orderDAO = new OrderDAO();
  ReviewDAO reviewDAO = new ReviewDAO();
  List<OrderSummary> accountOrders = ordersLoggedIn
          ? orderDAO.getOrderSummariesForUser(ordersCurrentUser.getId())
          : java.util.Collections.emptyList();
  NumberFormat moneyFormat = NumberFormat.getInstance(new Locale("vi", "VN"));
  java.text.SimpleDateFormat orderDateFormat = new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm");
  int accountOrderCount = accountOrders.size();
  int accountChannel1Count = 0; // Hẹn gặp trực tiếp
  int accountChannel2Count = 0; // Giao tận nhà GHN
  int accountBuyCount = 0;
  int accountSellCount = 0;
  double accountEscrowTotal = 0;
  for (OrderSummary item : accountOrders) {
    if (item.buyerId == ordersCurrentUser.getId()) accountBuyCount++;
    if (item.sellerId == ordersCurrentUser.getId()) accountSellCount++;
    if (item.deliveryMethod == 2) accountChannel2Count++;
    else accountChannel1Count++;
    accountEscrowTotal += item.depositAmount;
  }

  // Lấy Flash message nếu có
  String flashMsg = (String) session.getAttribute("orderFlashMessage");
  Boolean flashSuccess = (Boolean) session.getAttribute("orderFlashSuccess");
  if (flashMsg != null) {
    session.removeAttribute("orderFlashMessage");
    session.removeAttribute("orderFlashSuccess");
  }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Quản Lý Đơn Hàng & Ký Quỹ Bảo Đảm - MuaNgay</title>
  <link rel="icon" type="image/svg+xml" href="assets/logos/muangay-logo-icon.svg">
  <script src="https://cdn.tailwindcss.com"></script>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="css/style.css">
  <link rel="stylesheet" href="css/05-quan-ly-don-hang.css">
</head>
<body class="bg-slate-50 text-slate-900 min-h-screen flex flex-col">

  <!-- THANH ĐIỀU HƯỚNG CHÍNH -->
  <jsp:include page="includes/header.jsp" />

  <!-- NỘI DUNG CHÍNH: TRUNG TÂM QUẢN LÝ ĐƠN HÀNG KÊNH 1 & KÊNH 2 -->
  <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 flex-1 w-full space-y-6 relative">
    
    <!-- THÔNG BÁO FLASH MESSAGE (KHI XÁC NHẬN / TẠO GHN THÀNH CÔNG) -->
    <% if (flashMsg != null) { %>
    <div id="flash-alert-banner" class="p-4 rounded-xl <%= Boolean.TRUE.equals(flashSuccess) ? "bg-green-50 border border-green-200 text-green-800" : "bg-red-50 border border-red-200 text-red-800" %> flex items-center justify-between shadow-xs transition-all duration-500 ease-in-out">
      <div class="flex items-center gap-2.5 text-xs font-semibold">
        <span><%= Boolean.TRUE.equals(flashSuccess) ? "✓" : "✕" %></span>
        <span><%= h(flashMsg) %></span>
      </div>
      <button onclick="dismissFlashAlert()" class="text-xs font-bold text-slate-400 hover:text-slate-600 cursor-pointer p-1">✕</button>
    </div>
    <script>
      function dismissFlashAlert() {
        var el = document.getElementById('flash-alert-banner');
        if (el) {
          el.style.opacity = '0';
          el.style.transform = 'translateY(-8px)';
          setTimeout(function() {
            if (el && el.parentNode) el.parentNode.removeChild(el);
          }, 500);
        }
      }
      // Tự động biến mất sau 5 giây mà không cần người dùng tự tắt
      setTimeout(dismissFlashAlert, 5000);
    </script>
    <% } %>

    <!-- TIÊU ĐỀ TRANG VÀ GIẢI THÍCH MÔ HÌNH BẢO CHỨNG -->
    <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-3 pb-4 border-b border-slate-200">
      <div>
        <h1 class="text-xl sm:text-2xl font-bold text-slate-900">Quản Lý Đơn Hàng & Trạng Thái Giữ Tiền An Toàn</h1>
        <p class="text-xs text-slate-500 mt-1">
          <%= ordersLoggedIn
                  ? "Theo dõi và cập nhật trạng thái đơn hàng (Giao trực tiếp & Giao qua GHN Express)."
                  : "Theo dõi 4 đơn hàng demo: 2 đơn Hẹn gặp trực tiếp và 2 đơn Giao tận nhà qua bưu điện." %>
        </p>
      </div>

      <div class="flex flex-wrap items-center gap-2 text-xs">
        <span class="px-3 py-1 bg-green-50 text-green-700 border border-green-200 rounded-lg font-bold">
          Tổng Tiền Đang Được Sàn Giữ An Toàn: <%= ordersLoggedIn ? moneyFormat.format(Math.round(accountEscrowTotal)) + " đ" : "29.850.000 đ" %>
        </span>
      </div>
    </div>

    <!-- TABS BỘ LỌC ĐƠN HÀNG: TẤT CẢ, HẸN GẶP, GIAO TẬN NHÀ, ĐƠN MUA, ĐƠN BÁN -->
    <% if (ordersLoggedIn) { %>
    <div class="flex flex-wrap items-center gap-2 border-b border-slate-200 pb-3 text-xs font-semibold">
      <button onclick="filterOrders('all')" id="btnFilterAll" class="px-3.5 py-2 rounded-lg bg-blue-600 text-white transition shadow-xs">
        Tất Cả (<%= accountOrderCount %> Đơn)
      </button>
      <button onclick="filterOrders('channel1')" id="btnFilterChannel1" class="px-3.5 py-2 rounded-lg bg-white border border-slate-300 text-slate-700 hover:bg-slate-50 transition">
        Hẹn Gặp Trực Tiếp (<%= accountChannel1Count %> Đơn)
      </button>
      <button onclick="filterOrders('channel2')" id="btnFilterChannel2" class="px-3.5 py-2 rounded-lg bg-white border border-slate-300 text-slate-700 hover:bg-slate-50 transition">
        Giao Tận Nhà (GHN) (<%= accountChannel2Count %> Đơn)
      </button>
      <button onclick="filterOrders('buy')" id="btnFilterBuy" class="px-3.5 py-2 rounded-lg bg-white border border-slate-300 text-slate-700 hover:bg-slate-50 transition">
        Đơn Tôi Mua (<%= accountBuyCount %> Đơn)
      </button>
      <button onclick="filterOrders('sell')" id="btnFilterSell" class="px-3.5 py-2 rounded-lg bg-white border border-slate-300 text-slate-700 hover:bg-slate-50 transition">
        Đơn Tôi Bán (<%= accountSellCount %> Đơn)
      </button>
    </div>
    <% } else { %>
    <div class="flex flex-wrap items-center gap-2 border-b border-slate-200 pb-3 text-xs font-semibold">
      <button onclick="filterOrders('all')" id="btnFilterAll" class="px-3.5 py-2 rounded-lg bg-blue-600 text-white transition shadow-xs">
        Tất Cả (4 Đơn Hàng)
      </button>
      <button onclick="filterOrders('channel1')" id="btnFilterChannel1" class="px-3.5 py-2 rounded-lg bg-white border border-slate-300 text-slate-700 hover:bg-slate-50 transition">
        Hẹn Gặp Trực Tiếp (2 Đơn)
      </button>
      <button onclick="filterOrders('channel2')" id="btnFilterChannel2" class="px-3.5 py-2 rounded-lg bg-white border border-slate-300 text-slate-700 hover:bg-slate-50 transition">
        Giao Tận Nhà Dùng Thử 48H (2 Đơn)
      </button>
      <button onclick="filterOrders('buy')" id="btnFilterBuy" class="px-3.5 py-2 rounded-lg bg-white border border-slate-300 text-slate-700 hover:bg-slate-50 transition">
        Đơn Tôi Mua (2 Đơn)
      </button>
      <button onclick="filterOrders('sell')" id="btnFilterSell" class="px-3.5 py-2 rounded-lg bg-white border border-slate-300 text-slate-700 hover:bg-slate-50 transition">
        Đơn Tôi Bán (2 Đơn)
      </button>
    </div>
    <% } %>

    <!-- DANH SÁCH ĐƠN HÀNG CHI TIẾT -->
    <div class="space-y-6" id="ordersListContainer">
    <% if (ordersLoggedIn) { %>
      <% if (accountOrders.isEmpty()) { %>
      <div class="bg-white rounded-xl border border-slate-200 shadow-sm p-8 text-center">
        <div class="w-12 h-12 rounded-full bg-slate-100 text-slate-400 flex items-center justify-center mx-auto text-lg font-bold">0</div>
        <h2 class="mt-3 text-sm font-bold text-slate-900">Tài khoản này chưa có đơn hàng</h2>
        <p class="mt-1 text-xs text-slate-500">Khi bạn đặt cọc qua VNPay, mua hàng hoặc bán được sản phẩm, đơn sẽ xuất hiện tại đây.</p>
        <a href="01-trang-chu.jsp" class="inline-flex mt-4 px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white text-xs font-bold rounded-lg transition">
          Về trang chủ
        </a>
      </div>
      <% } else { %>
        <% for (OrderSummary item : accountOrders) {
          boolean mineBuy = item.buyerId == ordersCurrentUser.getId();
          String type = mineBuy ? "buy" : "sell";
          String channel = item.deliveryMethod == 2 ? "channel2" : "channel1";
          String partnerName = mineBuy ? item.sellerName : item.buyerName;
          double remain = Math.max(0, item.agreedPrice - item.depositAmount);
          boolean isDirect = item.deliveryMethod != 2;
          boolean isCompleted = "COMPLETED".equalsIgnoreCase(item.status);
          boolean hasGhnTracking = item.trackingCode != null && !item.trackingCode.trim().isEmpty();
          boolean isOrderCancelled = "CANCELLED".equalsIgnoreCase(item.status) || "CANCELLED".equalsIgnoreCase(item.shippingStatus) || "CANCELED".equalsIgnoreCase(item.status);
        %>
      <div id="order-card-db-<%= item.id %>" data-channel="<%= channel %>" data-type="<%= type %>" data-ghn-active="<%= (!isDirect && hasGhnTracking && !isOrderCancelled && !isCompleted) %>" data-order-id="<%= item.id %>" class="order-card bg-white rounded-xl border <%= isDirect ? "border-amber-200" : "border-orange-200" %> shadow-sm p-5 sm:p-6 space-y-4">
        
        <!-- HEADER ĐƠN HÀNG -->
        <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-2 pb-3 border-b border-slate-100">
          <div class="flex flex-wrap items-center gap-2.5">
            <% if (isDirect) { %>
              <span class="px-2.5 py-0.5 rounded text-[11px] font-bold bg-amber-100 text-amber-800 uppercase tracking-wider flex items-center gap-1">
                <span></span> Hẹn Gặp Trực Tiếp
              </span>
            <% } else { %>
              <span class="px-2.5 py-0.5 rounded text-[11px] font-bold bg-orange-100 text-orange-800 uppercase tracking-wider flex items-center gap-1">
                <span></span> Giao Tận Nhà (GHN Express Demo)
              </span>
            <% } %>

            <span class="px-2 py-0.5 rounded text-[10px] font-bold <%= mineBuy ? "bg-blue-50 text-blue-700 border border-blue-200" : "bg-purple-50 text-purple-700 border border-purple-200" %>">
              <%= mineBuy ? "Tôi Là Người Mua" : "Tôi Là Người Bán" %>
            </span>
            <span class="text-xs font-mono text-slate-400">Mã đơn: #MN-<%= item.id %></span>
            <% if (item.createdAt != null) { %>
              <span class="text-[11px] text-slate-400">• <%= orderDateFormat.format(item.createdAt) %></span>
            <% } %>
          </div>
          <div class="<%= orderBadgeClass(item.status) %>">
            Trạng thái: <%= h(orderStatusText(item.status)) %>
          </div>
        </div>

        <!-- THÔNG TIN SẢN PHẨM & TÀI CHÍNH -->
        <div class="flex flex-col md:flex-row md:items-start justify-between gap-4">
          <div class="flex gap-3.5 items-start">
            <img src="<%= h(item.productImage) %>" alt="<%= h(item.productTitle) %>" class="w-20 h-20 rounded-lg object-cover shrink-0 border border-slate-200">
            <div class="space-y-1">
              <h2 class="font-bold text-sm text-slate-900"><%= h(item.productTitle) %></h2>
              <p class="text-[11px] text-slate-500">
                <%= mineBuy ? "Người bán" : "Người mua" %>: 
                <a href="seller-profile?id=<%= mineBuy ? item.sellerId : item.buyerId %>" class="font-bold text-blue-600 hover:underline inline-flex items-center gap-1" title="Xem hồ sơ và đánh giá">
                  <span><%= h(partnerName) %></span>
                  <svg class="w-3 h-3 text-blue-500 inline" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"/></svg>
                </a>
                <% String partnerPhone = mineBuy ? item.sellerPhone : item.buyerPhone; %>
                <% if (partnerPhone != null && !partnerPhone.isEmpty()) { %>
                  (<%= h(partnerPhone) %>)
                <% } %>
              </p>
              <div class="flex flex-wrap gap-2 text-[11px] pt-1">
                <span class="px-2 py-0.5 rounded bg-slate-100 text-slate-700">Giá gốc: <%= moneyFormat.format(Math.round(item.productPrice)) %> đ</span>
                <span class="px-2 py-0.5 rounded bg-green-50 text-green-700 border border-green-200 font-semibold">Giá chốt: <%= moneyFormat.format(Math.round(item.agreedPrice)) %> đ</span>
              </div>
            </div>
          </div>

          <!-- BOX TIỀN CỌC & THANH TOÁN -->
          <div class="p-3 bg-slate-50 border border-slate-200 rounded-lg text-xs space-y-1 w-full md:w-72 shrink-0">
            <div class="flex justify-between">
              <span class="text-slate-500">Tiền cọc sàn giữ (VNPay):</span>
              <span class="font-bold text-amber-700"><%= moneyFormat.format(Math.round(item.depositAmount)) %> đ</span>
            </div>
            <div class="flex justify-between">
              <span class="text-slate-500"><%= isDirect ? "Tiền mặt thu tại chỗ:" : "Tiền thu hộ COD (GHN):" %></span>
              <span class="font-bold text-slate-900"><%= moneyFormat.format(Math.round(remain)) %> đ</span>
            </div>
            <div class="text-[11px] text-slate-500 pt-1 border-t border-slate-200">
              <% if (isCompleted) { %>
                <span class="text-green-700 font-bold">Tiền cọc đã giải ngân cho Người bán.</span>
              <% } else { %>
                <span class="text-slate-600">Sàn đang bảo chứng tiền cọc 100%.</span>
              <% } %>
            </div>
          </div>
        </div>

        <!-- THÔNG TIN VẬN CHUYỂN / ĐIỂM HẸN THEO PHƯƠNG THỨC -->
        <% if (isDirect) { %>
          <!-- KÊNH 1: HẸN GẶP TRỰC TIẾP -->
          <div class="p-3 bg-amber-50/60 border border-amber-200 rounded-lg text-xs space-y-1">
            <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-1 text-[11px]">
              <div>
                <span class="font-bold text-amber-900">Điểm hẹn xem & nhận đồ:</span>
                <span class="text-amber-800"><%= item.productAddress != null ? h(item.productAddress) : "Trao đổi điểm hẹn trong khung chat" %></span>
              </div>
              <div class="text-amber-700 font-medium">
                Hình thức: Gặp trực tiếp • Kiểm tra máy rồi mới giao tiền
              </div>
            </div>
          </div>
        <% } else { %>
          <!-- KÊNH 2: GIAO TẬN NHÀ QUA GHN EXPRESS DEMO -->
          <div class="p-3.5 bg-orange-50/70 border border-orange-200 rounded-lg text-xs space-y-2">
            <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-2">
              <div class="flex items-center gap-2">
                <span class="px-2 py-0.5 bg-orange-600 text-white font-bold rounded text-[10px]">GHN Express</span>
                <span class="text-slate-500 text-[11px]">Mã vận đơn:</span>
                <% if (hasGhnTracking) { %>
                  <span class="font-mono font-bold text-orange-600 text-sm"><%= item.trackingCode %></span>
                <% } else { %>
                  <span class="font-medium text-amber-700 italic">Chưa tạo vận đơn GHN</span>
                <% } %>
              </div>
              <div>
                <% if (hasGhnTracking) { %>
                  <% boolean isCancelled = "CANCELLED".equalsIgnoreCase(item.shippingStatus) || "CANCELLED".equalsIgnoreCase(item.status) || "CANCELED".equalsIgnoreCase(item.status);
                     String ghnStatusTxt = "Chờ bưu tá lấy hàng";
                     if (isCancelled) ghnStatusTxt = "Vận đơn đã hủy";
                     else if ("DANG_GIAO".equalsIgnoreCase(item.shippingStatus)) ghnStatusTxt = "Shipper đang giao hàng tới người mua";
                     else if ("DA_GIAO".equalsIgnoreCase(item.shippingStatus)) ghnStatusTxt = "Bưu tá đã giao hàng thành công";
                  %>
                  <span class="font-bold <%= isCancelled ? "text-red-700 bg-red-50 border-red-200" : ("DA_GIAO".equalsIgnoreCase(item.shippingStatus) ? "text-emerald-700 bg-emerald-50 border-emerald-200" : ("DANG_GIAO".equalsIgnoreCase(item.shippingStatus) ? "text-orange-700 bg-orange-50 border-orange-200" : "text-blue-700 bg-blue-50 border-blue-200")) %> px-2.5 py-0.5 rounded-full border text-[11px]">
                    <%= ghnStatusTxt %>
                  </span>
                <% } else { %>
                  <span class="text-[11px] text-amber-700 bg-amber-50 px-2 py-0.5 rounded border border-amber-200">
                    Chờ Người bán tạo đơn vận chuyển
                  </span>
                <% } %>
              </div>
            </div>
            <div class="flex flex-col sm:flex-row sm:items-center justify-between text-[11px] text-slate-600 gap-1 pt-1 border-t border-orange-200/60">
              <div>
                Địa chỉ giao hàng: <strong><%= item.buyerAddress != null ? h(item.buyerAddress) : "Chưa cập nhật địa chỉ" %></strong>
              </div>
              <div class="text-orange-700 font-medium">
                Khách được kiểm tra hàng trước khi thanh toán COD
              </div>
            </div>
          </div>
        <% } %>


        <!-- THÔNG BÁO YÊU CẦU HỦY ĐƠN (KỊCH BẢN A) -->
        <% if (item.cancelRequested && !isOrderCancelled && !isCompleted) { %>
          <% if (mineBuy) { %>
            <div class="p-3.5 bg-amber-50 border border-amber-300 rounded-xl text-xs flex flex-col sm:flex-row sm:items-center justify-between gap-2 text-amber-900">
              <div class="flex items-start gap-2.5">
                <svg class="w-5 h-5 text-amber-600 shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                <div>
                  <div class="font-bold text-amber-950 flex items-center gap-1.5">
                    <span>Bạn đã gửi yêu cầu hủy đơn hàng &amp; hoàn cọc</span>
                    <span class="text-[10px] font-bold bg-amber-200/70 text-amber-800 px-2 py-0.5 rounded-full">Đang chờ Người Bán duyệt</span>
                  </div>
                  <div class="mt-0.5 text-slate-700">Lý do hủy: <em>"<%= (item.cancelReason != null && !item.cancelReason.trim().isEmpty()) ? h(item.cancelReason) : "Đổi ý không muốn mua nữa" %>"</em></div>
                  <div class="mt-0.5 text-[11px] text-amber-700">Khi người bán bấm đồng ý, số tiền cọc <strong><%= moneyFormat.format(Math.round(item.depositAmount)) %> đ</strong> sẽ được hoàn lại cho bạn 100%.</div>
                </div>
              </div>
            </div>
          <% } else { %>
            <div class="p-4 bg-amber-50 border-2 border-amber-400 rounded-xl text-xs space-y-2.5 text-slate-900 shadow-xs">
              <div class="flex items-center justify-between border-b border-amber-200 pb-2">
                <div class="flex items-center gap-2 font-bold text-amber-950 text-sm">
                  <svg class="w-5 h-5 text-amber-600 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/></svg>
                  <span>Khách mua đã gửi Yêu Cầu Hủy Đơn Hàng</span>
                </div>
                <span class="text-[10px] font-bold bg-red-100 text-red-800 px-2.5 py-1 rounded-full uppercase tracking-wider">Cần Bạn Xử Lý</span>
              </div>
              <div class="text-xs text-slate-800">
                Lý do từ người mua: <strong class="text-red-700">"<%= (item.cancelReason != null && !item.cancelReason.trim().isEmpty()) ? h(item.cancelReason) : "Đổi ý không muốn mua nữa" %>"</strong>
              </div>
              <div class="p-2.5 bg-white/80 border border-amber-200 rounded-lg text-[11px] text-slate-600 leading-relaxed">
                ℹ️ <strong>Quy chế thỏa thuận:</strong> Nếu bạn đồng ý hủy, hệ thống sẽ hoàn 100% tiền cọc (<strong><%= moneyFormat.format(Math.round(item.depositAmount)) %> đ</strong>) lại cho khách mua, đồng thời <strong>tự động mở bán lại bài đăng</strong> để khách khác có thể mua ngay.
              </div>
              <div class="flex flex-wrap items-center gap-2.5 pt-1">
                <form action="order-action" method="POST" onsubmit="return confirm('Bạn xác nhận ĐỒNG Ý hủy đơn hàng này?\n\n- Tiền cọc <%= moneyFormat.format(Math.round(item.depositAmount)) %> đ sẽ được hoàn lại cho người mua.\n- Tin đăng sản phẩm sẽ được mở bán lại tự động.');">
                  <input type="hidden" name="action" value="seller_accept_cancel">
                  <input type="hidden" name="orderId" value="<%= item.id %>">
                  <button type="submit" class="px-4 py-2 bg-green-600 hover:bg-green-700 text-white font-bold text-xs rounded-lg transition shadow-xs flex items-center gap-1.5">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/></svg>
                    <span>Đồng Ý Hủy Đơn &amp; Hoàn Cọc</span>
                  </button>
                </form>
                <button type="button" onclick="openRejectCancelModal(<%= item.id %>)" class="px-4 py-2 bg-white hover:bg-slate-100 text-slate-700 border border-slate-300 font-bold text-xs rounded-lg transition shadow-xs flex items-center gap-1.5">
                  <svg class="w-4 h-4 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg>
                  <span>Từ Chối Hủy Đơn</span>
                </button>
              </div>
            </div>
          <% } %>
        <% } %>

        <!-- ======================================================== -->
        <!-- KHỐI NÚT HÀNH ĐỘNG CẬP NHẬT TRẠNG THÁI (CORE ACTIONS)    -->
        <!-- ======================================================== -->
        <div class="pt-3 border-t border-slate-100 flex flex-col sm:flex-row sm:items-center justify-between gap-3">
          
          <div class="flex flex-wrap items-center gap-2">
            <!-- NÚT CHUNG CHO MỌI ĐƠN -->
            <a href="04-chat-tra-gia-vietqr.jsp" class="px-3.5 py-2 bg-blue-600 hover:bg-blue-700 text-white font-bold text-xs rounded-lg transition shadow-xs text-center">
              Mở chat giao dịch
            </a>
            <a href="product-detail?id=<%= item.productId %>" class="px-3.5 py-2 bg-white border border-slate-300 hover:bg-slate-50 text-slate-700 font-bold text-xs rounded-lg transition shadow-xs text-center">
              Xem sản phẩm
            </a>
            <% 
              boolean canBuyerCancel = mineBuy && !isCompleted && !isOrderCancelled && !item.cancelRequested
                && ((isDirect && !item.sellerConfirmed) || (!isDirect && (!hasGhnTracking || "CHO_LAY_HANG".equalsIgnoreCase(item.shippingStatus))));
            %>
            <% if (canBuyerCancel) { %>
              <button type="button" onclick="openRequestCancelModal(<%= item.id %>, '<%= h(item.productTitle) %>', <%= Math.round(item.depositAmount) %>)" class="px-3.5 py-2 bg-red-50 hover:bg-red-100 text-red-700 border border-red-200 font-bold text-xs rounded-lg transition shadow-xs text-center flex items-center gap-1" title="Gửi yêu cầu hủy đơn và hoàn cọc cho người bán">
                <svg class="w-3.5 h-3.5 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg>
                <span>Yêu Cầu Hủy Đơn</span>
              </button>
            <% } %>
          </div>

          <!-- NÚT RIÊNG THEO HÌNH THỨC VÀ THEO VAI TRÒ (NGƯỜI BÁN / NGƯỜI MUA) -->
          <div class="flex flex-wrap items-center gap-2">
            <% if (isDirect) { %>
              <!-- ================= NHÁNH 1: GIAO TRỰC TIẾP ================= -->
              <% if (!isCompleted) { %>
                <% if (!mineBuy) { %>
                  <!-- TÔI LÀ NGƯỜI BÁN -->
                  <% if (item.sellerConfirmed) { %>
                    <span class="px-3 py-2 bg-blue-50 text-blue-700 border border-blue-200 font-bold text-xs rounded-lg flex items-center gap-1.5">
                      <svg class="w-4 h-4 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/></svg>
                      <span>Bạn đã xác nhận giao hàng (Chờ Người Mua)</span>
                    </span>
                  <% } else { %>
                    <form action="order-action" method="POST" onsubmit="return confirm('Bạn xác nhận đã gặp mặt và bàn giao sản phẩm trực tiếp cho người mua?');">
                      <input type="hidden" name="action" value="confirm_delivery">
                      <input type="hidden" name="orderId" value="<%= item.id %>">
                      <button type="submit" class="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white font-bold text-xs rounded-lg transition shadow-xs flex items-center gap-1.5">
                        <span>Xác Nhận Đã Giao Hàng</span>
                      </button>
                    </form>
                  <% } %>
                <% } else { %>
                  <!-- TÔI LÀ NGƯỜI MUA -->
                  <% if (item.buyerConfirmed) { %>
                    <span class="px-3 py-2 bg-green-50 text-green-700 border border-green-200 font-bold text-xs rounded-lg flex items-center gap-1.5">
                      <span>✓ Bạn đã xác nhận nhận hàng</span>
                    </span>
                  <% } else if (!item.sellerConfirmed) { %>
                    <!-- NGƯỜI BÁN CHƯA BẤM GIAO HÀNG -> NGƯỜI MUA CHƯA ĐƯỢC BẤM NHẬN HÀNG -->
                    <span class="px-3.5 py-2 bg-slate-100 text-slate-500 border border-slate-200 font-semibold text-xs rounded-lg flex items-center gap-1.5 cursor-not-allowed select-none" title="Vui lòng gặp người bán tại điểm hẹn. Khi người bán bấm 'Xác nhận đã giao hàng', bạn mới bấm xác nhận nhận hàng.">
                      <svg class="w-4 h-4 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                      <span>Chờ người bán bấm xác nhận đã giao</span>
                    </span>
                  <% } else { %>
                    <!-- NGƯỜI BÁN ĐÃ BẤM GIAO HÀNG -> NGƯỜI MUA ĐƯỢC PHÉP BẤM XÁC NHẬN ĐÃ NHẬN HÀNG -->
                    <form action="order-action" method="POST" onsubmit="return confirm('Người bán đã xác nhận giao hàng. Bạn xác nhận đã kiểm tra và nhận được món đồ này?');">
                      <input type="hidden" name="action" value="confirm_receipt">
                      <input type="hidden" name="orderId" value="<%= item.id %>">
                      <button type="submit" class="px-4 py-2 bg-green-600 hover:bg-green-700 text-white font-bold text-xs rounded-lg transition shadow-xs flex items-center gap-1.5 ring-2 ring-green-300">
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/></svg>
                        <span>Xác Nhận Đã Nhận Hàng</span>
                      </button>
                    </form>
                  <% } %>
                <% } %>
              <% } else { %>
                <!-- ĐƠN ĐÃ COMPLETED -->
                <span class="px-3 py-1.5 bg-green-100 text-green-800 font-bold text-xs rounded-lg border border-green-300 flex items-center gap-1">
                  <span>Giao Dịch Đã Hoàn Tất</span>
                </span>
                <% if (mineBuy) { %>
                  <% boolean hasReviewed = reviewDAO.hasReviewedOrder(item.id); %>
                  <% if (hasReviewed) { %>
                    <span class="px-3 py-1.5 bg-amber-50 text-amber-800 font-bold text-xs rounded-lg border border-amber-200 flex items-center gap-1">
                      <span>★</span> Đã Đánh Giá Người Bán
                    </span>
                  <% } else { %>
                    <button type="button" onclick="openOrderReviewModal(<%= item.id %>, '<%= h(item.sellerName) %>', '<%= h(item.productTitle) %>')" class="px-3.5 py-1.5 bg-amber-500 hover:bg-amber-600 text-slate-950 font-bold text-xs rounded-lg transition shadow-xs flex items-center gap-1">
                      <span>★</span> Đánh Giá Người Bán
                    </button>
                  <% } %>
                <% } %>
              <% } %>

            <% } else { %>
              <!-- ================= NHÁNH 2: GIAO QUA GHN EXPRESS ================= -->
              <% if (isOrderCancelled) { %>
                <!-- Đơn hàng đã hủy: Không hiển thị nút thao tác nào bên phải cho cả người mua và người bán -->
              <% } else if (!isCompleted) { %>
                <% if (!mineBuy) { %>
                  <!-- TÔI LÀ NGƯỜI BÁN -->
                  <% if (!hasGhnTracking) { %>
                    <a href="ghn-simulator?orderId=<%= item.id %>" class="px-4 py-2 bg-orange-600 hover:bg-orange-700 text-white font-bold text-xs rounded-lg transition shadow-xs flex items-center gap-1.5">
                      <span>Tạo Đơn Vận Chuyển GHN (Demo)</span>
                    </a>
                  <% } else { %>
                    <!-- Nút thao tác cập nhật trạng thái nhanh trực tiếp cho Người Bán -->
<%--                    <% if ("CHO_LAY_HANG".equalsIgnoreCase(item.shippingStatus) || item.shippingStatus == null) { %>--%>
<%--                      <form action="order-action" method="POST" class="inline">--%>
<%--                        <input type="hidden" name="action" value="ghn_update_status">--%>
<%--                        <input type="hidden" name="orderId" value="<%= item.id %>">--%>
<%--                        <input type="hidden" name="shippingStatus" value="DANG_GIAO">--%>
<%--                        <input type="hidden" name="redirectUrl" value="05-quan-ly-don-hang.jsp?orderId=<%= item.id %>">--%>
<%--                        <button type="submit" class="px-3.5 py-2 bg-blue-600 hover:bg-blue-700 text-white font-bold text-xs rounded-lg transition shadow-xs flex items-center gap-1.5" title="Cập nhật: Bưu tá GHN đã lấy hàng và đang đi giao tới khách mua">--%>
<%--                          <span>🚚 Bưu Tá Đi Giao</span>--%>
<%--                        </button>--%>
<%--                      </form>--%>
<%--                    <% } else if ("DANG_GIAO".equalsIgnoreCase(item.shippingStatus)) { %>--%>
<%--                      <form action="order-action" method="POST" class="inline" onsubmit="return confirm('Bạn xác nhận bưu tá GHN đã giao kiện hàng đến người nhận?');">--%>
<%--                        <input type="hidden" name="action" value="ghn_update_status">--%>
<%--                        <input type="hidden" name="orderId" value="<%= item.id %>">--%>
<%--                        <input type="hidden" name="shippingStatus" value="DA_GIAO">--%>
<%--                        <input type="hidden" name="redirectUrl" value="05-quan-ly-don-hang.jsp?orderId=<%= item.id %>">--%>
<%--                        <button type="submit" class="px-3.5 py-2 bg-emerald-600 hover:bg-emerald-700 text-white font-bold text-xs rounded-lg transition shadow-xs flex items-center gap-1.5" title="Cập nhật: Bưu tá GHN đã giao hàng thành công đến khách mua">--%>
<%--                          <span>✓ Đã Giao Thành Công</span>--%>
<%--                        </button>--%>
<%--                      </form>--%>
<%--                    <% } else if ("DA_GIAO".equalsIgnoreCase(item.shippingStatus)) { %>--%>
<%--                      <span class="px-3 py-2 bg-emerald-50 text-emerald-800 border border-emerald-300 font-bold text-xs rounded-lg flex items-center gap-1.5" title="Bưu tá đã giao hàng thành công. Khách mua có thể bấm xác nhận nhận hàng.">--%>
<%--                        <span>✓ Bưu tá đã giao (Chờ khách nhận)</span>--%>
<%--                      </span>--%>
<%--                    <% } %>--%>

                    <!-- Menu tùy chọn đổi trạng thái bất kỳ lúc nào -->
                    <div class="relative inline-block text-left dropdown-status-container" id="dropdown-status-<%= item.id %>">
                      <button type="button" onclick="toggleStatusDropdown(<%= item.id %>)" class="px-3 py-2 bg-slate-100 hover:bg-slate-200 text-slate-700 border border-slate-300 font-bold text-xs rounded-lg transition shadow-xs flex items-center gap-1" title="Tùy chọn đổi trạng thái vận chuyển">
                        <span>Đổi trạng thái</span>
                        <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"/></svg>
                      </button>
                      <div id="status-menu-<%= item.id %>" class="hidden absolute right-0 mt-1 w-52 bg-white rounded-xl shadow-lg border border-slate-200 py-1.5 z-20 text-xs">
                        <form action="order-action" method="POST">
                          <input type="hidden" name="action" value="ghn_update_status">
                          <input type="hidden" name="orderId" value="<%= item.id %>">
                          <input type="hidden" name="shippingStatus" value="CHO_LAY_HANG">
                          <input type="hidden" name="redirectUrl" value="05-quan-ly-don-hang.jsp?orderId=<%= item.id %>">
                          <button type="submit" class="w-full text-left px-3.5 py-2 hover:bg-amber-50 text-slate-700 flex items-center justify-between <%= "CHO_LAY_HANG".equalsIgnoreCase(item.shippingStatus) ? "font-bold text-amber-700 bg-amber-50/50" : "" %>">
                            <span>1. Chờ bưu tá lấy hàng</span>
                            <%= "CHO_LAY_HANG".equalsIgnoreCase(item.shippingStatus) ? "✓" : "" %>
                          </button>
                        </form>
                        <form action="order-action" method="POST">
                          <input type="hidden" name="action" value="ghn_update_status">
                          <input type="hidden" name="orderId" value="<%= item.id %>">
                          <input type="hidden" name="shippingStatus" value="DANG_GIAO">
                          <input type="hidden" name="redirectUrl" value="05-quan-ly-don-hang.jsp?orderId=<%= item.id %>">
                          <button type="submit" class="w-full text-left px-3.5 py-2 hover:bg-blue-50 text-slate-700 flex items-center justify-between <%= "DANG_GIAO".equalsIgnoreCase(item.shippingStatus) ? "font-bold text-blue-700 bg-blue-50/50" : "" %>">
                            <span>2. Bưu tá đang đi giao</span>
                            <%= "DANG_GIAO".equalsIgnoreCase(item.shippingStatus) ? "✓" : "" %>
                          </button>
                        </form>
                        <form action="order-action" method="POST">
                          <input type="hidden" name="action" value="ghn_update_status">
                          <input type="hidden" name="orderId" value="<%= item.id %>">
                          <input type="hidden" name="shippingStatus" value="DA_GIAO">
                          <input type="hidden" name="redirectUrl" value="05-quan-ly-don-hang.jsp?orderId=<%= item.id %>">
                          <button type="submit" class="w-full text-left px-3.5 py-2 hover:bg-emerald-50 text-slate-700 flex items-center justify-between <%= "DA_GIAO".equalsIgnoreCase(item.shippingStatus) ? "font-bold text-emerald-700 bg-emerald-50/50" : "" %>">
                            <span>3. Đã giao hàng thành công</span>
                            <%= "DA_GIAO".equalsIgnoreCase(item.shippingStatus) ? "✓" : "" %>
                          </button>
                        </form>
                      </div>
                    </div>

                    <a href="ghn-simulator?orderId=<%= item.id %>" class="px-3.5 py-2 bg-orange-50 border border-orange-300 hover:bg-orange-100 text-orange-800 font-bold text-xs rounded-lg transition shadow-xs flex items-center gap-1.5" title="Mở trang chi tiết mô phỏng lộ trình GHN Express">
                      <span>Lộ trình GHN</span>
                      <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/></svg>
                    </a>
                  <% } %>
                <% } else { %>
                  <!-- TÔI LÀ NGƯỜI MUA -->
                  <% if (hasGhnTracking) { %>
                    <a href="ghn-simulator?orderId=<%= item.id %>" class="px-3.5 py-2 bg-orange-50 border border-orange-300 hover:bg-orange-100 text-orange-800 font-bold text-xs rounded-lg transition shadow-xs flex items-center gap-1.5">
                      <span>Xem Lộ Trình GHN</span>
                    </a>
                  <% } %>

                  <% boolean isGhnDelivered = "DA_GIAO".equalsIgnoreCase(item.shippingStatus); %>
                  <% if (!isGhnDelivered) { %>
                    <!-- CHƯA GIAO THÀNH CÔNG -> CHƯA ĐƯỢC BẤM XÁC NHẬN NHẬN HÀNG -->
                    <span class="px-3.5 py-2 bg-slate-100 text-slate-500 border border-slate-200 font-semibold text-xs rounded-lg flex items-center gap-1.5 cursor-not-allowed select-none" title="Bạn chỉ có thể bấm xác nhận sau khi bưu tá GHN đã giao hàng thành công đến địa chỉ của bạn.">
                      <svg class="w-4 h-4 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/></svg>
                      <span><%= !hasGhnTracking ? "Chờ người bán gửi hàng GHN" : ("DANG_GIAO".equalsIgnoreCase(item.shippingStatus) ? "Bưu tá đang đi giao hàng" : "Chờ bưu tá lấy hàng") %></span>
                    </span>
                  <% } else { %>
                    <!-- BƯU TÁ ĐÃ GIAO THÀNH CÔNG -> ĐƯỢC PHÉP BẤM XÁC NHẬN NHẬN HÀNG -->
                    <form action="order-action" method="POST" onsubmit="return confirm('Bưu tá GHN đã giao hàng thành công. Bạn xác nhận đã kiểm tra và đồng ý nhận món đồ này?');">
                      <input type="hidden" name="action" value="confirm_receipt">
                      <input type="hidden" name="orderId" value="<%= item.id %>">
                      <button type="submit" class="px-4 py-2 bg-green-600 hover:bg-green-700 text-white font-bold text-xs rounded-lg transition shadow-xs flex items-center gap-1.5 ring-2 ring-green-300">
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/></svg>
                        <span>Xác Nhận Đã Nhận Hàng</span>
                      </button>
                    </form>
                  <% } %>
                <% } %>
              <% } else { %>
                <!-- ĐƠN GHN ĐÃ COMPLETED -->
                <span class="px-3 py-1.5 bg-green-100 text-green-800 font-bold text-xs rounded-lg border border-green-300 flex items-center gap-1">
                  <span>Giao Hàng GHN Thành Công</span>
                </span>
                <% if (mineBuy) { %>
                  <% boolean hasReviewed = reviewDAO.hasReviewedOrder(item.id); %>
                  <% if (hasReviewed) { %>
                    <span class="px-3 py-1.5 bg-amber-50 text-amber-800 font-bold text-xs rounded-lg border border-amber-200 flex items-center gap-1">
                      <span>★</span> Đã Đánh Giá Người Bán
                    </span>
                  <% } else { %>
                    <button type="button" onclick="openOrderReviewModal(<%= item.id %>, '<%= h(item.sellerName) %>', '<%= h(item.productTitle) %>')" class="px-3.5 py-1.5 bg-amber-500 hover:bg-amber-600 text-slate-950 font-bold text-xs rounded-lg transition shadow-xs flex items-center gap-1">
                      <span>★</span> Đánh Giá Người Bán
                    </button>
                  <% } %>
                <% } %>
                <% if (hasGhnTracking) { %>
                  <a href="ghn-simulator?orderId=<%= item.id %>" class="px-3 py-1.5 bg-slate-100 hover:bg-slate-200 text-slate-700 font-semibold text-xs rounded-lg transition">
                    Lịch sử GHN
                  </a>
                <% } %>
              <% } %>
            <% } %>
          </div>

        </div>

        <% if (isOrderCancelled) { %>
          <div class="p-3 bg-red-50 border border-red-200 rounded-xl text-xs flex items-center gap-2 text-red-800">
            <svg class="w-4 h-4 text-red-600 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/></svg>
            <span><strong>Thông báo:</strong> Đơn hàng này đã bị hủy. <strong>Lý do:</strong> <%= (item.shippingNote != null && !item.shippingNote.trim().isEmpty()) ? h(item.shippingNote) : ((item.cancelReason != null && !item.cancelReason.trim().isEmpty()) ? h(item.cancelReason) : "Đơn hàng đã được thỏa thuận hủy thành công.") %></span>
          </div>
        <% } %>

      </div>
        <% } %>
      <% } %>
    <% } else { %>


      <!-- ========================================== -->
      <!-- ĐƠN 1: GIAO TẬN NHÀ (TÔI LÀ NGƯỜI MUA) - IPHONE 13 PRO MAX -->
      <!-- ========================================== -->
      <div id="order-card-1" data-channel="channel2" data-type="buy" class="order-card bg-white rounded-xl border-2 border-green-500 shadow-sm p-5 sm:p-6 space-y-4">
        
        <!-- HEADER ĐƠN HÀNG -->
        <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-2 pb-3 border-b border-slate-100">
          <div class="flex flex-wrap items-center gap-2.5">
            <span class="px-2.5 py-0.5 rounded text-[11px] font-bold bg-green-100 text-green-800 uppercase tracking-wider">
              Giao Hàng Tận Nhà (Giao Hàng Nhanh - GHN)
            </span>
            <span class="px-2 py-0.5 rounded text-[10px] font-bold bg-blue-50 text-blue-700 border border-blue-200">
              Tôi Là Người Mua
            </span>
            <span class="text-xs font-mono text-slate-400">Mã đơn: #MN-GHN-88219</span>
          </div>
          <div id="order1StatusBadge" class="text-xs text-green-700 font-bold bg-green-50 px-3 py-1 rounded-full border border-green-200 self-start sm:self-auto">
            Trạng thái: Đã nhận hàng • Đang dùng thử và kiểm tra 48 giờ
          </div>
        </div>

        <!-- THÔNG TIN SẢN PHẨM VÀ GIÁ TIỀN -->
        <div class="flex flex-col sm:flex-row items-start justify-between gap-4">
          <div class="flex items-start gap-3.5">
            <img src="assets/images/products/iphone-13-pro-max.jpg" alt="iPhone 13 Pro Max" class="w-20 h-20 rounded-lg object-cover shrink-0 border border-slate-200">
            <div>
              <h3 class="font-bold text-sm text-slate-900">iPhone 13 Pro Max 128GB Xanh Sierra bản VN/A, pin 88%</h3>
              <p class="text-[11px] text-slate-500 mt-0.5">Người bán: <strong>Trần Quốc Bảo</strong> (Quận 1, TP.HCM)</p>
              <div class="text-xs font-bold text-green-600 mt-1.5">Tổng tiền đã thanh toán: 14.800.000 đ (Đang được Sàn giữ an toàn)</div>
            </div>
          </div>

          <!-- MÃ VẬN ĐƠN VÀ THÔNG TIN BƯU CỤC -->
          <div class="p-3 bg-slate-50 border border-slate-200 rounded-lg text-xs space-y-1 w-full sm:w-64">
            <div class="flex justify-between">
              <span class="text-slate-500 text-[11px]">Đơn vị:</span>
              <span class="font-bold text-slate-800">Giao Hàng Nhanh (GHN)</span>
            </div>
            <div class="flex justify-between">
              <span class="text-slate-500 text-[11px]">Mã vận đơn:</span>
              <span class="font-mono font-bold text-blue-600">GHN-77821902VN</span>
            </div>
            <div class="text-[11px] text-slate-500 pt-1 border-t border-slate-200">
              Đã xem hàng khi nhận lúc 09:30 sáng nay.
            </div>
          </div>
        </div>

        <!-- KHỐI ĐỒNG HỒ ĐẾM NGƯỢC 48 GIỜ KIỂM TRA MÁY -->
        <div id="escrowControlBox1" class="p-4 bg-amber-50/80 border-2 border-amber-300 rounded-xl space-y-3">
          <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-2">
            <div>
              <span class="text-xs font-bold text-amber-900 uppercase tracking-wider block">
                Thời Gian Dùng Thử & Kiểm Tra Máy Tại Nhà (48 Giờ)
              </span>
              <p class="text-[11px] text-amber-800 mt-0.5">
                Tiền hàng 14.800.000 đ đang được Sàn MuaNgay giữ an toàn. Bạn có 48 giờ để test máy (FaceID, pin, camera, loa, màn hình).
              </p>
            </div>
            
            <!-- ĐỒNG HỒ ĐẾM NGƯỢC -->
            <div class="text-center bg-white px-4 py-2 rounded-lg border border-amber-300 shadow-xs shrink-0">
              <span class="text-[10px] text-slate-500 block uppercase font-medium">Thời gian còn lại</span>
              <span class="font-mono text-base font-bold text-red-600">34 Giờ : 18 Phút</span>
            </div>
          </div>

          <!-- HAI HÀNH ĐỘNG CỐT LÕI CỦA NGƯỜI MUA -->
          <div class="flex flex-col sm:flex-row items-center justify-between gap-3 pt-2 border-t border-amber-200">
            <span class="text-[11px] text-slate-600">
              Sau 48 giờ nếu máy không có lỗi, Sàn sẽ tự động chuyển tiền cho người bán.
            </span>
            
            <div class="flex items-center gap-2.5 w-full sm:w-auto">
              <!-- NÚT KHIẾU NẠI 48H -->
              <button onclick="openDisputeModal()" class="flex-1 sm:flex-none px-4 py-2 bg-white border border-red-300 hover:bg-red-50 text-red-700 text-xs font-bold rounded-lg transition shadow-xs">
                Báo Lỗi / Yêu Cầu Trả Hàng (Tải Video)
              </button>

              <!-- NÚT TẤT TOÁN SỚM -->
              <button onclick="confirmEarlyRelease1()" class="flex-1 sm:flex-none px-4 py-2 bg-green-600 hover:bg-green-700 text-white text-xs font-bold rounded-lg transition shadow-xs">
                Máy Rất Tốt - Xác Nhận Chuyển Tiền Ngay
              </button>
            </div>
          </div>
        </div>

      </div>


      <!-- ========================================== -->
      <!-- ĐƠN 2: GIAO TẬN NHÀ (TÔI LÀ NGƯỜI BÁN) - DELL XPS 13 -->
      <!-- ========================================== -->
      <div id="order-card-2" data-channel="channel2" data-type="sell" class="order-card bg-white rounded-xl border border-slate-200 shadow-sm p-5 sm:p-6 space-y-4">
        
        <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-2 pb-3 border-b border-slate-100">
          <div class="flex flex-wrap items-center gap-2.5">
            <span class="px-2.5 py-0.5 rounded text-[11px] font-bold bg-blue-100 text-blue-800 uppercase tracking-wider">
              Giao Hàng Tận Nhà (Viettel Post)
            </span>
            <span class="px-2 py-0.5 rounded text-[10px] font-bold bg-purple-50 text-purple-700 border border-purple-200">
              Tôi Là Người Bán
            </span>
            <span class="text-xs font-mono text-slate-400">Mã đơn: #MN-VTP-99402</span>
          </div>
          <div id="order2StatusBadge" class="text-xs text-blue-700 font-bold bg-blue-50 px-3 py-1 rounded-full border border-blue-200 self-start sm:self-auto">
            Trạng thái: Shipper đang giao tới người mua tại Hà Nội
          </div>
        </div>

        <div class="flex flex-col sm:flex-row items-start justify-between gap-4">
          <div class="flex items-start gap-3.5">
            <img src="assets/images/products/laptop-dell-xps13.jpg" alt="Dell XPS 13" class="w-20 h-20 rounded-lg object-cover shrink-0 border border-slate-200">
            <div>
              <h3 class="font-bold text-sm text-slate-900">Dell XPS 13 9305 Core i5 Gen 11, RAM 16GB, SSD 512GB</h3>
              <p class="text-[11px] text-slate-500 mt-0.5">Người mua: <strong>Lê Hoàng Nam</strong> (Cầu Giấy, Hà Nội)</p>
              <div class="text-xs font-bold text-slate-800 mt-1.5">
                Giá bán: <strong>13.450.000 đ</strong> • Tiền thực nhận vào tài khoản: <strong class="text-green-600">13.113.750 đ</strong> (Đã trừ phí dịch vụ 2.5%)
              </div>
            </div>
          </div>

          <div class="p-3 bg-slate-50 border border-slate-200 rounded-lg text-xs space-y-1 w-full sm:w-64">
            <div class="flex justify-between">
              <span class="text-slate-500 text-[11px]">Đơn vị vận chuyển:</span>
              <span class="font-bold text-slate-800">Viettel Post</span>
            </div>
            <div class="flex justify-between">
              <span class="text-slate-500 text-[11px]">Mã vận đơn:</span>
              <span class="font-mono font-bold text-blue-600">VTP-8839102VN</span>
            </div>
            <div class="text-[11px] text-slate-500 pt-1 border-t border-slate-200">
              Đã xuất kho phân loại Hà Nội lúc 08:15.
            </div>
          </div>
        </div>

        <!-- HÀNH TRÌNH VẬN ĐƠN & THÔNG BÁO TIỀN HÀNG -->
        <div class="p-3.5 bg-blue-50 border border-blue-200 rounded-lg flex flex-col sm:flex-row sm:items-center justify-between gap-3 text-xs">
          <div>
            <span class="font-bold text-blue-900 block">Tiền hàng đang được Sàn MuaNgay giữ an toàn:</span>
            <p class="text-[11px] text-blue-800 mt-0.5">
              Khách hàng đã thanh toán 100%. Sau khi bưu tá giao thành công và sau 48h dùng thử khách không có khiếu nại, tiền sẽ tự động chuyển về tài khoản ngân hàng của bạn.
            </p>
          </div>
          <div class="flex items-center gap-2 shrink-0">
            <button onclick="showShippingDetailsModal('VTP-8839102VN')" class="px-3.5 py-2 bg-white border border-blue-300 hover:bg-blue-100 text-blue-700 font-bold text-xs rounded-lg transition shadow-xs">
              Xem Lộ Trình Gói Hàng
            </button>
            <a href="04-chat-tra-gia-vietqr.jsp" class="px-3.5 py-2 bg-blue-600 hover:bg-blue-700 text-white font-bold text-xs rounded-lg transition shadow-xs text-center">
              Nhắn Tin Cho Khách
            </a>
          </div>
        </div>

      </div>


      <!-- ========================================== -->
      <!-- ĐƠN 3: HẸN GẶP TRỰC TIẾP (TÔI LÀ NGƯỜI MUA) - IPHONE 18 PRO MAX -->
      <!-- ========================================== -->
      <div id="order-card-3" data-channel="channel1" data-type="buy" class="order-card bg-white rounded-xl border border-slate-200 shadow-sm p-5 sm:p-6 space-y-4">
        
        <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-2 pb-3 border-b border-slate-100">
          <div class="flex flex-wrap items-center gap-2.5">
            <span class="px-2.5 py-0.5 rounded text-[11px] font-bold bg-amber-100 text-amber-800 uppercase tracking-wider">
              Hẹn Gặp Trực Tiếp
            </span>
            <span class="px-2 py-0.5 rounded text-[10px] font-bold bg-blue-50 text-blue-700 border border-blue-200">
              Tôi Là Người Mua
            </span>
            <span class="text-xs font-mono text-slate-400">Mã đơn: #MN-DIR-11029</span>
          </div>
          <div id="order3StatusBadge" class="text-xs text-amber-700 font-bold bg-amber-50 px-3 py-1 rounded-full border border-amber-200 self-start sm:self-auto">
            Trạng thái: Đã cọc qua VNPay • Hẹn gặp kiểm tra sản phẩm
          </div>
        </div>

        <div class="flex flex-col sm:flex-row items-start justify-between gap-4">
          <div class="flex items-start gap-3.5">
            <img src="assets/images/iphone-18-pro-mau-do-anh-dao-dam-1-iphone-18-pro-mau-do-burgundy-co-gi-dac-biet-1.jpg" alt="iPhone 18 Pro Max" class="w-20 h-20 rounded-lg object-cover shrink-0 border border-slate-200">
            <div>
              <h3 class="font-bold text-sm text-slate-900">iPhone 18 Pro Max Đỏ Burgundy 256GB chính hãng VN/A</h3>
              <p class="text-[11px] text-slate-500 mt-0.5">Người bán: <strong>Nguyễn Văn Tuấn</strong> (Quận 10, TP.HCM)</p>
              <div class="text-xs text-slate-700 mt-1.5">
                Giá chốt: <strong>37.000.000 đ</strong> • Đã cọc VNPay: <strong class="text-green-600">3.700.000 đ</strong> (Tin đăng đã tạm khóa)
              </div>
            </div>
          </div>

          <div class="p-3 bg-slate-50 border border-slate-200 rounded-lg text-xs space-y-1 w-full sm:w-64">
            <div class="flex justify-between">
              <span class="text-slate-500 text-[11px]">Tiền cần thanh toán thêm:</span>
              <span class="font-bold text-slate-900">36.000.000 đ</span>
            </div>
            <div class="flex justify-between">
              <span class="text-slate-500 text-[11px]">Điểm hẹn:</span>
              <span class="text-slate-800">142 Tô Hiến Thành, Q10</span>
            </div>
            <div class="text-[11px] text-blue-600 pt-1 border-t border-slate-200 font-medium">
              Khung giờ hẹn: 16:00 chiều nay
            </div>
          </div>
        </div>

        <!-- KHỐI XÁC NHẬN KHI GẶP MẶT -->
        <div id="order3DualBox" class="p-3.5 bg-blue-50 border border-blue-200 rounded-lg flex flex-col sm:flex-row sm:items-center justify-between gap-3 text-xs">
          <div>
            <span class="font-bold text-blue-900 block">Quy trình hẹn gặp người bán:</span>
            <p class="text-[11px] text-blue-800 mt-0.5">
              1. Cắm 3uTools & test kỹ chức năng máy -> 2. Chuyển khoản hoặc đưa 36.000.000 đ -> 3. Cả hai cùng bấm xác nhận trên app để sàn mở khóa cọc 1tr cho người bán.
            </p>
          </div>
          <div class="flex items-center gap-2 shrink-0">
            <button onclick="openHandshakeModal('order3')" id="btnBuyerConfirm3" class="px-3.5 py-2 bg-green-600 hover:bg-green-700 text-white font-bold text-xs rounded-lg transition shadow-xs">
              Mở Bàn Giao (QR / Mã PIN)
            </button>
            <a href="04-chat-tra-gia-vietqr.jsp" class="px-3.5 py-2 bg-blue-600 hover:bg-blue-700 text-white font-bold text-xs rounded-lg transition shadow-xs text-center">
              Mở Khung Chat
            </a>
          </div>
        </div>

      </div>


      <!-- ========================================== -->
      <!-- ĐƠN 4: HẸN GẶP TRỰC TIẾP (TÔI LÀ NGƯỜI BÁN) - BÀN LÀM VIỆC GỖ SỒI -->
      <!-- ========================================== -->
      <div id="order-card-4" data-channel="channel1" data-type="sell" class="order-card bg-white rounded-xl border border-slate-200 shadow-sm p-5 sm:p-6 space-y-4">
        
        <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-2 pb-3 border-b border-slate-100">
          <div class="flex flex-wrap items-center gap-2.5">
            <span class="px-2.5 py-0.5 rounded text-[11px] font-bold bg-amber-100 text-amber-800 uppercase tracking-wider">
              Hẹn Gặp Trực Tiếp
            </span>
            <span class="px-2 py-0.5 rounded text-[10px] font-bold bg-purple-50 text-purple-700 border border-purple-200">
              Tôi Là Người Bán
            </span>
            <span class="text-xs font-mono text-slate-400">Mã đơn: #MN-DIR-08912</span>
          </div>
          <div id="order4StatusBadge" class="text-xs text-amber-700 font-bold bg-amber-50 px-3 py-1 rounded-full border border-amber-200 self-start sm:self-auto">
            Khách đã cọc qua VNPay • Hẹn qua chở bàn lúc 17:30
          </div>
        </div>

        <div class="flex flex-col sm:flex-row items-start justify-between gap-4">
          <div class="flex items-start gap-3.5">
            <img src="assets/images/products/ban-go-thong.jpg" alt="Bàn làm việc gỗ sồi" class="w-20 h-20 rounded-lg object-cover shrink-0 border border-slate-200">
            <div>
              <h3 class="font-bold text-sm text-slate-900">Bàn làm việc gỗ sồi tự nhiên 1m4 x 70cm, có 3 hộc kéo</h3>
              <p class="text-[11px] text-slate-500 mt-0.5">Người mua: <strong>Trần Đình Trọng</strong> (Tài khoản chính chủ đã xác thực)</p>
              <div class="text-xs font-bold text-green-600 mt-1.5">
                Tiền cọc giữ đồ: 200.000 đ (Đã nhận qua VNPay trên sàn)
              </div>
            </div>
          </div>

          <div class="p-3 bg-slate-50 border border-slate-200 rounded-lg text-xs space-y-1 w-full sm:w-64">
            <div class="flex justify-between">
              <span class="text-slate-500 text-[11px]">Tiền mặt thu tại chỗ:</span>
              <span class="font-bold text-green-700">900.000 đ</span>
            </div>
            <div class="flex justify-between">
              <span class="text-slate-500 text-[11px]">Điểm hẹn xem bàn:</span>
              <span class="text-slate-800">45/12 D2, Bình Thạnh</span>
            </div>
            <div class="text-[11px] text-blue-600 pt-1 border-t border-slate-200 font-medium">
              Khung giờ hẹn: 17:30 chiều nay
            </div>
          </div>
        </div>

        <div id="order4DualBox" class="p-3.5 bg-blue-50 border border-blue-200 rounded-lg flex flex-col sm:flex-row sm:items-center justify-between gap-3 text-xs">
          <div>
            <span class="font-bold text-blue-900 block">Xác nhận giao bàn trực tiếp:</span>
            <p class="text-[11px] text-blue-800 mt-0.5">
              Khi khách Trần Đình Trọng qua xem bàn và gửi 900.000 đ tiền mặt, bạn nhấn nút bên phải để Sàn mở khóa 200.000 đ tiền cọc vào tài khoản của bạn.
            </p>
          </div>
          <div class="flex items-center gap-2 shrink-0">
            <button onclick="openHandshakeModal('order4')" id="btnSellerConfirm4" class="px-4 py-2 bg-green-600 hover:bg-green-700 text-white font-bold text-xs rounded-lg transition shadow-xs">
              Mở Bàn Giao (QR / Mã PIN)
            </button>
            <a href="04-chat-tra-gia-vietqr.jsp" class="px-3.5 py-2 bg-blue-600 hover:bg-blue-700 text-white font-bold text-xs rounded-lg transition shadow-xs text-center">
              Mở Khung Chat
            </a>
          </div>
        </div>

      </div>
    <% } %>

    </div>

    <!-- MODAL YÊU CẦU HỦY ĐƠN HÀNG (DÀNH CHO NGƯỜI MUA) -->
    <div id="requestCancelModal" class="hidden fixed inset-0 bg-slate-900/60 backdrop-blur-xs z-50 flex items-center justify-center p-4 overflow-y-auto">
      <div class="bg-white rounded-2xl max-w-md w-full p-6 shadow-2xl space-y-4 my-auto">
        <div class="flex items-center justify-between border-b border-slate-100 pb-3">
          <div class="flex items-center gap-2 text-red-600">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/></svg>
            <h3 class="font-bold text-slate-900 text-sm uppercase">Yêu Cầu Hủy Đơn Hàng</h3>
          </div>
          <button type="button" onclick="closeRequestCancelModal()" class="text-slate-400 hover:text-slate-600 font-bold text-lg px-2">✕</button>
        </div>

        <form action="order-action" method="POST" class="space-y-3.5 text-xs">
          <input type="hidden" name="action" value="buyer_request_cancel">
          <input type="hidden" name="orderId" id="cancelModalOrderId" value="0">

          <div>
            <label class="block font-bold text-slate-700 mb-1">Sản phẩm:</label>
            <div id="cancelModalProductTitle" class="p-2.5 bg-slate-50 border border-slate-200 rounded-lg font-semibold text-slate-800"></div>
          </div>

          <div class="p-3 bg-emerald-50 border border-emerald-200 rounded-lg text-emerald-900">
            <div class="flex items-center justify-between">
              <span>Số tiền cọc dự kiến hoàn lại:</span>
              <strong id="cancelModalDeposit" class="text-sm text-emerald-700">0 đ</strong>
            </div>
            <div class="mt-1 text-[11px] text-slate-600 leading-relaxed">
              Tiền cọc sẽ được hoàn lại <strong>100%</strong> cho bạn ngay khi Người Bán bấm đồng ý yêu cầu hủy.
            </div>
          </div>

          <div>
            <label class="block font-bold text-slate-700 mb-1">Chọn lý do hủy:</label>
            <select id="cancelReasonPreset" onchange="onCancelReasonSelect(this.value)" class="w-full p-2.5 bg-slate-50 border border-slate-300 rounded-lg text-xs focus:ring-2 focus:ring-blue-500">
              <option value="Đổi ý, không còn nhu cầu mua sản phẩm này nữa">1. Đổi ý, không còn nhu cầu mua sản phẩm này nữa</option>
              <option value="Đã tìm thấy sản phẩm khác phù hợp hơn">2. Đã tìm thấy sản phẩm khác phù hợp hơn</option>
              <option value="Đã thương lượng riêng với người bán để hủy đơn">3. Đã thương lượng riêng với người bán để hủy đơn</option>
              <option value="Người bán chậm phản hồi / không hẹn giao hàng">4. Người bán chậm phản hồi / không hẹn giao hàng</option>
              <option value="custom">5. Lý do khác (tự nhập)...</option>
            </select>
          </div>

          <div>
            <label for="cancelReasonInput" class="block font-bold text-slate-700 mb-1">Chi tiết lý do gửi Người Bán:</label>
            <textarea id="cancelReasonInput" name="cancelReason" rows="3" required class="w-full p-2.5 bg-slate-50 border border-slate-300 rounded-lg text-xs focus:ring-2 focus:ring-blue-500" placeholder="Nhập lý do gửi đến người bán...">Đổi ý, không còn nhu cầu mua sản phẩm này nữa</textarea>
          </div>

          <div class="pt-2 flex gap-2">
            <button type="button" onclick="closeRequestCancelModal()" class="flex-1 py-2.5 border border-slate-300 hover:bg-slate-100 font-semibold text-slate-700 rounded-lg transition">
              Quay Lại
            </button>
            <button type="submit" class="flex-1 py-2.5 bg-red-600 hover:bg-red-700 text-white font-bold rounded-lg transition shadow-xs">
              Gửi Yêu Cầu Hủy
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- MODAL TỪ CHỐI YÊU CẦU HỦY ĐƠN (DÀNH CHO NGƯỜI BÁN) -->
    <div id="rejectCancelModal" class="hidden fixed inset-0 bg-slate-900/60 backdrop-blur-xs z-50 flex items-center justify-center p-4 overflow-y-auto">
      <div class="bg-white rounded-2xl max-w-sm w-full p-6 shadow-2xl space-y-4 my-auto">
        <div class="flex items-center justify-between border-b border-slate-100 pb-3">
          <h3 class="font-bold text-slate-900 text-sm uppercase">Từ Chối Yêu Cầu Hủy Đơn</h3>
          <button type="button" onclick="closeRejectCancelModal()" class="text-slate-400 hover:text-slate-600 font-bold text-lg px-2">✕</button>
        </div>

        <form action="order-action" method="POST" class="space-y-3.5 text-xs">
          <input type="hidden" name="action" value="seller_reject_cancel">
          <input type="hidden" name="orderId" id="rejectModalOrderId" value="0">

          <p class="text-slate-600 leading-relaxed">
            Bạn đang từ chối yêu cầu hủy đơn hàng. Đơn hàng sẽ tiếp tục được tiến hành theo quy trình đã hẹn.
          </p>

          <div>
            <label for="rejectReasonInput" class="block font-bold text-slate-700 mb-1">Lý do từ chối (gửi tới người mua):</label>
            <textarea id="rejectReasonInput" name="rejectReason" rows="3" required class="w-full p-2.5 bg-slate-50 border border-slate-300 rounded-lg text-xs focus:ring-2 focus:ring-blue-500" placeholder="Nhập lý do từ chối...">Tôi đã chuẩn bị hàng sẵn sàng để giao, vui lòng tiếp tục đơn hàng theo thỏa thuận.</textarea>
          </div>

          <div class="pt-2 flex gap-2">
            <button type="button" onclick="closeRejectCancelModal()" class="flex-1 py-2 border border-slate-300 hover:bg-slate-100 font-semibold text-slate-700 rounded-lg transition">
              Đóng
            </button>
            <button type="submit" class="flex-1 py-2 bg-red-600 hover:bg-red-700 text-white font-bold rounded-lg transition shadow-xs">
              Xác Nhận Từ Chối
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- MODAL KHIẾU NẠI TRẢ HÀNG 48H -->
    <div id="disputeModal" class="hidden fixed inset-0 bg-slate-900/50 backdrop-blur-xs z-50 flex items-center justify-center p-4">
      <div class="bg-white rounded-2xl shadow-2xl border border-slate-200 max-w-md w-full p-6 space-y-4 text-left">
        <div class="flex items-center justify-between border-b border-slate-100 pb-2.5">
          <h3 class="text-sm font-bold text-red-600 uppercase">Yêu Cầu Khiếu Nại & Trả Hàng (Trong 48 Giờ)</h3>
          <button onclick="closeDisputeModal()" class="text-sm text-slate-400 font-bold hover:text-slate-700">X</button>
        </div>
        
        <div>
          <label class="block text-xs font-semibold text-slate-700 mb-1">Lý do khiếu nại sản phẩm:</label>
          <select id="disputeReason" class="w-full px-3 py-2 bg-slate-50 border border-slate-300 rounded-lg text-xs font-medium focus:outline-none focus:ring-2 focus:ring-red-500">
            <option>Màn hình có sọc / điểm chết không như mô tả</option>
            <option>Máy bị dính tài khoản iCloud / Mật khẩu giới hạn</option>
            <option>Pin tụt nhanh bất thường / Loa rè</option>
            <option>Hàng không đúng model hoặc linh kiện đã bị thay thế</option>
          </select>
        </div>

        <div>
          <label class="block text-xs font-semibold text-slate-700 mb-1">Mô tả chi tiết lỗi phát hiện trong 48h:</label>
          <textarea rows="3" class="w-full px-3 py-2 bg-slate-50 border border-slate-300 rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-red-500" placeholder="Mô tả cụ thể triệu chứng lỗi để Sàn đối chiếu..."></textarea>
        </div>

        <div class="p-3 bg-red-50 border border-red-200 rounded-lg text-[11px] text-red-900 space-y-1">
          <p class="font-bold">Quy trình bảo vệ tiền của MuaNgay:</p>
          <p>• Số tiền 14.800.000 đ lập tức được TẠM DỪNG CHUYỂN TIỀN để bảo vệ người mua.</p>
          <p>• Ban quản trị sẽ đối chiếu video để hỗ trợ hoàn tiền 100% cho bạn.</p>
        </div>

        <div class="flex items-center gap-2 pt-2">
          <button onclick="closeDisputeModal()" class="flex-1 py-2 bg-slate-100 hover:bg-slate-200 text-slate-700 font-semibold text-xs rounded-lg transition">
            Hủy Bỏ
          </button>
          <button onclick="submitDispute()" class="flex-1 py-2 bg-red-600 hover:bg-red-700 text-white font-bold text-xs rounded-lg transition shadow-sm">
            Gửi Khiếu Nại Lên Sàn
          </button>
        </div>
      </div>
    </div>

    <!-- CỬA SỔ BẬT LÊN (MODAL): XÁC NHẬN BÀN GIAO TRỰC TIẾP (MÃ QR & MÃ PIN 4 SỐ) -->
    <div id="handshakeModal" class="hidden fixed inset-0 bg-slate-900/60 backdrop-blur-xs z-50 flex items-center justify-center p-4 overflow-y-auto">
      <div class="bg-white rounded-2xl shadow-2xl border border-slate-200 max-w-md w-full p-5 space-y-4 text-left my-auto">
        
        <!-- TIÊU ĐỀ MODAL -->
        <div class="flex items-center justify-between border-b border-slate-100 pb-3">
          <div>
            <h3 class="text-xs font-bold text-slate-900 uppercase">Xác Nhận Bàn Giao Tại Điểm Hẹn</h3>
            <p id="handshakeOrderSub" class="text-[10px] text-slate-500 mt-0.5">Mã đơn: #MN-DIR-10826 • Gặp mặt trực tiếp</p>
          </div>
          <button onclick="closeHandshakeModal()" class="text-slate-400 hover:text-slate-700 font-bold p-1 text-sm">✕</button>
        </div>

        <!-- BƯỚC 1: XÁC THỰC HAI BÊN (QR CODE HOẶC PIN 4 SỐ) -->
        <div id="handshakeStepAuth" class="space-y-4">
          
          <!-- CHUYỂN ĐỔI VAI TRÒ ĐỂ DEMO THUYẾT TRÌNH -->
          <div class="flex rounded-lg bg-slate-100 p-1 text-xs font-semibold">
            <button type="button" id="btnRoleSeller" onclick="switchHandshakeRole('seller')" class="flex-1 py-1.5 rounded-md bg-white text-blue-700 shadow-xs transition text-center">
              Tôi Là Người Bán (Hiện QR & PIN)
            </button>
            <button type="button" id="btnRoleBuyer" onclick="switchHandshakeRole('buyer')" class="flex-1 py-1.5 rounded-md text-slate-600 hover:text-slate-900 transition text-center">
              Tôi Là Người Mua (Quét QR / Nhập PIN)
            </button>
          </div>

          <!-- GIAO DIỆN DÀNH CHO NGƯỜI BÁN -->
          <div id="sellerHandshakeView" class="space-y-3.5 text-center">
            <div class="p-3 bg-amber-50 rounded-xl border border-amber-200 text-left text-xs space-y-1">
              <div class="flex justify-between">
                <span class="text-amber-800">Số tiền mặt cần thu thêm:</span>
                <span id="handshakeCashNeed" class="font-bold text-red-600 text-sm">36.000.000 đ</span>
              </div>
              <div class="flex justify-between text-[11px] text-amber-700">
                <span>Tiền cọc sàn đang giữ:</span>
                <span id="handshakeEscrowHold" class="font-medium text-slate-900">1.000.000 đ (Giải ngân khi hoàn tất)</span>
              </div>
            </div>

            <!-- MÃ QR BÀN GIAO ĐỘNG -->
            <div class="p-3.5 bg-slate-50 border border-slate-200 rounded-xl inline-block mx-auto">
              <div class="w-44 h-44 bg-white border border-slate-300 rounded-lg p-2.5 flex flex-col items-center justify-center shadow-inner relative">
                <svg class="w-36 h-36" viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <rect x="5" y="5" width="26" height="26" rx="4" stroke="#0f172a" stroke-width="4" fill="white"/>
                  <rect x="11" y="11" width="14" height="14" rx="2" fill="#0f172a"/>
                  <rect x="69" y="5" width="26" height="26" rx="4" stroke="#0f172a" stroke-width="4" fill="white"/>
                  <rect x="75" y="11" width="14" height="14" rx="2" fill="#0f172a"/>
                  <rect x="5" y="69" width="26" height="26" rx="4" stroke="#0f172a" stroke-width="4" fill="white"/>
                  <rect x="11" y="75" width="14" height="14" rx="2" fill="#0f172a"/>
                  <rect x="36" y="8" width="6" height="6" fill="#0f172a"/>
                  <rect x="46" y="8" width="8" height="6" fill="#0f172a"/>
                  <rect x="58" y="8" width="6" height="6" fill="#0f172a"/>
                  <rect x="36" y="20" width="8" height="8" fill="#2563eb"/>
                  <rect x="48" y="20" width="6" height="6" fill="#0f172a"/>
                  <rect x="58" y="20" width="6" height="8" fill="#0f172a"/>
                  <rect x="8" y="36" width="6" height="6" fill="#0f172a"/>
                  <rect x="20" y="36" width="8" height="6" fill="#0f172a"/>
                  <rect x="8" y="48" width="8" height="8" fill="#0f172a"/>
                  <rect x="22" y="48" width="6" height="6" fill="#0f172a"/>
                  <rect x="8" y="58" width="6" height="6" fill="#0f172a"/>
                  <rect x="36" y="36" width="28" height="28" rx="4" fill="#eff6ff" stroke="#3b82f6" stroke-width="1.5"/>
                  <text x="50" y="51" font-size="7" font-weight="bold" fill="#1d4ed8" text-anchor="middle">MUANGAY</text>
                  <text x="50" y="59" font-size="5" fill="#2563eb" text-anchor="middle">HANDSHAKE</text>
                  <rect x="68" y="36" width="8" height="6" fill="#0f172a"/>
                  <rect x="80" y="36" width="12" height="6" fill="#0f172a"/>
                  <rect x="72" y="46" width="6" height="8" fill="#0f172a"/>
                  <rect x="82" y="46" width="10" height="6" fill="#0f172a"/>
                  <rect x="68" y="58" width="10" height="6" fill="#0f172a"/>
                  <rect x="82" y="58" width="6" height="6" fill="#0f172a"/>
                  <rect x="36" y="68" width="6" height="12" fill="#0f172a"/>
                  <rect x="46" y="68" width="8" height="6" fill="#0f172a"/>
                  <rect x="58" y="68" width="6" height="8" fill="#0f172a"/>
                  <rect x="46" y="78" width="18" height="6" fill="#0f172a"/>
                  <rect x="68" y="72" width="8" height="8" fill="#0f172a"/>
                  <rect x="80" y="72" width="12" height="6" fill="#0f172a"/>
                  <rect x="72" y="84" width="8" height="8" fill="#0f172a"/>
                  <rect x="84" y="84" width="8" height="8" fill="#0f172a"/>
                </svg>
                <span class="text-[9px] text-slate-500 font-mono mt-1">Mã xác thực động 5 phút</span>
              </div>
            </div>

            <!-- MÃ PIN BẢO MẬT 4 SỐ (DỰ PHÒNG KHI CAMERA HỎNG) -->
            <div class="space-y-1">
              <div class="text-[11px] text-slate-500">Mã số bàn giao dự phòng (khi người mua không quét được QR):</div>
              <div class="inline-flex items-center gap-2 bg-slate-100 border border-slate-300 px-4 py-1.5 rounded-lg">
                <span id="handshakePinDisplay" class="text-xl font-mono font-bold tracking-widest text-slate-900">8912</span>
                <span class="text-[10px] text-blue-700 bg-blue-50 px-2 py-0.5 rounded font-semibold">Đọc cho người mua</span>
              </div>
            </div>

            <div class="pt-1 text-xs text-slate-500 text-left bg-slate-50 p-2.5 rounded-lg border border-slate-200">
              <strong>Hướng dẫn:</strong> Đưa mã QR này cho người mua quét hoặc đọc mã số trên sau khi đã nhận đủ tiền mặt.
            </div>
          </div>

          <!-- GIAO DIỆN DÀNH CHO NGƯỜI MUA -->
          <div id="buyerHandshakeView" class="hidden space-y-3.5">
            <div id="handshakeBuyerNote" class="p-2.5 bg-blue-50 rounded-xl border border-blue-200 text-xs text-blue-900 leading-relaxed">
              Sau khi kiểm tra kỹ món đồ và đã thanh toán tiền mặt cho đối tác, hãy chọn 1 trong 2 cách xác nhận:
            </div>

            <!-- CÁCH 1: QUÉT MÃ QR CỦA NGƯỜI BÁN -->
            <div class="border border-slate-200 rounded-xl p-3 bg-slate-50 text-center space-y-2">
              <div class="text-xs font-bold text-slate-800 text-left">Cách 1: Quét Mã QR Trên Điện Thoại Người Bán</div>
              <div class="relative w-full h-28 bg-slate-900 rounded-lg overflow-hidden flex flex-col items-center justify-center text-white">
                <div class="absolute w-full h-0.5 bg-green-400 shadow-[0_0_8px_#4ade80] animate-pulse"></div>
                <div class="border-2 border-dashed border-white/60 rounded-lg w-24 h-24 flex items-center justify-center text-[10px] text-slate-300">
                  Khung Camera
                </div>
              </div>
              <button type="button" onclick="triggerSuccessfulHandshake()" class="w-full py-2 bg-blue-600 hover:bg-blue-700 text-white font-bold text-xs rounded-lg transition shadow-xs">
                Mô Phỏng Quét Mã QR Thành Công
              </button>
            </div>

            <!-- PHÂN CÁCH HOẶC -->
            <div class="relative flex items-center justify-center">
              <div class="border-t border-slate-200 w-full"></div>
              <span class="bg-white px-2.5 text-[10px] font-bold text-slate-400 uppercase tracking-wider shrink-0">
                Hoặc Nhập Mã PIN 4 Số Dự Phòng
              </span>
            </div>

            <!-- CÁCH 2: NHẬP MÃ PIN 4 SỐ -->
            <div class="border border-slate-200 rounded-xl p-3 bg-slate-50 space-y-2">
              <div class="text-xs font-bold text-slate-800">Cách 2: Nhập Mã Do Người Bán Đọc</div>
              <p class="text-[11px] text-slate-500">Phòng khi camera hỏng, chói nắng hoặc trời tối:</p>
              <div class="flex items-center gap-2">
                <input id="handshakePinInput" type="text" maxlength="4" value="8912" placeholder="Ví dụ: 8912" class="flex-1 text-center font-mono text-base font-bold tracking-widest px-3 py-1.5 bg-white border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:outline-none">
                <button type="button" onclick="submitHandshakePin()" class="px-3.5 py-1.5 bg-green-600 hover:bg-green-700 text-white font-bold text-xs rounded-lg transition shadow-xs shrink-0">
                  Xác Nhận PIN
                </button>
              </div>
            </div>
          </div>

        </div>

        <!-- BƯỚC 2: BIÊN NHẬN THÀNH CÔNG VÀ ĐÁNH GIÁ UY TÍN -->
        <div id="handshakeStepSuccess" class="hidden space-y-3.5">
          <div class="p-3 bg-green-50 border border-green-300 rounded-xl text-center space-y-1">
            <span class="px-2.5 py-0.5 rounded-full text-[10px] font-bold bg-green-600 text-white uppercase tracking-wider">
              Giao Dịch Hoàn Tất Thành Công
            </span>
            <h4 class="text-xs font-bold text-green-900 pt-1">Đã Bàn Giao Hàng & Mở Khóa Tiền Cọc!</h4>
            <p id="handshakeSuccessDesc" class="text-[11px] text-green-800">
              Sàn đã giải ngân tiền cọc cho Người Bán.
            </p>
          </div>

          <!-- BIÊN NHẬN ĐIỆN TỬ -->
          <div class="bg-slate-50 border border-slate-200 rounded-xl p-3 space-y-1.5 text-xs">
            <div class="font-bold text-slate-900 border-b border-slate-200 pb-1 flex justify-between text-[11px]">
              <span>Biên Nhận Bàn Giao Trực Tiếp</span>
              <span id="handshakeReceiptCode" class="text-blue-600 font-mono">#MN-REC-10826</span>
            </div>
            <div class="space-y-1 text-[11px]">
              <div class="flex justify-between">
                <span class="text-slate-500">Sản phẩm:</span>
                <span id="handshakeReceiptProduct" class="font-semibold text-slate-800">iPhone 18 Pro Max Đỏ Burgundy 256GB</span>
              </div>
              <div class="flex justify-between">
                <span class="text-slate-500">Tổng thanh toán:</span>
                <span id="handshakeReceiptTotal" class="font-bold text-slate-900">37.000.000 đ</span>
              </div>
              <div class="flex justify-between text-green-700">
                <span>Tiền cọc giải ngân:</span>
                <span id="handshakeReceiptEscrow">1.000.000 đ (Chuyển ví người bán)</span>
              </div>
              <div class="flex justify-between text-slate-700">
                <span>Tiền mặt trả tại chỗ:</span>
                <span id="handshakeReceiptCash">36.000.000 đ</span>
              </div>
              <div class="flex justify-between text-blue-700 pt-1 border-t border-slate-200">
                <span>Trạng thái bài đăng:</span>
                <span class="font-bold">ĐÃ BÁN (Tự động đóng bài)</span>
              </div>
              <div class="flex justify-between text-slate-500">
                <span>Phí dịch vụ sàn:</span>
                <span class="font-bold text-green-600">0 đ (Miễn phí 100% tiền mặt)</span>
              </div>
            </div>
          </div>

          <!-- ĐÁNH GIÁ ĐỐI TÁC -->
          <div class="space-y-2 pt-1">
            <div class="flex items-center justify-between">
              <span class="text-xs font-bold text-slate-900">Đánh Giá Đối Tác:</span>
              <div id="starContainer" class="flex items-center gap-1 text-amber-400 cursor-pointer text-base">
                <span onclick="setRating(1)">★</span>
                <span onclick="setRating(2)">★</span>
                <span onclick="setRating(3)">★</span>
                <span onclick="setRating(4)">★</span>
                <span onclick="setRating(5)">★</span>
              </div>
            </div>

            <div class="flex flex-wrap gap-1.5 text-[11px]">
              <button type="button" onclick="toggleTag(this)" class="tag-badge px-2.5 py-0.5 rounded-full bg-blue-50 border border-blue-300 text-blue-700 font-medium">Hàng đúng mô tả 100%</button>
              <button type="button" onclick="toggleTag(this)" class="tag-badge px-2.5 py-0.5 rounded-full bg-slate-100 border border-slate-200 text-slate-700">Đúng giờ hẹn</button>
              <button type="button" onclick="toggleTag(this)" class="tag-badge px-2.5 py-0.5 rounded-full bg-slate-100 border border-slate-200 text-slate-700">Người bán nhiệt tình</button>
              <button type="button" onclick="toggleTag(this)" class="tag-badge px-2.5 py-0.5 rounded-full bg-slate-100 border border-slate-200 text-slate-700">Giao dịch uy tín</button>
            </div>

            <textarea id="handshakeReviewNote" rows="2" class="w-full px-3 py-1.5 bg-slate-100 border border-slate-200 rounded-lg text-xs focus:ring-2 focus:ring-blue-500 focus:outline-none">Món đồ đúng như thỏa thuận, người giao dịch rất lịch sự và đúng giờ. Rất hài lòng!</textarea>
          </div>

          <button type="button" onclick="finishHandshakeFlow()" class="w-full py-2 bg-green-600 hover:bg-green-700 text-white font-bold text-xs rounded-lg transition shadow-sm">
            Gửi Đánh Giá & Hoàn Tất (+5 Điểm Uy Tín)
          </button>
        </div>

      </div>
    </div>

    <!-- MODAL TRA CỨU VẬN ĐƠN VIETTEL POST -->
    <div id="shippingModal" class="hidden fixed inset-0 bg-slate-900/50 backdrop-blur-xs z-50 flex items-center justify-center p-4">
      <div class="bg-white rounded-2xl shadow-2xl border border-slate-200 max-w-md w-full p-6 space-y-4 text-left">
        <div class="flex items-center justify-between border-b border-slate-100 pb-2.5">
          <h3 class="text-sm font-bold text-blue-600 uppercase">Hành Trình Vận Đơn Viettel Post</h3>
          <button onclick="closeShippingModal()" class="text-sm text-slate-400 font-bold hover:text-slate-700">X</button>
        </div>

        <div class="space-y-2 text-xs">
          <div class="flex justify-between border-b border-slate-100 pb-2">
            <span class="text-slate-500">Mã vận đơn:</span>
            <span class="font-mono font-bold text-blue-600" id="shipTrackingCode">VTP-8839102VN</span>
          </div>
          <div class="flex justify-between border-b border-slate-100 pb-2">
            <span class="text-slate-500">Người nhận:</span>
            <span class="font-bold text-slate-800">Lê Hoàng Nam (0912.xxx.889)</span>
          </div>
          <div class="space-y-2 pt-2">
            <span class="font-bold text-slate-700 block">Lịch sử di chuyển gói hàng:</span>
            <div class="border-l-2 border-blue-500 pl-3 space-y-2 text-[11px]">
              <div>
                <span class="font-bold text-green-700">08:15 Hôm nay:</span>
                <p class="text-slate-600">Gói hàng đang trên xe bưu tá giao tới địa chỉ người nhận tại Cầu Giấy, Hà Nội.</p>
              </div>
              <div>
                <span class="font-bold text-slate-700">22:30 Hôm qua:</span>
                <p class="text-slate-600">Đã đến Kho trung chuyển Nội Bài, Hà Nội.</p>
              </div>
              <div>
                <span class="font-bold text-slate-700">14:00 Ngày 28/09:</span>
                <p class="text-slate-600">Người gửi đã bàn giao bưu kiện tại Bưu cục Bình Thạnh, TP.HCM.</p>
              </div>
            </div>
          </div>
        </div>

        <button onclick="closeShippingModal()" class="w-full py-2 bg-blue-600 hover:bg-blue-700 text-white font-bold text-xs rounded-lg transition">
          Đóng Cửa Sổ
        </button>
      </div>
    </div>

    <!-- MODAL ĐÁNH GIÁ 5 SAO KHI HOÀN TẤT ĐƠN HÀNG -->
    <div id="reviewModal" class="hidden fixed inset-0 bg-slate-900/50 backdrop-blur-xs z-50 flex items-center justify-center p-4">
      <div class="bg-white rounded-2xl shadow-2xl border border-slate-200 max-w-sm w-full p-6 text-center space-y-4">
        <div class="w-14 h-14 bg-green-100 rounded-full flex items-center justify-center mx-auto text-green-600 font-bold text-2xl">
          ✓
        </div>
        <div>
          <h3 class="font-bold text-base text-slate-900">Giao Dịch Hoàn Tất Xuất Sắc!</h3>
          <p class="text-xs text-slate-500 mt-1">Sàn đã giải ngân tiền thành công. Vui lòng đánh giá độ uy tín của đối tác.</p>
        </div>
        <div class="text-amber-400 text-2xl tracking-widest cursor-pointer">
          ★★★★★
        </div>
        <textarea rows="2" class="w-full px-3 py-2 bg-slate-50 border border-slate-300 rounded-lg text-xs" placeholder="Nhận xét: Giao dịch nhanh gọn, hàng đúng mô tả..."></textarea>
        <button onclick="closeReviewModal()" class="w-full py-2 bg-blue-600 hover:bg-blue-700 text-white font-bold text-xs rounded-lg transition shadow-sm">
          Gửi Đánh Giá Uy Tín
        </button>
      </div>
    </div>

    <!-- MODAL ĐÁNH GIÁ NGƯỜI BÁN THẬT (1 - 5 SAO & NHẬN XÉT CHỮ) -->
    <div id="orderReviewModal" class="hidden fixed inset-0 bg-slate-900/60 backdrop-blur-xs z-50 flex items-center justify-center p-4">
      <div class="bg-white rounded-2xl shadow-2xl border border-slate-200 max-w-md w-full p-6 space-y-4 text-left">
        <div class="flex items-center justify-between border-b border-slate-100 pb-3">
          <div>
            <h3 class="text-sm font-bold text-slate-900 uppercase">Đánh Giá Người Bán</h3>
            <p id="reviewModalSubtitle" class="text-xs text-slate-500 mt-0.5">Sản phẩm: ...</p>
          </div>
          <button type="button" onclick="closeOrderReviewModal()" class="text-slate-400 hover:text-slate-600 font-bold p-1">✕</button>
        </div>

        <form action="submit-review" method="POST" class="space-y-4">
          <input type="hidden" name="orderId" id="reviewModalOrderId" value="0">
          <input type="hidden" name="rating" id="reviewModalRating" value="5">

          <!-- CHỌN SỐ SAO -->
          <div>
            <label class="block text-xs font-semibold text-slate-700 mb-1.5">Mức độ hài lòng:</label>
            <div class="flex items-center gap-2">
              <div id="modalStarContainer" class="flex items-center gap-1.5 text-2xl text-amber-400 cursor-pointer">
                <span onclick="setOrderRating(1)">★</span>
                <span onclick="setOrderRating(2)">★</span>
                <span onclick="setOrderRating(3)">★</span>
                <span onclick="setOrderRating(4)">★</span>
                <span onclick="setOrderRating(5)">★</span>
              </div>
              <span id="modalRatingText" class="text-xs font-bold text-amber-800 bg-amber-50 px-2.5 py-0.5 rounded border border-amber-200">5/5 - Rất hài lòng</span>
            </div>
          </div>

          <!-- NHẬN XÉT CHỮ -->
          <div>
            <label class="block text-xs font-semibold text-slate-700 mb-1">Nhận xét chi tiết về người bán:</label>
            <textarea name="comment" rows="3" required class="w-full px-3 py-2 bg-slate-50 border border-slate-300 rounded-xl text-xs focus:ring-2 focus:ring-blue-500 focus:outline-none" placeholder="Chia sẻ trải nghiệm của bạn (Người bán nhiệt tình, đúng giờ hẹn, hàng đúng như mô tả...)..."></textarea>
            <p class="text-[10px] text-slate-400 mt-1">
              Đánh giá của bạn sẽ hiển thị công khai trên trang cá nhân của người bán để hỗ trợ cộng đồng.
            </p>
          </div>

          <div class="flex items-center gap-2 pt-2 border-t border-slate-100">
            <button type="button" onclick="closeOrderReviewModal()" class="flex-1 py-2 rounded-xl bg-slate-100 hover:bg-slate-200 text-slate-700 text-xs font-bold transition">
              Hủy bỏ
            </button>
            <button type="submit" class="flex-1 py-2 rounded-xl bg-amber-500 hover:bg-amber-600 text-slate-950 text-xs font-bold transition shadow-sm">
              Gửi Đánh Giá Ngay
            </button>
          </div>
        </form>
      </div>
    </div>

  </main>

  <!-- CHÂN TRANG ĐẦY ĐỦ 8 MÀN HÌNH -->
  <jsp:include page="includes/footer.jsp" />

  <!-- SCRIPT XỬ LÝ TOÀN BỘ LOGIC FLOW ĐƠN HÀNG, KHIẾU NẠI VÀ DUAL HANDSHAKE -->
  <script>
    function openRequestCancelModal(orderId, productTitle, depositAmount) {
      document.getElementById('cancelModalOrderId').value = orderId;
      document.getElementById('cancelModalProductTitle').textContent = productTitle;
      document.getElementById('cancelModalDeposit').textContent = new Intl.NumberFormat('vi-VN').format(depositAmount) + ' đ';
      const select = document.getElementById('cancelReasonPreset');
      if (select) {
        select.selectedIndex = 0;
        document.getElementById('cancelReasonInput').value = select.value;
      }
      document.getElementById('requestCancelModal').classList.remove('hidden');
    }

    function closeRequestCancelModal() {
      document.getElementById('requestCancelModal').classList.add('hidden');
    }

    function onCancelReasonSelect(val) {
      const input = document.getElementById('cancelReasonInput');
      if (val === 'custom') {
        input.value = '';
        input.placeholder = 'Vui lòng nhập lý do cụ thể gửi tới người bán...';
        input.focus();
      } else {
        input.value = val;
      }
    }

    function openRejectCancelModal(orderId) {
      document.getElementById('rejectModalOrderId').value = orderId;
      document.getElementById('rejectCancelModal').classList.remove('hidden');
    }

    function closeRejectCancelModal() {
      document.getElementById('rejectCancelModal').classList.add('hidden');
    }

    function filterOrders(type) {
      const cards = document.querySelectorAll('.order-card');
      const btnAll = document.getElementById('btnFilterAll');
      const btnCh1 = document.getElementById('btnFilterChannel1');
      const btnCh2 = document.getElementById('btnFilterChannel2');
      const btnBuy = document.getElementById('btnFilterBuy');
      const btnSell = document.getElementById('btnFilterSell');

      // Reset style nút
      [btnAll, btnCh1, btnCh2, btnBuy, btnSell].forEach(b => {
        if (!b) return;
        const shouldStayHidden = b.dataset.filterHidden === 'true';
        b.className = 'px-3.5 py-2 rounded-lg bg-white border border-slate-300 text-slate-700 hover:bg-slate-50 transition';
        if (shouldStayHidden) b.classList.add('hidden');
      });

      if (type === 'all') {
        btnAll.className = 'px-3.5 py-2 rounded-lg bg-blue-600 text-white transition shadow-xs';
        cards.forEach(c => c.classList.remove('hidden'));
      } else if (type === 'channel1') {
        btnCh1.className = 'px-3.5 py-2 rounded-lg bg-blue-600 text-white transition shadow-xs';
        cards.forEach(c => {
          if (c.dataset.channel === 'channel1') c.classList.remove('hidden');
          else c.classList.add('hidden');
        });
      } else if (type === 'channel2') {
        btnCh2.className = 'px-3.5 py-2 rounded-lg bg-blue-600 text-white transition shadow-xs';
        cards.forEach(c => {
          if (c.dataset.channel === 'channel2') c.classList.remove('hidden');
          else c.classList.add('hidden');
        });
      } else if (type === 'buy') {
        btnBuy.className = 'px-3.5 py-2 rounded-lg bg-blue-600 text-white transition shadow-xs';
        cards.forEach(c => {
          if (c.dataset.type === 'buy') c.classList.remove('hidden');
          else c.classList.add('hidden');
        });
      } else if (type === 'sell') {
        btnSell.className = 'px-3.5 py-2 rounded-lg bg-blue-600 text-white transition shadow-xs';
        cards.forEach(c => {
          if (c.dataset.type === 'sell') c.classList.remove('hidden');
          else c.classList.add('hidden');
        });
      }
    }

    // Xử lý tất toán sớm Kênh 2 Đơn 1
    function confirmEarlyRelease1() {
      const box = document.getElementById('escrowControlBox1');
      box.className = 'p-4 bg-green-50 border-2 border-green-400 rounded-xl space-y-2';
      box.innerHTML = `
        <div class="flex items-center justify-between">
          <span class="font-bold text-green-900 text-xs uppercase">ĐÃ TẤT TOÁN THÀNH CÔNG CHO NGƯỜI BÁN</span>
          <span class="text-[10px] text-green-700 bg-green-100 px-2 py-0.5 rounded font-bold">Đã Giải Ngân 14.800.000 đ</span>
        </div>
        <p class="text-[11px] text-green-800">
          Cảm ơn bạn đã xác nhận máy chuẩn! Số tiền đã được chuyển vào ví người bán. Giao dịch kết thúc an toàn.
        </p>
      `;
      document.getElementById('order1StatusBadge').innerText = 'Trạng thái: Đã hoàn tất • Đã giải ngân cho người bán';
      document.getElementById('order1StatusBadge').className = 'text-xs text-green-700 font-bold bg-green-100 px-3 py-1 rounded-full border border-green-300';
      
      showToast('Đã xác nhận máy đạt chuẩn và tất toán thành công!');
      setTimeout(() => {
        document.getElementById('reviewModal').classList.remove('hidden');
      }, 600);
    }

    // Xử lý Khiếu nại 48h Đơn 1
    function openDisputeModal() {
      document.getElementById('disputeModal').classList.remove('hidden');
    }
    function closeDisputeModal() {
      document.getElementById('disputeModal').classList.add('hidden');
    }
    function submitDispute() {
      closeDisputeModal();
      const box = document.getElementById('escrowControlBox1');
      box.className = 'p-4 bg-red-50 border-2 border-red-400 rounded-xl space-y-2';
      box.innerHTML = `
        <div class="flex items-center justify-between">
          <span class="font-bold text-red-900 text-xs uppercase">ĐANG ĐÓNG BĂNG TIỀN KÝ QUỸ - ADMIN ĐANG THẨM ĐỊNH</span>
          <span class="text-[10px] text-red-700 bg-red-100 px-2 py-0.5 rounded font-bold">Tranh Chấp #DS-88219</span>
        </div>
        <p class="text-[11px] text-red-800">
          Đơn hàng đã được tạm dừng giải ngân. Đội ngũ kiểm soát gian lận của MuaNgay đang liên hệ cả 2 bên để đối chiếu video mở hộp và hướng dẫn hoàn hàng hoàn tiền 100%.
        </p>
        <div class="pt-1">
          <a href="04-chat-tra-gia-vietqr.jsp" class="inline-block text-red-700 font-bold underline text-xs">Vào phòng chat phân xử 3 bên -></a>
        </div>
      `;
      document.getElementById('order1StatusBadge').innerText = 'Trạng thái: Đang khiếu nại • Đóng băng tiền 14.800.000 đ';
      document.getElementById('order1StatusBadge').className = 'text-xs text-red-700 font-bold bg-red-100 px-3 py-1 rounded-full border border-red-300';
      showToast('Đã mở khiếu nại và đóng băng tiền ký quỹ thành công!');
    }

    // Xử lý Giao nhận Kênh 1 Đơn 3 (Người mua xác nhận)
    function simulateBuyerConfirmOrder3() {
      const btn = document.getElementById('btnBuyerConfirm3');
      btn.innerText = 'Đã Xác Nhận Nhận Máy ✓';
      btn.className = 'px-3.5 py-2 bg-green-100 text-green-800 border border-green-300 font-bold text-xs rounded-lg cursor-not-allowed';
      btn.disabled = true;

      const badge = document.getElementById('order3StatusBadge');
      badge.innerText = 'Trạng thái: Người mua đã xác nhận • Đang chờ Người Bán bấm xác nhận';
      badge.className = 'text-xs text-blue-700 font-bold bg-blue-50 px-3 py-1 rounded-full border border-blue-200';

      const box = document.getElementById('order3DualBox');
      box.innerHTML = `
        <div>
          <span class="font-bold text-green-900 block">Bạn đã xác nhận thanh toán 36.000.000 đ thành công!</span>
          <p class="text-[11px] text-green-800 mt-0.5">
            Khi người bán (Nguyễn Văn Tuấn) mở app bấm xác nhận trên điện thoại của họ, Sàn sẽ lập tức chuyển 1.000.000 đ tiền cọc cho người bán.
          </p>
        </div>
        <button onclick="simulateSellerConfirmOrder3()" class="px-3.5 py-2 bg-amber-500 hover:bg-amber-600 text-slate-950 font-bold text-xs rounded-lg transition shadow-xs shrink-0">
          [Demo] Mô Phỏng Người Bán Bấm Xác Nhận
        </button>
      `;
      showToast('Bạn đã xác nhận trả tiền và nhận máy thành công!');
    }

    // === XỬ LÝ MODAL BÀN GIAO GẶP MẶT TRỰC TIẾP (HANDSHAKE QR & PIN) ===
    let activeHandshakeTarget = 'order3';

    function openHandshakeModal(target = 'order3') {
      activeHandshakeTarget = target;
      const modal = document.getElementById('handshakeModal');
      modal.classList.remove('hidden');
      document.getElementById('handshakeStepAuth').classList.remove('hidden');
      document.getElementById('handshakeStepSuccess').classList.add('hidden');

      if (target === 'order3') {
        document.getElementById('handshakeOrderSub').innerText = 'Mã đơn: #MN-DIR-10826 • Gặp mặt trực tiếp';
        document.getElementById('handshakeCashNeed').innerText = '36.000.000 đ';
        document.getElementById('handshakeEscrowHold').innerText = '1.000.000 đ (Giải ngân khi hoàn tất)';
        document.getElementById('handshakePinDisplay').innerText = '8912';
        document.getElementById('handshakePinInput').value = '8912';
        document.getElementById('handshakeReceiptCode').innerText = '#MN-REC-10826';
        document.getElementById('handshakeReceiptProduct').innerText = 'iPhone 18 Pro Max Đỏ Burgundy 256GB';
        document.getElementById('handshakeReceiptTotal').innerText = '37.000.000 đ';
        document.getElementById('handshakeReceiptEscrow').innerText = '1.000.000 đ (Chuyển ví người bán)';
        document.getElementById('handshakeReceiptCash').innerText = '36.000.000 đ';
        switchHandshakeRole('buyer');
      } else {
        document.getElementById('handshakeOrderSub').innerText = 'Mã đơn: #MN-DIR-08912 • Gặp mặt trực tiếp';
        document.getElementById('handshakeCashNeed').innerText = '900.000 đ';
        document.getElementById('handshakeEscrowHold').innerText = '200.000 đ (Giải ngân khi hoàn tất)';
        document.getElementById('handshakePinDisplay').innerText = '4521';
        document.getElementById('handshakePinInput').value = '4521';
        document.getElementById('handshakeReceiptCode').innerText = '#MN-REC-08912';
        document.getElementById('handshakeReceiptProduct').innerText = 'Bàn làm việc gỗ sồi tự nhiên 1m4';
        document.getElementById('handshakeReceiptTotal').innerText = '1.100.000 đ';
        document.getElementById('handshakeReceiptEscrow').innerText = '200.000 đ (Chuyển ví người bán)';
        document.getElementById('handshakeReceiptCash').innerText = '900.000 đ';
        switchHandshakeRole('seller');
      }
    }

    function closeHandshakeModal() {
      document.getElementById('handshakeModal').classList.add('hidden');
    }

    function switchHandshakeRole(role) {
      const btnSeller = document.getElementById('btnRoleSeller');
      const btnBuyer = document.getElementById('btnRoleBuyer');
      const sellerView = document.getElementById('sellerHandshakeView');
      const buyerView = document.getElementById('buyerHandshakeView');

      if (role === 'seller') {
        btnSeller.className = 'flex-1 py-1.5 rounded-md bg-white text-blue-700 shadow-xs transition text-center';
        btnBuyer.className = 'flex-1 py-1.5 rounded-md text-slate-600 hover:text-slate-900 transition text-center';
        sellerView.classList.remove('hidden');
        buyerView.classList.add('hidden');
      } else {
        btnBuyer.className = 'flex-1 py-1.5 rounded-md bg-white text-blue-700 shadow-xs transition text-center';
        btnSeller.className = 'flex-1 py-1.5 rounded-md text-slate-600 hover:text-slate-900 transition text-center';
        buyerView.classList.remove('hidden');
        sellerView.classList.add('hidden');
      }
    }

    function triggerSuccessfulHandshake() {
      showHandshakeSuccess();
    }

    function submitHandshakePin() {
      const pin = document.getElementById('handshakePinInput').value.trim();
      const expected = (activeHandshakeTarget === 'order3') ? '8912' : '4521';
      if (pin === expected || pin.length === 4) {
        showHandshakeSuccess();
      } else {
        alert('Mã PIN không đúng. Vui lòng nhập mã ' + expected + ' do đối tác cung cấp.');
      }
    }

    function showHandshakeSuccess() {
      document.getElementById('handshakeStepAuth').classList.add('hidden');
      document.getElementById('handshakeStepSuccess').classList.remove('hidden');
    }

    let currentRating = 5;
    function setRating(stars) {
      currentRating = stars;
      const spans = document.querySelectorAll('#starContainer span');
      spans.forEach((s, idx) => {
        if (idx < stars) {
          s.className = 'text-amber-400 font-bold';
        } else {
          s.className = 'text-slate-300';
        }
      });
    }

    function toggleTag(btn) {
      if (btn.classList.contains('bg-blue-50')) {
        btn.className = 'tag-badge px-2.5 py-0.5 rounded-full bg-slate-100 border border-slate-200 text-slate-700';
      } else {
        btn.className = 'tag-badge px-2.5 py-0.5 rounded-full bg-blue-50 border border-blue-300 text-blue-700 font-medium';
      }
    }

    function finishHandshakeFlow() {
      closeHandshakeModal();

      if (activeHandshakeTarget === 'order3') {
        simulateSellerConfirmOrder3();
      } else {
        simulateSellerConfirmOrder4();
      }
    }

    function simulateSellerConfirmOrder3() {
      const badge = document.getElementById('order3StatusBadge');
      badge.innerText = 'Trạng thái: CẢ HAI BÊN ĐÃ XÁC NHẬN • GIAO DỊCH THÀNH CÔNG';
      badge.className = 'text-xs text-green-700 font-bold bg-green-100 px-3 py-1 rounded-full border border-green-300';

      const box = document.getElementById('order3DualBox');
      box.className = 'p-3.5 bg-green-50 border border-green-300 rounded-lg text-xs space-y-1';
      box.innerHTML = `
        <span class="font-bold text-green-900 block text-xs uppercase">GIAO DỊCH HOÀN TẤT TỐT ĐẸP!</span>
        <p class="text-[11px] text-green-800">
          Cả hai bên đã hoàn tất giao dịch trực tiếp bằng mã QR/PIN. Tiền cọc 1.000.000 đ đã chuyển vào ví người bán và ghi nhận +5 điểm uy tín.
        </p>
      `;

      showToast('Giao dịch hoàn tất! Đã chuyển tiền cọc 1tr cho người bán.');
    }

    // Xử lý Xác nhận Giao nhận Kênh 1 Đơn 4 (Người bán xác nhận nhận tiền mặt)
    function simulateSellerConfirmOrder4() {
      const badge = document.getElementById('order4StatusBadge');
      badge.innerText = 'Trạng thái: CẢ HAI BÊN ĐÃ XÁC NHẬN • GIAO DỊCH THÀNH CÔNG';
      badge.className = 'text-xs text-green-700 font-bold bg-green-100 px-3 py-1 rounded-full border border-green-300';

      const box = document.getElementById('order4DualBox');
      box.className = 'p-3.5 bg-green-50 border border-green-300 rounded-lg text-xs space-y-1';
      box.innerHTML = `
        <div class="flex items-center justify-between">
          <span class="font-bold text-green-900 block text-xs uppercase">BÀN GIAO THÀNH CÔNG • ĐÃ MỞ KHÓA CỌC</span>
          <span class="text-[10px] text-green-700 bg-green-100 px-2 py-0.5 rounded font-bold">+200.000 đ vào ví</span>
        </div>
        <p class="text-[11px] text-green-800">
          Bạn đã xác nhận nhận đủ 900.000 đ tiền mặt từ người mua Trần Đình Trọng. Số tiền cọc 200.000 đ đã chuyển vào số dư khả dụng của bạn.
        </p>
      `;

      showToast('Đã xác nhận nhận 900k tiền mặt! Cọc 200k đã giải ngân vào ví.');
      setTimeout(() => {
        document.getElementById('reviewModal').classList.remove('hidden');
      }, 600);
    }

    // Tra cứu vận đơn
    function showShippingDetailsModal(code) {
      document.getElementById('shipTrackingCode').textContent = code;
      document.getElementById('shippingModal').classList.remove('hidden');
    }
    function closeShippingModal() {
      document.getElementById('shippingModal').classList.add('hidden');
    }

    function closeReviewModal() {
      document.getElementById('reviewModal').classList.add('hidden');
      showToast('Cảm ơn bạn đã gửi đánh giá uy tín!');
    }

    function showToast(msg) {
      const toast = document.getElementById('toastNotification');
      if (!toast) return;
      document.getElementById('toastMsg').textContent = msg;
      toast.classList.remove('hidden');
      setTimeout(() => {
        toast.classList.add('hidden');
      }, 3500);
    }

    // === XỬ LÝ ĐÁNH GIÁ NGƯỜI BÁN THẬT (1 - 5 SAO) ===
    let selectedOrderRating = 5;
    const ratingLabels = {
      1: '1/5 - Rất tệ',
      2: '2/5 - Không hài lòng',
      3: '3/5 - Bình thường',
      4: '4/5 - Hài lòng',
      5: '5/5 - Rất hài lòng'
    };

    function openOrderReviewModal(orderId, sellerName, productTitle) {
      document.getElementById('reviewModalOrderId').value = orderId;
      document.getElementById('reviewModalSubtitle').innerText = 'Người bán: ' + sellerName + ' • ' + productTitle;
      setOrderRating(5);
      document.getElementById('orderReviewModal').classList.remove('hidden');
    }

    function closeOrderReviewModal() {
      document.getElementById('orderReviewModal').classList.add('hidden');
    }

    function setOrderRating(rating) {
      selectedOrderRating = rating;
      document.getElementById('reviewModalRating').value = rating;
      document.getElementById('modalRatingText').innerText = ratingLabels[rating] || (rating + '/5');
      const spans = document.querySelectorAll('#modalStarContainer span');
      spans.forEach((span, index) => {
        if (index < rating) {
          span.className = 'text-amber-400 font-bold';
        } else {
          span.className = 'text-slate-300';
        }
      });
    }

    // Tự động cuộn đến đơn hàng và làm nổi bật khi truy cập từ thông báo (?orderId=...)
    window.addEventListener('DOMContentLoaded', () => {
      const urlParams = new URLSearchParams(window.location.search);
      const targetOrderId = urlParams.get('orderId') || (window.location.hash ? window.location.hash.replace('#order-card-db-', '').replace('#', '') : null);
      if (targetOrderId) {
        const card = document.getElementById('order-card-db-' + targetOrderId);
        if (card) {
          // Hiện tất cả đơn để đảm bảo không bị ẩn bởi filter
          if (typeof filterOrders === 'function') {
            filterOrders('all');
          }
          card.classList.remove('hidden');
          card.style.display = '';

          // Cuộn mượt mà đến đúng vị trí thẻ đơn hàng
          setTimeout(() => {
            card.scrollIntoView({ behavior: 'smooth', block: 'center' });
            // Hiệu ứng viền phát sáng nổi bật
            card.classList.add('ring-4', 'ring-blue-500', 'ring-offset-2', 'bg-blue-50/40', 'transition-all', 'duration-500');
            setTimeout(() => {
              card.classList.remove('ring-4', 'ring-blue-500', 'ring-offset-2', 'bg-blue-50/40');
            }, 3500);
          }, 300);
        }
      }
    });
  </script>

  <!-- ĐIỀU KHIỂN DROPDOWN ĐỔI TRẠNG THÁI GIAO HÀNG -->
  <script>
    function toggleStatusDropdown(orderId) {
      const menu = document.getElementById('status-menu-' + orderId);
      if (menu) {
        const isHidden = menu.classList.contains('hidden');
        document.querySelectorAll('[id^="status-menu-"]').forEach(el => el.classList.add('hidden'));
        if (isHidden) {
          menu.classList.remove('hidden');
        }
      }
    }
    document.addEventListener('click', function(e) {
      if (!e.target.closest('.dropdown-status-container')) {
        document.querySelectorAll('[id^="status-menu-"]').forEach(el => el.classList.add('hidden'));
      }
    });
  </script>

  <!-- TỰ ĐỘNG ĐỒNG BỘ TRẠNG THÁI GHN NGẦM (KHÔNG CẦN BẤM NÚT) -->
  <script>
    (function() {
      let isCheckingGhn = false;

      async function autoSyncActiveGhnOrders() {
        if (isCheckingGhn) return;
        const activeOrders = document.querySelectorAll('.order-card[data-ghn-active="true"]');
        if (!activeOrders || activeOrders.length === 0) return;

        isCheckingGhn = true;
        try {
          for (const card of activeOrders) {
            const orderId = card.dataset.orderId;
            if (!orderId) continue;

            const response = await fetch('order-action?action=ghn_sync_status&ajax=true&orderId=' + encodeURIComponent(orderId), {
              method: 'POST',
              headers: { 'X-Requested-With': 'XMLHttpRequest' }
            });

            if (response.ok) {
              const data = await response.json();
              if (data && data.statusChanged) {
                // Trạng thái đã thay đổi trên GHN (ví dụ: đã hủy hoặc đã giao) -> Tự động reload trang ngay lập tức!
                window.location.reload();
                return;
              }
            }
          }
        } catch (err) {
          // Bỏ qua lỗi ngầm
        } finally {
          isCheckingGhn = false;
        }
      }

      // 1. Tự động kiểm tra ngay sau khi mở trang 1 giây
      setTimeout(autoSyncActiveGhnOrders, 1000);

      // 2. Tự động kiểm tra ngay khi chuyển từ tab GHN quay lại tab web này!
      window.addEventListener('focus', () => {
        setTimeout(autoSyncActiveGhnOrders, 500);
      });

      // 3. Thăm dò định kỳ mỗi 6 giây một lần
      setInterval(autoSyncActiveGhnOrders, 6000);
    })();
  </script>
</body>
</html>
