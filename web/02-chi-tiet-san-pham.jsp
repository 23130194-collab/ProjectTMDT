<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
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
  <c:if test="${product.dealType ne 'GIVE' and product.price gt 0 and not isProductOwner}">
  <section id="scenarioDemoControls" class="bg-slate-900 text-white py-2 px-4 text-xs">
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
  </c:if>

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
        <div class="bg-white rounded-xl ${product.vipActive ? (product.priorityLevel >= 2 ? 'border-2 border-purple-400 shadow-md shadow-purple-100/50' : 'border-2 border-amber-300 shadow-md shadow-amber-100/50') : 'border border-slate-200'} overflow-hidden p-3 shadow-sm relative">

          <!-- OVERLAY TRẠNG THÁI TẠM KHÓA / ĐÃ BÁN -->
          <div id="imageLockOverlay"
            class="hidden absolute inset-3 bg-slate-900/60 backdrop-blur-xs rounded-lg z-10 flex flex-col items-center justify-center text-white text-center p-4">
            <span id="overlayBadge"
              class="px-3 py-1 bg-amber-500 text-slate-950 font-bold text-xs uppercase tracking-wider rounded-md mb-2">
              Đã Nhận Cọc 10% Giá Sản Phẩm
            </span>
            <h3 id="overlayTitle" class="text-lg font-bold">Bài Đăng Đang Tạm Khóa Giao Dịch</h3>
            <p id="overlayDesc" class="text-xs text-slate-200 mt-1 max-w-md">
              Người mua đã đặt cọc qua VNPay để giữ sản phẩm. Hai bên đang hẹn gặp kiểm tra hàng trực tiếp.
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
            <c:if test="${product.vipActive}">
              <span class="absolute top-3 right-3 ${product.priorityLevel >= 2 ? 'bg-gradient-to-r from-purple-600 to-indigo-600' : 'bg-gradient-to-r from-amber-500 to-orange-500'} text-white text-xs font-black px-3 py-1 rounded-full shadow-md flex items-center gap-1 uppercase tracking-wide">
                <c:out value="${not empty product.badgeLabel ? product.badgeLabel : 'VIP'}"/>
              </span>
            </c:if>
            <span id="activeImageIndex"
              class="absolute bottom-3 right-3 bg-slate-900/80 text-white text-xs px-2.5 py-1 rounded backdrop-blur">
              1 / <c:choose><c:when test="${not empty images}">${fn:length(images)}</c:when><c:otherwise>0</c:otherwise></c:choose> Góc chụp
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

          <c:choose>
            <c:when test="${not empty productSpecs}">
              <div class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-3 text-xs">
                <c:forEach var="spec" items="${productSpecs}">
                  <div class="bg-slate-50 p-2.5 rounded-lg border border-slate-100 flex flex-col justify-between shadow-2xs">
                    <span class="text-slate-400 block text-[10px] font-medium mb-0.5">${spec[0]}</span>
                    <span class="font-bold text-slate-800 text-xs">${spec[1]}</span>
                  </div>
                </c:forEach>
              </div>
            </c:when>
            <c:otherwise>
              <div class="grid grid-cols-2 sm:grid-cols-4 gap-3 text-xs">
                <div class="bg-slate-50 p-2.5 rounded-lg border border-slate-100">
                  <span class="text-slate-400 block text-[10px]">Tình trạng</span>
                  <span class="font-bold text-green-700 text-xs">${product.conditionStatus}</span>
                </div>
                <div class="bg-slate-50 p-2.5 rounded-lg border border-slate-100">
                  <span class="text-slate-400 block text-[10px]">Khu vực</span>
                  <span class="font-bold text-slate-800 text-xs"><c:out value="${product.displayLocation}"/></span>
                </div>
              </div>
            </c:otherwise>
          </c:choose>

          <div class="text-xs text-slate-700 leading-relaxed space-y-2 pt-2"><p>${product.description}</p></div>

          <!-- ĐỊA CHỈ XEM HÀNG TRỰC TIẾP -->
          <div class="mt-3 p-3.5 rounded-lg bg-blue-50 border border-blue-200 text-xs">
            <span class="font-bold text-blue-900 uppercase tracking-wide block text-[11px]">Tạm Điểm Hẹn Gặp Xem &amp; Test Máy Trực Tiếp</span>
            <p class="text-blue-800 font-medium mt-1">
              <c:choose>
                <c:when test="${not empty product.displayLocation}"><c:out value="${product.displayLocation}"/>. </c:when>
                <c:otherwise>Liên hệ người bán để biết địa điểm hẹn gặp. </c:otherwise>
              </c:choose>
              <c:choose><c:when test="${product.dealType eq 'GIVE' or product.price == 0}">Vui lòng nhắn tin với người tặng để thống nhất thời gian nhận sản phẩm.</c:when><c:otherwise>Vui lòng liên hệ đặt cọc hoặc hẹn trước khi qua.</c:otherwise></c:choose>
            </p>
          </div>
        </div>

        <c:choose>
        <c:when test="${isProductOwner}">
        <div class="bg-white rounded-xl border border-slate-200 p-5 sm:p-6 shadow-sm space-y-2">
          <h3 class="text-xs font-bold text-slate-900 uppercase tracking-wider">Tin đăng của bạn</h3>
          <p class="text-xs leading-relaxed text-slate-600">Bạn là người đăng sản phẩm này. Người mua có thể nhắn tin cho bạn để trao đổi.</p>
        </div>
        </c:when>
        <c:when test="${product.dealType eq 'GIVE' or product.price == 0}">
        <div class="bg-white rounded-xl border border-slate-200 p-5 sm:p-6 shadow-sm space-y-2">
          <h3 class="text-xs font-bold text-slate-900 uppercase tracking-wider">Nhận sản phẩm được tặng</h3>
          <p class="text-xs leading-relaxed text-slate-600">Sản phẩm được tặng miễn phí. Nhắn tin với người tặng để thống nhất cách nhận.</p>
        </div>
        </c:when>
        <c:otherwise>
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
              <div class="font-bold text-slate-800">Đặt cọc giữ sản phẩm</div>
              <p class="text-[11px] text-slate-500">Mức cọc theo giá: trên 100.000đ cọc 10%; trên 50.000đ đến 100.000đ cọc 50%; từ 10.000đ đến 50.000đ cọc đủ 100%.</p>
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
        </c:otherwise>
        </c:choose>

      </div>

      <!-- CỘT PHẢI (5 CỘT): GIÁ, HÀNH ĐỘNG VÀ HỒ SƠ NGƯỜI BÁN -->
      <div class="lg:col-span-5 space-y-5">

        <!-- THẺ GIÁ VÀ ĐIỀU HƯỚNG GIAO NHẬN -->
        <div class="bg-white rounded-xl ${product.vipActive ? (product.priorityLevel >= 2 ? 'border-2 border-purple-400 shadow-sm shadow-purple-50' : 'border-2 border-amber-300 shadow-sm shadow-amber-50') : 'border border-slate-200'} p-5 sm:p-6 shadow-sm space-y-4">
          <div>
            <div class="flex items-center gap-2 mb-2 flex-wrap">
              <c:if test="${product.vipActive}">
                <span class="px-2.5 py-0.5 rounded text-[10px] font-black ${product.priorityLevel >= 2 ? 'bg-gradient-to-r from-purple-600 to-indigo-600 text-white shadow-xs' : 'bg-gradient-to-r from-amber-500 to-orange-500 text-white shadow-xs'} uppercase flex items-center gap-1 tracking-wide">
                  <c:out value="${not empty product.badgeLabel ? product.badgeLabel : 'VIP'}"/>
                </span>
              </c:if>
              <span id="dealTypeBadge"
                  class="px-2 py-0.5 rounded text-[10px] font-bold bg-blue-100 text-blue-800 uppercase">
                  <c:choose><c:when test="${product.dealType eq 'GIVE' or product.price == 0}">TIN TẶNG MIỄN PHÍ</c:when><c:otherwise>TIN BÁN THANH LÝ</c:otherwise></c:choose>
                </span>
              <span id="dealMethodBadge" class="px-2 py-0.5 rounded text-[10px] font-bold bg-slate-100 text-slate-700">
                  <c:choose><c:when test="${product.deliveryMethod == 2}">Giao Hàng Qua Bưu Điện</c:when><c:otherwise>Hẹn Gặp Trực Tiếp</c:otherwise></c:choose>
                </span>
            </div>
            <h1 id="productTitle" class="text-base sm:text-lg font-bold text-slate-900 leading-snug">${product.title}</h1>
            <div class="mt-2.5 flex items-baseline gap-2">
              <span class="text-2xl sm:text-3xl font-bold text-red-600"><fmt:formatNumber value="${product.price}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></span>
              <span class="text-xs text-slate-500">Giá tốt bắt trend</span>
            </div>
            <p class="text-[11px] text-slate-500 mt-1">Đăng lúc ${product.createdAt} tại <c:out value="${product.displayLocation}"/></p>
          </div>

          <!-- BANNER TRẠNG THÁI THEO KỊCH BẢN FLOW -->
          <div id="scenarioNoticeBox"
            class="p-3 <c:out value='${product.dealType eq "GIVE" or product.price == 0 ? "bg-emerald-50 border-emerald-200 text-emerald-900" : "bg-amber-50 border-amber-200 text-amber-900"}'/> border rounded-lg text-xs leading-relaxed">
            <span id="scenarioNoticeTitle" class="font-bold block text-[11px] uppercase tracking-wide"><c:choose><c:when test="${isProductOwner}">Tin đăng của bạn:</c:when><c:when test="${product.dealType eq 'GIVE' or product.price == 0}">Nhận sản phẩm miễn phí:</c:when><c:otherwise>Hướng dẫn giao dịch an toàn:</c:otherwise></c:choose></span>
            <span id="scenarioNoticeContent"><c:choose><c:when test="${isProductOwner}">
              Người mua có thể nhắn tin cho bạn để trao đổi về sản phẩm.
            </c:when><c:when test="${product.dealType eq 'GIVE' or product.price == 0}">
              Nhắn tin với người tặng để thống nhất cách nhận sản phẩm. Không cần trả giá hoặc đặt cọc.
            </c:when><c:otherwise>
              Mức cọc: trên 100.000đ cọc 10%; trên 50.000đ đến 100.000đ cọc 50%; từ 10.000đ đến 50.000đ cọc đủ 100%.
            </c:otherwise></c:choose></span>
          </div>

          <!-- CÁC NÚT HÀNH ĐỘNG CHÍNH (THAY ĐỔI THEO FLOW) -->
          <div id="actionButtonsContainer" class="space-y-2.5 pt-1">
            <c:choose>
            <c:when test="${isProductOwner}">
            <button type="button" disabled class="w-full py-3 bg-slate-100 text-slate-500 font-bold text-xs sm:text-sm rounded-lg flex items-center justify-center cursor-not-allowed border border-slate-200">
              Đây là tin đăng của bạn
            </button>
            </c:when>
            <c:when test="${product.dealType eq 'GIVE' or product.price == 0}">
            <a id="btnMessageGift" href="04-chat-tra-gia-vietqr.jsp?productId=${product.id}"
              class="w-full py-3 bg-blue-600 hover:bg-blue-700 text-white font-bold text-xs sm:text-sm rounded-lg flex items-center justify-center shadow-sm transition">
              Nhắn tin
            </a>
            </c:when>
            <c:otherwise>
            <a id="btnDepositMain" href="04-chat-tra-gia-vietqr.jsp?productId=${product.id}"
              class="w-full py-3 bg-green-600 hover:bg-green-700 text-white font-bold text-xs sm:text-sm rounded-lg flex items-center justify-center shadow-sm transition">
              Đặt cọc giữ sản phẩm
            </a>

            <div class="grid grid-cols-2 gap-2">
              <a href="04-chat-tra-gia-vietqr.jsp?productId=${product.id}"
                class="py-2.5 bg-blue-600 hover:bg-blue-700 text-white font-semibold text-xs rounded-lg flex items-center justify-center shadow-sm transition">
                Nhắn tin
              </a>
              <c:choose>
                <c:when test="${product.price == 0}">
                  <button type="button" disabled title="Tin tặng miễn phí không hỗ trợ đề xuất trả giá"
                    class="py-2.5 bg-slate-100 text-slate-400 border border-slate-200 font-semibold text-xs rounded-lg flex items-center justify-center cursor-not-allowed">
                    Đề Xuất Trả Giá
                  </button>
                </c:when>
                <c:otherwise>
                  <a href="04-chat-tra-gia-vietqr.jsp?productId=${product.id}&action=offer"
                    class="py-2.5 bg-amber-50 hover:bg-amber-100 text-amber-900 border border-amber-300 font-semibold text-xs rounded-lg flex items-center justify-center transition">
                    Đề Xuất Trả Giá
                  </a>
                </c:otherwise>
              </c:choose>
            </div>
            </c:otherwise>
            </c:choose>

            <button id="favoriteBtn" onclick="toggleFavorite()"
              class="w-full py-2 bg-slate-100 hover:bg-slate-200 text-slate-700 font-medium text-xs rounded-lg transition">
              ${isFavorited ? 'Đã lưu vào danh sách yêu thích' : 'Lưu tin vào danh sách yêu thích'}
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
            <div class="w-12 h-12 rounded-full bg-blue-600 text-white font-bold text-base flex items-center justify-center shrink-0">
              <c:choose>
                <c:when test="${not empty seller and not empty seller.fullName}">${fn:substring(seller.fullName, 0, 1)}</c:when>
                <c:otherwise>?</c:otherwise>
              </c:choose>
            </div>
            <div>
              <a href="seller-profile?id=${seller.id}" class="font-bold text-slate-900 text-sm hover:text-blue-600 hover:underline inline-flex items-center gap-1">
                <c:choose>
                  <c:when test="${not empty seller and not empty seller.fullName}">${seller.fullName}</c:when>
                  <c:otherwise>Người dùng</c:otherwise>
                </c:choose>
                <svg class="w-3 h-3 text-blue-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"/></svg>
              </a>
              <div class="text-[11px] text-slate-500">
                <c:choose>
                  <c:when test="${not empty product.displayLocation}"><c:out value="${product.displayLocation}"/></c:when>
                  <c:otherwise>Việt Nam</c:otherwise>
                </c:choose>
              </div>
              <div class="text-[11px] text-green-700 font-semibold mt-0.5">Tài khoản chính chủ đã xác thực SĐT</div>
            </div>
          </div>

          <div class="grid grid-cols-2 gap-2.5 pt-2 border-t border-slate-100 text-center text-xs">
            <div class="bg-slate-50 p-2 rounded-lg">
              <span class="block font-bold text-slate-900 text-xs">
                <c:choose>
                  <c:when test="${not empty seller}">${seller.reputationScore} Điểm uy tín</c:when>
                  <c:otherwise>-- Điểm</c:otherwise>
                </c:choose>
              </span>
              <span class="text-[10px] text-slate-500">Chỉ số uy tín trên sàn</span>
            </div>
            <div class="bg-slate-50 p-2 rounded-lg">
              <span class="block font-bold text-slate-900 text-xs">@<c:choose><c:when test="${not empty seller and not empty seller.username}">${seller.username}</c:when><c:otherwise>--</c:otherwise></c:choose></span>
              <span class="text-[10px] text-slate-500">Tên tài khoản</span>
            </div>
          </div>

          <div class="text-[11px] text-slate-500 space-y-1">
            <p>Tham gia: <c:choose><c:when test="${not empty seller}">${seller.createdAt}</c:when><c:otherwise>--</c:otherwise></c:choose></p>
            <p>Tỷ lệ phản hồi tin nhắn: 100% (trong 15 phút)</p>
          </div>

          <a href="seller-profile?id=${seller.id}" class="w-full py-2 bg-slate-100 hover:bg-slate-200 text-slate-800 font-bold text-xs rounded-lg transition shadow-xs flex items-center justify-center gap-1.5 border border-slate-200">
            <span>Xem Hồ Sơ & Đánh Giá Người Bán</span>
            <svg class="w-3.5 h-3.5 text-slate-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"/></svg>
          </a>
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
    const ACTUAL_PRODUCT_SOLD = '${product.status}' === 'SOLD';
    const listedProductPrice = Number('${product.price}') || 0;
    const IS_GIFT_PRODUCT = '${product.dealType}' === 'GIVE' || listedProductPrice <= 0;
    const listedDepositAmount = listedProductPrice > 100000 ? Math.round(listedProductPrice * 0.10) : (listedProductPrice >= 10000 && listedProductPrice <= 50000 ? Math.round(listedProductPrice) : Math.round(listedProductPrice * 0.50));
    const listedDepositRate = listedProductPrice > 100000 ? "10%" : (listedProductPrice >= 10000 && listedProductPrice <= 50000 ? "100%" : "50%");
    const listedDepositText = new Intl.NumberFormat('vi-VN').format(listedDepositAmount) + ' đ';
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

    let isFavorited = ${isFavorited};
    const favoriteEndpoint = '${pageContext.request.contextPath}/favorites';
    function syncFavoriteButton() {
      const btn = document.getElementById('favoriteBtn');
      if (!btn) return;
      if (isFavorited) {
        btn.innerText = 'Đã Lưu Vào Danh Sách Yêu Thích';
        btn.className = 'w-full py-2 bg-amber-100 border border-amber-300 text-amber-900 font-bold text-xs rounded-lg transition';
      } else {
        btn.innerText = 'Lưu Tin Vào Danh Sách Yêu Thích';
        btn.className = 'w-full py-2 bg-slate-100 hover:bg-slate-200 text-slate-700 font-medium text-xs rounded-lg transition';
      }
    }
    async function toggleFavorite() {
      const btn = document.getElementById('favoriteBtn');
      const action = isFavorited ? 'remove' : 'add';
      const body = new URLSearchParams({action, productId: '${product.id}'});
      try {
        const response = await fetch(favoriteEndpoint, {method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'}, body});
        if (response.status === 401) { alert('Vui lòng đăng nhập để lưu tin yêu thích.'); window.location.href='${pageContext.request.contextPath}/07-dang-nhap-xac-thuc.jsp'; return; }
        const result = await response.json();
        if (!result.success) { alert('Không thể cập nhật danh sách yêu thích.'); return; }
        isFavorited = action === 'add'; syncFavoriteButton();
      } catch (e) { alert('Không thể kết nối để cập nhật tin yêu thích.'); }
    }
    syncFavoriteButton();

    function reportListing() {
      const titleEl = document.getElementById('productTitle');
      const title = titleEl ? titleEl.innerText : 'Sản phẩm này';
      alert('Đã tiếp nhận báo cáo của bạn về tin đăng "' + title + '". Bộ phận Kiểm duyệt Admin MuaNgay sẽ xác minh trong vòng 15 phút.');
    }

    // CHUYỂN ĐỔI KỊCH BẢN FLOW (SCENARIO SWITCHER)
    function setScenario(scen) {
      if (ACTUAL_PRODUCT_SOLD && scen !== 'reserved') return;
      // Reset nút điều khiển
      ['open', 'locked', 'sold'].forEach(s => {
        const b = document.getElementById('scen-' + s);
        b.className = 'px-2.5 py-1 rounded font-medium text-xs bg-slate-800 text-slate-300 hover:text-white transition';
      });
      const selectedScenarioButton = document.getElementById('scen-' + scen);
      if (selectedScenarioButton) selectedScenarioButton.className = 'px-2.5 py-1 rounded font-bold text-xs bg-blue-600 text-white transition';

      const overlay = document.getElementById('imageLockOverlay');
      const box = document.getElementById('scenarioNoticeBox');
      const title = document.getElementById('scenarioNoticeTitle');
      const content = document.getElementById('scenarioNoticeContent');
      const actionContainer = document.getElementById('actionButtonsContainer');

      if (scen === 'open') {
        overlay.classList.add('hidden');
        if (IS_GIFT_PRODUCT) {
          box.className = 'p-3 bg-emerald-50 border border-emerald-200 rounded-lg text-xs text-emerald-900 leading-relaxed';
          title.innerText = 'Nhận sản phẩm miễn phí:';
          content.innerText = 'Sản phẩm được tặng miễn phí. Nhắn tin với người tặng để thống nhất cách nhận.';
          actionContainer.innerHTML = `
            <a href="04-chat-tra-gia-vietqr.jsp?productId=${product.id}" class="w-full py-3 bg-blue-600 hover:bg-blue-700 text-white font-bold text-xs sm:text-sm rounded-lg flex items-center justify-center shadow-sm transition">Nhắn tin</a>
            <button id="favoriteBtn" onclick="toggleFavorite()" class="w-full py-2 bg-slate-100 hover:bg-slate-200 text-slate-700 font-medium text-xs rounded-lg transition">Lưu tin vào danh sách yêu thích</button>`;
          syncFavoriteButton();
          return;
        }
        box.className = 'p-3 bg-amber-50 border border-amber-200 rounded-lg text-xs text-amber-900 leading-relaxed';
        title.innerText = 'Điều hướng giao nhận an toàn:';
        content.innerText = 'Đặt cọc ' + listedDepositRate + ' giá sản phẩm (' + listedDepositText + ') qua VNPay để người bán giữ sản phẩm trong lúc hai bên hoàn tất giao dịch.';

        actionContainer.innerHTML = `
          <a href="04-chat-tra-gia-vietqr.jsp?productId=${product.id}" class="w-full py-3 bg-green-600 hover:bg-green-700 text-white font-bold text-xs sm:text-sm rounded-lg flex items-center justify-center shadow-sm transition">
              Đặt cọc giữ sản phẩm
          </a>
          <div class="grid grid-cols-2 gap-2">
            <a href="04-chat-tra-gia-vietqr.jsp?productId=${product.id}" class="py-2.5 bg-blue-600 hover:bg-blue-700 text-white font-semibold text-xs rounded-lg flex items-center justify-center shadow-sm transition">
                Nhắn tin
            </a>
            <c:choose>
              <c:when test="${product.price == 0}">
                <button type="button" disabled title="Tin tặng miễn phí không hỗ trợ đề xuất trả giá" class="py-2.5 bg-slate-100 text-slate-400 border border-slate-200 font-semibold text-xs rounded-lg flex items-center justify-center cursor-not-allowed">
                  Đề Xuất Trả Giá
                </button>
              </c:when>
              <c:otherwise>
                <a href="04-chat-tra-gia-vietqr.jsp?productId=${product.id}&action=offer" class="py-2.5 bg-amber-50 hover:bg-amber-100 text-amber-900 border border-amber-300 font-semibold text-xs rounded-lg flex items-center justify-center transition">
                  Đề Xuất Trả Giá
                </a>
              </c:otherwise>
            </c:choose>
          </div>
          <button id="favoriteBtn" onclick="toggleFavorite()" class="w-full py-2 bg-slate-100 hover:bg-slate-200 text-slate-700 font-medium text-xs rounded-lg transition">
            Lưu Tin Vào Danh Sách Yêu Thích
          </button>
        `;
        syncFavoriteButton();
      } else if (scen === 'locked') {
        overlay.classList.remove('hidden');
        document.getElementById('overlayBadge').innerText = 'ĐÃ NHẬN CỌC ' + listedDepositText.toUpperCase();
        document.getElementById('overlayBadge').className = 'px-3 py-1 bg-amber-500 text-slate-950 font-bold text-xs uppercase tracking-wider rounded-md mb-2';
        document.getElementById('overlayTitle').innerText = 'Bài Đăng Đang Tạm Khóa Giao Dịch';
        document.getElementById('overlayDesc').innerText = 'Người mua đã đặt cọc ' + listedDepositRate + ' giá sản phẩm (' + listedDepositText + ') thành công. Hai bên đang hẹn gặp để kiểm tra sản phẩm.';

        box.className = 'p-3.5 bg-amber-100 border-2 border-amber-400 rounded-lg text-xs text-amber-950 leading-relaxed';
        title.innerText = 'TRẠNG THÁI: ĐÃ TẠM KHÓA BÀI ĐĂNG (ĐẶT CỌC ' + listedDepositText.toUpperCase() + ')';
        content.innerText = 'Tin đăng này đã được tạm khóa để bảo vệ người mua đã đặt cọc. Không ai khác có thể cọc đè. Vui lòng theo dõi hoặc mở khung chat nếu bạn là người mua/người bán của đơn hàng.';

        actionContainer.innerHTML = `
          <button disabled class="w-full py-3 bg-slate-300 text-slate-500 font-bold text-xs sm:text-sm rounded-lg flex items-center justify-center cursor-not-allowed">
            Tin đăng đang tạm khóa (đã nhận cọc \${listedDepositText})
          </button>
          <a href="04-chat-tra-gia-vietqr.jsp?productId=${product.id}" class="w-full py-2.5 bg-blue-600 hover:bg-blue-700 text-white font-bold text-xs rounded-lg flex items-center justify-center shadow-sm transition">
            Vào Khung Chat Xem Địa Điểm Hẹn & Xác Nhận Giao Nhận ->
          </a>
          <a href="05-quan-ly-don-hang.jsp" class="w-full py-2 bg-slate-100 hover:bg-slate-200 text-slate-700 font-semibold text-xs rounded-lg flex items-center justify-center transition border border-slate-200">
            Xem Tiến Độ Đơn Hàng Tại Quản Lý Đơn
          </a>
        `;
      } else if (scen === 'reserved') {
        overlay.classList.remove('hidden');
        document.getElementById('overlayBadge').innerText = 'SẢN PHẨM ĐÃ HẾT';
        document.getElementById('overlayBadge').className = 'px-3 py-1 bg-red-600 text-white font-bold text-xs uppercase tracking-wider rounded-md mb-2';
        document.getElementById('overlayTitle').innerText = 'Sản Phẩm Đã Được Đặt Cọc';
        document.getElementById('overlayDesc').innerText = 'Đơn hàng đã được xác nhận. Sản phẩm hiện không nhận thêm trả giá hoặc đặt cọc.';
        box.className = 'p-3.5 bg-red-50 border-2 border-red-300 rounded-lg text-xs text-red-900 leading-relaxed';
        title.innerText = 'TRẠNG THÁI: SẢN PHẨM ĐÃ HẾT';
        content.innerText = 'Sản phẩm đã có đơn đặt cọc và đang được giữ cho giao dịch. Không thể tiếp tục trả giá hoặc đặt cọc sản phẩm này.';
        actionContainer.innerHTML = `
          <button disabled class="w-full py-3 bg-slate-200 text-slate-500 font-bold text-xs sm:text-sm rounded-lg flex items-center justify-center cursor-not-allowed">Sản phẩm đã hết</button>
          <a href="home" class="w-full py-2.5 bg-blue-600 hover:bg-blue-700 text-white font-bold text-xs rounded-lg flex items-center justify-center shadow-sm transition">Xem sản phẩm khác</a>
        `;
      } else if (scen === 'sold') {
        overlay.classList.remove('hidden');
        document.getElementById('overlayBadge').innerText = 'ĐÃ BÁN THÀNH CÔNG';
        document.getElementById('overlayBadge').className = 'px-3 py-1 bg-green-600 text-white font-bold text-xs uppercase tracking-wider rounded-md mb-2';
        document.getElementById('overlayTitle').innerText = 'Giao Dịch Đã Hoàn Tất Thành Công';
        document.getElementById('overlayDesc').innerText = 'Hai bên đã kiểm tra máy, thanh toán tiền mặt và cùng xác nhận thành công. Sàn đã hoàn tất chuyển cọc cho người bán.';

        box.className = 'p-3.5 bg-green-100 border-2 border-green-400 rounded-lg text-xs text-green-950 leading-relaxed';
        title.innerText = 'TRẠNG THÁI: ĐÃ BÁN THÀNH CÔNG';
        content.innerText = 'Giao dịch đã kết thúc tốt đẹp. Khoản cọc theo mức giá của đơn hàng đã được chuyển cho người bán sau khi hai bên xác nhận hoàn tất.';

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

    if (ACTUAL_PRODUCT_SOLD) {
      document.getElementById('scenarioDemoControls').classList.add('hidden');
      setScenario('reserved');
    }
  </script>

</body>

</html>
