<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.OrderSummary" %>
<%@ page import="model.User" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%
  OrderSummary order = (OrderSummary) request.getAttribute("order");
  User currentUser = (User) request.getAttribute("currentUser");
  String suggestedTrackingCode = (String) request.getAttribute("suggestedTrackingCode");
  if (order == null || currentUser == null) {
    response.sendRedirect("05-quan-ly-don-hang.jsp");
    return;
  }
  NumberFormat moneyFormat = NumberFormat.getInstance(new Locale("vi", "VN"));
  boolean isSeller = order.sellerId == currentUser.getId();
  boolean isBuyer = order.buyerId == currentUser.getId();
  boolean hasTracking = order.trackingCode != null && !order.trackingCode.trim().isEmpty();
  double codAmount = Math.max(0, order.agreedPrice - order.depositAmount);
  String activeTracking = hasTracking ? order.trackingCode : suggestedTrackingCode;
  String currentShippingStatus = order.shippingStatus != null ? order.shippingStatus : "CHO_LAY_HANG";

  String flashMsg = (String) session.getAttribute("orderFlashMessage");
  Boolean flashSuccess = (Boolean) session.getAttribute("orderFlashSuccess");
  session.removeAttribute("orderFlashMessage");
  session.removeAttribute("orderFlashSuccess");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>GHN Express Sandbox - Cổng Mô Phỏng Giao Hàng Nhanh</title>
  <link rel="icon" type="image/svg+xml" href="assets/logos/muangay-logo-icon.svg">
  <script src="https://cdn.tailwindcss.com"></script>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  <style>
    body { font-family: 'Inter', sans-serif; }
    .ghn-orange { background-color: #F26522; }
    .ghn-text-orange { color: #F26522; }
    .ghn-border-orange { border-color: #F26522; }
  </style>
</head>
<body class="bg-slate-100 min-h-screen text-slate-900 flex flex-col justify-between">

  <!-- TOP BAR: THÔNG BÁO SANDBOX -->
  <header class="ghn-orange text-white shadow-md">
    <div class="max-w-5xl mx-auto px-4 py-3 flex flex-wrap items-center justify-between gap-3">
      <div class="flex items-center gap-3">
        <!-- GHN Logo Concept -->
        <div class="bg-white text-orange-600 font-extrabold px-3 py-1 rounded-lg text-lg tracking-wider flex items-center gap-1 shadow-sm">
          <span>GHN</span>
          <span class="text-xs bg-orange-600 text-white px-1.5 py-0.5 rounded font-bold">Express</span>
        </div>
        <div>
          <h1 class="text-sm font-bold tracking-wide">GHN SANDBOX GATEWAY (MÔ PHỎNG VẬN ĐƠN)</h1>
          <p class="text-[11px] text-orange-100">Tích hợp giao vận thương mại điện tử MuaNgay</p>
        </div>
      </div>
      <div class="flex items-center gap-2">
        <span class="text-[11px] bg-black/25 px-2.5 py-1 rounded-full font-mono text-orange-100">
          Môi trường Thử nghiệm • Demo
        </span>
        <a href="05-quan-ly-don-hang.jsp" class="text-xs bg-white/20 hover:bg-white/30 text-white px-3 py-1 rounded-lg font-semibold transition">
          Quay lại Đơn Hàng
        </a>
      </div>
    </div>
  </header>

  <!-- NỘI DUNG CHÍNH -->
  <main class="max-w-5xl mx-auto px-4 py-6 w-full flex-1 space-y-6">

    <% if (flashMsg != null && !flashMsg.trim().isEmpty()) { %>
      <div id="ghn-flash-alert-banner" class="p-4 rounded-xl <%= Boolean.TRUE.equals(flashSuccess) ? "bg-green-50 border border-green-200 text-green-800" : "bg-red-50 border border-red-200 text-red-800" %> flex items-center justify-between shadow-xs text-xs font-semibold transition-all duration-500 ease-in-out">
        <div class="flex items-center gap-2">
          <span class="text-base"><%= Boolean.TRUE.equals(flashSuccess) ? "✓" : "⚠" %></span>
          <span><%= flashMsg %></span>
        </div>
        <button onclick="dismissGhnFlashAlert()" class="text-xs font-bold text-slate-400 hover:text-slate-600 cursor-pointer p-1">✕</button>
      </div>
      <script>
        function dismissGhnFlashAlert() {
          var el = document.getElementById('ghn-flash-alert-banner');
          if (el) {
            el.style.opacity = '0';
            el.style.transform = 'translateY(-8px)';
            setTimeout(function() {
              if (el && el.parentNode) el.parentNode.removeChild(el);
            }, 500);
          }
        }
        // Tự động biến mất sau 5 giây mà không cần bấm tắt
        setTimeout(dismissGhnFlashAlert, 5000);
      </script>
    <% } %>

    <!-- THẺ TRẠNG THÁI TỔNG QUAN ĐƠN HÀNG -->
    <div class="bg-white rounded-2xl shadow-sm border border-slate-200 p-5 space-y-4">
      <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-3 pb-3 border-b border-slate-100">
        <div class="flex items-center gap-2.5">
          <span class="px-2.5 py-1 rounded-lg text-xs font-bold bg-orange-50 text-orange-700 border border-orange-200">
            GHN Express TMĐT
          </span>
          <span class="text-xs font-mono font-semibold text-slate-500">Đơn hàng MuaNgay: #MN-<%= order.id %></span>
        </div>
        <div class="text-xs">
          <% if (hasTracking) { %>
            <span class="font-bold text-green-700 bg-green-50 border border-green-200 px-3 py-1 rounded-full">
              Đã phát hành mã vận đơn: <%= order.trackingCode %>
            </span>
          <% } else { %>
            <span class="font-bold text-amber-700 bg-amber-50 border border-amber-200 px-3 py-1 rounded-full">
              Chờ người bán tạo đơn vận chuyển
            </span>
          <% } %>
        </div>
      </div>

      <!-- THÔNG TIN SẢN PHẨM & TÀI CHÍNH -->
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4 text-xs">
        <div class="flex gap-3 md:col-span-2 items-center">
          <img src="<%= order.productImage %>" alt="<%= order.productTitle %>" class="w-16 h-16 rounded-xl object-cover border border-slate-200 shrink-0">
          <div class="space-y-1">
            <h2 class="font-bold text-slate-900 text-sm"><%= order.productTitle %></h2>
            <div class="text-slate-500 text-[11px]">
              Người bán: <strong><%= order.sellerName %></strong> • Người mua: <strong><%= order.buyerName %></strong>
            </div>
            <div class="flex flex-wrap gap-2 text-[11px] pt-0.5">
              <span class="text-slate-600">Giá chốt: <strong><%= moneyFormat.format(Math.round(order.agreedPrice)) %> đ</strong></span>
              <span class="text-green-600 font-semibold">• Đã cọc VNPay: <%= moneyFormat.format(Math.round(order.depositAmount)) %> đ</span>
            </div>
          </div>
        </div>

        <div class="bg-orange-50/70 border border-orange-200 rounded-xl p-3.5 space-y-1.5 flex flex-col justify-center">
          <div class="flex justify-between text-slate-600">
            <span>Tiền thu hộ COD:</span>
            <span class="font-bold text-base ghn-text-orange font-mono"><%= moneyFormat.format(Math.round(codAmount)) %> đ</span>
          </div>
          <div class="flex justify-between text-[11px] text-slate-500">
            <span>Phí bưu tá GHN:</span>
            <span class="font-semibold text-slate-700">Miễn phí (Demo)</span>
          </div>
          <div class="text-[10px] text-slate-500 italic pt-1 border-t border-orange-200/60">
            Số tiền thu hộ = Giá chốt trừ tiền cọc đã giữ qua VNPay.
          </div>
        </div>
      </div>
    </div>

    <% if (!hasTracking) { %>
      <!-- ======================================================== -->
      <!-- CHƯA CÓ VẬN ĐƠN: FORM PHÁT HÀNH MÃ VẬN ĐƠN GHN (NGƯỜI BÁN) -->
      <!-- ======================================================== -->
      <div class="bg-white rounded-2xl shadow-sm border border-slate-200 p-6 space-y-6">
        <div>
          <h3 class="text-base font-bold text-slate-900 flex items-center gap-2">
            <span class="w-6 h-6 rounded-full ghn-orange text-white text-xs flex items-center justify-center font-bold">1</span>
            Xác Nhận Tạo Đơn Vận Chuyển GHN Express
          </h3>
          <p class="text-xs text-slate-500 mt-1">
            Bưu tá GHN sẽ đối soát bưu kiện theo thông tin dưới đây để đến lấy hàng tại kho Người bán và giao đến Người mua.
          </p>
        </div>

        <form action="order-action" method="POST" class="space-y-5">
          <input type="hidden" name="action" value="ghn_create">
          <input type="hidden" name="orderId" value="<%= order.id %>">
          <input type="hidden" name="trackingCode" value="<%= suggestedTrackingCode %>">

          <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
            <!-- THÔNG TIN NGƯỜI GỬI (NGƯỜI BÁN) -->
            <div class="border border-slate-200 rounded-xl p-4 bg-slate-50/50 space-y-3 text-xs">
              <div class="font-bold text-slate-900 flex items-center gap-1.5 text-xs pb-1 border-b border-slate-200">
                <svg class="w-4 h-4 text-orange-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"/></svg>
                Địa Điểm Lấy Hàng (Kho Người Bán)
              </div>
              <div>
                <label class="block text-slate-500 text-[11px] mb-1">Người gửi hàng:</label>
                <input type="text" readonly value="<%= order.sellerName %> (<%= order.sellerPhone != null && !order.sellerPhone.isEmpty() ? order.sellerPhone : "Chưa có SĐT" %>)" class="w-full bg-white border border-slate-300 rounded-lg px-3 py-2 font-medium">
              </div>
              <div>
                <label class="block text-slate-500 text-[11px] mb-1">Địa chỉ lấy hàng:</label>
                <textarea rows="2" readonly class="w-full bg-white border border-slate-300 rounded-lg px-3 py-2 font-medium"><%= order.sellerAddress %></textarea>
              </div>
              <div class="text-[11px] text-orange-700 bg-orange-50 p-2 rounded-lg border border-orange-200">
                Bưu tá GHN sẽ liên hệ lấy hàng trong vòng 2 - 4 giờ làm việc.
              </div>
            </div>

            <!-- THÔNG TIN NGƯỜI NHẬN (NGƯỜI MUA) -->
            <div class="border border-slate-200 rounded-xl p-4 bg-slate-50/50 space-y-3 text-xs">
              <div class="font-bold text-slate-900 flex items-center gap-1.5 text-xs pb-1 border-b border-slate-200">
                <svg class="w-4 h-4 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"/></svg>
                Địa Điểm Giao Hàng (Khách Mua)
              </div>
              <div>
                <label class="block text-slate-500 text-[11px] mb-1">Người nhận hàng:</label>
                <input type="text" readonly value="<%= order.buyerName %> (<%= order.buyerPhone != null && !order.buyerPhone.isEmpty() ? order.buyerPhone : "Chưa có SĐT" %>)" class="w-full bg-white border border-slate-300 rounded-lg px-3 py-2 font-medium">
              </div>
              <div>
                <label class="block text-slate-500 text-[11px] mb-1">Địa chỉ giao hàng:</label>
                <textarea rows="2" readonly class="w-full bg-white border border-slate-300 rounded-lg px-3 py-2 font-medium"><%= order.buyerAddress %></textarea>
              </div>
              <div>
                <label class="block text-slate-500 text-[11px] mb-1">Ghi chú bưu tá (Người bán điều chỉnh nếu cần):</label>
                <input type="text" name="shippingNote" value="Cho xem hàng, dùng thử kiểm tra 48h theo quy định sàn MuaNgay" class="w-full bg-white border border-slate-300 rounded-lg px-3 py-2 font-medium focus:outline-none focus:ring-2 focus:ring-orange-500">
              </div>
            </div>
          </div>

          <!-- MÃ VẬN ĐƠN DỰ KIẾN CẤP PHÁT -->
          <div class="bg-gradient-to-r from-orange-50 to-amber-50 border border-orange-200 rounded-xl p-4 flex flex-col sm:flex-row sm:items-center justify-between gap-3 text-xs">
            <div>
              <span class="font-bold text-orange-950 block flex items-center gap-1.5">
                <span class="w-2 h-2 rounded-full bg-green-500 animate-pulse"></span>
                Kết nối Cổng GHN Sandbox API (5sao.ghn.dev)
              </span>
              <p class="text-[11px] text-orange-800 mt-0.5">
                Mã vận đơn chính thức sẽ do hệ thống GHN cấp phát tự động theo thời gian thực ngay khi bạn bấm nút xác nhận bên dưới.
              </p>
            </div>
            <div class="font-mono text-sm font-bold text-orange-700 bg-white px-3.5 py-2 rounded-xl border border-orange-300 shadow-xs tracking-wide text-center">
              GHN Sandbox API Auto-Generate
            </div>
          </div>

          <!-- NÚT HÀNH ĐỘNG -->
          <div class="flex items-center justify-end gap-3 pt-3 border-t border-slate-200">
            <a href="05-quan-ly-don-hang.jsp" class="px-5 py-2.5 rounded-xl border border-slate-300 text-slate-700 hover:bg-slate-50 font-bold text-xs transition">
              Hủy bỏ / Xem sau
            </a>
            <% if (isSeller) { %>
              <button type="submit" class="px-6 py-2.5 rounded-xl ghn-orange hover:bg-orange-600 text-white font-bold text-xs transition shadow-md flex items-center gap-2">
                <span>Xác Nhận Phát Hành Vận Đơn GHN</span>
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14 5l7 7m0 0l-7 7m7-7H3"/></svg>
              </button>
            <% } else { %>
              <span class="text-xs text-slate-500 italic">Đang chờ Người bán xác nhận tạo mã vận đơn GHN.</span>
            <% } %>
          </div>
        </form>
      </div>

    <% } else { %>
      <!-- ======================================================== -->
      <!-- ĐÃ CÓ VẬN ĐƠN: TIMELINE HÀNH TRÌNH & ĐIỀU KHIỂN SANDBOX -->
      <!-- ======================================================== -->
      <div class="bg-white rounded-2xl shadow-sm border border-slate-200 p-6 space-y-6">
        <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
          <div>
            <h3 class="text-base font-bold text-slate-900 flex items-center gap-2">
              <span class="w-6 h-6 rounded-full bg-green-600 text-white text-xs flex items-center justify-center font-bold">✓</span>
              Hành Trình Vận Đơn GHN Express: <span class="font-mono ghn-text-orange"><%= order.trackingCode %></span>
            </h3>
            <p class="text-xs text-slate-500 mt-1">
              Ghi chú bưu tá: "<%= order.shippingNote != null ? order.shippingNote : "Cho xem hàng" %>"
            </p>
          </div>
          <div class="flex flex-wrap items-center gap-2">
            <form action="order-action" method="POST" class="inline">
              <input type="hidden" name="action" value="ghn_sync_status">
              <input type="hidden" name="orderId" value="<%= order.id %>">
              <button type="submit" class="px-3.5 py-1.5 bg-blue-600 hover:bg-blue-700 text-white text-xs font-bold rounded-lg transition shadow-xs flex items-center gap-1.5" title="Gọi API GHN Sandbox để kiểm tra trạng thái mới nhất từ hệ thống 5sao.ghn.dev">
                <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/></svg>
                <span>Đồng Bộ Từ GHN Sandbox</span>
              </button>
            </form>
            <a href="https://5sao.ghn.dev/ops-live" target="_blank" rel="noopener noreferrer" class="px-3 py-1.5 bg-orange-50 hover:bg-orange-100 text-orange-700 text-xs font-semibold rounded-lg transition border border-orange-200 flex items-center gap-1" title="Mở trang quản trị 5sao.ghn.dev">
              <span>Mở 5sao.ghn.dev ↗</span>
            </a>
            <button onclick="navigator.clipboard.writeText('<%= order.trackingCode %>'); alert('Đã sao chép mã vận đơn!');" class="px-3 py-1.5 bg-slate-100 hover:bg-slate-200 text-slate-700 text-xs font-semibold rounded-lg transition border border-slate-300">
              Sao chép mã
            </button>
          </div>
        </div>

        <% boolean isOrderCancelled = "CANCELLED".equalsIgnoreCase(currentShippingStatus) || "CANCELLED".equalsIgnoreCase(order.status) || "CANCELED".equalsIgnoreCase(order.status); %>
        <% if (isOrderCancelled) { %>
          <div class="p-4 bg-red-50 border border-red-200 rounded-xl space-y-2 text-xs">
            <div class="flex items-center justify-between">
              <span class="font-bold text-red-900 uppercase flex items-center gap-1.5 text-xs">
                <svg class="w-4 h-4 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/></svg>
                Thông Báo: Đơn Hàng Đã Bị Hủy Trên GHN Express
              </span>
              <span class="px-2.5 py-0.5 bg-red-100 text-red-800 rounded font-bold text-[10px] border border-red-200">
                ĐÃ HỦY ĐƠN
              </span>
            </div>
            <div class="text-slate-800 leading-relaxed text-xs bg-white/70 p-2.5 rounded-lg border border-red-200/60">
              <span class="font-bold text-red-950">Lý do hủy:</span> 
              <span class="text-red-900 font-medium"><%= (order.shippingNote != null && !order.shippingNote.trim().isEmpty()) ? order.shippingNote : "Người bán đã thao tác hủy vận đơn trên cổng GHN Express." %></span>
            </div>
          </div>
        <% } %>

        <!-- PROGRESS BAR 4 BƯỚC CỦA GHN -->
        <%
          int step = 1;
          if ("DANG_GIAO".equalsIgnoreCase(currentShippingStatus)) step = 3;
          else if ("DA_GIAO".equalsIgnoreCase(currentShippingStatus) || "COMPLETED".equalsIgnoreCase(order.status)) step = 4;
          else if ("CHO_LAY_HANG".equalsIgnoreCase(currentShippingStatus)) step = 2;
        %>
        <div class="py-4">
          <div class="grid grid-cols-4 gap-2 text-center text-xs">
            <!-- BƯỚC 1 -->
            <div class="space-y-2">
              <div class="w-8 h-8 rounded-full <%= step >= 1 ? "bg-orange-500 text-white font-bold" : "bg-slate-200 text-slate-500" %> flex items-center justify-center mx-auto text-xs shadow-sm">
                1
              </div>
              <div class="font-bold <%= step >= 1 ? "text-orange-600" : "text-slate-400" %> text-[11px]">Đã tạo vận đơn</div>
              <div class="text-[10px] text-slate-400">Shop sẵn sàng</div>
            </div>

            <!-- BƯỚC 2 -->
            <div class="space-y-2">
              <div class="w-8 h-8 rounded-full <%= step >= 2 ? "bg-orange-500 text-white font-bold" : "bg-slate-200 text-slate-500" %> flex items-center justify-center mx-auto text-xs shadow-sm">
                2
              </div>
              <div class="font-bold <%= step >= 2 ? "text-orange-600" : "text-slate-400" %> text-[11px]">Bưu tá đã lấy hàng</div>
              <div class="text-[10px] text-slate-400">Nhập kho trung chuyển</div>
            </div>

            <!-- BƯỚC 3 -->
            <div class="space-y-2">
              <div class="w-8 h-8 rounded-full <%= step >= 3 ? "bg-orange-500 text-white font-bold" : "bg-slate-200 text-slate-500" %> flex items-center justify-center mx-auto text-xs shadow-sm">
                3
              </div>
              <div class="font-bold <%= step >= 3 ? "text-orange-600" : "text-slate-400" %> text-[11px]">Đang đi phát</div>
              <div class="text-[10px] text-slate-400">Shipper liên hệ người nhận</div>
            </div>

            <!-- BƯỚC 4 -->
            <div class="space-y-2">
              <div class="w-8 h-8 rounded-full <%= step >= 4 ? "bg-green-600 text-white font-bold" : "bg-slate-200 text-slate-500" %> flex items-center justify-center mx-auto text-xs shadow-sm">
                4
              </div>
              <div class="font-bold <%= step >= 4 ? "text-green-600" : "text-slate-400" %> text-[11px]">Giao thành công</div>
              <div class="text-[10px] text-slate-400">Khách kiểm tra 48h</div>
            </div>
          </div>
        </div>

        <!-- BẢNG ĐIỀU KHIỂN DÀNH CHO NGƯỜI BÁN (DEMO / SIMULATOR) -->
        <% if (isSeller) { %>
        <div class="bg-amber-50/80 border-2 border-dashed border-amber-300 rounded-xl p-4 space-y-3">
          <div class="flex items-center justify-between">
            <span class="text-xs font-bold text-amber-900 uppercase tracking-wide flex items-center gap-1.5">
              <svg class="w-4 h-4 text-amber-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6V4m0 2a2 2 0 100 4m0-4a2 2 0 110 4m-6 8a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4m6 6v10m6-2a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4"/></svg>
              Bảng Điều Khiển Giả Lập Shipper GHN (Dành Cho Người Bán Demo & Kiểm Thử)
            </span>
            <span class="text-[10px] text-amber-800 bg-amber-100 px-2 py-0.5 rounded font-semibold">Demo Shipper</span>
          </div>
          <p class="text-[11px] text-amber-800">
            Vì không gọi API thật của GHN, người bán có thể click các nút dưới đây để mô phỏng shipper cập nhật trạng thái gói hàng theo thời gian thực:
          </p>
          <div class="flex flex-wrap items-center gap-2.5 pt-1">
            <form action="order-action" method="POST" class="inline">
              <input type="hidden" name="action" value="ghn_update_status">
              <input type="hidden" name="orderId" value="<%= order.id %>">
              <input type="hidden" name="shippingStatus" value="CHO_LAY_HANG">
              <button type="submit" class="px-3.5 py-1.5 rounded-lg text-xs font-semibold bg-white border border-amber-300 hover:bg-amber-100 text-slate-800 transition shadow-xs">
                1. Mô phỏng: Bưu tá lấy hàng & nhập kho
              </button>
            </form>

            <form action="order-action" method="POST" class="inline">
              <input type="hidden" name="action" value="ghn_update_status">
              <input type="hidden" name="orderId" value="<%= order.id %>">
              <input type="hidden" name="shippingStatus" value="DANG_GIAO">
              <button type="submit" class="px-3.5 py-1.5 rounded-lg text-xs font-semibold bg-white border border-amber-300 hover:bg-amber-100 text-slate-800 transition shadow-xs">
                2. Mô phỏng: Shipper đang đi giao tới người nhận
              </button>
            </form>

            <form action="order-action" method="POST" class="inline">
              <input type="hidden" name="action" value="ghn_update_status">
              <input type="hidden" name="orderId" value="<%= order.id %>">
              <input type="hidden" name="shippingStatus" value="DA_GIAO">
              <button type="submit" class="px-3.5 py-1.5 rounded-lg text-xs font-semibold bg-green-600 hover:bg-green-700 text-white transition shadow-xs">
                3. Mô phỏng: Shipper đã giao thành công ✓
              </button>
            </form>
          </div>
        </div>
        <% } %>

        <!-- GIAO DIỆN THEO DÕI & HÀNH ĐỘNG DÀNH CHO NGƯỜI MUA -->
        <% if (isBuyer && !"COMPLETED".equalsIgnoreCase(order.status)) { %>
          <% boolean isDeliveredToBuyer = "DA_GIAO".equalsIgnoreCase(currentShippingStatus); %>
          <% if (isDeliveredToBuyer) { %>
            <div class="p-4 bg-green-50 border border-green-200 rounded-xl space-y-2">
              <div class="flex items-center justify-between">
                <span class="text-xs font-bold text-green-900 uppercase">Gói hàng đã được giao đến bạn:</span>
                <span class="text-[10px] text-green-700 bg-green-100 px-2 py-0.5 rounded font-semibold">Đã giao hàng</span>
              </div>
              <p class="text-[11px] text-green-800">
                Shipper GHN đã cập nhật giao hàng thành công. Khi bạn đã kiểm tra sản phẩm đạt chuẩn, vui lòng bấm nút xác nhận dưới đây để hoàn tất đơn hàng và giải ngân tiền cọc cho người bán:
              </p>
              <div class="pt-2">
                <form action="order-action" method="POST" onsubmit="return confirm('Bạn xác nhận đã nhận hàng từ shipper GHN và món đồ hoàn toàn đạt yêu cầu?');">
                  <input type="hidden" name="action" value="confirm_receipt">
                  <input type="hidden" name="orderId" value="<%= order.id %>">
                  <button type="submit" class="px-5 py-2.5 bg-green-600 hover:bg-green-700 text-white font-bold text-xs rounded-xl transition shadow-md flex items-center gap-2">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/></svg>
                    <span>Tôi Xác Nhận Đã Nhận Hàng & Tất Toán Đơn</span>
                  </button>
                </form>
              </div>
            </div>
          <% } else { %>
            <div class="p-4 bg-slate-50 border border-slate-200 rounded-xl space-y-2">
              <div class="flex items-center justify-between">
                <span class="text-xs font-bold text-slate-800 uppercase flex items-center gap-1.5">
                  <svg class="w-4 h-4 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                  Thông tin theo dõi đơn hàng (Dành cho Người Mua)
                </span>
                <span class="text-[10px] text-amber-700 bg-amber-50 border border-amber-200 px-2 py-0.5 rounded font-semibold">Đang vận chuyển</span>
              </div>
              <p class="text-xs text-slate-600 leading-relaxed">
                Trạng thái vận chuyển do bưu tá và hệ thống GHN tự động cập nhật. Khi shipper giao hàng thành công đến địa chỉ của bạn, hệ thống sẽ mở nút <strong>"Xác Nhận Đã Nhận Hàng"</strong> để bạn kiểm tra và giải ngân tiền cọc.
              </p>
            </div>
          <% } %>
        <% } %>

        <div class="flex items-center justify-between pt-3 border-t border-slate-200">
          <a href="05-quan-ly-don-hang.jsp" class="px-4 py-2 rounded-xl bg-slate-100 hover:bg-slate-200 text-slate-700 text-xs font-bold transition">
            ← Về Quản Lý Đơn Hàng
          </a>
          <a href="04-chat-tra-gia-vietqr.jsp" class="px-4 py-2 rounded-xl bg-blue-600 hover:bg-blue-700 text-white text-xs font-bold transition">
            Mở Khung Chat Với Đối Tác →
          </a>
        </div>
      </div>
    <% } %>

  </main>

  <!-- FOOTER -->
  <footer class="bg-white border-t border-slate-200 py-4 text-center text-xs text-slate-500">
    <div class="max-w-5xl mx-auto px-4">
      Mô phỏng tích hợp Cổng giao vận Giao Hàng Nhanh (GHN Express) cho Đồ án TMĐT MuaNgay.
    </div>
  </footer>

</body>
</html>
