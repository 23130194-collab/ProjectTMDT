<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Tin Nhắn & Đàm Phán Trả Giá VietQR - MuaNgay</title>
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
      <a href="01-trang-chu.jsp" class="flex items-center gap-2">
        <img src="assets/logos/muangay-logo-icon.svg" alt="MuaNgay Logo" class="w-8 h-8 rounded-lg shadow-xs">
        <span class="text-base font-extrabold text-slate-900">Mua<span class="text-blue-600">Ngay</span></span>
      </a>
      <span class="text-slate-300">|</span>
      <span class="text-xs font-semibold text-slate-600">Đàm Phán Trả Giá & Ký Quỹ Bảo Đảm</span>
    </div>
    <div class="flex items-center gap-3">
      <a href="05-quan-ly-don-hang.jsp" class="text-xs font-semibold text-slate-700 hover:text-blue-600">Quản lý đơn hàng (2)</a>
      <a href="01-trang-chu.jsp" class="text-xs font-medium text-slate-500 hover:text-blue-600">Về trang chủ</a>
      <a href="08-ho-so-ca-nhan.jsp" class="w-8 h-8 rounded-full bg-blue-600 text-white flex items-center justify-center text-xs font-bold">VB</a>
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

        <a href="02-chi-tiet-san-pham.jsp" class="flex items-center gap-2.5 bg-slate-50 hover:bg-slate-100 border border-slate-200 px-3 py-1.5 rounded-lg transition">
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
          <strong>Lưu ý an toàn:</strong> MuaNgay tự động che số điện thoại và STK để bảo vệ bạn khỏi lừa đảo. Đặt cọc qua VietQR để được sàn giữ tiền an toàn.
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
              Tiền cọc giữ máy: <strong class="text-slate-900">1.000.000 đ</strong>. 
              Số tiền còn lại <strong class="text-slate-900">36.000.000 đ</strong> thanh toán trực tiếp khi test máy xong.
            </div>
          </div>
        </div>

        <!-- KHỐI XÁC NHẬN NHẬN ĐỒ TẠI ĐIỂM HẸN -->
        <div class="flex justify-center my-2" id="dualHandshakeBlock">
          <div class="bg-blue-50 border-2 border-blue-400 rounded-xl p-4 w-full max-w-md shadow-sm space-y-3">
            <div class="flex items-center justify-between border-b border-blue-200 pb-2">
              <span class="text-xs font-bold text-blue-900 uppercase tracking-wider">
                Xác Nhận Đã Nhận Máy & Trả Tiền
              </span>
              <span class="text-[10px] text-blue-700 font-semibold">Gặp Mặt Trực Tiếp</span>
            </div>

            <p class="text-[11px] text-slate-600 leading-relaxed">
              Hai bên gặp mặt tại điểm hẹn và test máy cẩn thận. Cả hai cùng bấm xác nhận để Sàn mở khóa tiền cọc 1.000.000 đ cho người bán:
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
              Khi hai bên quét mã QR hoặc nhập mã PIN 8912, Sàn sẽ chuyển 1.000.000 đ tiền cọc vào tài khoản của Người Bán và tích lũy điểm uy tín cho cả hai bên.
            </div>
          </div>
        </div>

      </div>

      <!-- THANH ĐẶT CỌC VIETQR NHANH -->
      <div id="quickDepositBar" class="px-4 py-2 bg-amber-50 border-t border-amber-200 flex items-center justify-between text-xs shrink-0">
        <span class="text-amber-900 font-medium text-[11px]">
          Giá đã chốt: 37.000.000 đ. Đặt cọc 1.000.000 đ qua VietQR để tạm khóa bài đăng chống người khác mua mất!
        </span>
        <button onclick="openQrModal()" class="px-3 py-1.5 bg-amber-600 hover:bg-amber-700 text-white font-bold text-xs rounded-md shadow-sm transition shrink-0">
          Xem Mã VietQR Cọc
        </button>
      </div>

      <!-- THANH NHẬP LIỆU GỬI TIN NHẮN -->
      <div class="p-3 border-t border-slate-200 bg-white flex flex-wrap sm:flex-nowrap items-center gap-2 shrink-0">
        <div class="flex items-center gap-1.5">
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

      <!-- CỬA SỔ BẬT LÊN (MODAL): THANH TOÁN CỌC VIETQR 10% TỰ ĐỘNG -->
      <div id="qrModal" class="hidden absolute inset-0 bg-slate-900/50 backdrop-blur-xs z-50 flex items-center justify-center p-4">
        <div class="bg-white rounded-2xl shadow-2xl border border-slate-200 max-w-sm w-full p-5 space-y-3.5 text-center transform transition-all scale-100">
          
          <div class="flex items-center justify-between border-b border-slate-100 pb-2.5">
            <span class="text-xs font-bold text-slate-900 uppercase">Đặt Cọc Bảo Đảm VietQR (Kênh 1)</span>
            <button onclick="closeQrModal()" class="text-sm text-slate-400 font-bold hover:text-slate-700 p-1">✕</button>
          </div>

          <div class="p-3 bg-slate-50 border border-slate-200 rounded-xl inline-block mx-auto">
            <div class="w-48 h-48 bg-white border-2 border-slate-800 rounded-lg flex flex-col items-center justify-center p-2 shadow-inner">
              <div class="w-40 h-40 bg-slate-900 flex flex-col items-center justify-center text-white text-[10px] font-mono p-2 text-center leading-relaxed rounded">
                <span class="text-amber-400 font-bold mb-1">VIETQR NAPAS 247</span>
                <span>CỔNG THANH TOÁN VIETQR</span>
                <span class="text-emerald-400 font-bold text-xs mt-1">1.000.000 VNĐ</span>
                <span class="text-[9px] text-slate-400 mt-1">COC IP18PMAX</span>
              </div>
            </div>
          </div>

          <div class="space-y-0.5">
            <div class="text-[11px] text-slate-500">Số tiền đặt cọc giữ máy:</div>
            <div class="text-xl font-bold text-green-600">1.000.000 đ</div>
            <div class="text-[10px] text-slate-500">Nội dung CK: <strong class="text-slate-900 font-mono bg-slate-100 px-1 py-0.5 rounded">COC IP18PMAX UID108</strong></div>
          </div>

          <button onclick="confirmPaymentDone()" class="w-full py-2.5 bg-blue-600 hover:bg-blue-700 text-white font-bold text-xs rounded-lg transition shadow-sm">
            Tôi Đã Quét Mã Chuyển Khoản Xong
          </button>

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
                  <span class="font-medium text-slate-900">1.000.000 đ (Giải ngân khi hoàn tất)</span>
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
                Sàn đã giải ngân 1.000.000 đ tiền cọc cho Người Bán.
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
                  <span>1.000.000 đ (Chuyển ví người bán)</span>
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
      <p>MuaNgay - Bảo chứng giao dịch an toàn qua cọc VietQR & Ship 3PL.</p>
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
    let currentRole = 'buyer';

    function switchRole(role) {
      currentRole = role;
      if (role === 'buyer') {
        document.getElementById('buyerThreadsList').classList.remove('hidden');
        document.getElementById('sellerThreadsList').classList.add('hidden');
        document.getElementById('roleBuyerBtn').className = 'flex-1 py-2.5 text-center text-blue-600 border-b-2 border-blue-600 transition font-bold';
        document.getElementById('roleSellerBtn').className = 'flex-1 py-2.5 text-center text-slate-500 hover:text-slate-900 transition font-bold';
        selectBuyerThread(1);
      } else {
        document.getElementById('buyerThreadsList').classList.add('hidden');
        document.getElementById('sellerThreadsList').classList.remove('hidden');
        document.getElementById('roleSellerBtn').className = 'flex-1 py-2.5 text-center text-blue-600 border-b-2 border-blue-600 transition font-bold';
        document.getElementById('roleBuyerBtn').className = 'flex-1 py-2.5 text-center text-slate-500 hover:text-slate-900 transition font-bold';
        selectSellerThread(1);
      }
    }

    function selectBuyerThread(id) {
      document.querySelectorAll('#buyerThreadsList .chat-thread').forEach(el => {
        el.className = 'chat-thread p-3 hover:bg-slate-100 cursor-pointer transition';
      });
      const activeEl = document.getElementById('buyer-thread-' + id);
      if (activeEl) activeEl.className = 'chat-thread p-3 bg-blue-50/90 border-l-4 border-blue-600 cursor-pointer transition';

      if (id === 1) {
        document.getElementById('targetName').innerText = 'Nguyễn Văn Tuấn (Người Bán)';
        document.getElementById('targetStatus').innerText = 'Đang trực tuyến • Quận 10, TP.HCM';
        document.getElementById('productTitle').innerText = 'iPhone 18 Pro Max Đỏ Burgundy 256GB';
        document.getElementById('productPrice').innerText = 'Giá gốc: 38.000.000 đ';
        document.getElementById('productThumb').src = 'assets/images/iphone-18-pro-mau-do-anh-dao-dam-1-iphone-18-pro-mau-do-burgundy-co-gi-dac-biet-1.jpg';
        document.getElementById('quickDepositBar').classList.remove('hidden');
        document.getElementById('dualHandshakeBlock').classList.remove('hidden');
      } else {
        document.getElementById('targetName').innerText = 'Trần Quốc Bảo (Người Bán)';
        document.getElementById('targetStatus').innerText = 'Đang trực tuyến • Quận 1, TP.HCM';
        document.getElementById('productTitle').innerText = 'iPhone 13 Pro Max 128GB VN/A';
        document.getElementById('productPrice').innerText = 'Giá gốc: 14.800.000 đ';
        document.getElementById('productThumb').src = 'assets/images/products/iphone-13-pro-max.jpg';
        document.getElementById('quickDepositBar').classList.add('hidden');
        document.getElementById('dualHandshakeBlock').classList.add('hidden');
      }
    }

    function selectSellerThread(id) {
      document.querySelectorAll('#sellerThreadsList .chat-thread').forEach(el => {
        el.className = 'chat-thread p-3 hover:bg-slate-100 cursor-pointer transition';
      });
      const activeEl = document.getElementById('seller-thread-' + id);
      if (activeEl) activeEl.className = 'chat-thread p-3 bg-blue-50/90 border-l-4 border-blue-600 cursor-pointer transition';

      if (id === 1) {
        document.getElementById('targetName').innerText = 'Lê Minh Khang (Khách Mua Hàng)';
        document.getElementById('targetStatus').innerText = 'Tài khoản chính chủ • Quận Tân Bình, TP.HCM';
        document.getElementById('productTitle').innerText = 'Bàn làm việc gỗ thông 1m2';
        document.getElementById('productPrice').innerText = 'Giá cho tặng: Miễn phí 0 đ';
        document.getElementById('productThumb').src = 'assets/images/products/ban-go-thong.jpg';
        document.getElementById('quickDepositBar').classList.add('hidden');
        document.getElementById('dualHandshakeBlock').classList.remove('hidden');
      } else {
        document.getElementById('targetName').innerText = 'Hoàng Thị Yến (Khách Mua Hàng)';
        document.getElementById('targetStatus').innerText = 'Đang trực tuyến • Quận Phú Nhuận, TP.HCM';
        document.getElementById('productTitle').innerText = 'Máy giặt Electrolux Inverter 8kg';
        document.getElementById('productPrice').innerText = 'Giá bán: 3.800.000 đ';
        document.getElementById('productThumb').src = 'assets/images/products/may-giat-electrolux.jpg';
        document.getElementById('quickDepositBar').classList.remove('hidden');
        document.getElementById('dualHandshakeBlock').classList.remove('hidden');
      }
    }

    // Modal QR
    function openQrModal() { document.getElementById('qrModal').classList.remove('hidden'); }
    function closeQrModal() { document.getElementById('qrModal').classList.add('hidden'); }
    function confirmPaymentDone() {
      closeQrModal();
      appendBotMessage("Hệ thống Webhook: Đã nhận thành công 1.000.000 đ tiền cọc từ Quý khách! Tin đăng đã chuyển sang trạng thái [TẠM KHÓA GIAO DỊCH].");
      const quickBar = document.getElementById('quickDepositBar');
      if (quickBar) {
        quickBar.innerHTML = '<span class="text-green-700 font-bold text-[11px]">Đã nạp cọc 1.000.000 đ thành công qua VietQR. Tin đăng đã được khóa bảo vệ!</span><span class="text-[10px] text-slate-500 font-medium">Mã GD: #VNQR-9921</span>';
        quickBar.className = 'px-4 py-2 bg-green-50 border-t border-green-200 flex items-center justify-between text-xs shrink-0';
      }
    }

    // Modal Trả Giá
    function openOfferModal() { document.getElementById('offerModal').classList.remove('hidden'); }
    function closeOfferModal() { document.getElementById('offerModal').classList.add('hidden'); }
    function submitCustomOffer() {
      const price = document.getElementById('customOfferPrice').value;
      const note = document.getElementById('customOfferNote').value;
      const formattedPrice = parseInt(price).toLocaleString('vi-VN') + ' đ';
      
      closeOfferModal();
      document.getElementById('offerPriceDisplay').innerText = formattedPrice;
      document.getElementById('offerNoteDisplay').innerText = 'Lời nhắn: "' + note + '"';
      document.getElementById('offerStatusBadge').innerText = 'Đang chờ phản hồi';
      document.getElementById('offerStatusBadge').className = 'text-[10px] text-amber-800 font-bold bg-amber-100 px-1.5 py-0.5 rounded';
      
      appendUserMessage('Em xin phép gửi đề xuất trả giá: ' + formattedPrice + '. Lời nhắn: ' + note);
      
      setTimeout(() => {
        document.getElementById('offerStatusBadge').innerText = 'Đối tác đã đồng ý';
        document.getElementById('offerStatusBadge').className = 'text-[10px] text-green-700 font-bold bg-green-100 px-1.5 py-0.5 rounded';
        appendBotMessage('Mình đồng ý với mức giá ' + formattedPrice + ' nhé! Bạn tiến hành đặt cọc để giữ hàng nha.');
      }, 1500);
    }

    function sendQuickAction(type) {
      if (type === 'image') {
        appendUserMessage('[Đã đính kèm ảnh chụp thực tế món đồ]');
        setTimeout(() => { appendBotMessage('Ảnh rõ nét lắm bạn nhé!'); }, 1200);
      } else if (type === 'location') {
        appendUserMessage('Cho em xin địa chỉ chính xác và khung giờ chiều nay để qua xem nhé!');
        setTimeout(() => { appendBotMessage('Địa chỉ: 142 Tô Hiến Thành, Phường 13, Quận 10. Bạn cứ qua tầm 16h30 nhé!'); }, 1200);
      }
    }

    function handleSendMessage(e) {
      e.preventDefault();
      const input = document.getElementById('chatInput');
      const text = input.value.trim();
      if (!text) return;

      appendUserMessage(text);
      input.value = '';

      setTimeout(() => {
        const replies = [
          "Dạ món đồ vẫn còn bạn nhé, đồ nguyên bản hoạt động tốt ạ!",
          "Vâng, chiều nay từ 16h30 bạn cứ ghé xem trực tiếp nhé.",
          "Dạ được bạn ơi, bạn cứ đặt cọc trên sàn là hệ thống tự khóa tin cho bạn ngay."
        ];
        appendBotMessage(replies[Math.floor(Math.random() * replies.length)]);
      }, 1000);
    }

    function appendUserMessage(text) {
      const container = document.getElementById('messagesContainer');
      const div = document.createElement('div');
      div.className = 'flex justify-end';
      div.innerHTML = `<div class="bg-blue-600 text-white p-3 rounded-2xl rounded-tr-none text-xs max-w-md shadow-sm">\${escapeHtml(text)}</div>`;
      container.appendChild(div);
      container.scrollTop = container.scrollHeight;
    }

    function appendBotMessage(text) {
      const container = document.getElementById('messagesContainer');
      const div = document.createElement('div');
      div.className = 'flex justify-start';
      div.innerHTML = `<div class="bg-white border border-slate-200 text-slate-800 p-3 rounded-2xl rounded-tl-none text-xs max-w-md shadow-sm">\${escapeHtml(text)}</div>`;
      container.appendChild(div);
      container.scrollTop = container.scrollHeight;
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
              Cả hai bên đã quét mã QR / nhập PIN xác nhận bàn giao tại điểm hẹn. Sàn đã giải ngân 1.000.000 đ tiền cọc cho Người Bán.
            </p>
            <div class="text-[10px] text-slate-500 italic pt-1">
              Bài đăng iPhone 18 Pro Max Đỏ Burgundy đã chuyển sang trạng thái ĐÃ BÁN. Cả hai bên được cộng +5 điểm uy tín.
            </div>
          </div>
        `;
      }

      appendBotMessage('Hệ thống MuaNgay: Giao dịch hoàn tất thành công tại điểm hẹn. Tiền cọc 1.000.000 đ đã được giải ngân cho Người Bán. Bài đăng đã đóng trạng thái ĐÃ BÁN. Cảm ơn bạn đã gửi đánh giá uy tín!');
    }

    function escapeHtml(string) {
      return String(string).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
    }
  </script>

</body>
</html>
