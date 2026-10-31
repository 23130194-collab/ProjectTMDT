<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%@ page import="model.Product" %>
<%@ page import="dao.ReviewDAO.ReviewDetail" %>
<%@ page import="dao.ReviewDAO.SellerRatingSummary" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Locale" %>
<%
  User seller = (User) request.getAttribute("seller");
  List<Product> sellerProducts = (List<Product>) request.getAttribute("sellerProducts");
  List<ReviewDetail> sellerReviews = (List<ReviewDetail>) request.getAttribute("sellerReviews");
  SellerRatingSummary ratingSummary = (SellerRatingSummary) request.getAttribute("sellerRatingSummary");
  Integer completedSalesCount = (Integer) request.getAttribute("completedSalesCount");

  if (seller == null) {
    response.sendRedirect("01-trang-chu.jsp");
    return;
  }
  if (completedSalesCount == null) completedSalesCount = 0;
  if (ratingSummary == null) ratingSummary = new SellerRatingSummary();

  NumberFormat moneyFormat = NumberFormat.getInstance(new Locale("vi", "VN"));
  SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");
  SimpleDateFormat reviewDateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm");

  String sellerInitial = seller.getFullName() != null && !seller.getFullName().isEmpty()
          ? seller.getFullName().substring(0, 1).toUpperCase() : "?";

  // Tạo địa chỉ rút gọn
  StringBuilder addrSb = new StringBuilder();
  if (seller.getWard() != null && !seller.getWard().isEmpty()) addrSb.append(seller.getWard());
  if (seller.getProvince() != null && !seller.getProvince().isEmpty()) {
    if (addrSb.length() > 0) addrSb.append(", ");
    addrSb.append(seller.getProvince());
  }
  String displayLocation = addrSb.length() > 0 ? addrSb.toString() : "Toàn quốc";
%>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Hồ Sơ Người Bán: <%= seller.getFullName() %> - MuaNgay</title>
  <link rel="icon" type="image/svg+xml" href="assets/logos/muangay-logo-icon.svg">
  <script src="https://cdn.tailwindcss.com"></script>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="css/style.css">
</head>
<body class="bg-slate-50 text-slate-900 min-h-screen flex flex-col justify-between">

  <!-- THANH HEADER CHÍNH -->
  <jsp:include page="includes/header.jsp" />

  <main class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-8 w-full flex-1 space-y-6">

    <!-- KHỐI 1: THẺ HỒ SƠ NGƯỜI BÁN (PROFILE HEADER) -->
    <div class="bg-white rounded-2xl border border-slate-200 shadow-sm p-6 sm:p-8 relative overflow-hidden">
      <!-- Background trang trí nhẹ -->
      <div class="absolute top-0 right-0 w-96 h-96 bg-gradient-to-br from-blue-50 to-indigo-50/40 rounded-full blur-3xl -z-10 pointer-events-none"></div>

      <div class="flex flex-col md:flex-row md:items-center justify-between gap-6">
        
        <!-- THÔNG TIN AVATAR & TÊN -->
        <div class="flex items-start sm:items-center gap-4">
          <div class="w-20 h-20 sm:w-24 sm:h-24 rounded-2xl bg-gradient-to-tr from-blue-600 to-indigo-600 text-white flex items-center justify-center font-extrabold text-3xl shadow-md shrink-0 border-2 border-white">
            <%= sellerInitial %>
          </div>

          <div class="space-y-1.5">
            <div class="flex flex-wrap items-center gap-2">
              <h1 class="text-xl sm:text-2xl font-bold text-slate-900"><%= seller.getFullName() %></h1>
              <span class="px-2.5 py-0.5 rounded-full text-[10px] font-bold bg-green-50 text-green-700 border border-green-200 inline-flex items-center gap-1">
                <span>✓</span> Đã Xác Thực Danh Tính
              </span>
            </div>

            <div class="text-xs text-slate-500 flex flex-wrap items-center gap-x-3 gap-y-1">
              <span>@<%= seller.getUsername() %></span>
              <span>•</span>
              <span>Tham gia: <%= seller.getCreatedAt() != null ? dateFormat.format(seller.getCreatedAt()) : "Mới tham gia" %></span>
              <span>•</span>
              <span>Khu vực: <strong><%= displayLocation %></strong></span>
            </div>

            <!-- RATING SAO & ĐIỂM UY TÍN -->
            <div class="flex flex-wrap items-center gap-3 pt-1 text-xs">
              <div class="flex items-center gap-1 bg-amber-50 border border-amber-200 px-2.5 py-1 rounded-lg">
                <span class="text-amber-500 text-sm">★</span>
                <span class="font-extrabold text-amber-900 text-sm">
                  <%= String.format(Locale.US, "%.1f", ratingSummary.averageRating) %>
                </span>
                <span class="text-[11px] text-amber-700">/ 5.0 (<%= ratingSummary.totalReviews %> lượt đánh giá)</span>
              </div>

              <div class="bg-blue-50 border border-blue-200 px-2.5 py-1 rounded-lg text-blue-900 font-bold text-xs flex items-center gap-1">
                <span>🏆</span>
                <span><%= seller.getReputationScore() %> Điểm Uy Tín</span>
              </div>
            </div>
          </div>
        </div>

        <!-- HÀNH ĐỘNG NHẮN TIN -->
        <div class="flex sm:flex-col gap-2 shrink-0">
          <a href="04-chat-tra-gia-vietqr.jsp" class="px-5 py-2.5 bg-blue-600 hover:bg-blue-700 text-white font-bold text-xs rounded-xl transition shadow-sm text-center flex items-center justify-center gap-1.5">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"/></svg>
            <span>Nhắn Tin Cho Người Bán</span>
          </a>
        </div>

      </div>

      <!-- 4 CHỈ SỐ THỐNG KÊ NHANH -->
      <div class="grid grid-cols-2 sm:grid-cols-4 gap-3 pt-6 mt-6 border-t border-slate-100 text-center">
        <div class="p-3 bg-slate-50/80 rounded-xl border border-slate-100">
          <span class="text-[11px] text-slate-500 block">Đang Bán</span>
          <span class="font-bold text-base text-slate-900"><%= sellerProducts.size() %> Tin</span>
        </div>
        <div class="p-3 bg-slate-50/80 rounded-xl border border-slate-100">
          <span class="text-[11px] text-slate-500 block">Giao Dịch Thành Công</span>
          <span class="font-bold text-base text-green-700"><%= completedSalesCount %> Đơn</span>
        </div>
        <div class="p-3 bg-slate-50/80 rounded-xl border border-slate-100">
          <span class="text-[11px] text-slate-500 block">Đánh Giá Tích Cực</span>
          <span class="font-bold text-base text-amber-600"><%= ratingSummary.totalReviews > 0 ? Math.round((double)(ratingSummary.count5Star + ratingSummary.count4Star) * 100 / ratingSummary.totalReviews) : 100 %>%</span>
        </div>
        <div class="p-3 bg-slate-50/80 rounded-xl border border-slate-100">
          <span class="text-[11px] text-slate-500 block">Tỷ Lệ Phản Hồi Chat</span>
          <span class="font-bold text-base text-blue-600">100% (Dưới 15p)</span>
        </div>
      </div>
    </div>

    <!-- KHỐI 2: TABS BÀI ĐĂNG & ĐÁNH GIÁ -->
    <div class="space-y-4">
      
      <!-- NÚT CHUYỂN TABS -->
      <div class="flex items-center gap-2 border-b border-slate-200 pb-3 text-xs font-bold">
        <button id="tabBtnProducts" onclick="switchSellerTab('products')" class="px-4 py-2.5 rounded-xl bg-blue-600 text-white shadow-xs transition flex items-center gap-1.5">
          <span>Các Bài Đăng Của Người Bán</span>
          <span class="bg-white/20 text-white px-2 py-0.5 rounded-full text-[10px]"><%= sellerProducts.size() %></span>
        </button>
        <button id="tabBtnReviews" onclick="switchSellerTab('reviews')" class="px-4 py-2.5 rounded-xl bg-white border border-slate-300 text-slate-700 hover:bg-slate-50 transition flex items-center gap-1.5">
          <span>Đánh Giá Từ Người Mua</span>
          <span class="bg-amber-100 text-amber-800 px-2 py-0.5 rounded-full text-[10px]"><%= sellerReviews.size() %></span>
        </button>
      </div>

      <!-- NỘI DUNG TAB 1: CÁC BÀI ĐĂNG CỦA NGƯỜI BÁN -->
      <div id="tabContentProducts" class="space-y-4">
        <% if (sellerProducts.isEmpty()) { %>
          <div class="bg-white rounded-2xl border border-slate-200 p-12 text-center text-slate-400 text-xs">
            Người bán hiện chưa có bài đăng nào đang hiển thị.
          </div>
        <% } else { %>
          <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
            <% for (Product p : sellerProducts) {
              boolean isSold = "SOLD".equalsIgnoreCase(p.getStatus());
              String imgUrl = p.getPrimaryImage() != null && !p.getPrimaryImage().isEmpty()
                      ? p.getPrimaryImage() : "assets/images/products/iphone-13-pro-max.jpg";
            %>
            <a href="product-detail?id=<%= p.getId() %>" class="group bg-white rounded-xl border border-slate-200 overflow-hidden shadow-xs hover:shadow-md transition flex flex-col justify-between">
              <div>
                <div class="relative w-full aspect-square bg-slate-100 overflow-hidden">
                  <img src="<%= imgUrl %>" alt="<%= p.getTitle() %>" class="w-full h-full object-cover group-hover:scale-105 transition duration-300">
                  <% if (isSold) { %>
                    <div class="absolute inset-0 bg-slate-900/50 flex items-center justify-center">
                      <span class="px-3 py-1 bg-red-600 text-white font-extrabold text-xs uppercase tracking-wider rounded-lg shadow-md">
                        Đã Bán
                      </span>
                    </div>
                  <% } else { %>
                    <span class="absolute top-2 left-2 px-2 py-0.5 bg-green-600 text-white font-bold text-[10px] rounded shadow-xs">
                      Đang Bán
                    </span>
                  <% } %>
                </div>

                <div class="p-3.5 space-y-1.5">
                  <h3 class="font-bold text-xs text-slate-900 line-clamp-2 group-hover:text-blue-600 transition">
                    <%= p.getTitle() %>
                  </h3>
                  <div class="font-extrabold text-sm text-red-600">
                    <%= moneyFormat.format(Math.round(p.getPrice())) %> đ
                  </div>
                </div>
              </div>

              <div class="px-3.5 pb-3 pt-1 text-[11px] text-slate-400 border-t border-slate-100 flex items-center justify-between">
                <span><%= p.getProvince() != null ? p.getProvince() : "Toàn quốc" %></span>
                <span><%= p.getCreatedAt() != null ? dateFormat.format(p.getCreatedAt()) : "" %></span>
              </div>
            </a>
            <% } %>
          </div>
        <% } %>
      </div>

      <!-- NỘI DUNG TAB 2: ĐÁNH GIÁ TỪ NGƯỜI MUA -->
      <div id="tabContentReviews" class="hidden space-y-5">
        
        <!-- BẢNG TỔNG QUAN PHÂN BỐ SAO ĐÁNH GIÁ -->
        <div class="bg-white rounded-2xl border border-slate-200 p-6 space-y-4">
          <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
            <div>
              <h2 class="text-sm font-bold text-slate-900 uppercase tracking-wide">
                Đánh Giá Thực Tế Từ Khách Hàng Đã Mua
              </h2>
              <p class="text-xs text-slate-500 mt-0.5">
                Chỉ những khách hàng đã đặt cọc và mua đơn hàng thành công mới được đánh giá người bán. Mỗi đơn hàng chỉ được đánh giá 1 lần.
              </p>
            </div>

            <!-- ĐIỂM SAO LỚN -->
            <div class="text-center sm:text-right shrink-0">
              <div class="text-3xl font-extrabold text-slate-900">
                <%= String.format(Locale.US, "%.1f", ratingSummary.averageRating) %><span class="text-base text-slate-400 font-normal"> / 5.0</span>
              </div>
              <div class="text-amber-400 text-base tracking-wider">
                ★★★★★
              </div>
              <div class="text-[11px] text-slate-500 mt-0.5">Dựa trên <%= ratingSummary.totalReviews %> lượt đánh giá</div>
            </div>
          </div>

          <!-- THANH TIẾN TRÌNH CÁC SAO -->
          <% if (ratingSummary.totalReviews > 0) { %>
          <div class="grid grid-cols-1 sm:grid-cols-5 gap-2 pt-4 border-t border-slate-100 text-xs">
            <div class="flex items-center gap-1.5">
              <span class="text-[11px] text-slate-600 w-10">5 sao:</span>
              <div class="flex-1 h-2 bg-slate-100 rounded-full overflow-hidden">
                <div class="h-full bg-amber-400 rounded-full" style="width: <%= (ratingSummary.count5Star * 100 / ratingSummary.totalReviews) %>%"></div>
              </div>
              <span class="text-[10px] text-slate-400 w-6 text-right"><%= ratingSummary.count5Star %></span>
            </div>

            <div class="flex items-center gap-1.5">
              <span class="text-[11px] text-slate-600 w-10">4 sao:</span>
              <div class="flex-1 h-2 bg-slate-100 rounded-full overflow-hidden">
                <div class="h-full bg-amber-400 rounded-full" style="width: <%= (ratingSummary.count4Star * 100 / ratingSummary.totalReviews) %>%"></div>
              </div>
              <span class="text-[10px] text-slate-400 w-6 text-right"><%= ratingSummary.count4Star %></span>
            </div>

            <div class="flex items-center gap-1.5">
              <span class="text-[11px] text-slate-600 w-10">3 sao:</span>
              <div class="flex-1 h-2 bg-slate-100 rounded-full overflow-hidden">
                <div class="h-full bg-amber-400 rounded-full" style="width: <%= (ratingSummary.count3Star * 100 / ratingSummary.totalReviews) %>%"></div>
              </div>
              <span class="text-[10px] text-slate-400 w-6 text-right"><%= ratingSummary.count3Star %></span>
            </div>

            <div class="flex items-center gap-1.5">
              <span class="text-[11px] text-slate-600 w-10">2 sao:</span>
              <div class="flex-1 h-2 bg-slate-100 rounded-full overflow-hidden">
                <div class="h-full bg-amber-400 rounded-full" style="width: <%= (ratingSummary.count2Star * 100 / ratingSummary.totalReviews) %>%"></div>
              </div>
              <span class="text-[10px] text-slate-400 w-6 text-right"><%= ratingSummary.count2Star %></span>
            </div>

            <div class="flex items-center gap-1.5">
              <span class="text-[11px] text-slate-600 w-10">1 sao:</span>
              <div class="flex-1 h-2 bg-slate-100 rounded-full overflow-hidden">
                <div class="h-full bg-amber-400 rounded-full" style="width: <%= (ratingSummary.count1Star * 100 / ratingSummary.totalReviews) %>%"></div>
              </div>
              <span class="text-[10px] text-slate-400 w-6 text-right"><%= ratingSummary.count1Star %></span>
            </div>
          </div>
          <% } %>
        </div>

        <!-- DANH SÁCH CÁC BÌNH LUẬN ĐÁNH GIÁ CHI TIẾT -->
        <% if (sellerReviews.isEmpty()) { %>
          <div class="bg-white rounded-2xl border border-slate-200 p-12 text-center space-y-2">
            <div class="w-12 h-12 rounded-full bg-amber-50 text-amber-500 flex items-center justify-center mx-auto text-xl font-bold">★</div>
            <h3 class="text-sm font-bold text-slate-800">Chưa có đánh giá nào cho người bán này</h3>
            <p class="text-xs text-slate-500 max-w-sm mx-auto">
              Khi bạn mua sản phẩm và xác nhận đã nhận hàng thành công, bạn sẽ có thể để lại đánh giá uy tín cho người bán.
            </p>
          </div>
        <% } else { %>
          <div class="space-y-3.5">
            <% for (ReviewDetail r : sellerReviews) {
              String rInitial = r.reviewerName != null && !r.reviewerName.isEmpty() ? r.reviewerName.substring(0, 1).toUpperCase() : "U";
            %>
            <div class="bg-white rounded-2xl border border-slate-200 p-5 shadow-xs space-y-3">
              <div class="flex items-start justify-between gap-3">
                <div class="flex items-center gap-3">
                  <div class="w-10 h-10 rounded-full bg-slate-100 text-slate-700 font-bold flex items-center justify-center text-sm border border-slate-200">
                    <%= rInitial %>
                  </div>
                  <div>
                    <span class="font-bold text-xs text-slate-900 block"><%= r.reviewerName %></span>
                    <span class="text-[11px] text-slate-400">Đã mua: <strong><%= r.productTitle %></strong></span>
                  </div>
                </div>

                <div class="text-right">
                  <div class="text-amber-400 text-sm tracking-wider">
                    <% for (int s = 1; s <= 5; s++) { %>
                      <%= s <= r.rating ? "★" : "☆" %>
                    <% } %>
                  </div>
                  <div class="text-[10px] text-slate-400 mt-0.5">
                    <%= r.createdAt != null ? reviewDateFormat.format(r.createdAt) : "" %>
                  </div>
                </div>
              </div>

              <!-- NỘI DUNG NHẬN XÉT CHỮ -->
              <div class="p-3 bg-slate-50 rounded-xl border border-slate-100 text-xs text-slate-800 leading-relaxed">
                "<%= r.comment %>"
              </div>
            </div>
            <% } %>
          </div>
        <% } %>

      </div>

    </div>

  </main>

  <!-- CHÂN TRANG -->
  <jsp:include page="includes/footer.jsp" />

  <script>
    function switchSellerTab(tab) {
      const btnP = document.getElementById('tabBtnProducts');
      const btnR = document.getElementById('tabBtnReviews');
      const contentP = document.getElementById('tabContentProducts');
      const contentR = document.getElementById('tabContentReviews');

      if (tab === 'products') {
        btnP.className = 'px-4 py-2.5 rounded-xl bg-blue-600 text-white shadow-xs transition flex items-center gap-1.5';
        btnR.className = 'px-4 py-2.5 rounded-xl bg-white border border-slate-300 text-slate-700 hover:bg-slate-50 transition flex items-center gap-1.5';
        contentP.classList.remove('hidden');
        contentR.classList.add('hidden');
      } else {
        btnR.className = 'px-4 py-2.5 rounded-xl bg-blue-600 text-white shadow-xs transition flex items-center gap-1.5';
        btnP.className = 'px-4 py-2.5 rounded-xl bg-white border border-slate-300 text-slate-700 hover:bg-slate-50 transition flex items-center gap-1.5';
        contentR.classList.remove('hidden');
        contentP.classList.add('hidden');
      }
    }
  </script>

</body>
</html>
