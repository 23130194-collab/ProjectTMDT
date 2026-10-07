<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${product.title} | MuaNgay</title>
  <link rel="icon" type="image/svg+xml" href="assets/logos/muangay-logo-icon.svg">
  <script src="https://cdn.tailwindcss.com"></script>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="css/style.css">
  <link rel="stylesheet" href="css/02-chi-tiet-san-pham.css">
</head>

<body class="bg-slate-50 text-slate-900 min-h-screen flex flex-col">

  <!-- THANH ĐIỀU HƯỚNG CHÍNH -->
  <jsp:include page="includes/header.jsp" />

  <!-- THANH ĐIỀU KHIỂN KỊCH BẢN FLOW (SCENARIO SWITCHER FOR DEMO) -->
  <section class="bg-slate-900 text-white py-2 px-4 text-xs">
    <div class="max-w-7xl mx-auto flex flex-col sm:flex-row items-center justify-between gap-2">
      <div class="flex items-center gap-2">
        <span class="px-2 py-0.5 rounded bg-blue-600 font-bold uppercase text-[10px]">Trình diễn Kịch bản Flow</span>
        <span class="text-slate-300">Chuyển đổi trạng thái bài đăng thực tế:</span>
      </div>
      <div class="flex items-center gap-2">
        <button onclick="setScenario('open')" id="scen-open"
          class="px-2.5 py-1 rounded font-bold text-xs bg-blue-600 text-white transition">
          1. Đang Mở Bán Tự Do
        </button>
        <button onclick="setScenario('locked')" id="scen-locked"
          class="px-2.5 py-1 rounded font-medium text-xs bg-slate-800 text-slate-300 hover:text-white transition">
          2. Đã Nhận Cọc (Tạm Khóa Tin)
        </button>
        <button onclick="setScenario('sold')" id="scen-sold"
          class="px-2.5 py-1 rounded font-medium text-xs bg-slate-800 text-slate-300 hover:text-white transition">
          3. Đã Bán Thành Công
        </button>
      </div>
    </div>
  </section>

  <!-- ĐƯỜNG DẪN BREADCRUMB PHÂN CẤP -->
  <div class="bg-white border-b border-slate-200">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-2 text-xs text-slate-500 flex items-center gap-2">
      <a href="home" class="hover:text-blue-600">Trang chủ</a>
      <span>/</span>
      <a href="home" class="hover:text-blue-600">Điện Thoại & Thiết Bị Số</a>
      <span>/</span>
      <a href="home" class="hover:text-blue-600">TP. Hồ Chí Minh</a>
      <span>/</span>
      <span class="text-slate-900 font-medium truncate">${product.title}</span>
    </div>
  </div>

  <!-- NỘI DUNG CHÍNH CHI TIẾT SẢN PHẨM -->
  <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 flex-1 w-full">
    <div class="grid grid-cols-1 lg:grid-cols-12 gap-8">

      <!-- CỘT TRÁI (7 CỘT): ẢNH, MÔ TẢ & CHÍNH SÁCH BẢO CHỨNG -->
      <div class="lg:col-span-7 space-y-6">

        <!-- KHUNG ẢNH CHÍNH & THUMBNAILS THỰC TẾ -->
        <div class="bg-white rounded-xl border border-slate-200 overflow-hidden p-3 shadow-sm relative">

          <!-- OVERLAY TRẠNG THÁI TẠM KHÓA / ĐÃ BÁN -->
          <div id="imageLockOverlay"
            class="hidden absolute inset-3 bg-slate-900/60 backdrop-blur-xs rounded-lg z-10 flex flex-col items-center justify-center text-white text-center p-4">
            <span id="overlayBadge"
              class="px-3 py-1 bg-amber-500 text-slate-950 font-bold text-xs uppercase tracking-wider rounded-md mb-2">
              Đã Nhận Cọc 1.000.000 đ
            </span>
            <h3 id="overlayTitle" class="text-lg font-bold">Bài Đăng Đang Tạm Khóa Giao Dịch</h3>
            <p id="overlayDesc" class="text-xs text-slate-200 mt-1 max-w-md">
              Người mua đã đặt cọc VietQR giữ máy. Hai bên đang hẹn gặp test máy trực tiếp tại Quận 10.
            </p>
          </div>

                    <div
            class="w-full h-80 sm:h-96 rounded-lg overflow-hidden relative group bg-slate-950 flex items-center justify-center">
            <c:set var="mainImage" value="${not empty images ? images[0].imageUrl : 'assets/images/no-image.jpg'}" />
            <img id="mainDetailImage"
              src="${mainImage}"
              alt="${product.title}"
              class="w-full h-full object-cover transition duration-300">
            <span id="productTopBadge"
              class="absolute top-3 left-3 bg-blue-600 text-white text-xs font-semibold px-2.5 py-1 rounded shadow-sm">
              Ảnh thực tế 100%
            </span>
            <span id="activeImageIndex"
              class="absolute bottom-3 right-3 bg-slate-900/80 text-white text-xs px-2.5 py-1 rounded backdrop-blur">
              1 / ${images.size()} Góc chụp
            </span>
          </div>
          <div class="grid grid-cols-4 gap-2.5 mt-3">
            <c:forEach var="img" items="${images}" varStatus="loop">
                <div onclick="changeImage('${img.imageUrl}', ${loop.index + 1}, this)"
                  class="thumb-btn h-20 rounded-lg overflow-hidden border ${loop.index == 0 ? 'border-2 border-blue-600' : 'border-slate-200'} cursor-pointer hover:border-slate-400 opacity-70 hover:opacity-100 transition shadow-xs">
                  <img src="${img.imageUrl}" alt="Ảnh ${loop.index + 1}" class="w-full h-full object-cover">
                </div>
            </c:forEach>
          </div>
        </div>

        <!-- MÔ TẢ CHI TIẾT SẢN PHẨM -->
        <div class="bg-white rounded-xl border border-slate-200 p-5 sm:p-6 shadow-sm space-y-4">
          <h2 class="text-sm font-bold text-slate-900 border-b border-slate-100 pb-3">
            Đặc Điểm Kỹ Thuật & Tình Trạng Thực Tế
          </h2>

          <div class="grid grid-cols-2 sm:grid-cols-4 gap-3 text-xs">
            <div class="bg-slate-50 p-2.5 rounded-lg border border-slate-100">
              <span class="text-slate-400 block text-[10px]">Hãng sản xuất</span>
              <span class="font-bold text-slate-800 text-xs">Apple</span>
            </div>
            <div class="bg-slate-50 p-2.5 rounded-lg border border-slate-100">
              <span class="text-slate-400 block text-[10px]">Dòng máy</span>
              <span class="font-bold text-slate-800 text-xs">iPhone 18 Pro Max</span>
            </div>
            <div class="bg-slate-50 p-2.5 rounded-lg border border-slate-100">
              <span class="text-slate-400 block text-[10px]">Dung lượng / Màu</span>
              <span class="font-bold text-slate-800 text-xs">256GB • Đỏ Burgundy</span>
            </div>
            <div class="bg-slate-50 p-2.5 rounded-lg border border-slate-100">
              <span class="text-slate-400 block text-[10px]">Tình trạng máy</span>
              <span class="font-bold text-green-700 text-xs">${product.conditionStatus}</span>
            </div>
          </div>

          <div class="text-xs text-slate-700 leading-relaxed space-y-2 pt-2"><p>${product.description}</p></div>

          <!-- ĐỊA CHỈ XEM HÀNG TRỰC TIẾP -->
          <div class="mt-3 p-3.5 rounded-lg bg-blue-50 border border-blue-200 text-xs">
            <span class="font-bold text-blue-900 uppercase tracking-wide block text-[11px]">Địa Điểm Hẹn Gặp Xem & Test
              Máy Trực Tiếp</span>
            <p class="text-blue-800 font-medium mt-1">
              Đường Tô Hiến Thành, Phường 13, Quận 10, TP. Hồ Chí Minh. Vui lòng liên hệ đặt cọc hoặc hẹn trước khung
              giờ trước khi qua.
            </p>
          </div>
        </div>

        <!-- QUY TRÌNH MUA BÁN HẸN GẶP TRỰC TIẾP -->
        <div class="bg-white rounded-xl border border-slate-200 p-5 sm:p-6 shadow-sm space-y-3">
          <div class="flex items-center justify-between border-b border-slate-100 pb-2">
            <h3 class="text-xs font-bold text-slate-900 uppercase tracking-wider">
              Quy Trình Hẹn Gặp Mua Bán Trực Tiếp An Toàn
            </h3>
            <span class="text-[11px] font-semibold text-blue-600 bg-blue-50 px-2 py-0.5 rounded">
              Không Thu Phí Tiền Mặt
            </span>
          </div>

          <div class="grid grid-cols-1 sm:grid-cols-4 gap-3 text-xs pt-1">
            <div class="p-2.5 bg-slate-50 rounded-lg border border-slate-200 space-y-1">
              <span
                class="w-5 h-5 rounded-full bg-blue-600 text-white text-[10px] font-bold flex items-center justify-center">1</span>
              <div class="font-bold text-slate-800">Đặt cọc giữ máy</div>
              <p class="text-[11px] text-slate-500">Cọc 1.000.000 đ qua VietQR để tạm khóa tin, tránh bị người khác mua
                mất.</p>
            </div>
            <div class="p-2.5 bg-slate-50 rounded-lg border border-slate-200 space-y-1">
              <span
                class="w-5 h-5 rounded-full bg-blue-600 text-white text-[10px] font-bold flex items-center justify-center">2</span>
              <div class="font-bold text-slate-800">Hẹn gặp test máy</div>
              <p class="text-[11px] text-slate-500">Gặp trực tiếp tại điểm hẹn, test 3uTools, màn hình và chụp ảnh thực
                tế.</p>
            </div>
            <div class="p-2.5 bg-slate-50 rounded-lg border border-slate-200 space-y-1">
              <span
                class="w-5 h-5 rounded-full bg-blue-600 text-white text-[10px] font-bold flex items-center justify-center">3</span>
              <div class="font-bold text-slate-800">Thanh toán tại chỗ</div>
              <p class="text-[11px] text-slate-500">Trao tay tiền mặt hoặc chuyển khoản số tiền 37.000.000 đ còn lại.
              </p>
            </div>
            <div class="p-2.5 bg-slate-50 rounded-lg border border-slate-200 space-y-1">
              <span
                class="w-5 h-5 rounded-full bg-green-600 text-white text-[10px] font-bold flex items-center justify-center">4</span>
              <div class="font-bold text-slate-800">Hai bên xác nhận</div>
              <p class="text-[11px] text-slate-500">Cả 2 cùng bấm xác nhận trên app -> Sàn hoàn trả tiền cọc cho người
                bán.</p>
            </div>
          </div>
        </div>

      </div>

      <!-- CỘT PHẢI (5 CỘT): GIÁ, HÀNH ĐỘNG VÀ HỒ SƠ NGƯỜI BÁN -->
      <div class="lg:col-span-5 space-y-5">

        <!-- THẺ GIÁ VÀ ĐIỀU HƯỚNG GIAO NHẬN -->
        <div class="bg-white rounded-xl border border-slate-200 p-5 sm:p-6 shadow-sm space-y-4">
          <div>
            <div class="flex items-center gap-2 mb-2">
                              <span id="dealTypeBadge"
                  class="px-2 py-0.5 rounded text-[10px] font-bold bg-blue-100 text-blue-800 uppercase">
                  <c:choose><c:when test="${product.price == 0}">TIN TẶNG MIỄN PHÍ</c:when><c:otherwise>TIN BÁN THANH LÝ</c:otherwise></c:choose>
                </span>
                              <span id="dealMethodBadge" class="px-2 py-0.5 rounded text-[10px] font-bold bg-slate-100 text-slate-700">
                  <c:choose><c:when test="${product.deliveryMethod == 2}">Giao Hàng Qua Bưu Điện</c:when><c:otherwise>Hẹn Gặp Trực Tiếp</c:otherwise></c:choose>
                </span>
            </div>
            <h1 class="text-base sm:text-lg font-bold text-slate-900 leading-snug">${product.title}</h1>
            <div class="mt-2.5 flex items-baseline gap-2">
              <span class="text-2xl sm:text-3xl font-bold text-red-600"><fmt:formatNumber value="${product.price}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></span>
              <span class="text-xs text-slate-500">Giá tốt bắt trend</span>
            </div>
            <p class="text-[11px] text-slate-500 mt-1">Đăng lúc ${product.createdAt} tại ${product.location}</p>
          </div>

          <!-- BANNER TRẠNG THÁI THEO KỊCH BẢN FLOW -->
          <div id="scenarioNoticeBox"
            class="p-3 bg-amber-50 border border-amber-200 rounded-lg text-xs text-amber-900 leading-relaxed">
            <span id="scenarioNoticeTitle" class="font-bold block text-[11px] uppercase tracking-wide">Hướng dẫn giao
              dịch an toàn:</span>
            <span id="scenarioNoticeContent">
              Mặt hàng Thiết bị số cao cấp nên hẹn gặp trực tiếp tại quán cafe hoặc tại nhà để test máy kỹ càng. Bạn có
              thể đặt cọc 1.000.000 đ qua VietQR để người bán giữ máy không bán cho người khác.
            </span>
          </div>

          <!-- CÁC NÚT HÀNH ĐỘNG CHÍNH (THAY ĐỔI THEO FLOW) -->
          <div id="actionButtonsContainer" class="space-y-2.5 pt-1">
            <a id="btnDepositMain" href="04-chat-tra-gia-vietqr.jsp"
              class="w-full py-3 bg-green-600 hover:bg-green-700 text-white font-bold text-xs sm:text-sm rounded-lg flex items-center justify-center shadow-sm transition">
              Đặt Cọc Giữ Máy Ngay (VietQR Cọc 1.000.000 đ)
            </a>

            <div class="grid grid-cols-2 gap-2">
              <a href="04-chat-tra-gia-vietqr.jsp"
                class="py-2.5 bg-blue-600 hover:bg-blue-700 text-white font-semibold text-xs rounded-lg flex items-center justify-center shadow-sm transition">
                Nhắn Tin Mua Máy
              </a>
              <a href="04-chat-tra-gia-vietqr.jsp"
                class="py-2.5 bg-amber-50 hover:bg-amber-100 text-amber-900 border border-amber-300 font-semibold text-xs rounded-lg flex items-center justify-center transition">
                Đề Xuất Trả Giá
              </a>
            </div>

            <button id="favoriteBtn" onclick="toggleFavorite()"
              class="w-full py-2 bg-slate-100 hover:bg-slate-200 text-slate-700 font-medium text-xs rounded-lg transition">
              Lưu Tin Vào Danh Sách Yêu Thích
            </button>
          </div>

          <div class="pt-3 border-t border-slate-100 text-center">
            <button onclick="reportListing()" class="text-[11px] text-red-600 hover:underline font-medium">
              Báo cáo tin đăng lừa đảo hoặc thông tin sai lệch
            </button>
          </div>
        </div>

        <!-- THẺ THÔNG TIN NGƯỜI BÁN & UY TÍN -->
        <div class="bg-white rounded-xl border border-slate-200 p-5 sm:p-6 shadow-sm space-y-3.5">
          <h3 class="text-xs font-bold text-slate-500 uppercase tracking-wider">Hồ Sơ Người Bán Đã Xác Thực</h3>

          <div class="flex items-center gap-3.5">
            <div
              class="w-12 h-12 rounded-full bg-blue-600 text-white font-bold text-base flex items-center justify-center shrink-0">
              NV
            </div>
            <div>
              <div class="font-bold text-slate-900 text-sm">Nguyễn Văn Tuấn</div>
              <div class="text-[11px] text-slate-500">Quận 10, TP. Hồ Chí Minh</div>
              <div class="text-[11px] text-green-700 font-semibold mt-0.5">Tài khoản chính chủ đã xác thực SĐT</div>
            </div>
          </div>

          <div class="grid grid-cols-2 gap-2.5 pt-2 border-t border-slate-100 text-center text-xs">
            <div class="bg-slate-50 p-2 rounded-lg">
              <span class="block font-bold text-slate-900 text-xs">5.0 / 5.0 Điểm</span>
              <span class="text-[10px] text-slate-500">8 lượt đánh giá uy tín</span>
            </div>
            <div class="bg-slate-50 p-2 rounded-lg">
              <span class="block font-bold text-slate-900 text-xs">6 Món đồ</span>
              <span class="text-[10px] text-slate-500">Đã bán thành công</span>
            </div>
          </div>

          <div class="text-[11px] text-slate-500 space-y-1">
            <p>Thời gian tham gia: 1 năm trước</p>
            <p>Tỷ lệ phản hồi tin nhắn: 100% (trong 15 phút)</p>
          </div>
        </div>

        <!-- SO SÁNH NHANH KÊNH GIAO HÀNG TẬN NHÀ -->
        <div class="bg-slate-100 rounded-xl p-4 text-xs text-slate-600 space-y-2 border border-slate-200">
          <span class="font-bold text-slate-800 block text-xs">Bạn muốn mua giao hàng tận nhà?</span>
          <p class="text-[11px] leading-relaxed">
            Đối với mặt hàng Điện tử hoặc Thời trang, MuaNgay hỗ trợ giao hàng qua bưu điện (GHN/GHTK) với quyền lợi
            đồng kiểm 5-10 phút và được dùng thử 48 giờ tại nhà trước khi chuyển tiền cho người bán.
          </p>
          <a href="05-quan-ly-don-hang.jsp" class="inline-block text-blue-600 font-bold hover:underline text-[11px]">
            Xem minh họa đơn hàng giao tận nhà & dùng thử 48h ->
          </a>
        </div>

      </div>

    </div>
  </main>

  <!-- CHÂN TRANG ĐỒNG BỘ -->
  <jsp:include page="includes/footer.jsp" />

  <!-- SCRIPT XỬ LÝ ĐỔI ẢNH VÀ CHUYỂN ĐỔI KỊCH BẢN FLOW -->
  <script>
    function changeImage(src, index, btn) {
      document.getElementById('mainDetailImage').src = src;
      document.getElementById('activeImageIndex').innerText = `\${index} /  Góc chụp`;

      document.querySelectorAll('.thumb-btn').forEach(b => {
        b.className = 'thumb-btn h-20 rounded-lg overflow-hidden border border-slate-200 hover:border-slate-400 cursor-pointer opacity-70 hover:opacity-100 transition';
      });
      if (btn) {
        btn.className = 'thumb-btn h-20 rounded-lg overflow-hidden border-2 border-blue-600 cursor-pointer shadow-xs transition';
      }
    }

    let isFavorited = false;
    function toggleFavorite() {
      isFavorited = !isFavorited;
      const btn = document.getElementById('favoriteBtn');
      if (isFavorited) {
        btn.innerText = 'Đã Lưu Vào Danh Sách Yêu Thích';
        btn.className = 'w-full py-2 bg-amber-100 border border-amber-300 text-amber-900 font-bold text-xs rounded-lg transition';
      } else {
        btn.innerText = 'Lưu Tin Vào Danh Sách Yêu Thích';
        btn.className = 'w-full py-2 bg-slate-100 hover:bg-slate-200 text-slate-700 font-medium text-xs rounded-lg transition';
      }
    }

    function reportListing() {
      alert('Đã tiếp nhận báo cáo của bạn về tin đăng "iPhone 18 Pro Max Đỏ Burgundy 256GB". Bộ phận Kiểm duyệt Admin MuaNgay sẽ xác minh trong vòng 15 phút.');
    }

    // CHUYỂN ĐỔI KỊCH BẢN FLOW (SCENARIO SWITCHER)
    function setScenario(scen) {
      // Reset nút điều khiển
      ['open', 'locked', 'sold'].forEach(s => {
        const b = document.getElementById('scen-' + s);
        b.className = 'px-2.5 py-1 rounded font-medium text-xs bg-slate-800 text-slate-300 hover:text-white transition';
      });
      document.getElementById('scen-' + scen).className = 'px-2.5 py-1 rounded font-bold text-xs bg-blue-600 text-white transition';

      const overlay = document.getElementById('imageLockOverlay');
      const box = document.getElementById('scenarioNoticeBox');
      const title = document.getElementById('scenarioNoticeTitle');
      const content = document.getElementById('scenarioNoticeContent');
      const actionContainer = document.getElementById('actionButtonsContainer');

      if (scen === 'open') {
        overlay.classList.add('hidden');
        box.className = 'p-3 bg-amber-50 border border-amber-200 rounded-lg text-xs text-amber-900 leading-relaxed';
        title.innerText = 'Điều hướng giao nhận an toàn:';
        content.innerText = 'Mặt hàng Điện thoại cao cấp bắt buộc test máy trực tiếp hoặc chọn giao nhận có đồng kiểm. Người mua đặt cọc 1.000.000 đ qua VietQR để tạm khóa bài đăng chống người khác mua mất.';

        actionContainer.innerHTML = `
          <a href="04-chat-tra-gia-vietqr.jsp" class="w-full py-3 bg-green-600 hover:bg-green-700 text-white font-bold text-xs sm:text-sm rounded-lg flex items-center justify-center shadow-sm transition">
            Đặt Cọc Giữ Máy Ngay (VietQR Cọc 1.000.000 đ)
          </a>
          <div class="grid grid-cols-2 gap-2">
            <a href="04-chat-tra-gia-vietqr.jsp" class="py-2.5 bg-blue-600 hover:bg-blue-700 text-white font-semibold text-xs rounded-lg flex items-center justify-center shadow-sm transition">
              Nhắn Tin Mua Máy
            </a>
            <a href="04-chat-tra-gia-vietqr.jsp" class="py-2.5 bg-amber-50 hover:bg-amber-100 text-amber-900 border border-amber-300 font-semibold text-xs rounded-lg flex items-center justify-center transition">
              Đề Xuất Trả Giá
            </a>
          </div>
          <button id="favoriteBtn" onclick="toggleFavorite()" class="w-full py-2 bg-slate-100 hover:bg-slate-200 text-slate-700 font-medium text-xs rounded-lg transition">
            Lưu Tin Vào Danh Sách Yêu Thích
          </button>
        `;
      } else if (scen === 'locked') {
        overlay.classList.remove('hidden');
        document.getElementById('overlayBadge').innerText = 'ĐÃ NHẬN CỌC 1.000.000 Đ';
        document.getElementById('overlayBadge').className = 'px-3 py-1 bg-amber-500 text-slate-950 font-bold text-xs uppercase tracking-wider rounded-md mb-2';
        document.getElementById('overlayTitle').innerText = 'Bài Đăng Đang Tạm Khóa Giao Dịch';
        document.getElementById('overlayDesc').innerText = 'Người mua đã đặt cọc VietQR 1.000.000 đ thành công. Hai bên đang hẹn gặp test máy trực tiếp tại Quận 10 lúc 16:00 chiều nay.';

        box.className = 'p-3.5 bg-amber-100 border-2 border-amber-400 rounded-lg text-xs text-amber-950 leading-relaxed';
        title.innerText = 'TRẠNG THÁI: ĐÃ TẠM KHÓA BÀI ĐĂNG (ĐẶT CỌC 1.000.000 Đ)';
        content.innerText = 'Tin đăng này đã được tạm khóa để bảo vệ người mua đã đặt cọc. Không ai khác có thể cọc đè. Vui lòng theo dõi hoặc mở khung chat nếu bạn là người mua/người bán của đơn hàng.';

        actionContainer.innerHTML = `
          <button disabled class="w-full py-3 bg-slate-300 text-slate-500 font-bold text-xs sm:text-sm rounded-lg flex items-center justify-center cursor-not-allowed">
            Tin Đăng Đang Tạm Khóa (Đã Nhận Cọc 1 Triệu)
          </button>
          <a href="04-chat-tra-gia-vietqr.jsp" class="w-full py-2.5 bg-blue-600 hover:bg-blue-700 text-white font-bold text-xs rounded-lg flex items-center justify-center shadow-sm transition">
            Vào Khung Chat Xem Địa Điểm Hẹn & Xác Nhận Giao Nhận ->
          </a>
          <a href="05-quan-ly-don-hang.jsp" class="w-full py-2 bg-slate-100 hover:bg-slate-200 text-slate-700 font-semibold text-xs rounded-lg flex items-center justify-center transition border border-slate-200">
            Xem Tiến Độ Đơn Hàng Tại Quản Lý Đơn
          </a>
        `;
      } else if (scen === 'sold') {
        overlay.classList.remove('hidden');
        document.getElementById('overlayBadge').innerText = 'ĐÃ BÁN THÀNH CÔNG';
        document.getElementById('overlayBadge').className = 'px-3 py-1 bg-green-600 text-white font-bold text-xs uppercase tracking-wider rounded-md mb-2';
        document.getElementById('overlayTitle').innerText = 'Giao Dịch Đã Hoàn Tất Thành Công';
        document.getElementById('overlayDesc').innerText = 'Hai bên đã kiểm tra máy, thanh toán tiền mặt và cùng xác nhận thành công. Sàn đã hoàn tất chuyển cọc cho người bán.';

        box.className = 'p-3.5 bg-green-100 border-2 border-green-400 rounded-lg text-xs text-green-950 leading-relaxed';
        title.innerText = 'TRẠNG THÁI: ĐÃ BÁN THÀNH CÔNG';
        content.innerText = 'Giao dịch đã kết thúc tốt đẹp. Tiền cọc 1.000.000 đ đã chuyển vào tài khoản người bán, người mua đã nhận máy và thanh toán đủ.';

        actionContainer.innerHTML = `
          <button disabled class="w-full py-3 bg-slate-200 text-slate-500 font-bold text-xs sm:text-sm rounded-lg flex items-center justify-center cursor-not-allowed">
            Món Đồ Này Đã Được Bán
          </button>
          <a href="home" class="w-full py-2.5 bg-blue-600 hover:bg-blue-700 text-white font-bold text-xs rounded-lg flex items-center justify-center shadow-sm transition">
            Xem Các Tin Đăng Điện Thoại Khác Tại Trang Chủ ->
          </a>
        `;
      }
    }
  </script>

</body>

</html>