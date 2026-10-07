<%@ page contentType="text/html;charset=UTF-8" language="java" %>
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

  <!-- NỘI DUNG CHÍNH: TRUNG TÂM QUẢN LÝ 4 ĐƠN HÀNG KÊNH 1 & KÊNH 2 -->
  <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 flex-1 w-full space-y-6 relative">
    
    <!-- TIÊU ĐỀ TRANG VÀ GIẢI THÍCH MÔ HÌNH BẢO CHỨNG -->
    <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-3 pb-4 border-b border-slate-200">
      <div>
        <h1 class="text-xl sm:text-2xl font-bold text-slate-900">Quản Lý Đơn Hàng & Trạng Thái Giữ Tiền An Toàn</h1>
        <p class="text-xs text-slate-500 mt-1">
          Theo dõi 4 đơn hàng: 2 đơn Hẹn gặp trực tiếp (Đặt cọc giữ chỗ) và 2 đơn Giao tận nhà qua bưu điện (Dùng thử kiểm tra máy trong 48 giờ)
        </p>
      </div>

      <div class="flex flex-wrap items-center gap-2 text-xs">
        <span class="px-3 py-1 bg-green-50 text-green-700 border border-green-200 rounded-lg font-bold">
          Tổng Tiền Đang Được Sàn Giữ An Toàn: 29.850.000 đ
        </span>
      </div>
    </div>

    <!-- TABS BỘ LỌC ĐƠN HÀNG: TẤT CẢ, HẸN GẶP, GIAO TẬN NHÀ, ĐƠN MUA, ĐƠN BÁN -->
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

    <!-- DANH SÁCH 4 ĐƠN HÀNG CHI TIẾT -->
    <div class="space-y-6" id="ordersListContainer">

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
            Trạng thái: Đã cọc VietQR 1 triệu • Hẹn gặp test máy tại Quận 10
          </div>
        </div>

        <div class="flex flex-col sm:flex-row items-start justify-between gap-4">
          <div class="flex items-start gap-3.5">
            <img src="assets/images/iphone-18-pro-mau-do-anh-dao-dam-1-iphone-18-pro-mau-do-burgundy-co-gi-dac-biet-1.jpg" alt="iPhone 18 Pro Max" class="w-20 h-20 rounded-lg object-cover shrink-0 border border-slate-200">
            <div>
              <h3 class="font-bold text-sm text-slate-900">iPhone 18 Pro Max Đỏ Burgundy 256GB chính hãng VN/A</h3>
              <p class="text-[11px] text-slate-500 mt-0.5">Người bán: <strong>Nguyễn Văn Tuấn</strong> (Quận 10, TP.HCM)</p>
              <div class="text-xs text-slate-700 mt-1.5">
                Giá chốt: <strong>37.000.000 đ</strong> • Đã cọc VietQR: <strong class="text-green-600">1.000.000 đ</strong> (Tin đăng đã tạm khóa)
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
            Khách đã cọc VietQR 200k • Hẹn qua chở bàn lúc 17:30
          </div>
        </div>

        <div class="flex flex-col sm:flex-row items-start justify-between gap-4">
          <div class="flex items-start gap-3.5">
            <img src="assets/images/products/ban-go-thong.jpg" alt="Bàn làm việc gỗ sồi" class="w-20 h-20 rounded-lg object-cover shrink-0 border border-slate-200">
            <div>
              <h3 class="font-bold text-sm text-slate-900">Bàn làm việc gỗ sồi tự nhiên 1m4 x 70cm, có 3 hộc kéo</h3>
              <p class="text-[11px] text-slate-500 mt-0.5">Người mua: <strong>Trần Đình Trọng</strong> (Tài khoản chính chủ đã xác thực)</p>
              <div class="text-xs font-bold text-green-600 mt-1.5">
                Tiền cọc giữ đồ: 200.000 đ (Đã nhận qua VietQR trên sàn)
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

    <!-- TOAST THÔNG BÁO TỨC THÌ -->
    <div id="toastNotification" class="fixed bottom-6 right-6 bg-slate-900 text-white text-xs px-4 py-3 rounded-lg shadow-lg border border-slate-700 hidden z-50 flex items-center gap-3">
      <div class="w-2 h-2 rounded-full bg-emerald-400"></div>
      <span id="toastMsg" class="font-medium">Thông báo</span>
    </div>

  </main>

  <!-- CHÂN TRANG ĐẦY ĐỦ 8 MÀN HÌNH -->
  <jsp:include page="includes/footer.jsp" />

  <!-- SCRIPT XỬ LÝ TOÀN BỘ LOGIC FLOW ĐƠN HÀNG, KHIẾU NẠI VÀ DUAL HANDSHAKE -->
  <script>
    function filterOrders(type) {
      const cards = document.querySelectorAll('.order-card');
      const btnAll = document.getElementById('btnFilterAll');
      const btnCh1 = document.getElementById('btnFilterChannel1');
      const btnCh2 = document.getElementById('btnFilterChannel2');
      const btnBuy = document.getElementById('btnFilterBuy');
      const btnSell = document.getElementById('btnFilterSell');

      // Reset style nút
      [btnAll, btnCh1, btnCh2, btnBuy, btnSell].forEach(b => {
        b.className = 'px-3.5 py-2 rounded-lg bg-white border border-slate-300 text-slate-700 hover:bg-slate-50 transition';
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
      document.getElementById('toastMsg').textContent = msg;
      toast.classList.remove('hidden');
      setTimeout(() => {
        toast.classList.add('hidden');
      }, 3500);
    }
  </script>

</body>
</html>
