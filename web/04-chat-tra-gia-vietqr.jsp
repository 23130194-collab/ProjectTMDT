<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%@ page import="dao.OrderDAO" %>
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

  private String initials(String name) {
    if (name == null || name.trim().isEmpty()) {
      return "TK";
    }
    String[] parts = name.trim().split("\\s+");
    String first = parts[0].substring(0, 1);
    String last = parts.length > 1 ? parts[parts.length - 1].substring(0, 1) : "";
    return (first + last).toUpperCase();
  }
%>
<%
  User chatCurrentUser = (User) session.getAttribute("user");
  boolean chatLoggedIn = chatCurrentUser != null;
  int chatOrderCount = chatLoggedIn ? new OrderDAO().countOrdersForUser(chatCurrentUser.getId()) : 0;
  String chatDisplayName = "";
  String chatAvatarImage = "";
  String chatAvatarText = "TK";
  if (chatLoggedIn) {
    chatDisplayName = chatCurrentUser.getFullName() != null && !chatCurrentUser.getFullName().trim().isEmpty()
            ? chatCurrentUser.getFullName().trim()
            : chatCurrentUser.getUsername();
    chatAvatarImage = chatCurrentUser.getAvatar() != null ? chatCurrentUser.getAvatar().trim() : "";
    chatAvatarText = initials(chatDisplayName);
  }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Tin Nhắn & Đàm Phán Trả Giá VNPay - MuaNgay</title>
  <link rel="icon" type="image/svg+xml" href="assets/logos/muangay-logo-icon.svg">
  <script src="https://cdn.tailwindcss.com"></script>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="css/style.css">
  <link rel="stylesheet" href="css/04-chat-tra-gia-vietqr.css">
</head>
<body class="bg-slate-100 text-slate-900 h-screen flex flex-col overflow-hidden">

  <!-- THANH ĐIỀU HƯỚNG CHÍNH -->
  <header class="bg-white border-b border-slate-200 h-14 flex items-center justify-between px-4 sm:px-6 shrink-0">
    <div class="flex items-center gap-3">
      <a href="home" class="flex items-center gap-2" aria-label="Về trang chủ MuaNgay">
        <img src="assets/logos/muangay-logo-icon.svg" alt="MuaNgay Logo" class="w-8 h-8 rounded-lg shadow-xs">
        <span class="text-base font-extrabold text-slate-900">Mua<span class="text-blue-600">Ngay</span></span>
      </a>
      <span class="text-slate-300">|</span>
      <span class="text-xs font-semibold text-slate-600">Đàm Phán Trả Giá & Ký Quỹ Bảo Đảm</span>
    </div>
    <div class="flex items-center gap-3">
      <a href="05-quan-ly-don-hang.jsp" class="text-xs font-semibold text-slate-700 hover:text-blue-600">
        Quản lý đơn hàng<%= chatLoggedIn ? " (" + chatOrderCount + ")" : "" %>
      </a>
      <a href="01-trang-chu.jsp" class="text-xs font-medium text-slate-500 hover:text-blue-600">Về trang chủ</a>
      <a href="<%= chatLoggedIn ? "08-ho-so-ca-nhan.jsp" : "07-dang-nhap-xac-thuc.jsp" %>" title="<%= chatLoggedIn ? h(chatDisplayName) : "Đăng nhập" %>" class="w-8 h-8 rounded-full bg-blue-600 text-white flex items-center justify-center text-xs font-bold overflow-hidden">
        <% if (chatLoggedIn && !chatAvatarImage.isEmpty()) { %>
          <img src="<%= h(chatAvatarImage) %>" alt="Ảnh đại diện" class="w-full h-full rounded-full object-cover">
        <% } else { %>
          <%= h(chatLoggedIn ? chatAvatarText : "ĐN") %>
        <% } %>
      </a>
    </div>
  </header>

  <!-- BỐ CỤC CHAT 2 CỘT -->
  <div class="flex-1 flex overflow-hidden max-w-7xl w-full mx-auto my-2 sm:my-3 bg-white border border-slate-200 rounded-xl shadow-sm">

    <!-- CỘT TRÁI (320px): DANH SÁCH CUỘC TRÒ CHUYỆN (CÓ TAB MUA / BÁN) -->
    <div class="w-72 sm:w-80 border-r border-slate-200 flex flex-col bg-slate-50 shrink-0">
      
      <!-- TABS CHUYỂN ĐỔI VAI TRÒ MUA VS BÁN -->
      <div class="flex border-b border-slate-200 bg-white text-xs font-bold shrink-0">
        <button onclick="switchRole('buyer')" id="roleBuyerBtn" class="flex-1 py-2.5 text-center text-blue-600 border-b-2 border-blue-600 transition">
          Tôi Là Người Mua (2)
        </button>
        <button onclick="switchRole('seller')" id="roleSellerBtn" class="flex-1 py-2.5 text-center text-slate-500 hover:text-slate-900 transition">
          Tôi Là Người Bán (2)
        </button>
      </div>

      <div class="p-2.5 border-b border-slate-200 bg-white">
        <input 
          id="searchChatInput"
          type="text" 
          placeholder="Tìm kiếm cuộc trò chuyện..." 
          class="w-full px-3 py-1.5 bg-slate-100 border border-slate-200 rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-blue-500"
        >
      </div>

      <!-- DANH SÁCH HỘI THOẠI KHI LÀ NGƯỜI MUA -->
      <div id="buyerThreadsList" class="flex-1 overflow-y-auto divide-y divide-slate-100">
        
        <!-- CUỘC TRÒ CHUYỆN 1 (IPHONE 18 PRO MAX - ĐANG CHỌN) -->
        <div onclick="selectBuyerThread(1)" id="buyer-thread-1" class="chat-thread p-3 bg-blue-50/90 border-l-4 border-blue-600 cursor-pointer transition">
          <div class="flex items-center justify-between">
            <span class="font-bold text-xs text-slate-900">Nguyễn Văn Tuấn (Người Bán)</span>
            <span class="text-[10px] text-slate-400">10:45</span>
          </div>
          <div class="text-xs font-semibold text-blue-800 mt-0.5 truncate">iPhone 18 Pro Max Đỏ Burgundy 256GB</div>
          <p class="text-[11px] text-slate-500 truncate mt-0.5">Đã chốt giá: 37.000.000 đ • Đã cọc 1tr</p>
        </div>

        <!-- CUỘC TRÒ CHUYỆN 2 (IPHONE 13 PRO MAX) -->
        <div onclick="selectBuyerThread(2)" id="buyer-thread-2" class="chat-thread p-3 hover:bg-slate-100 cursor-pointer transition">
          <div class="flex items-center justify-between">
            <span class="font-bold text-xs text-slate-800">Trần Quốc Bảo (Người Bán)</span>
            <span class="text-[10px] text-slate-400">09:15</span>
          </div>
          <div class="text-xs font-semibold text-slate-700 mt-0.5 truncate">iPhone 13 Pro Max 128GB VN/A</div>
          <p class="text-[11px] text-green-700 font-medium truncate mt-0.5">Ship 3PL đang kiểm tra 48h</p>
        </div>

      </div>

      <!-- DANH SÁCH HỘI THOẠI KHI LÀ NGƯỜI BÁN -->
      <div id="sellerThreadsList" class="flex-1 overflow-y-auto divide-y divide-slate-100 hidden">
        
        <!-- CUỘC TRÒ CHUYỆN BÁN 1 (BÀN GỖ) -->
        <div onclick="selectSellerThread(1)" id="seller-thread-1" class="chat-thread p-3 bg-blue-50/90 border-l-4 border-blue-600 cursor-pointer transition">
          <div class="flex items-center justify-between">
            <span class="font-bold text-xs text-slate-900">Lê Minh Khang (Khách Mua)</span>
            <span class="text-[10px] text-slate-400">11:20</span>
          </div>
          <div class="text-xs font-semibold text-blue-800 mt-0.5 truncate">Bàn làm việc gỗ thông 1m2</div>
          <p class="text-[11px] text-slate-500 truncate mt-0.5">Chiều 16h em qua chở bàn nhé anh!</p>
        </div>

        <!-- CUỘC TRÒ CHUYỆN BÁN 2 (MÁY GIẶT) -->
        <div onclick="selectSellerThread(2)" id="seller-thread-2" class="chat-thread p-3 hover:bg-slate-100 cursor-pointer transition">
          <div class="flex items-center justify-between">
            <span class="font-bold text-xs text-slate-800">Hoàng Thị Yến (Khách Mua)</span>
            <span class="text-[10px] text-slate-400">Hôm qua</span>
          </div>
          <div class="text-xs font-semibold text-slate-700 mt-0.5 truncate">Máy giặt Electrolux 8kg</div>
          <p class="text-[11px] text-amber-700 font-bold truncate mt-0.5">Đang đề xuất trả giá: 3.500.000 đ</p>
        </div>

      </div>

    </div>

    <!-- CỘT PHẢI: CỬA SỔ CHAT, ĐÀM PHÁN VÀ DUAL HANDSHAKE -->
    <div class="flex-1 flex flex-col bg-white overflow-hidden relative">

      <!-- HEADER CỬA SỔ CHAT -->
      <div class="p-3 border-b border-slate-200 flex items-center justify-between bg-white shrink-0">
        <div class="flex items-center gap-3">
          <div id="targetAvatar" class="w-9 h-9 rounded-full bg-blue-600 text-white font-bold text-xs flex items-center justify-center shrink-0">
            NV
          </div>
          <div>
            <div id="targetName" class="font-bold text-xs sm:text-sm text-slate-900">Nguyễn Văn Tuấn (Người Bán)</div>
            <div id="targetStatus" class="text-[11px] text-green-600 font-medium">Đang trực tuyến • Quận 10, TP. Hồ Chí Minh</div>
          </div>
        </div>

        <a id="productHeaderLink" href="02-chi-tiet-san-pham.jsp" class="flex items-center gap-2.5 bg-slate-50 hover:bg-slate-100 border border-slate-200 px-3 py-1.5 rounded-lg transition" title="Xem chi tiết sản phẩm">
          <img id="productThumb" src="assets/images/iphone-18-pro-mau-do-anh-dao-dam-1-iphone-18-pro-mau-do-burgundy-co-gi-dac-biet-1.jpg" class="w-8 h-8 rounded object-cover">
          <div>
            <div id="productTitle" class="text-xs font-bold text-slate-800 line-clamp-1 max-w-[150px] sm:max-w-[200px]">iPhone 18 Pro Max Đỏ Burgundy 256GB</div>
            <div id="productPrice" class="text-[11px] font-bold text-red-600">Giá gốc: 38.000.000 đ</div>
          </div>
        </a>
      </div>

      <!-- BANNER CẢNH BÁO AN TOÀN -->
      <div class="bg-amber-50 border-b border-amber-200 px-4 py-1.5 text-[11px] text-amber-900 flex items-center justify-between shrink-0">
        <span>
          <strong>Lưu ý an toàn:</strong> MuaNgay tự động che số điện thoại và STK để bảo vệ bạn khỏi lừa đảo. Thanh toán đặt cọc qua cổng VNPay để sàn ghi nhận giao dịch.
        </span>
        <span class="text-amber-700 font-bold ml-2 shrink-0">Giao Dịch Đảm Bảo</span>
      </div>

      <!-- NỘI DUNG CUỘC TRÒ CHUYỆN -->
      <div id="messagesContainer" class="flex-1 overflow-y-auto p-4 space-y-4 bg-slate-50">
        
        <div class="text-center">
          <span class="text-[10px] font-semibold text-slate-400 bg-slate-200 px-2 py-0.5 rounded-full uppercase tracking-wider">
            Hôm nay 10:30
          </span>
        </div>

        <!-- TIN NHẮN 1 -->
        <div class="flex justify-end">
          <div class="bg-blue-600 text-white p-3 rounded-2xl rounded-tr-none text-xs max-w-md shadow-sm">
            Chào anh Tuấn, iPhone 18 Pro Max Đỏ Burgundy này pin chuẩn 100% và fullbox trùng IMEI chứ ạ? Chiều nay em qua test máy trực tiếp được không?
          </div>
        </div>

        <!-- TIN NHẮN 2 -->
        <div class="flex justify-start">
          <div class="bg-white border border-slate-200 text-slate-800 p-3 rounded-2xl rounded-tl-none text-xs max-w-md shadow-sm">
            Chào bạn, máy mình đẹp keng 99.9% không một vết xước, bảo hành Apple Care chính hãng. Bạn cứ qua cắm 3uTools kiểm tra thoải mái tại nhà mình ở Phường 13, Quận 10 nhé.
          </div>
        </div>

        <!-- THẺ ĐỀ XUẤT TRẢ GIÁ (OFFER CARD) -->
        <div class="flex justify-center my-1" id="offerCardBlock">
          <div class="bg-amber-50 border-2 border-amber-400 rounded-xl p-4 w-full max-w-md shadow-sm space-y-2.5">
            <div class="flex items-center justify-between border-b border-amber-200 pb-1.5">
              <span class="text-[11px] font-bold text-amber-900 uppercase tracking-wider">Đề Xuất Trả Giá Mới</span>
              <span id="offerStatusBadge" class="text-[10px] text-green-700 font-bold bg-green-100 px-1.5 py-0.5 rounded">Người bán đã đồng ý</span>
            </div>
            <div class="flex items-baseline justify-between">
              <div>
                <span class="text-[11px] text-slate-600 block">Giá chốt giao dịch:</span>
                <span id="offerPriceDisplay" class="text-xl font-bold text-red-600">37.000.000 đ</span>
              </div>
              <span class="text-xs text-slate-400 line-through">Giá gốc: 38.000.000 đ</span>
            </div>
            <p id="offerNoteDisplay" class="text-[11px] text-amber-900 italic">
              Lời nhắn: "Em qua xem và test máy trực tiếp trong chiều nay, anh bớt em 1 triệu lấy lộc nhé!"
            </p>
            <div class="pt-1 text-[11px] text-slate-600 bg-white/70 p-2 rounded border border-amber-200">
              Tiền cọc giữ sản phẩm (10% giá đã chốt): <strong class="text-slate-900">3.700.000 đ</strong>.
              Số tiền còn lại <strong class="text-slate-900">33.300.000 đ</strong> thanh toán trực tiếp khi nhận sản phẩm.
            </div>
          </div>
        </div>

        <!-- KHỐI XÁC NHẬN NHẬN ĐỒ TẠI ĐIỂM HẸN -->
        <div class="hidden flex justify-center my-2" id="dualHandshakeBlock">
          <div class="bg-blue-50 border-2 border-blue-400 rounded-xl p-4 w-full max-w-md shadow-sm space-y-3">
            <div class="flex items-center justify-between border-b border-blue-200 pb-2">
              <span class="text-xs font-bold text-blue-900 uppercase tracking-wider">
                Xác Nhận Đã Nhận Máy & Trả Tiền
              </span>
              <span class="text-[10px] text-blue-700 font-semibold">Gặp Mặt Trực Tiếp</span>
            </div>

            <p class="text-[11px] text-slate-600 leading-relaxed">
              Hai bên gặp mặt tại điểm hẹn và kiểm tra sản phẩm. Cả hai cùng xác nhận để sàn giải ngân khoản cọc 10% giá đã chốt cho người bán:
            </p>

            <div class="space-y-2">
              <div class="flex items-center justify-between p-2 bg-white rounded-lg border border-slate-200 text-xs">
                <span class="text-slate-700">Người Mua:</span>
                <span id="buyerHandshakeStatus" class="text-green-700 font-bold bg-green-50 px-2 py-0.5 rounded border border-green-200">
                  Đã xác nhận nhận máy & trả tiền
                </span>
              </div>

              <div class="flex items-center justify-between p-2 bg-white rounded-lg border border-slate-200 text-xs">
                <span class="text-slate-700">Người Bán (Nguyễn Văn Tuấn):</span>
                <button id="sellerConfirmBtn" onclick="openHandshakeModal()" class="px-3 py-1 bg-green-600 hover:bg-green-700 text-white font-bold rounded text-[11px] shadow-sm transition">
                  Mở Bàn Giao (QR / PIN)
                </button>
              </div>
            </div>

            <button onclick="openHandshakeModal()" class="w-full py-2 bg-blue-600 hover:bg-blue-700 text-white font-bold rounded-lg text-xs shadow-sm transition text-center">
              Mở Giao Diện Bàn Giao Tại Chỗ (Mã QR & Mã PIN 4 Số)
            </button>

            <div id="handshakeFooterNote" class="text-[10px] text-slate-500 italic">
              Khi hai bên xác nhận bàn giao, Sàn sẽ chuyển khoản cọc 10% giá đã chốt vào tài khoản của Người Bán và tích lũy điểm uy tín cho cả hai bên.
            </div>
          </div>
        </div>

      </div>

      <!-- THANH ĐẶT CỌC VNPAY NHANH -->
      <div id="quickDepositBar" class="hidden px-4 py-2 bg-amber-50 border-t border-amber-200 flex items-center justify-between text-xs shrink-0">
        <span class="text-amber-900 font-medium text-[11px]">
          Giá đã chốt: 37.000.000 đ. Đặt cọc 10% (3.700.000 đ) qua VNPay để giữ sản phẩm!
        </span>
        <button onclick="openQrModal()" class="px-3 py-1.5 bg-amber-600 hover:bg-amber-700 text-white font-bold text-xs rounded-md shadow-sm transition shrink-0">
          Thanh toán cọc VNPay
        </button>
      </div>

      <!-- THANH NHẬP LIỆU GỬI TIN NHẮN -->
      <div class="p-3 border-t border-slate-200 bg-white flex flex-wrap sm:flex-nowrap items-center gap-2 shrink-0">
        <div id="chatQuickActions" class="flex items-center gap-1.5">
          <button onclick="sendQuickAction('image')" class="px-2.5 py-1.5 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-lg text-xs font-semibold whitespace-nowrap transition border border-slate-200">
            Gửi Ảnh
          </button>
          <button onclick="openOfferModal()" class="px-2.5 py-1.5 bg-amber-50 hover:bg-amber-100 text-amber-900 rounded-lg text-xs font-semibold whitespace-nowrap transition border border-amber-300">
            Trả Giá
          </button>
          <button onclick="sendQuickAction('location')" class="px-2.5 py-1.5 bg-blue-50 hover:bg-blue-100 text-blue-800 rounded-lg text-xs font-semibold whitespace-nowrap transition border border-blue-200">
            Hẹn Gặp
          </button>
        </div>
        <form onsubmit="handleSendMessage(event)" class="flex-1 flex items-center gap-2 w-full sm:w-auto">
          <input id="chatImageInput" type="file" accept="image/*" class="hidden" onchange="handleImageSelected(event)">
          <input 
            id="chatInput"
            type="text" 
            placeholder="Nhập tin nhắn đàm phán (Enter để gửi)..." 
            class="flex-1 px-3 py-1.5 bg-slate-100 border border-slate-200 rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-blue-500 focus:bg-white"
          >
          <button type="submit" class="px-4 py-1.5 bg-blue-600 hover:bg-blue-700 text-white text-xs font-semibold rounded-lg shadow-sm transition shrink-0">
            Gửi
          </button>
        </form>
      </div>

      <!-- CỬA SỔ BẬT LÊN (MODAL): THANH TOÁN CỌC VNPAY 10% -->
      <div id="qrModal" class="hidden absolute inset-0 bg-slate-900/50 backdrop-blur-xs z-50 flex items-center justify-center p-4">
        <div class="bg-white rounded-2xl shadow-2xl border border-slate-200 max-w-sm w-full p-5 space-y-3.5 text-center transform transition-all scale-100">
          
          <div class="flex items-center justify-between border-b border-slate-100 pb-2.5">
            <span class="text-xs font-bold text-slate-900 uppercase">Đặt cọc giữ sản phẩm qua VNPay</span>
            <button onclick="closeQrModal()" class="text-sm text-slate-400 font-bold hover:text-slate-700 p-1">✕</button>
          </div>

          <div class="p-5 bg-blue-50 border border-blue-200 rounded-xl text-center">
            <div class="text-2xl font-extrabold tracking-wide text-blue-700">VNPAY</div>
            <p class="mt-2 text-xs text-slate-600">Bạn sẽ được chuyển đến cổng VNPay Sandbox để thanh toán đặt cọc.</p>
          </div>

          <div class="space-y-0.5">
            <div id="qrDepositRule" class="text-[11px] text-slate-500">Số tiền đặt cọc theo mức giá đã chốt:</div>
            <div id="qrDepositAmount" class="text-xl font-bold text-green-600">0 đ</div>
            <div class="text-[10px] text-slate-500">Mã giao dịch: <strong id="qrTransferReference" class="text-slate-900 font-mono bg-slate-100 px-1 py-0.5 rounded">Tạo khi thanh toán</strong></div>
            <p id="depositExpiryNotice" class="hidden mt-2 text-[11px] font-bold text-red-600">Trong vòng 15 phút nếu không tiến hành đặt cọc sẽ hủy giao dịch.</p>
            <p id="depositCountdown" class="hidden text-[11px] font-semibold text-red-600"></p>
          </div>

          <form id="vnpayPaymentForm" action="vnpay-create" method="post">
            <input id="vnpayConversationId" type="hidden" name="conversationId" value="">
            <input id="vnpayPaymentType" type="hidden" name="paymentType" value="DEPOSIT">
            <button type="submit" class="w-full py-2.5 bg-blue-600 hover:bg-blue-700 text-white font-bold text-xs rounded-lg transition shadow-sm">
              Thanh toán đặt cọc qua VNPay Sandbox
            </button>
          </form>

        </div>
      </div>

      <!-- CỬA SỔ BẬT LÊN (MODAL): YÊU CẦU CẬP NHẬT ĐỊA CHỈ CHO ĐƠN GIAO QUA GHN -->
      <div id="requireAddressModal" class="hidden absolute inset-0 bg-slate-900/50 backdrop-blur-xs z-50 flex items-center justify-center p-4">
        <div class="bg-white rounded-2xl shadow-2xl border border-slate-200 max-w-sm w-full p-5 space-y-4 text-center transform transition-all scale-100">
          <div class="mx-auto flex h-14 w-14 items-center justify-center rounded-full bg-amber-100 text-amber-600">
            <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"/>
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"/>
            </svg>
          </div>
          <div>
            <h3 class="text-sm font-bold text-slate-900 uppercase">Cần Cập Nhật Địa Chỉ Nhận Hàng</h3>
            <p class="mt-2 text-xs text-slate-600 leading-relaxed text-left">
              Đơn hàng này được người bán đăng ký <strong>Giao hàng qua bưu điện / shipper (GHN Express)</strong>. 
              Bạn cần có đầy đủ <strong>địa chỉ nhận hàng (Tỉnh/Thành phố, Phường/Xã, Số nhà - Tên đường)</strong> thì mới có thể tính phí vận chuyển và tạo đơn giao hàng.
            </p>
            <div class="mt-3 p-2.5 bg-amber-50 border border-amber-200 rounded-lg text-left text-[11px] text-amber-900">
              <p class="font-semibold">⚠️ Tài khoản của bạn chưa có thông tin địa chỉ đầy đủ.</p>
              <p class="mt-0.5 text-slate-600">Vui lòng cập nhật thông tin trong <strong>Hồ sơ cá nhân</strong> trước khi tiến hành thanh toán đặt cọc.</p>
            </div>
          </div>
          <div class="pt-1 flex flex-col gap-2">
            <a id="btnGoToUpdateAddress" href="08-ho-so-ca-nhan.jsp?openEdit=1" class="w-full py-2.5 bg-blue-600 hover:bg-blue-700 text-white font-bold text-xs rounded-lg transition shadow-sm flex items-center justify-center gap-1.5">
              <span>Cập nhật địa chỉ trong Hồ sơ</span>
              <span>&rarr;</span>
            </a>
            <button type="button" onclick="closeRequireAddressModal()" class="w-full py-2 border border-slate-200 hover:bg-slate-50 text-slate-700 font-semibold text-xs rounded-lg transition">
              Để sau
            </button>
          </div>
        </div>
      </div>

      <!-- MODAL TRẢ GIÁ (OFFER MODAL) -->
      <div id="offerModal" class="hidden absolute inset-0 bg-slate-900/50 backdrop-blur-xs z-50 flex items-center justify-center p-4">
        <div class="bg-white rounded-2xl shadow-2xl border border-slate-200 max-w-sm w-full p-5 space-y-3.5 text-left">
          <div class="flex items-center justify-between border-b border-slate-100 pb-2.5">
            <span class="text-xs font-bold text-slate-900 uppercase">Gửi Đề Xuất Trả Giá (Make Offer)</span>
            <button onclick="closeOfferModal()" class="text-sm text-slate-400 font-bold hover:text-slate-700 p-1">✕</button>
          </div>
          <div>
            <label class="block text-xs font-medium text-slate-700 mb-1">Mức giá bạn muốn đề xuất (VNĐ):</label>
            <input id="customOfferPrice" type="number" value="37000000" step="500000" class="w-full px-3 py-2 bg-slate-100 border border-slate-300 rounded-lg text-xs font-bold text-green-700 focus:outline-none focus:ring-2 focus:ring-blue-500">
            <p id="offerProductHint" class="mt-1 text-[10px] text-slate-500"></p>
          </div>
          <div>
            <label class="block text-xs font-medium text-slate-700 mb-1">Lời nhắn gửi đối tác:</label>
            <textarea id="customOfferNote" rows="2" class="w-full px-3 py-1.5 bg-slate-100 border border-slate-300 rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-blue-500">Em qua xem và test máy trực tiếp trong chiều nay, bớt em 1 triệu lấy lộc nhé anh!</textarea>
          </div>
          <button onclick="submitCustomOffer()" class="w-full py-2.5 bg-amber-500 hover:bg-amber-600 text-slate-950 font-bold text-xs rounded-lg transition shadow-sm">
            Gửi Đề Xuất Trả Giá
          </button>
        </div>
      </div>

      <!-- CỬA SỔ BẬT LÊN (MODAL): XÁC NHẬN BÀN GIAO TRỰC TIẾP (MÃ QR & MÃ PIN 4 SỐ) -->
      <div id="handshakeModal" class="hidden absolute inset-0 bg-slate-900/60 backdrop-blur-xs z-50 flex items-center justify-center p-4 overflow-y-auto">
        <div class="bg-white rounded-2xl shadow-2xl border border-slate-200 max-w-md w-full p-5 space-y-4 text-left my-auto">
          
          <!-- TIÊU ĐỀ MODAL -->
          <div class="flex items-center justify-between border-b border-slate-100 pb-3">
            <div>
              <h3 class="text-xs font-bold text-slate-900 uppercase">Xác Nhận Bàn Giao Tại Điểm Hẹn</h3>
              <p class="text-[10px] text-slate-500 mt-0.5">Mã đơn: #MN-DIR-10826 • Gặp mặt trực tiếp</p>
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
                  <span class="font-bold text-red-600 text-sm">36.000.000 đ</span>
                </div>
                <div class="flex justify-between text-[11px] text-amber-700">
                  <span>Tiền cọc sàn đang giữ:</span>
                  <span class="font-medium text-slate-900">3.700.000 đ (10% giá chốt, giải ngân khi hoàn tất)</span>
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
                  <span class="text-xl font-mono font-bold tracking-widest text-slate-900">8912</span>
                  <span class="text-[10px] text-blue-700 bg-blue-50 px-2 py-0.5 rounded font-semibold">Đọc cho người mua</span>
                </div>
              </div>

              <div class="pt-1 text-xs text-slate-500 text-left bg-slate-50 p-2.5 rounded-lg border border-slate-200">
                <strong>Hướng dẫn:</strong> Đưa mã QR này cho người mua quét hoặc đọc mã số <strong>8912</strong> sau khi đã nhận đủ 36.000.000 đ tiền mặt.
              </div>
            </div>

            <!-- GIAO DIỆN DÀNH CHO NGƯỜI MUA -->
            <div id="buyerHandshakeView" class="hidden space-y-3.5">
              <div class="p-2.5 bg-blue-50 rounded-xl border border-blue-200 text-xs text-blue-900 leading-relaxed">
                Sau khi test kỹ máy và đã giao 36.000.000 đ tiền mặt cho anh Tuấn, hãy chọn 1 trong 2 cách xác nhận:
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
              <h4 class="text-xs font-bold text-green-900 pt-1">Đã Bàn Giao Máy & Mở Khóa Tiền Cọc!</h4>
              <p class="text-[11px] text-green-800">
                Sàn đã giải ngân khoản cọc 10% giá chốt cho Người Bán.
              </p>
            </div>

            <!-- BIÊN NHẬN ĐIỆN TỬ -->
            <div class="bg-slate-50 border border-slate-200 rounded-xl p-3 space-y-1.5 text-xs">
              <div class="font-bold text-slate-900 border-b border-slate-200 pb-1 flex justify-between text-[11px]">
                <span>Biên Nhận Bàn Giao Trực Tiếp</span>
                <span class="text-blue-600 font-mono">#MN-REC-10826</span>
              </div>
              <div class="space-y-1 text-[11px]">
                <div class="flex justify-between">
                  <span class="text-slate-500">Sản phẩm:</span>
                  <span class="font-semibold text-slate-800">iPhone 18 Pro Max Đỏ Burgundy 256GB</span>
                </div>
                <div class="flex justify-between">
                  <span class="text-slate-500">Tổng thanh toán:</span>
                  <span class="font-bold text-slate-900">37.000.000 đ</span>
                </div>
                <div class="flex justify-between text-green-700">
                  <span>Tiền cọc giải ngân:</span>
                  <span>10% giá chốt (Chuyển ví người bán)</span>
                </div>
                <div class="flex justify-between text-slate-700">
                  <span>Tiền mặt trả tại chỗ:</span>
                  <span>36.000.000 đ</span>
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
                <button type="button" onclick="toggleTag(this)" class="tag-badge px-2.5 py-0.5 rounded-full bg-slate-100 border border-slate-200 text-slate-700">Máy chuẩn nguyên zin</button>
              </div>

              <textarea id="handshakeReviewNote" rows="2" class="w-full px-3 py-1.5 bg-slate-100 border border-slate-200 rounded-lg text-xs focus:ring-2 focus:ring-blue-500 focus:outline-none">Máy đẹp keng nguyên hộp trùng IMEI, đúng như cam kết. Giao dịch rất nhanh và uy tín!</textarea>
            </div>

            <button type="button" onclick="finishHandshakeFlow()" class="w-full py-2 bg-green-600 hover:bg-green-700 text-white font-bold text-xs rounded-lg transition shadow-sm">
              Gửi Đánh Giá & Hoàn Tất (+5 Điểm Uy Tín)
            </button>
          </div>

        </div>
      </div>

    </div>

  </div>

  <!-- CHÂN TRANG ĐẦY ĐỦ 8 MÀN HÌNH -->
  <footer class="bg-white border-t border-slate-200 py-4 text-xs text-slate-500 shrink-0">
    <div class="max-w-7xl mx-auto px-4 flex flex-col sm:flex-row items-center justify-between gap-2">
      <p>MuaNgay - Bảo chứng giao dịch an toàn qua VNPay & Ship 3PL.</p>
      <div class="flex flex-wrap justify-center gap-3 text-xs font-medium">
        <a href="01-trang-chu.jsp" class="hover:text-blue-600">01. Trang chủ</a>
        <a href="02-chi-tiet-san-pham.jsp" class="hover:text-blue-600">02. Chi tiết tin</a>
        <a href="03-dang-tin.jsp" class="hover:text-blue-600">03. Đăng tin</a>
        <a href="04-chat-tra-gia-vietqr.jsp" class="text-blue-600 font-bold hover:underline">04. Chat & Trả giá</a>
        <a href="05-quan-ly-don-hang.jsp" class="hover:text-blue-600">05. Quản lý đơn hàng</a>
        <a href="06-quan-tri-admin.jsp" class="hover:text-blue-600">06. Quản trị Admin</a>
        <a href="07-dang-nhap-xac-thuc.jsp" class="hover:text-blue-600">07. Đăng nhập / Đăng ký</a>
        <a href="08-ho-so-ca-nhan.jsp" class="hover:text-blue-600">08. Hồ sơ cá nhân</a>
      </div>
    </div>
  </footer>

  <!-- SCRIPT XỬ LÝ TOÀN BỘ TƯƠNG TÁC CHAT VÀ NÚT BẤM -->
  <script>
    const CHAT_LOGGED_IN = <%= chatLoggedIn %>;
    const INITIAL_PARAMS = new URLSearchParams(window.location.search);
    const INITIAL_PRODUCT_ID = INITIAL_PARAMS.get('productId');
    const INITIAL_ACTION = INITIAL_PARAMS.get('action');
    let currentRole = 'buyer';
    let currentConversationId = 0;
    let initialOfferHandled = false;
    let chatState = {
      currentUser: null,
      buyerConversations: [],
      sellerConversations: [],
      selectedConversation: null,
      messages: []
    };
    let refreshTimer = null;
    let depositDeadlineTimer = null;
    let depositPaymentDeadline = 0;
    let renderedExpiredProposalId = null;
    const offerDeadlineCache = Object.create(null);

    function switchRole(role) {
      currentRole = role;
      if (role === 'buyer') {
        document.getElementById('buyerThreadsList').classList.remove('hidden');
        document.getElementById('sellerThreadsList').classList.add('hidden');
        document.getElementById('roleBuyerBtn').className = 'flex-1 py-2.5 text-center text-blue-600 border-b-2 border-blue-600 transition font-bold';
        document.getElementById('roleSellerBtn').className = 'flex-1 py-2.5 text-center text-slate-500 hover:text-slate-900 transition font-bold';
        const firstBuyer = chatState.buyerConversations[0];
        if (firstBuyer) selectBuyerThread(firstBuyer.id);
      } else {
        document.getElementById('buyerThreadsList').classList.add('hidden');
        document.getElementById('sellerThreadsList').classList.remove('hidden');
        document.getElementById('roleSellerBtn').className = 'flex-1 py-2.5 text-center text-blue-600 border-b-2 border-blue-600 transition font-bold';
        document.getElementById('roleBuyerBtn').className = 'flex-1 py-2.5 text-center text-slate-500 hover:text-slate-900 transition font-bold';
        const firstSeller = chatState.sellerConversations[0];
        if (firstSeller) selectSellerThread(firstSeller.id);
      }
    }

    function selectBuyerThread(id) {
      selectThread('buyer', id);
    }

    function selectSellerThread(id) {
      selectThread('seller', id);
    }

    function selectThread(role, id) {
      if (currentConversationId !== id) depositPaymentDeadline = 0;
      currentRole = role;
      currentConversationId = id;
      loadChat(role, id);
    }

    async function loadChat(role = currentRole, conversationId = currentConversationId, keepScroll = false) {
      if (!CHAT_LOGGED_IN) {
        return;
      }

      const params = new URLSearchParams();
      params.set('role', role);
      if (conversationId) params.set('conversationId', conversationId);
      if (!conversationId && INITIAL_PRODUCT_ID) params.set('productId', INITIAL_PRODUCT_ID);

      try {
        const response = await fetch('chat-data?' + params.toString(), { headers: { 'Accept': 'application/json' } });
        const data = await response.json();
        if (!data.success) {
          renderEmptyState(data.message || 'Không thể tải dữ liệu chat.');
          return;
        }

        chatState = data;
        currentRole = data.activeRole || role;
        currentConversationId = data.selectedConversationId || 0;
        renderChatState(keepScroll);
      } catch (error) {
        renderEmptyState('Không kết nối được dữ liệu chat. Vui lòng kiểm tra server và database.');
        console.error(error);
      }
    }

    function renderChatState(keepScroll) {
      document.getElementById('roleBuyerBtn').innerText = 'Tôi Là Người Mua (' + chatState.buyerConversations.length + ')';
      document.getElementById('roleSellerBtn').innerText = 'Tôi Là Người Bán (' + chatState.sellerConversations.length + ')';

      renderThreadList('buyer', chatState.buyerConversations);
      renderThreadList('seller', chatState.sellerConversations);

      if (currentRole === 'seller') {
        document.getElementById('buyerThreadsList').classList.add('hidden');
        document.getElementById('sellerThreadsList').classList.remove('hidden');
        document.getElementById('roleSellerBtn').className = 'flex-1 py-2.5 text-center text-blue-600 border-b-2 border-blue-600 transition font-bold';
        document.getElementById('roleBuyerBtn').className = 'flex-1 py-2.5 text-center text-slate-500 hover:text-slate-900 transition font-bold';
      } else {
        document.getElementById('buyerThreadsList').classList.remove('hidden');
        document.getElementById('sellerThreadsList').classList.add('hidden');
        document.getElementById('roleBuyerBtn').className = 'flex-1 py-2.5 text-center text-blue-600 border-b-2 border-blue-600 transition font-bold';
        document.getElementById('roleSellerBtn').className = 'flex-1 py-2.5 text-center text-slate-500 hover:text-slate-900 transition font-bold';
      }

      renderConversationHeader();
      renderMessages(keepScroll);
      renderComposerActions();
      renderQuickDepositBar();
      maybeOpenInitialOffer();
      updateDepositExpiryDisplay();
    }

    <%--function renderComposerActions() {--%>
    <%--  const actions = document.getElementById('chatQuickActions');--%>
    <%--  const input = document.getElementById('chatInput');--%>
    <%--  if (!actions || !input) return;--%>

    <%--  const c = chatState.selectedConversation;--%>
    <%--  const canOffer = c && Number(c.productPrice) > 0;--%>
    <%--  const offerButton = canOffer--%>
    <%--    ? '<button id="offerActionBtn" onclick="openOfferModal()" class="px-2.5 py-1.5 bg-amber-50 hover:bg-amber-100 text-amber-900 rounded-lg text-xs font-semibold whitespace-nowrap transition border border-amber-300">Trả Giá</button>'--%>
    <%--    : '<button id="offerActionBtn" type="button" disabled title="Tin tặng miễn phí không hỗ trợ đề xuất trả giá" class="px-2.5 py-1.5 bg-slate-100 text-slate-400 rounded-lg text-xs font-semibold whitespace-nowrap border border-slate-200 cursor-not-allowed">Trả Giá</button>';--%>

    <%--  if (currentRole === 'seller') {--%>
    <%--    actions.innerHTML = `--%>
    <%--      <button onclick="triggerImageUpload()" class="px-2.5 py-1.5 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-lg text-xs font-semibold whitespace-nowrap transition border border-slate-200">Gửi Ảnh</button>--%>
    <%--      ${offerButton}--%>
    <%--      <button onclick="sendQuickAction('location')" class="px-2.5 py-1.5 bg-blue-50 hover:bg-blue-100 text-blue-800 rounded-lg text-xs font-semibold whitespace-nowrap transition border border-blue-200">Hẹn Gặp</button>--%>
    <%--      <button onclick="sendQuickAction('available')" class="px-2.5 py-1.5 bg-green-50 hover:bg-green-100 text-green-800 rounded-lg text-xs font-semibold whitespace-nowrap transition border border-green-200">Còn Hàng</button>--%>
    <%--    `;--%>
    <%--    input.placeholder = 'Nhập tin nhắn trả lời khách mua (Enter để gửi)...';--%>
    <%--    return;--%>
    <%--  }--%>

    <%--  actions.innerHTML = `--%>
    <%--    <button onclick="triggerImageUpload()" class="px-2.5 py-1.5 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-lg text-xs font-semibold whitespace-nowrap transition border border-slate-200">Gửi Ảnh</button>--%>
    <%--    ${offerButton}--%>
    <%--    <button onclick="sendQuickAction('location')" class="px-2.5 py-1.5 bg-blue-50 hover:bg-blue-100 text-blue-800 rounded-lg text-xs font-semibold whitespace-nowrap transition border border-blue-200">Hẹn Gặp</button>--%>
    <%--  `;--%>
    <%--  input.placeholder = 'Nhập tin nhắn đàm phán (Enter để gửi)...';--%>
    <%--}--%>
    function renderComposerActions() {
      const actions = document.getElementById('chatQuickActions');
      const input = document.getElementById('chatInput');
      if (!actions || !input) return;

      const c = chatState.selectedConversation;
      const productSold = !!c && String(c.productStatus || '').toUpperCase() === 'SOLD';
      const productAvailable = !!c && String(c.productStatus || '').toUpperCase() === 'ACTIVE';
      const canOffer = productAvailable && Number(c.productPrice) > 0 && !hasPaidDeposit();

      // Dùng hàm tạo nút, tránh template literal để JSP không nuốt ký tự dollar-brace
      function makeBtn(label, onclick, classes) {
        return '<button type="button" onclick="' + onclick + '" class="' + classes + '">' + label + '</button>';
      }

      const base = 'px-2.5 py-1.5 rounded-lg text-xs font-semibold whitespace-nowrap transition border ';

      const imageBtn = makeBtn(
              'Gửi Ảnh',
              'triggerImageUpload()',
              base + 'bg-slate-100 hover:bg-slate-200 text-slate-700 border-slate-200'
      );

      const locationBtn = makeBtn(
              'Hẹn Gặp',
              "sendQuickAction('location')",
              base + 'bg-blue-50 hover:bg-blue-100 text-blue-800 border-blue-200'
      );

      const availableBtn = makeBtn(
              'Còn Hàng',
              "sendQuickAction('available')",
              base + 'bg-green-50 hover:bg-green-100 text-green-800 border-green-200'
      );

      let offerBtn;
      if (canOffer) {
        offerBtn = '<button id="offerActionBtn" type="button" onclick="openOfferModal()" class="' +
                base + 'bg-amber-50 hover:bg-amber-100 text-amber-900 border-amber-300">Trả Giá</button>';
      } else if (hasPaidDeposit()) {
        offerBtn = '';
      } else if (productSold) {
        offerBtn = '<button id="offerActionBtn" type="button" disabled title="Sản phẩm đã hết" class="' +
                base + 'bg-slate-100 text-slate-500 border-slate-200 cursor-not-allowed">Sản phẩm đã hết</button>';
      } else {
        const reason = !c
                ? 'Hãy chọn một cuộc trò chuyện trước'
                : productAvailable ? 'Tin tặng miễn phí không hỗ trợ đề xuất trả giá' : 'Sản phẩm hiện không nhận trả giá';
        offerBtn = '<button id="offerActionBtn" type="button" disabled title="' + reason + '" class="' +
                base + 'bg-slate-100 text-slate-400 border-slate-200 cursor-not-allowed">Trả Giá</button>';
      }

      if (currentRole === 'seller') {
        actions.innerHTML = imageBtn + offerBtn + locationBtn + (productSold ? '' : availableBtn);
        input.placeholder = 'Nhập tin nhắn trả lời khách mua (Enter để gửi)...';
      } else {
        actions.innerHTML = imageBtn + offerBtn + locationBtn;
        input.placeholder = 'Nhập tin nhắn đàm phán (Enter để gửi)...';
      }
    }

    function renderThreadList(role, conversations) {
      const list = document.getElementById(role + 'ThreadsList');
      const keyword = (document.getElementById('searchChatInput').value || '').trim().toLowerCase();
      const filtered = conversations.filter(item => {
        return !keyword ||
          (item.targetName || '').toLowerCase().includes(keyword) ||
          (item.productTitle || '').toLowerCase().includes(keyword) ||
          (item.lastMessage || '').toLowerCase().includes(keyword);
      });

      if (!filtered.length) {
        const emptyText = keyword ? 'Không tìm thấy cuộc trò chuyện phù hợp.' : 'Chưa có cuộc trò chuyện nào.';
        list.innerHTML = '<div class="p-4 text-center text-[11px] text-slate-500">' + emptyText + '</div>';
        return;
      }

      list.innerHTML = filtered.map(item => {
        const active = item.id === currentConversationId;
        const wrapperClass = active
          ? 'chat-thread p-3 bg-blue-50/90 border-l-4 border-blue-600 cursor-pointer transition'
          : 'chat-thread p-3 hover:bg-slate-100 cursor-pointer transition';
        const titleClass = active
          ? 'text-xs font-semibold text-blue-800 mt-0.5 truncate'
          : 'text-xs font-semibold text-slate-700 mt-0.5 truncate';
        const lastClass = item.lastMessageType === 'PROPOSAL'
          ? 'text-[11px] text-amber-700 font-bold truncate mt-0.5'
          : 'text-[11px] text-slate-500 truncate mt-0.5';
        const lastText = getThreadLastText(item);

        return '<div onclick="select' + capitalize(role) + 'Thread(' + item.id + ')" id="' + role + '-thread-' + item.id + '" class="' + wrapperClass + '">' +
          '<div class="flex items-center justify-between">' +
            '<span class="font-bold text-xs text-slate-900">' + escapeHtml(item.targetName) + '</span>' +
            '<span class="text-[10px] text-slate-400">' + escapeHtml(item.lastTimeText) + '</span>' +
          '</div>' +
          '<div class="' + titleClass + '">' + escapeHtml(item.productTitle) + '</div>' +
          '<p class="' + lastClass + '">' + escapeHtml(lastText) + '</p>' +
        '</div>';
      }).join('');
    }

    function renderConversationHeader() {
      const c = chatState.selectedConversation;
      if (!c) {
        document.getElementById('targetAvatar').innerText = 'MN';
        document.getElementById('targetName').innerText = 'Chưa chọn hội thoại';
        document.getElementById('targetStatus').innerText = 'Hãy chọn một cuộc trò chuyện ở cột trái';
        document.getElementById('productTitle').innerText = 'Chưa có sản phẩm';
        document.getElementById('productPrice').innerText = 'Giá gốc: --';
        document.getElementById('productThumb').src = 'assets/images/products/iphone-13-pro-max.jpg';
        return;
      }
      document.getElementById('targetAvatar').innerText = c.partnerInitials || 'MN';
      document.getElementById('targetName').innerText = c.targetName;
      document.getElementById('targetStatus').innerText = c.targetStatus;
      document.getElementById('productTitle').innerText = c.productTitle;
      document.getElementById('productPrice').innerText = 'Giá gốc: ' + c.productPriceText;
      document.getElementById('productThumb').src = c.productImage;
      document.getElementById('productHeaderLink').href = 'product-detail?id=' + encodeURIComponent(c.productId);
    }

    function renderMessages(keepScroll) {
      const container = document.getElementById('messagesContainer');
      const shouldStickBottom = !keepScroll || container.scrollHeight - container.scrollTop - container.clientHeight < 80;
      const c = chatState.selectedConversation;

      if (!c) {
        renderEmptyState('Chưa có hội thoại nào. Hãy bắt đầu trao đổi từ trang chi tiết sản phẩm.');
        return;
      }

      if (!chatState.messages.length) {
        renderEmptyState('Chưa có tin nhắn trong hội thoại này. Hãy gửi lời chào để bắt đầu trao đổi.');
        return;
      }

      let html = '<div class="text-center"><span class="text-[10px] font-semibold text-slate-400 bg-slate-200 px-2 py-0.5 rounded-full uppercase tracking-wider">Hôm nay</span></div>';
      let latestProposal = null;
      let latestProposalIndex = -1;
      const depositPaid = hasPaidDeposit();

      chatState.messages.forEach((message, index) => {
        if (message.messageType === 'PROPOSAL') {
          latestProposal = message;
          latestProposalIndex = index;
        }
        html += renderMessageBubble(message);
      });

      // Keep transaction details out of the chat timeline after deposit so
      // meetup and handoff messages stay visible. Full order details are in
      // order management.
      if (latestProposal && !depositPaid) {
        html += renderOfferCard(latestProposal, c, getOfferState(latestProposalIndex, c), depositPaid);
      }
      container.innerHTML = html;

      if (shouldStickBottom) {
        container.scrollTop = container.scrollHeight;
      }
    }

    function renderMessageBubble(message) {
      if (isImageMessage(message.content)) {
        const imageUrl = getImageMessageUrl(message.content);
        const align = message.mine ? 'justify-end' : 'justify-start';
        const bubble = message.mine
          ? 'bg-blue-600 rounded-tr-none'
          : 'bg-white border border-slate-200 rounded-tl-none';
        return '<div class="flex ' + align + '">' +
          '<div class="' + bubble + ' p-2 rounded-2xl text-xs max-w-xs shadow-sm">' +
            '<img src="' + escapeHtml(imageUrl) + '" alt="Ảnh trong tin nhắn" class="max-w-full max-h-64 rounded-xl object-contain bg-white">' +
          '</div></div>';
      }

      if (message.messageType === 'SYSTEM') {
        return '<div class="flex justify-center">' +
          '<div class="bg-emerald-50 border border-emerald-200 text-emerald-800 p-2.5 rounded-xl text-[11px] max-w-md shadow-sm text-center">' +
          escapeHtml(message.content) +
          '</div></div>';
      }

      if (message.messageType === 'PROPOSAL') {
        const align = message.mine ? 'justify-end' : 'justify-start';
        const bubble = message.mine
          ? 'bg-amber-500 text-slate-950 rounded-tr-none'
          : 'bg-amber-50 border border-amber-300 text-amber-950 rounded-tl-none';
        return '<div class="flex ' + align + '">' +
          '<div class="' + bubble + ' p-3 rounded-2xl text-xs max-w-md shadow-sm">' +
            '<div class="font-bold mb-1">Đề xuất trả giá: ' + escapeHtml(message.proposedPriceText) + '</div>' +
            '<div>' + escapeHtml(message.content) + '</div>' +
          '</div></div>';
      }

      if (message.mine) {
        return '<div class="flex justify-end"><div class="bg-blue-600 text-white p-3 rounded-2xl rounded-tr-none text-xs max-w-md shadow-sm">' +
          escapeHtml(message.content) +
        '</div></div>';
      }
      return '<div class="flex justify-start"><div class="bg-white border border-slate-200 text-slate-800 p-3 rounded-2xl rounded-tl-none text-xs max-w-md shadow-sm">' +
        escapeHtml(message.content) +
      '</div></div>';
    }

    function renderOfferCard(proposal, conversation, offerState, depositPaid) {
      const proposedPrice = Number(proposal.proposedPrice) || 0;
      const productSold = !depositPaid && String(conversation.productStatus || '').toUpperCase() === 'SOLD';
      const isExpired = !depositPaid && offerState.status === 'expired';
      const depositAmount = calculateDepositAmount(proposedPrice);
      const remain = formatMoney(Math.max(0, proposedPrice - depositAmount));
      const paidInFull = hasPaidFullAmount();
      const badge = depositPaid ? (paidInFull ? 'Đã thanh toán toàn bộ' : 'Đã thanh toán cọc') : productSold ? 'Sản phẩm đã hết' : offerState.badge;
      const cardTitle = depositPaid ? 'TÓM TẮT GIAO DỊCH' : productSold ? 'SẢN PHẨM ĐÃ HẾT' : 'ĐỀ XUẤT TRẢ GIÁ';
      const badgeClass = depositPaid
        ? 'text-[10px] text-green-700 font-bold bg-green-100 px-1.5 py-0.5 rounded'
        : productSold ? 'text-[10px] text-red-700 font-bold bg-red-100 px-1.5 py-0.5 rounded' : offerState.badgeClass;
      const sellerActions = !depositPaid && !productSold && currentRole === 'seller' && offerState.status === 'pending'
        ? '<div class="grid grid-cols-2 gap-2 pt-1">' +
            '<button type="button" onclick="respondToOffer(true)" class="py-1.5 bg-green-600 hover:bg-green-700 text-white font-bold text-[11px] rounded-lg transition">Đồng Ý Giá Này</button>' +
            '<button type="button" onclick="respondToOffer(false)" class="py-1.5 bg-white hover:bg-slate-50 text-slate-700 font-bold text-[11px] rounded-lg border border-slate-200 transition">Thương Lượng Thêm</button>' +
          '</div>'
        : '';
      const buyerRetryAction = !depositPaid && !productSold && currentRole === 'buyer' && (offerState.status === 'rejected' || isExpired)
        ? '<div class="pt-1"><button type="button" onclick="openOfferModal()" class="w-full py-1.5 bg-amber-500 hover:bg-amber-600 text-slate-950 font-bold text-[11px] rounded-lg transition">Gửi Giá Mới</button></div>'
        : '';
      const displayedPrice = isExpired ? conversation.productPriceText : proposal.proposedPriceText;
      const priceLabel = isExpired ? 'Giá sản phẩm sau khi hủy giá chốt:' : 'Giá chốt giao dịch:';
      const depositSummary = productSold
        ? 'Sản phẩm đã được người mua khác đặt cọc và không còn nhận trả giá.'
        : depositPaid
        ? (paidInFull ? 'Đã thanh toán toàn bộ giá chốt qua VNPay.' : 'Đã thanh toán cọc ' + escapeHtml(formatMoney(depositAmount)) + ' qua VNPay. Số tiền còn lại ' + escapeHtml(remain) + ' thanh toán theo lựa chọn của người mua.')
        : isExpired
        ? 'Mức trả giá đã hết hạn sau 15 phút chưa đặt cọc. Giá đã quay về giá ban đầu; người mua cần gửi đề xuất mới.'
        : 'Tiền cọc giữ sản phẩm (' + getDepositRateLabel(proposedPrice) + '): <strong class="text-slate-900">' + escapeHtml(formatMoney(depositAmount)) + '</strong>. Số tiền còn lại <strong class="text-slate-900">' + escapeHtml(formatMoney(remain)) + '</strong> thanh toán khi nhận sản phẩm.';
      return '<div class="flex justify-center my-1" id="offerCardBlock">' +
        '<div class="bg-amber-50 border-2 border-amber-400 rounded-xl p-4 w-full max-w-md shadow-sm space-y-2.5">' +
          '<div class="flex items-center justify-between border-b border-amber-200 pb-1.5">' +
          '<span class="text-[11px] font-bold text-amber-900 uppercase tracking-wider">' + cardTitle + '</span>' +
            '<span id="offerStatusBadge" class="' + badgeClass + '">' + badge + '</span>' +
          '</div>' +
          '<div class="flex items-baseline justify-between"><div>' +
            '<span class="text-[11px] text-slate-600 block">' + priceLabel + '</span>' +
            '<span id="offerPriceDisplay" class="text-xl font-bold text-red-600">' + escapeHtml(displayedPrice) + '</span>' +
          '</div><span class="text-xs text-slate-400 line-through">Giá gốc: ' + escapeHtml(conversation.productPriceText) + '</span></div>' +
          '<p id="offerNoteDisplay" class="text-[11px] text-amber-900 italic">Lời nhắn: "' + escapeHtml(proposal.content) + '"</p>' +
          '<div class="pt-1 text-[11px] text-slate-600 bg-white/70 p-2 rounded border border-amber-200">' +
            depositSummary +
          '</div>' +
          sellerActions +
          buyerRetryAction +
        '</div></div>';
    }

    function getOfferState(proposalIndex, conversation) {
      const fallback = chatState.messages[proposalIndex] && chatState.messages[proposalIndex].mine
        ? {
            status: 'pending',
            badge: 'Đang chờ phản hồi',
            badgeClass: 'text-[10px] text-amber-800 font-bold bg-amber-100 px-1.5 py-0.5 rounded'
          }
        : {
            status: 'pending',
            badge: 'Đề xuất từ đối tác',
            badgeClass: 'text-[10px] text-blue-700 font-bold bg-blue-100 px-1.5 py-0.5 rounded'
          };

      const sellerResponse = chatState.messages.slice(proposalIndex + 1).find(message => {
        return message.senderId === conversation.sellerId && message.messageType !== 'PROPOSAL';
      });
      if (!sellerResponse) {
        return fallback;
      }

      const responseText = sellerResponse.content || '';
      if (/chưa phù hợp|không đồng ý|không phù hợp|thương lượng thêm|từ chối|đề xuất lại/i.test(responseText)) {
        return {
          status: 'rejected',
          badge: 'Đã từ chối - chờ giá mới',
          badgeClass: 'text-[10px] text-red-700 font-bold bg-red-100 px-1.5 py-0.5 rounded'
        };
      }
      if (/đồng ý|chốt|ok|okay/i.test(responseText)) {
        const acceptedAt = Number(sellerResponse.createdAtMs) || 0;
        return {
          status: 'accepted',
          badge: 'Người bán đã đồng ý',
          badgeClass: 'text-[10px] text-green-700 font-bold bg-green-100 px-1.5 py-0.5 rounded',
          acceptedAt: acceptedAt,
          expiresAt: 0
        };
      }
      return fallback;
    }

    function getOfferExpiryAt(proposal, sellerResponse, conversation, acceptedAt) {
      const proposalKey = proposal && proposal.id ? proposal.id : 'index-' + findLatestProposalIndex();
      const responseKey = sellerResponse && sellerResponse.id ? sellerResponse.id : 'response';
      const storageKey = 'muangay-offer-expiry-' + conversation.id + '-' + proposalKey + '-' + responseKey;
      if (offerDeadlineCache[storageKey]) return offerDeadlineCache[storageKey];
      try {
        const savedDeadline = Number(localStorage.getItem(storageKey)) || 0;
        if (savedDeadline > 0) {
          offerDeadlineCache[storageKey] = savedDeadline;
          return savedDeadline;
        }
      } catch (error) {
        // Continue with the server message timestamp when browser storage is unavailable.
      }

      const now = Date.now();
      // Some local database/JDBC timezone combinations can return a message time in the future.
      // Anchor that offer to this first observed acceptance and persist its deadline per offer.
      const effectiveAcceptedAt = acceptedAt > now + 60 * 1000 ? now : (acceptedAt > 0 ? acceptedAt : now);
      const deadline = effectiveAcceptedAt + 15 * 60 * 1000;
      offerDeadlineCache[storageKey] = deadline;
      try {
        localStorage.setItem(storageKey, String(deadline));
      } catch (error) {
        // The timer still works for the current page if browser storage is unavailable.
      }
      return deadline;
    }

    function calculateDepositAmount(price) {
      const value = Number(price) || 0;
      if (value <= 0) return 0;
      if (value > 100000) return Math.round(value * 0.10);
      if (value >= 10000 && value <= 50000) return Math.round(value);
      return Math.round(value * 0.50);
    }

    function getDepositRateLabel(price) {
      const value = Number(price) || 0;
      if (value > 100000) return '10% giá chốt';
      if (value >= 10000 && value <= 50000) return '100% giá chốt';
      return '50% giá chốt';
    }

    function maybeOpenInitialOffer() {
      if (initialOfferHandled || INITIAL_ACTION !== 'offer' || hasPaidDeposit()) {
        return;
      }
      const c = chatState.selectedConversation;
      if (!c) {
        return;
      }
      if (String(c.productStatus || '').toUpperCase() !== 'ACTIVE') {
        initialOfferHandled = true;
        return;
      }
      initialOfferHandled = true;
      if (Number(c.productPrice) <= 0) {
        alert('Tin tặng miễn phí không hỗ trợ đề xuất trả giá.');
        return;
      }
      setTimeout(openOfferModal, 120);
    }

    function renderHandshakeCard(conversation) {
      const productTitle = escapeHtml(conversation.productTitle || 'sản phẩm');
      const agreedPrice = Number(conversation.dealPrice) || Number(conversation.productPrice) || 0;
      const depositAmount = Number(conversation.depositAmount) || calculateDepositAmount(agreedPrice);
      const remainingAmount = Math.max(0, agreedPrice - depositAmount);
      const postalDelivery = Number(conversation.deliveryMethod) === 2;
      const handoffTitle = postalDelivery ? 'ĐƠN HÀNG CHỜ GIAO ĐƠN VỊ VẬN CHUYỂN' : 'BÀN GIAO SẢN PHẨM';
      const handoffStatus = postalDelivery ? 'Chờ người bán gửi hàng' : 'Đã cọc qua VNPay';
      const handoffMessage = postalDelivery
        ? 'Đơn hàng đã được xác nhận. Người bán chuẩn bị sản phẩm và sẽ sớm bàn giao cho đơn vị vận chuyển. Hai bên hãy xác nhận địa chỉ nhận hàng và trao đổi mã vận đơn trong khung chat.'
        : 'VNPay đã xác nhận khoản cọc <strong>' + escapeHtml(formatMoney(depositAmount)) + '</strong> cho <strong>' + productTitle + '</strong>. Hai bên hãy nhắn tin để thống nhất cách gặp, giao nhận và kiểm tra sản phẩm.';
      const remainderLabel = postalDelivery ? 'Số tiền còn lại theo thỏa thuận' : 'Còn thanh toán khi nhận hàng';
      return '<div class="flex justify-center my-2" id="dualHandshakeBlock">' +
        '<div class="bg-blue-50 border-2 border-blue-400 rounded-xl p-4 w-full max-w-md shadow-sm space-y-3">' +
          '<div class="flex items-center justify-between border-b border-blue-200 pb-2">' +
            '<span class="text-xs font-bold text-blue-900 uppercase tracking-wider">' + handoffTitle + '</span>' +
            '<span class="text-[10px] text-green-700 font-bold">' + handoffStatus + '</span>' +
          '</div>' +
          '<p class="text-[11px] text-slate-600 leading-relaxed">' + handoffMessage + '</p>' +
          '<div class="grid grid-cols-1 sm:grid-cols-2 gap-2 text-xs">' +
            '<div class="p-2 bg-white rounded-lg border border-slate-200"><div class="text-slate-500">Giá đã thống nhất</div><strong class="text-slate-900">' + escapeHtml(formatMoney(agreedPrice)) + '</strong></div>' +
            '<div class="p-2 bg-white rounded-lg border border-slate-200"><div class="text-slate-500">' + remainderLabel + '</div><strong class="text-slate-900">' + escapeHtml(formatMoney(remainingAmount)) + '</strong></div>' +
          '</div>' +
          '<div class="text-[10px] text-slate-500 italic">' + (postalDelivery ? 'Khoản cọc đã được ghi nhận. Theo dõi cập nhật gửi hàng và thanh toán phần còn lại theo thỏa thuận khi nhận sản phẩm.' : 'Khoản cọc đã được ghi nhận. Phần tiền còn lại thanh toán khi nhận sản phẩm theo thỏa thuận giữa hai bên.') + '</div>' +
          '<div class="pt-1 flex justify-end">' +
            '<a href="05-quan-ly-don-hang.jsp" class="px-3.5 py-1.5 bg-blue-600 hover:bg-blue-700 text-white font-bold text-xs rounded-lg transition shadow-xs inline-flex items-center gap-1">' +
              '<span>' + (postalDelivery ? 'Quản lý vận đơn GHN Express' : 'Xác nhận giao nhận đơn hàng') + '</span> &rarr;' +
            '</a>' +
          '</div>' +
        '</div></div>';
    }

    function hasPaidDeposit() {
      return (chatState.messages || []).some(message => message.messageType === 'SYSTEM' &&
        /VNPay đã xác nhận thanh toán (đặt cọc|toàn bộ)/i.test(message.content || ''));
    }

    function hasPaidFullAmount() {
      return (chatState.messages || []).some(message => message.messageType === 'SYSTEM' &&
        /VNPay đã xác nhận thanh toán toàn bộ/i.test(message.content || ''));
    }

    function renderQuickDepositBar() {
      const bar = document.getElementById('quickDepositBar');
      const c = chatState.selectedConversation;
      const dealPrice = getDepositPrice(c);
      const depositAmount = calculateDepositAmount(dealPrice);
      if (currentRole === 'seller' || !c || String(c.productStatus || '').toUpperCase() !== 'ACTIVE' || depositAmount <= 0 || hasPaidDeposit()) {
        bar.classList.add('hidden');
        return;
      }
      bar.classList.remove('hidden');

      const isGhn = Number(c.deliveryMethod) === 2;
      const u = chatState.currentUser;
      const needsAddress = isGhn && (!u || !u.hasShippingAddress);

      let deliveryNote = '';
      if (isGhn) {
        if (needsAddress) {
          deliveryNote = '<span class="inline-flex items-center gap-1 font-semibold text-red-600 bg-red-50 border border-red-200 px-1.5 py-0.5 rounded text-[10px] ml-1.5">⚠️ Đơn giao GHN: Cần cập nhật địa chỉ trước khi cọc</span>';
        } else {
          deliveryNote = '<span class="inline-flex items-center gap-1 font-medium text-emerald-700 bg-emerald-50 border border-emerald-200 px-1.5 py-0.5 rounded text-[10px] ml-1.5">🚚 Giao tận nơi qua GHN</span>';
        }
      }

      bar.className = 'px-4 py-2 bg-amber-50 border-t border-amber-200 flex items-center justify-between text-xs shrink-0';
      bar.innerHTML = '<div class="min-w-0"><span class="block text-amber-900 font-medium text-[11px]">Giá đã chốt: ' + escapeHtml(formatMoney(dealPrice)) + '. Chọn đặt cọc ' + getDepositRateLabel(dealPrice) + ' (' + escapeHtml(formatMoney(depositAmount)) + ') hoặc thanh toán toàn bộ qua VNPay.' + deliveryNote + '</span>' +
        '<span class="block mt-1 text-[10px] text-amber-800">Đối với đơn hàng trên 100.000đ thì cọc mặc định là 10%, đơn từ 100.000đ trở xuống buộc cọc 50% và đối với đơn từ 10.000đ đến 50.000đ bắt buộc phải cọc 100%.</span></div>' +
        '<div class="flex gap-2 shrink-0"><button onclick="openQrModal()" class="px-3 py-1.5 ' + (needsAddress ? 'bg-red-600 hover:bg-red-700' : 'bg-amber-600 hover:bg-amber-700') + ' text-white font-bold text-xs rounded-md shadow-sm transition">' + (needsAddress ? 'Cập nhật địa chỉ & cọc' : 'Thanh toán cọc') + '</button>' +
        '<button onclick="startFullPayment()" class="px-3 py-1.5 bg-blue-600 hover:bg-blue-700 text-white font-bold text-xs rounded-md shadow-sm transition">Trả toàn bộ</button></div>';
    }

    function startFullPayment() {
      const c = chatState.selectedConversation;
      if (!c || currentRole === 'seller' || String(c.productStatus || '').toUpperCase() !== 'ACTIVE') { alert('Tin đăng không còn khả dụng để thanh toán.'); return; }
      if (Number(c.deliveryMethod) === 2 && (!chatState.currentUser || !chatState.currentUser.hasShippingAddress)) { openRequireAddressModal(); return; }
      const price = getDepositPrice(c);
      if (price <= 0) { alert('Chỉ thanh toán được sau khi hai bên thống nhất giá.'); return; }
      document.getElementById('vnpayConversationId').value = c.id;
      document.getElementById('vnpayPaymentType').value = 'FULL';
      document.getElementById('vnpayPaymentForm').submit();
    }

    function getDepositPrice(conversation) {
      if (!conversation) return 0;
      const proposalIndex = findLatestProposalIndex();
      if (proposalIndex < 0) return Number(conversation.productPrice) || 0;
      const offerState = getOfferState(proposalIndex, conversation);
      return offerState && offerState.status === 'accepted' ? (Number(conversation.dealPrice) || 0) : 0;
    }

    function updateDepositExpiryDisplay() {
      const c = chatState.selectedConversation;
      const notice = document.getElementById('depositExpiryNotice');
      const countdown = document.getElementById('depositCountdown');
      if (!c || !notice || !countdown) return;
      if (hasPaidDeposit()) {
        notice.classList.add('hidden');
        countdown.classList.add('hidden');
        closeQrModal();
        return;
      }
      const proposalIndex = findLatestProposalIndex();
      const offerState = proposalIndex >= 0 ? getOfferState(proposalIndex, c) : null;
      if (depositPaymentDeadline > 0) {
        const remainingMs = Math.max(0, depositPaymentDeadline - Date.now());
        const remainingSeconds = Math.ceil(remainingMs / 1000);
        notice.classList.remove('hidden');
        countdown.classList.remove('hidden');
        countdown.textContent = 'Thời gian còn lại: ' + String(Math.floor(remainingSeconds / 60)).padStart(2, '0') + ':' + String(remainingSeconds % 60).padStart(2, '0');
        if (remainingMs <= 0) {
          closeQrModal();
          document.getElementById('vnpayPaymentForm').classList.add('opacity-50');
        }
      } else {
        notice.classList.add('hidden');
        countdown.classList.add('hidden');
      }
    }

    function findLatestProposalIndex() {
      for (let i = chatState.messages.length - 1; i >= 0; i--) {
        if (chatState.messages[i].messageType === 'PROPOSAL') {
          return i;
        }
      }
      return -1;
    }

    function renderEmptyState(message) {
      document.getElementById('messagesContainer').innerHTML =
        '<div class="h-full flex items-center justify-center text-center text-xs text-slate-500 p-6">' + escapeHtml(message) + '</div>';
    }

    // Modal Yêu Cầu Cập Nhật Địa Chỉ (cho đơn GHN)
    function openRequireAddressModal() {
      const c = chatState.selectedConversation;
      const updateLink = document.getElementById('btnGoToUpdateAddress');
      if (updateLink) {
        let returnUrl = '04-chat-tra-gia-vietqr.jsp';
        if (c && c.productId) {
          returnUrl += '?productId=' + encodeURIComponent(c.productId);
        } else if (c && c.id) {
          returnUrl += '?conversationId=' + encodeURIComponent(c.id);
        }
        updateLink.href = '08-ho-so-ca-nhan.jsp?openEdit=1&returnUrl=' + encodeURIComponent(returnUrl);
      }
      document.getElementById('requireAddressModal').classList.remove('hidden');
    }
    function closeRequireAddressModal() {
      document.getElementById('requireAddressModal').classList.add('hidden');
    }

    // Modal QR
    function openQrModal() {
      const c = chatState.selectedConversation;
      if (hasPaidDeposit()) {
        alert('Khoản cọc đã được xác nhận. Hãy trao đổi với người bán để thống nhất bàn giao sản phẩm.');
        return;
      }
      if (!c) {
        alert('Vui lòng chọn hội thoại có sản phẩm cần đặt cọc.');
        return;
      }
      if (String(c.productStatus || '').toUpperCase() !== 'ACTIVE') {
        alert('Sản phẩm đã hết, không thể tiếp tục đặt cọc.');
        return;
      }
      const depositPrice = getDepositPrice(c);
      if (depositPrice <= 0) {
        alert('Đặt cọc có thể thực hiện sau khi người bán chấp nhận mức giá đề xuất.');
        return;
      }

      // KIỂM TRA ĐỊA CHỈ NẾU ĐƠN HÀNG LÀ GIAO QUA GHN (deliveryMethod === 2)
      if (Number(c.deliveryMethod) === 2) {
        const u = chatState.currentUser;
        const hasAddress = u && u.hasShippingAddress;
        if (!hasAddress) {
          openRequireAddressModal();
          return;
        }
      }

      const amount = calculateDepositAmount(depositPrice);
      depositPaymentDeadline = Date.now() + 15 * 60 * 1000;
      const reference = 'Được tạo tự động khi chuyển sang VNPay';
      document.getElementById('qrDepositAmount').textContent = formatMoney(amount);
      document.getElementById('qrDepositRule').textContent = 'Số tiền đặt cọc (' + getDepositRateLabel(depositPrice) + '):';
      document.getElementById('qrTransferReference').textContent = reference;
      document.getElementById('vnpayConversationId').value = c.id;
      document.getElementById('vnpayPaymentType').value = 'DEPOSIT';
      updateDepositExpiryDisplay();
      document.getElementById('qrModal').classList.remove('hidden');
    }
    function closeQrModal() { document.getElementById('qrModal').classList.add('hidden'); }
    // Modal Trả Giá
    function openOfferModal() {
      const c = chatState.selectedConversation;
      if (hasPaidDeposit()) {
        alert('Khoản cọc đã được xác nhận. Không thể trả giá lại cho giao dịch này.');
        return;
      }
      if (!c) {
        alert('Bạn cần chọn một hội thoại trước khi trả giá.');
        return;
      }
      if (String(c.productStatus || '').toUpperCase() === 'SOLD') {
        alert('Sản phẩm đã hết nên không thể tiếp tục trả giá.');
        return;
      }
      if (Number(c.productPrice) <= 0) {
        alert('Tin tặng miễn phí không hỗ trợ đề xuất trả giá.');
        return;
      }
      hydrateOfferModal(c);
      document.getElementById('offerModal').classList.remove('hidden');
    }
    function closeOfferModal() { document.getElementById('offerModal').classList.add('hidden'); }
    async function submitCustomOffer() {
      const price = parseInt(document.getElementById('customOfferPrice').value, 10) || 0;
      const note = document.getElementById('customOfferNote').value;
      const c = chatState.selectedConversation;
      if (!c || Number(c.productPrice) <= 0) {
        alert('Tin tặng miễn phí không hỗ trợ đề xuất trả giá.');
        return;
      }
      if (String(c.productStatus || '').toUpperCase() !== 'ACTIVE') {
        alert('Sản phẩm đã hết hoặc không còn nhận trả giá.');
        return;
      }
      if (price <= 0) {
        alert('Vui lòng nhập mức giá đề xuất lớn hơn 0.');
        return;
      }
      const formattedPrice = formatMoney(price);
      
      closeOfferModal();
      await persistMessage(note || ('Em xin phép gửi đề xuất trả giá: ' + formattedPrice), 'PROPOSAL', price);
    }

    function hydrateOfferModal(conversation) {
      const priceInput = document.getElementById('customOfferPrice');
      const noteInput = document.getElementById('customOfferNote');
      const hint = document.getElementById('offerProductHint');
      const productPrice = Number(conversation.productPrice) || 0;
      const suggestedPrice = Math.max(0, productPrice - 500000);
      priceInput.value = String(suggestedPrice || productPrice);
      priceInput.max = String(productPrice);
      if (hint) {
        hint.innerText = conversation.productTitle + ' • Giá gốc: ' + conversation.productPriceText;
      }
      if (noteInput && !noteInput.dataset.touched) {
        noteInput.value = 'Em quan tâm ' + conversation.productTitle + '. Anh/chị xem giúp em mức giá này được không ạ?';
      }
    }

    function sendQuickAction(type) {
      if (type === 'image') {
        triggerImageUpload();
      } else if (type === 'location') {
        const message = currentRole === 'seller'
          ? 'Mình gửi lịch hẹn xem hàng tại địa điểm đã đăng. Bạn nhắn giúp mình khung giờ thuận tiện nhé!'
          : 'Cho em xin địa chỉ chính xác và khung giờ chiều nay để qua xem nhé!';
        persistMessage(message, 'TEXT');
      } else if (type === 'available') {
        persistMessage('Sản phẩm vẫn còn bạn nhé. Bạn có thể trao đổi thêm hoặc hẹn lịch xem hàng.', 'TEXT');
      }
    }

    function triggerImageUpload() {
      const input = document.getElementById('chatImageInput');
      if (input) {
        input.value = '';
        input.click();
      }
    }

    async function handleImageSelected(event) {
      const file = event.target.files && event.target.files[0];
      if (!file) return;
      if (!file.type.startsWith('image/')) {
        alert('Vui lòng chọn file ảnh.');
        return;
      }
      if (file.size > 5 * 1024 * 1024) {
        alert('Ảnh tối đa 5MB. Vui lòng chọn ảnh nhỏ hơn.');
        return;
      }
      await uploadChatImage(file);
    }

    async function uploadChatImage(file) {
      if (!CHAT_LOGGED_IN) {
        alert('Bạn cần đăng nhập để gửi ảnh.');
        return false;
      }
      if (!currentConversationId) {
        alert('Bạn chưa có hội thoại nào để gửi ảnh.');
        return false;
      }

      const body = new FormData();
      body.set('conversationId', currentConversationId);
      body.set('messageType', 'IMAGE');
      body.set('imageFile', file);

      try {
        const response = await fetch('chat-data', {
          method: 'POST',
          headers: { 'Accept': 'application/json' },
          body
        });
        const data = await response.json();
        if (!data.success) {
          alert(data.message || 'Không thể gửi ảnh.');
          return false;
        }
        await loadChat(currentRole, currentConversationId);
        return true;
      } catch (error) {
        console.error(error);
        alert('Không upload được ảnh. Vui lòng thử lại.');
        return false;
      }
    }

    function respondToOffer(accepted) {
      if (!chatState.selectedConversation || String(chatState.selectedConversation.productStatus || '').toUpperCase() !== 'ACTIVE') {
        alert('Sản phẩm đã hết hoặc không còn nhận trả giá.');
        return;
      }
      const latestProposal = [...chatState.messages].reverse().find(message => message.messageType === 'PROPOSAL');
      const priceText = latestProposal ? latestProposal.proposedPriceText : 'mức giá này';
      const message = accepted
        ? 'Mình đồng ý với mức giá ' + priceText + '. Bạn có thể tiếp tục đặt cọc trên sàn để giữ hàng nhé.'
        : 'Mình đã xem đề xuất ' + priceText + '. Mức này chưa phù hợp, mình thương lượng thêm nhé.';
      persistMessage(message, 'TEXT');
    }

    async function handleSendMessage(e) {
      e.preventDefault();
      const input = document.getElementById('chatInput');
      const text = input.value.trim();
      if (!text) return;

      const sent = await persistMessage(text, 'TEXT');
      if (sent) {
        input.value = '';
      }
    }

    async function persistMessage(content, messageType, proposedPrice) {
      if (!CHAT_LOGGED_IN) {
        alert('Bạn cần đăng nhập để sử dụng tin nhắn thật.');
        return false;
      }
      if (!currentConversationId) {
        alert('Bạn chưa có hội thoại nào để gửi tin nhắn. Hãy mở chat từ trang chi tiết sản phẩm hoặc chọn một hội thoại ở cột trái.');
        return false;
      }
      const body = new URLSearchParams();
      body.set('conversationId', currentConversationId);
      body.set('content', content);
      body.set('messageType', messageType || 'TEXT');
      if (proposedPrice) body.set('proposedPrice', proposedPrice);

      try {
        const response = await fetch('chat-data', {
          method: 'POST',
          headers: { 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8', 'Accept': 'application/json' },
          body: body.toString()
        });
        const data = await response.json();
        if (!data.success) {
          alert(data.message || 'Không thể gửi tin nhắn.');
          return false;
        }
        await loadChat(currentRole, currentConversationId);
        return true;
      } catch (error) {
        console.error(error);
        alert('Không kết nối được server chat. Tin nhắn chưa được gửi.');
        return false;
      }
    }

    function confirmSellerHandshake() {
      openHandshakeModal();
    }

    // === XỬ LÝ MODAL BÀN GIAO GẶP MẶT TRỰC TIẾP (HANDSHAKE QR & PIN) ===
    function openHandshakeModal() {
      document.getElementById('handshakeModal').classList.remove('hidden');
      document.getElementById('handshakeStepAuth').classList.remove('hidden');
      document.getElementById('handshakeStepSuccess').classList.add('hidden');
      switchHandshakeRole('seller');
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
      if (pin === '8912' || pin.length === 4) {
        showHandshakeSuccess();
      } else {
        alert('Mã PIN không đúng. Vui lòng nhập mã 8912 do người bán cung cấp.');
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

      const block = document.getElementById('dualHandshakeBlock');
      if (block) {
        block.innerHTML = `
          <div class="bg-green-50 border-2 border-green-400 rounded-xl p-4 w-full max-w-md shadow-sm space-y-2">
            <div class="flex items-center justify-between border-b border-green-200 pb-1.5">
              <span class="text-xs font-bold text-green-900 uppercase tracking-wider">
                Giao Dịch Hoàn Tất Thành Công
              </span>
              <span class="text-[10px] text-green-700 font-bold bg-green-100 px-2 py-0.5 rounded">
                Đã Đánh Giá 5 Sao
              </span>
            </div>
            <p class="text-[11px] text-green-800 leading-relaxed">
              Cả hai bên đã xác nhận bàn giao tại điểm hẹn. Sàn đã giải ngân khoản cọc 10% giá chốt cho Người Bán.
            </p>
            <div class="text-[10px] text-slate-500 italic pt-1">
              Bài đăng iPhone 18 Pro Max Đỏ Burgundy đã chuyển sang trạng thái ĐÃ BÁN. Cả hai bên được cộng +5 điểm uy tín.
            </div>
          </div>
        `;
      }

      persistMessage('Hệ thống MuaNgay: Giao dịch hoàn tất thành công tại điểm hẹn. Tiền cọc đã được giải ngân cho Người Bán. Bài đăng đã đóng trạng thái ĐÃ BÁN. Cảm ơn bạn đã gửi đánh giá uy tín!', 'SYSTEM');
    }

    function capitalize(text) {
      return text.charAt(0).toUpperCase() + text.slice(1);
    }

    function formatMoney(value) {
      return (Number(value) || 0).toLocaleString('vi-VN') + ' đ';
    }

    function getThreadLastText(item) {
      if (item.lastMessageType === 'PROPOSAL' && item.lastProposedPrice > 0) {
        return 'Đang đề xuất trả giá: ' + item.lastProposedPriceText;
      }
      if (isImageMessage(item.lastMessage)) {
        return 'Đã gửi ảnh';
      }
      return item.lastMessage;
    }

    function isImageMessage(content) {
      return typeof content === 'string' && content.startsWith('IMAGE::');
    }

    function getImageMessageUrl(content) {
      return isImageMessage(content) ? content.substring('IMAGE::'.length) : '';
    }

    function escapeHtml(string) {
      return String(string).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
    }

    document.getElementById('searchChatInput').addEventListener('input', () => {
      if (CHAT_LOGGED_IN) {
        renderChatState(true);
      }
    });
    document.addEventListener('DOMContentLoaded', () => {
      depositDeadlineTimer = setInterval(updateDepositExpiryDisplay, 1000);
      const vnpayForm = document.getElementById('vnpayPaymentForm');
      if (vnpayForm) {
        vnpayForm.addEventListener('submit', function (e) {
          const c = chatState.selectedConversation;
          if (c && Number(c.deliveryMethod) === 2) {
            const u = chatState.currentUser;
            if (!u || !u.hasShippingAddress) {
              e.preventDefault();
              closeQrModal();
              openRequireAddressModal();
              return false;
            }
          }
        });
      }
      if (CHAT_LOGGED_IN) {
        loadChat('buyer');
        refreshTimer = setInterval(() => loadChat(currentRole, currentConversationId, true), 5000);
      }
    });
  </script>

</body>
</html>
