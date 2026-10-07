<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Quản Trị Sàn & Xử Lý Tranh Chấp Trọng Tài - MuaNgay Admin</title>
  <link rel="icon" type="image/svg+xml" href="assets/logos/muangay-logo-icon.svg">
  <script src="https://cdn.tailwindcss.com"></script>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="css/style.css">
  <link rel="stylesheet" href="css/06-quan-tri-admin.css">
</head>
<body class="bg-slate-100 text-slate-900 min-h-screen flex flex-col">

  <!-- THANH ĐIỀU HƯỚNG QUẢN TRỊ VIÊN -->
  <header class="bg-slate-900 text-white border-b border-slate-800 sticky top-0 z-50">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-16 flex items-center justify-between gap-4">
      <div class="flex items-center gap-3">
        <a href="01-trang-chu.jsp" class="flex items-center gap-2.5">
          <img src="assets/logos/muangay-logo-icon.svg" alt="MuaNgay Logo" class="w-9 h-9 rounded-xl shadow-xs">
          <div>
            <span class="text-base font-extrabold text-white tracking-tight block">Mua<span class="text-indigo-400">Ngay</span> <span class="text-xs font-semibold text-slate-300">Admin Portal</span></span>
            <span class="text-[10px] text-slate-400 block -mt-0.5 font-medium">Bàn Làm Việc Doanh Nghiệp Tạo Lập Thị Trường (Market Creator)</span>
          </div>
        </a>
      </div>

      <div class="flex items-center gap-4 text-xs font-semibold">
        <a href="01-trang-chu.jsp" class="text-slate-300 hover:text-white">Xem Giao Diện Người Dùng</a>
        <a href="05-quan-ly-don-hang.jsp" class="text-slate-300 hover:text-white">Quản Lý Đơn Hàng</a>
        <div class="flex items-center gap-2 pl-3 border-l border-slate-700">
          <div class="w-7 h-7 rounded-full bg-purple-600 flex items-center justify-center text-[11px] font-bold text-white">AD</div>
          <span class="text-slate-300 hidden sm:inline-block">Admin Trưởng Ca</span>
        </div>
      </div>
    </div>
  </header>

  <!-- NỘI DUNG CHÍNH: DASHBOARD QUẢN TRỊ SÀN (USE CASES UC15 - UC19) -->
  <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 flex-1 w-full space-y-8">
    
    <!-- TIÊU ĐỀ TRANG -->
    <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-3 pb-2 border-b border-slate-200">
      <div>
        <h1 class="text-xl sm:text-2xl font-bold text-slate-900">Bảng Điều Khiển Quản Trị & Xử Lý Khiếu Nại Giữ Tiền</h1>
        <p class="text-xs text-slate-500 mt-1">
          Giám sát doanh thu sàn, giải quyết khiếu nại trả hàng trong 48 giờ và kiểm soát an toàn giao dịch
        </p>
      </div>

      <div class="flex items-center gap-2 text-xs">
        <span class="px-2.5 py-1 bg-green-100 text-green-800 font-bold rounded-md">
          Hệ Thống Thanh Toán VietQR: Hoạt Động Bình Thường
        </span>
      </div>
    </div>

    <!-- 4 THẺ SỐ LIỆU DOANH THU & DÒNG TIỀN -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
      
      <!-- NGUỒN THU 1: GÓI ĐẨY TIN (65% DOANH THU) -->
      <div class="bg-white p-5 rounded-xl border border-slate-200 shadow-xs space-y-2">
        <div class="flex items-center justify-between">
          <span class="text-xs font-bold text-amber-900 bg-amber-50 px-2 py-0.5 rounded uppercase">Nguồn Thu 1 (65%)</span>
          <span class="text-[10px] text-slate-400">Tháng này</span>
        </div>
        <div class="text-2xl font-bold text-amber-600">18.450.000 đ</div>
        <div class="text-xs font-semibold text-slate-800">Doanh Thu Gói Đẩy Tin Nổi Bật</div>
        <p class="text-[11px] text-slate-500">142 bài đăng mua gói đẩy tin ưu tiên lên đầu trang chủ và danh mục.</p>
      </div>

      <!-- NGUỒN THU 2: PHÍ DỊCH VỤ GIỮ CỌC HẸN GẶP (5.000 Đ/ĐƠN) -->
      <div class="bg-white p-5 rounded-xl border border-slate-200 shadow-xs space-y-2">
        <div class="flex items-center justify-between">
          <span class="text-xs font-bold text-blue-900 bg-blue-50 px-2 py-0.5 rounded uppercase">Nguồn Thu 2</span>
          <span class="text-[10px] text-slate-400">Tháng này</span>
        </div>
        <div class="text-2xl font-bold text-blue-600">4.120.000 đ</div>
        <div class="text-xs font-semibold text-slate-800">Phí Dịch Vụ Giữ Cọc Hẹn Gặp</div>
        <p class="text-[11px] text-slate-500">824 đơn mua bán gặp mặt trực tiếp hoàn tất (thu 5.000 đ / đơn).</p>
      </div>

      <!-- NGUỒN THU 3: PHÍ SÀN 2.5% GIAO HÀNG TẬN NHÀ -->
      <div class="bg-white p-5 rounded-xl border border-slate-200 shadow-xs space-y-2">
        <div class="flex items-center justify-between">
          <span class="text-xs font-bold text-green-900 bg-green-50 px-2 py-0.5 rounded uppercase">Nguồn Thu 3</span>
          <span class="text-[10px] text-slate-400">Tháng này</span>
        </div>
        <div class="text-2xl font-bold text-green-600">12.350.000 đ</div>
        <div class="text-xs font-semibold text-slate-800">Phí Dịch Vụ Giao Hàng Tận Nhà (2.5%)</div>
        <p class="text-[11px] text-slate-500">Thu tự động khi đơn giao bưu điện thành công và sau 48h khách dùng thử ưng ý.</p>
      </div>

      <!-- DÒNG TIỀN TẠM GIỮ AN TOÀN -->
      <div class="bg-white p-5 rounded-xl border border-purple-200 shadow-xs space-y-2 bg-purple-50/30">
        <div class="flex items-center justify-between">
          <span class="text-xs font-bold text-purple-900 bg-purple-100 px-2 py-0.5 rounded uppercase">Tiền Giữ An Toàn</span>
          <span class="text-[10px] text-purple-700 font-bold">VietQR NAPAS</span>
        </div>
        <div class="text-2xl font-bold text-purple-700">84.600.000 đ</div>
        <div class="text-xs font-semibold text-slate-800">Tổng Tiền Đang Được Sàn Giữ Hộ</div>
        <p class="text-[11px] text-slate-500">Tiền cọc giữ chỗ và tiền hàng đang trong thời gian 48h người mua dùng thử.</p>
      </div>

    </div>

    <!-- KHU VỰC 1: BÀN LÀM VIỆC XỬ LÝ TRANH CHẤP & KHIẾU NẠI 48H -->
    <div class="bg-white rounded-xl border border-slate-200 shadow-sm overflow-hidden space-y-4">
      
      <div class="p-5 border-b border-slate-200 flex flex-col sm:flex-row sm:items-center justify-between gap-3 bg-slate-50">
        <div>
          <div class="flex items-center gap-2">
            <span class="w-2.5 h-2.5 rounded-full bg-red-600 animate-pulse"></span>
            <h2 class="text-sm sm:text-base font-bold text-slate-900">
              Bàn Làm Việc Xử Lý Khiếu Nại & Trả Hàng Trong 48 Giờ
            </h2>
          </div>
          <p class="text-xs text-slate-500 mt-0.5">
            Xem video bằng chứng, đối chiếu lịch sử trao đổi để ra phán quyết hoàn tiền cho Người Mua hoặc chuyển tiền cho Người Bán
          </p>
        </div>

        <span class="text-xs font-bold text-red-700 bg-red-50 border border-red-200 px-3 py-1 rounded-full self-start sm:self-auto">
          1 Hồ Sơ Cần Xử Lý
        </span>
      </div>

      <!-- HỒ SƠ TRANH CHẤP CHI TIẾT -->
      <div class="p-5 sm:p-6 space-y-5">
        <div class="border-2 border-red-200 bg-red-50/20 rounded-xl p-5 space-y-4">
          
          <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-2 pb-3 border-b border-red-100 text-xs">
            <div class="flex items-center gap-2">
              <span class="font-bold text-red-900 uppercase">Hồ sơ tranh chấp #TC-88219</span>
              <span class="text-slate-400">•</span>
              <span class="text-slate-700 font-mono">Đơn hàng: #MN-3PL-88219 (iPhone 11 64GB)</span>
            </div>
            <span class="text-red-700 font-bold">Thời gian mở khiếu nại: 10:15 Hôm nay (Trong khung 48h)</span>
          </div>

          <!-- THÔNG TIN HAI BÊN TRANH CHẤP -->
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4 text-xs">
            
            <!-- BÊN KHIẾU NẠI (NGƯỜI MUA) -->
            <div class="p-4 bg-white rounded-lg border border-slate-200 space-y-2">
              <div class="flex items-center justify-between border-b border-slate-100 pb-1.5">
                <span class="font-bold text-slate-900">Bên Khiếu Nại: Người Mua</span>
                <span class="text-[10px] text-blue-600 font-semibold">Tài khoản: HoangKhang_99</span>
              </div>
              <p class="text-slate-700 leading-relaxed">
                <strong>Nội dung phản ánh:</strong> "Tôi nhận máy sáng nay, khi mang về cắm sạc thì máy bị sập nguồn liên tục khi pin dưới 30%, loa trong rè nặng không thể nghe gọi được. Người bán cam kết máy zin hoàn hảo nên tôi yêu cầu trả hàng hoàn 100% tiền cọc và tiền hàng."
              </p>
              <div class="pt-2 flex items-center gap-2 text-[11px]">
                <span class="font-semibold text-slate-600">Bằng chứng gửi kèm:</span>
                <a href="#" class="text-blue-600 font-bold hover:underline">Video_test_loi_ngam_48h.mp4 (24 MB)</a>
              </div>
            </div>

            <!-- BÊN BỊ KHIẾU NẠI (NGƯỜI BÁN) -->
            <div class="p-4 bg-white rounded-lg border border-slate-200 space-y-2">
              <div class="flex items-center justify-between border-b border-slate-100 pb-1.5">
                <span class="font-bold text-slate-900">Bên Bị Khiếu Nại: Người Bán</span>
                <span class="text-[10px] text-blue-600 font-semibold">Tài khoản: VuMinhDuc_Shop</span>
              </div>
              <p class="text-slate-700 leading-relaxed">
                <strong>Ý kiến người bán:</strong> "Lúc đóng gói gửi bưu tá GHN máy vẫn dùng bình thường. Nếu người mua không ưng có thể gửi trả lại hàng theo đúng số IMEI và tem niêm phong trên ốc máy, tôi đồng ý nhận lại máy."
              </p>
              <div class="pt-2 flex items-center gap-2 text-[11px]">
                <span class="font-semibold text-slate-600">Lịch sử đàm phán:</span>
                <a href="04-chat-tra-gia-vietqr.jsp" class="text-blue-600 font-bold hover:underline">Xem trích xuất 24 tin nhắn trao đổi</a>
              </div>
            </div>

          </div>

          <!-- PHÁN QUYẾT CỦA TRỌNG TÀI SÀN (ADMIN DECISION) -->
          <div class="p-4 bg-white rounded-lg border border-slate-300 flex flex-col sm:flex-row sm:items-center justify-between gap-4 text-xs">
            <div>
              <span class="font-bold text-slate-900 block text-xs">Phán Quyết Trọng Tài Sàn MuaNgay:</span>
              <p class="text-[11px] text-slate-600 mt-0.5" id="disputeStatusText">
                Số tiền ký quỹ đang đóng băng: <strong class="text-green-700 font-bold">4.900.000 VNĐ</strong>. Sau khi thẩm định video lỗi ngầm xác thực:
              </p>
            </div>

            <div class="flex items-center gap-2.5" id="disputeActionButtons">
              <!-- NÚT CHẤP THUẬN HOÀN TIỀN -->
              <button onclick="resolveDispute('refund')" class="px-4 py-2 bg-green-600 hover:bg-green-700 text-white font-bold rounded-lg shadow-xs transition text-xs">
                Chấp Thuận Hoàn Tiền 100% Cho Người Mua
              </button>

              <!-- NÚT BÁC KHIẾU NẠI -->
              <button onclick="resolveDispute('payout')" class="px-3 py-2 bg-white border border-slate-300 hover:bg-slate-100 text-slate-700 font-semibold rounded-lg transition text-xs">
                Bác Khiếu Nại - Giải Ngân Cho Người Bán
              </button>
            </div>
          </div>

        </div>
      </div>

    </div>

    <!-- KHU VỰC 2: QUẢN LÝ NGƯỜI DÙNG & TỪ KHÓA CẤM CHAT (USE CASES UC15 & UC16) -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      
      <!-- BẢNG CẢNH CÁO & KHÓA TÀI KHOẢN VI PHẠM (UC_ADM_USERS, UC_ADM_WARNING, UC_ADM_LOCK) -->
      <div class="bg-white rounded-xl border border-slate-200 shadow-sm p-5 space-y-4">
        <div class="flex items-center justify-between border-b border-slate-100 pb-3">
          <div>
            <h3 class="font-bold text-sm text-slate-900">Cảnh Cáo & Khóa Tài Khoản Vi Phạm</h3>
            <p class="text-[11px] text-slate-500">Cơ chế tích lũy 3 lần cảnh cáo tự động khóa vĩnh viễn</p>
          </div>
          <span class="text-xs font-semibold text-slate-500" id="userCountText">Tổng: 2 trường hợp</span>
        </div>

        <div class="space-y-3 text-xs" id="userListContainer">
          <!-- THÀNH VIÊN 1: CẢNH CÁO 2/3 LẦN -->
          <div id="userCard1" class="p-3 bg-slate-50 border border-slate-200 rounded-lg flex items-center justify-between">
            <div>
              <div class="font-bold text-slate-900">tranvanthuan_sg (Trần Văn Thuận)</div>
              <p class="text-[11px] text-slate-500 mt-0.5">Lý do: Cố tình gửi số điện thoại lách sàn và hẹn ngoài</p>
              <span id="userStatus1" class="inline-block mt-1 text-[10px] font-bold text-amber-800 bg-amber-100 px-2 py-0.5 rounded">
                Mức độ: Cảnh cáo lần 2 / 3
              </span>
            </div>
            <button onclick="toggleUserLock('userCard1', 'userStatus1', 'tranvanthuan_sg')" class="px-2.5 py-1.5 bg-red-600 hover:bg-red-700 text-white font-bold text-[11px] rounded transition">
              Khóa Tài Khoản
            </button>
          </div>

          <!-- THÀNH VIÊN 2: ĐÃ KHÓA -->
          <div id="userCard2" class="p-3 bg-red-50/50 border border-red-200 rounded-lg flex items-center justify-between">
            <div>
              <div class="font-bold text-slate-900">shop_apple_fake (Nguyễn Đình Nam)</div>
              <p class="text-[11px] text-slate-500 mt-0.5">Lý do: Bán iPhone khóa mạng báo quốc tế, lừa tiền cọc</p>
              <span id="userStatus2" class="inline-block mt-1 text-[10px] font-bold text-red-800 bg-red-100 px-2 py-0.5 rounded">
                Trạng thái: Đã khóa tài khoản vĩnh viễn
              </span>
            </div>
            <button onclick="toggleUserUnlock('userCard2', 'userStatus2', 'shop_apple_fake')" class="px-2.5 py-1.5 bg-slate-200 hover:bg-slate-300 text-slate-700 font-semibold text-[11px] rounded transition">
              Mở Khóa
            </button>
          </div>
        </div>
      </div>

      <!-- BẢNG CẤU HÌNH TỪ KHÓA CẤM QUÉT TRONG KHUNG CHAT (UC_ADM_BANNED_KW) -->
      <div class="bg-white rounded-xl border border-slate-200 shadow-sm p-5 space-y-4">
        <div class="flex items-center justify-between border-b border-slate-100 pb-3">
          <div>
            <h3 class="font-bold text-sm text-slate-900">Cấu Hình Bộ Lọc Từ Khóa Cấm Trong Chat</h3>
            <p class="text-[11px] text-slate-500">Tự động thay thế thông tin liên lạc ngoài sàn bằng ký tự ***</p>
          </div>
          <button onclick="openAddKeywordModal()" class="px-2.5 py-1 bg-blue-600 hover:bg-blue-700 text-white font-bold text-xs rounded transition">
            + Thêm Từ Cấm
          </button>
        </div>

        <div class="space-y-2 text-xs" id="keywordListContainer">
          <div class="p-2.5 bg-slate-50 border border-slate-200 rounded-lg flex items-center justify-between">
            <div>
              <span class="font-mono font-bold text-slate-800 text-xs">(0[3|5|7|8|9])+([0-9]{8})\b</span>
              <p class="text-[10px] text-slate-500">Mẫu Regex phát hiện và che số điện thoại di động Việt Nam</p>
            </div>
            <span class="text-[10px] font-bold text-green-700 bg-green-100 px-2 py-0.5 rounded">Đang Bật</span>
          </div>

          <div class="p-2.5 bg-slate-50 border border-slate-200 rounded-lg flex items-center justify-between">
            <div>
              <span class="font-mono font-bold text-slate-800 text-xs">\b[0-9]{9,16}\b</span>
              <p class="text-[10px] text-slate-500">Mẫu Regex phát hiện và che số tài khoản ngân hàng</p>
            </div>
            <span class="text-[10px] font-bold text-green-700 bg-green-100 px-2 py-0.5 rounded">Đang Bật</span>
          </div>

          <div class="p-2.5 bg-slate-50 border border-slate-200 rounded-lg flex items-center justify-between">
            <div>
              <span class="font-semibold text-slate-800 text-xs">chuyển khoản ngoài, zalo riêng, cọc riêng</span>
              <p class="text-[10px] text-slate-500">Các cụm từ lôi kéo giao dịch bỏ cọc né sàn</p>
            </div>
            <span class="text-[10px] font-bold text-green-700 bg-green-100 px-2 py-0.5 rounded">Đang Bật</span>
          </div>
        </div>
      </div>

    </div>

  </main>

  <!-- MODAL THÊM TỪ KHÓA CẤM -->
  <div id="addKeywordModal" class="fixed inset-0 bg-slate-900/60 z-50 hidden flex items-center justify-center p-4">
    <div class="bg-white rounded-xl max-w-sm w-full p-6 shadow-2xl space-y-4">
      <div class="flex items-center justify-between border-b border-slate-100 pb-3">
        <h3 class="font-bold text-slate-900 text-sm">Thêm Từ Khóa Hoặc Mẫu Regex Cấm</h3>
        <button onclick="closeAddKeywordModal()" class="text-slate-400 hover:text-slate-600 font-bold text-lg px-2">X</button>
      </div>

      <div class="space-y-3 text-xs">
        <div>
          <label class="block font-bold text-slate-700 mb-1">Từ khóa hoặc Biểu thức quy tắc (Regex):</label>
          <input type="text" id="newKeywordInput" placeholder="Ví dụ: telegram, viber, ib zalo..." class="w-full p-2.5 border border-slate-300 rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-blue-500">
        </div>
        <div>
          <label class="block font-bold text-slate-700 mb-1">Ghi chú mục đích phát hiện:</label>
          <input type="text" id="newKeywordDesc" placeholder="Ngăn chặn hướng người dùng ra kênh chat ngoài" class="w-full p-2.5 border border-slate-300 rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-blue-500">
        </div>
      </div>

      <div class="pt-2 flex gap-2">
        <button onclick="closeAddKeywordModal()" class="flex-1 py-2 border border-slate-300 rounded-lg text-xs font-semibold hover:bg-slate-100">
          Hủy
        </button>
        <button onclick="submitNewKeyword()" class="flex-1 py-2 bg-blue-600 hover:bg-blue-700 font-bold text-xs text-white rounded-lg transition">
          Lưu Cấu Hình
        </button>
      </div>
    </div>
  </div>

  <!-- TOAST THÔNG BÁO TỨC THÌ -->
  <div id="toastNotification" class="fixed bottom-6 right-6 bg-slate-900 text-white text-xs px-4 py-3 rounded-lg shadow-lg border border-slate-700 hidden z-50 flex items-center gap-3">
    <div class="w-2 h-2 rounded-full bg-emerald-400"></div>
    <span id="toastMsg" class="font-medium">Thông báo</span>
  </div>

  <!-- CHÂN TRANG QUẢN TRỊ VIÊN -->
  <footer class="bg-slate-900 text-slate-400 border-t border-slate-800 py-6 text-xs mt-16">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 flex flex-col sm:flex-row items-center justify-between gap-4">
      <div>
        <p class="font-bold text-white">MuaNgay Admin Control Center</p>
        <p class="text-[11px] text-slate-500 mt-0.5">Phục vụ báo cáo khóa luận môn Thương Mại Điện Tử - Mô hình B2C Market Creator.</p>
      </div>
      <div class="flex flex-wrap gap-3 text-xs font-medium text-slate-300">
        <a href="01-trang-chu.jsp" class="hover:text-white">01. Trang chủ</a>
        <a href="02-chi-tiet-san-pham.jsp" class="hover:text-white">02. Chi tiết tin</a>
        <a href="03-dang-tin.jsp" class="hover:text-white">03. Đăng tin</a>
        <a href="04-chat-tra-gia-vietqr.jsp" class="hover:text-white">04. Chat & Trả giá</a>
        <a href="05-quan-ly-don-hang.jsp" class="hover:text-white">05. Quản lý đơn hàng</a>
        <a href="06-quan-tri-admin.jsp" class="text-purple-400 font-bold hover:underline">06. Quản trị Admin</a>
        <a href="07-dang-nhap-xac-thuc.jsp" class="hover:text-white">07. Đăng nhập / Đăng ký</a>
        <a href="08-ho-so-ca-nhan.jsp" class="hover:text-white">08. Hồ sơ cá nhân</a>
      </div>
    </div>
  </footer>

  <script>
    function resolveDispute(decision) {
      const statusText = document.getElementById('disputeStatusText');
      const actionButtons = document.getElementById('disputeActionButtons');

      if (decision === 'refund') {
        statusText.innerHTML = '<span class="text-green-700 font-bold">ĐÃ RA PHÁN QUYẾT:</span> Lệnh hoàn 4.900.000 VNĐ về tài khoản Người Mua (HoangKhang_99) đã được gửi qua cổng thanh toán NAPAS. Đơn hàng #MN-3PL-88219 chuyển sang trạng thái ĐÃ HOÀN TIỀN.';
        actionButtons.innerHTML = '<span class="px-3 py-1.5 bg-green-100 text-green-800 font-bold rounded-md text-xs">Đã Hoàn Tiền Thành Công</span>';
        showToast('Trọng tài đã phán quyết: Hoàn tiền 100% cho Người Mua thành công!');
      } else {
        statusText.innerHTML = '<span class="text-blue-700 font-bold">ĐÃ RA PHÁN QUYẾT:</span> Bác yêu cầu khiếu nại. Lệnh giải ngân 4.777.500 VNĐ (đã trừ 2.5% phí sàn) vào ví Người Bán (VuMinhDuc_Shop) đã hoàn tất.';
        actionButtons.innerHTML = '<span class="px-3 py-1.5 bg-blue-100 text-blue-800 font-bold rounded-md text-xs">Đã Giải Ngân Cho Người Bán</span>';
        showToast('Trọng tài đã phán quyết: Bác khiếu nại và giải ngân cho Người Bán!');
      }
    }

    function toggleUserLock(cardId, statusId, username) {
      const card = document.getElementById(cardId);
      const status = document.getElementById(statusId);
      card.className = 'p-3 bg-red-50/50 border border-red-200 rounded-lg flex items-center justify-between';
      status.className = 'inline-block mt-1 text-[10px] font-bold text-red-800 bg-red-100 px-2 py-0.5 rounded';
      status.textContent = 'Trạng thái: Đã khóa tài khoản vĩnh viễn';
      
      const btn = card.querySelector('button');
      btn.className = 'px-2.5 py-1.5 bg-slate-200 hover:bg-slate-300 text-slate-700 font-semibold text-[11px] rounded transition';
      btn.textContent = 'Mở Khóa';
      btn.setAttribute('onclick', `toggleUserUnlock('\${cardId}', '\${statusId}', '\${username}')`);
      
      showToast('Đã khóa vĩnh viễn tài khoản: ' + username);
    }

    function toggleUserUnlock(cardId, statusId, username) {
      const card = document.getElementById(cardId);
      const status = document.getElementById(statusId);
      card.className = 'p-3 bg-slate-50 border border-slate-200 rounded-lg flex items-center justify-between';
      status.className = 'inline-block mt-1 text-[10px] font-bold text-green-800 bg-green-100 px-2 py-0.5 rounded';
      status.textContent = 'Trạng thái: Đang hoạt động bình thường';
      
      const btn = card.querySelector('button');
      btn.className = 'px-2.5 py-1.5 bg-red-600 hover:bg-red-700 text-white font-bold text-[11px] rounded transition';
      btn.textContent = 'Khóa Tài Khoản';
      btn.setAttribute('onclick', `toggleUserLock('\${cardId}', '\${statusId}', '\${username}')`);
      
      showToast('Đã mở khóa và khôi phục quyền truy cập cho: ' + username);
    }

    function openAddKeywordModal() {
      document.getElementById('addKeywordModal').classList.remove('hidden');
    }

    function closeAddKeywordModal() {
      document.getElementById('addKeywordModal').classList.add('hidden');
    }

    function submitNewKeyword() {
      const kw = document.getElementById('newKeywordInput').value.trim();
      const desc = document.getElementById('newKeywordDesc').value.trim() || 'Từ khóa cấm do Admin cấu hình';
      
      if (!kw) {
        showToast('Vui lòng nhập từ khóa hoặc mẫu Regex.');
        return;
      }

      const container = document.getElementById('keywordListContainer');
      const item = document.createElement('div');
      item.className = 'p-2.5 bg-slate-50 border border-slate-200 rounded-lg flex items-center justify-between';
      item.innerHTML = `
        <div>
          <span class="font-semibold text-slate-800 text-xs">\${kw}</span>
          <p class="text-[10px] text-slate-500">\${desc}</p>
        </div>
        <span class="text-[10px] font-bold text-green-700 bg-green-100 px-2 py-0.5 rounded">Đang Bật</span>
      `;
      container.appendChild(item);

      document.getElementById('newKeywordInput').value = '';
      document.getElementById('newKeywordDesc').value = '';
      closeAddKeywordModal();
      showToast('Đã thêm từ khóa cấm quét tin nhắn mới thành công!');
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
