<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%@ page import="model.OrderSummary" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Locale" %>
<%@ page import="dao.ReviewDAO" %>
<%@ page import="dao.ReviewDAO.ReviewDetail" %>
<%@ page import="dao.ReviewDAO.SellerRatingSummary" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
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

  private String initials(String value) {
    if (value == null || value.trim().isEmpty()) {
      return "US";
    }
    String[] parts = value.trim().split("\\s+");
    String first = parts[0].substring(0, 1);
    String last = parts.length > 1 ? parts[parts.length - 1].substring(0, 1) : "";
    return (first + last).toUpperCase();
  }

  private String maskPhone(String phone) {
    if (phone == null || phone.trim().isEmpty()) {
      return "Chưa cập nhật";
    }
    String digits = phone.replaceAll("\\D+", "");
    if (digits.length() < 6) {
      return h(phone);
    }
    return digits.substring(0, 4) + "***" + digits.substring(digits.length() - 3);
  }

  private String orderStatusText(String status) {
    if ("COMPLETED".equalsIgnoreCase(status)) return "Đã hoàn tất";
    if ("DEPOSIT_CONFIRMED".equalsIgnoreCase(status) || "DEPOSITED".equalsIgnoreCase(status)) return "Đang giữ cọc";
    if ("DEPOSIT_PENDING".equalsIgnoreCase(status)) return "Chờ xác nhận cọc";
    if ("SHIPPING".equalsIgnoreCase(status)) return "Đang giao hàng";
    if ("CANCELED".equalsIgnoreCase(status) || "CANCELLED".equalsIgnoreCase(status)) return "Đã hủy đơn";
    if ("DISPUTED".equalsIgnoreCase(status)) return "Đang khiếu nại";
    if ("NEGOTIATING".equalsIgnoreCase(status)) return "Đang thương lượng";
    return "Đang giữ cọc";
  }

  private String orderBadgeClass(String status) {
    if ("COMPLETED".equalsIgnoreCase(status)) return "text-emerald-700 bg-emerald-50 border-emerald-200";
    if ("DEPOSIT_CONFIRMED".equalsIgnoreCase(status) || "DEPOSITED".equalsIgnoreCase(status) || "SHIPPING".equalsIgnoreCase(status)) return "text-blue-700 bg-blue-50 border-blue-200";
    if ("DEPOSIT_PENDING".equalsIgnoreCase(status)) return "text-amber-700 bg-amber-50 border-amber-200";
    if ("CANCELED".equalsIgnoreCase(status) || "CANCELLED".equalsIgnoreCase(status) || "DISPUTED".equalsIgnoreCase(status)) return "text-red-700 bg-red-50 border-red-200";
    return "text-slate-700 bg-slate-50 border-slate-200";
  }
%>
<%
  User currentUser = (User) session.getAttribute("user");
  if (currentUser == null) currentUser = (User) session.getAttribute("currentUser");
  if (currentUser == null) {
    response.sendRedirect(request.getContextPath() + "/07-dang-nhap-xac-thuc.jsp");
    return;
  }

  String displayName = currentUser.getFullName() != null && !currentUser.getFullName().trim().isEmpty()
          ? currentUser.getFullName().trim()
          : currentUser.getUsername();
  String email = currentUser.getEmail() != null ? currentUser.getEmail() : "";
  String phone = currentUser.getPhone() != null ? currentUser.getPhone() : "";
  String province = currentUser.getProvince() != null ? currentUser.getProvince() : "";
  String ward = currentUser.getWard() != null ? currentUser.getWard() : "";
  String addressDetail = currentUser.getAddressDetail() != null ? currentUser.getAddressDetail() : "";
  String fullAddress = String.join(", ", java.util.Arrays.asList(addressDetail, ward, province).stream().filter(s -> s != null && !s.trim().isEmpty()).toArray(String[]::new));
  String avatarText = initials(displayName);
  String avatarImage = currentUser.getAvatar() != null ? currentUser.getAvatar().trim() : "";
  Integer reqSuccessCount = (Integer) request.getAttribute("successfulOrdersCount");
  int successCount = reqSuccessCount != null ? reqSuccessCount : 0;
  List<ReviewDetail> customerReviews = (List<ReviewDetail>) request.getAttribute("customerReviews");
  if (customerReviews == null) customerReviews = java.util.Collections.emptyList();
  SellerRatingSummary sellerRatingSummary = (SellerRatingSummary) request.getAttribute("sellerRatingSummary");
  if (sellerRatingSummary == null) sellerRatingSummary = new SellerRatingSummary();
  SimpleDateFormat reviewDateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm");
  String createdText = currentUser.getCreatedAt() != null
          ? new SimpleDateFormat("MM/yyyy").format(currentUser.getCreatedAt())
          : "hôm nay";
  String statusText = currentUser.getStatus() != null ? currentUser.getStatus() : "ACTIVE";
  String authMessage = (String) session.getAttribute("authMessage");
  String changePassSuccess = (String) session.getAttribute("changePassSuccess");
  String profileMessage = (String) session.getAttribute("profileMessage");
  boolean profileMessageError = Boolean.TRUE.equals(session.getAttribute("profileMessageError"));
  Map<String, String> profileFieldErrors = (Map<String, String>) session.getAttribute("profileFieldErrors");
  Map<String, String> profileFormValues = (Map<String, String>) session.getAttribute("profileFormValues");
  if (profileFieldErrors == null) profileFieldErrors = java.util.Collections.emptyMap();
  if (profileFormValues == null) profileFormValues = java.util.Collections.emptyMap();
  String editName = profileFormValues.containsKey("fullName") ? profileFormValues.get("fullName") : displayName;
  String editEmail = profileFormValues.containsKey("email") ? profileFormValues.get("email") : email;
  String editPhone = profileFormValues.containsKey("phone") ? profileFormValues.get("phone") : phone;
  String editProvince = profileFormValues.containsKey("province") ? profileFormValues.get("province") : province;
  String editWard = profileFormValues.containsKey("ward") ? profileFormValues.get("ward") : ward;
  String editAddressDetail = profileFormValues.containsKey("addressDetail") ? profileFormValues.get("addressDetail") : addressDetail;
  if (authMessage != null) {
    session.removeAttribute("authMessage");
  }
  if (changePassSuccess != null) {
    session.removeAttribute("changePassSuccess");
  }
  if (profileMessage != null) {
    session.removeAttribute("profileMessage");
    session.removeAttribute("profileMessageError");
  }
  if (!profileFieldErrors.isEmpty()) {
    session.removeAttribute("profileFieldErrors");
    session.removeAttribute("profileFormValues");
  }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Tài Khoản & Quản Lý Đồ Bán Của Bạn - MuaNgay</title>
  <link rel="icon" type="image/svg+xml" href="assets/logos/muangay-logo-icon.svg">
  <script src="https://cdn.tailwindcss.com"></script>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="css/style.css">
  <link rel="stylesheet" href="css/08-ho-so-ca-nhan.css">
</head>
<body class="bg-slate-50 text-slate-900 min-h-screen flex flex-col">

  <!-- THANH ĐIỀU HƯỚNG CHÍNH (HEADER) -->
  <jsp:include page="includes/header.jsp" />

  <!-- NỘI DUNG CHÍNH: HỒ SƠ & QUẢN LÝ BÀI ĐĂNG CỦA TÔI -->
  <main class="max-w-5xl mx-auto px-4 py-8 flex-1 w-full space-y-6">
    
    <!-- THẺ TỔNG QUAN TÀI KHOẢN -->
    <div class="bg-white rounded-xl border border-slate-200 p-5 flex flex-col sm:flex-row sm:items-start justify-between gap-4">
      <div class="flex items-center gap-4">
        <div id="profileAvatarBig" class="w-16 h-16 rounded-full bg-teal-600 text-white font-bold text-2xl flex items-center justify-center shrink-0 overflow-hidden shadow-xs ring-2 ring-slate-100 select-none">
          <% if (!avatarImage.isEmpty()) { %>
            <img src="<%= h(avatarImage) %>" alt="<%= h(displayName) %>" referrerpolicy="no-referrer" class="w-full h-full rounded-full object-cover">
          <% } else { %>
            <%= h(avatarText) %>
          <% } %>
        </div>
        <div>
          <h1 id="profileDisplayName" class="text-lg font-bold text-slate-900"><%= h(displayName) %></h1>
          <div class="text-xs text-slate-500 mt-0.5">
            Thành viên MuaNgay<%= fullAddress.isEmpty() ? "" : " • " + h(fullAddress) %>
          </div>
          <div class="flex flex-wrap items-center gap-x-3 gap-y-1 mt-2">
            <% if (successCount >= 1) { %>
              <span class="px-2 py-0.5 rounded-md bg-emerald-50 text-emerald-700 text-xs font-semibold border border-emerald-200 flex items-center gap-1">
                <svg class="w-3.5 h-3.5 text-emerald-600" fill="currentColor" viewBox="0 0 20 20"><path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"/></svg>
                Điểm Uy Tín: 100/100
              </span>
            <% } else { %>
              <span class="px-2 py-0.5 rounded-md bg-teal-50 text-teal-700 text-xs font-semibold border border-teal-200">Thành viên mới</span>
            <% } %>
            <span class="text-xs text-slate-600">Đã giao dịch thành công: <strong class="text-slate-800"><%= successCount %> đơn</strong></span>
            <% if (sellerRatingSummary.totalReviews > 0) { %>
              <a href="javascript:void(0)" onclick="switchProfileSection('reviews')" class="text-xs text-amber-600 font-semibold flex items-center gap-1 hover:underline">
                <svg class="w-3.5 h-3.5 fill-amber-400 text-amber-400" viewBox="0 0 20 20"><path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"/></svg>
                <%= String.format(Locale.US, "%.1f", sellerRatingSummary.averageRating) %> (<%= sellerRatingSummary.totalReviews %> đánh giá)
              </a>
            <% } else { %>
              <span class="text-xs text-slate-500">0 đánh giá</span>
            <% } %>
          </div>
          <div class="flex items-center gap-1.5 mt-2 text-xs text-teal-600 font-medium">
            <svg class="w-3.5 h-3.5" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/></svg>
            Email đã xác thực
          </div>
          <% if (successCount >= 1) { %>
            <div class="text-xs text-emerald-600 font-medium mt-1 flex items-center gap-1">
              <svg class="w-3.5 h-3.5" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/></svg>
              Đã mở khoá Điểm Uy Tín (<%= successCount %>/1 giao dịch hoàn tất)
            </div>
          <% } else { %>
            <div class="text-xs text-slate-400 mt-1">Chưa đủ lịch sử giao dịch. Cần hoàn tất tối thiểu 1 giao dịch để mở khoá Điểm Uy Tín.</div>
            <div class="text-xs text-slate-400 mt-0.5">0/1 giao dịch</div>
          <% } %>
        </div>
      </div>

      <div class="flex sm:flex-col gap-2 shrink-0">
        <button onclick="openEditProfileModal()" class="px-3.5 py-2 border border-slate-200 hover:bg-slate-50 text-slate-700 text-xs rounded-lg transition text-center">
          Chỉnh sửa thông tin
        </button>
        <button onclick="openChangePasswordModal()" class="px-3.5 py-2 border border-slate-200 hover:bg-slate-50 text-slate-700 text-xs rounded-lg transition text-center">
          Đổi mật khẩu
        </button>
      </div>
    </div>

    <!-- TABS ĐIỀU HƯỚNG NỘI DUNG TRANG CÁ NHÂN -->
    <c:set var="isStatsTab" value="${param.tab == 'stats'}" />
    <c:set var="isOrdersTab" value="${param.tab == 'orders'}" />
    <c:set var="isReviewsTab" value="${param.tab == 'reviews'}" />
    <div class="flex border-b border-slate-200 gap-1 text-xs font-semibold overflow-x-auto">
      <button id="profileTabPosts" onclick="switchProfileSection('posts')" class="${!isStatsTab && !isOrdersTab && !isReviewsTab ? 'pb-3 px-3 text-blue-600 border-b-2 border-blue-600 transition whitespace-nowrap' : 'pb-3 px-3 text-slate-500 hover:text-slate-800 transition whitespace-nowrap'}">
        Tin Tôi Đang Đăng Bán (<c:choose><c:when test="${not empty myPosts}">${myPosts.size()}</c:when><c:otherwise>0</c:otherwise></c:choose>)
      </button>
      <button id="profileTabOrders" onclick="switchProfileSection('orders')" class="${isOrdersTab ? 'pb-3 px-3 text-blue-600 border-b-2 border-blue-600 transition whitespace-nowrap' : 'pb-3 px-3 text-slate-500 hover:text-slate-800 transition whitespace-nowrap'}">
        Lịch Sử Mua Hàng (<c:choose><c:when test="${not empty buyerOrders}">${buyerOrders.size()}</c:when><c:otherwise>0</c:otherwise></c:choose>)
      </button>
      <button id="profileTabStats" onclick="switchProfileSection('stats')" class="${isStatsTab ? 'pb-3 px-3 text-blue-600 border-b-2 border-blue-600 transition whitespace-nowrap' : 'pb-3 px-3 text-slate-500 hover:text-slate-800 transition whitespace-nowrap'}">
        Thống Kê Doanh Thu &amp; Đơn Bán
      </button>
      <button id="profileTabSaved" onclick="switchProfileSection('saved')" class="pb-3 px-3 text-slate-500 hover:text-slate-800 transition whitespace-nowrap">
        Tin Đã Lưu Yêu Thích
      </button>
      <button id="profileTabReviews" onclick="switchProfileSection('reviews')" class="${isReviewsTab ? 'pb-3 px-3 text-blue-600 border-b-2 border-blue-600 transition whitespace-nowrap' : 'pb-3 px-3 text-slate-500 hover:text-slate-800 transition whitespace-nowrap'}">
        Đánh Giá Từ Khách Hàng (<%= customerReviews.size() %>)
      </button>
    </div>

    <!-- PHẦN 1: QUẢN LÝ BÀI ĐĂNG CỦA TÔI -->
    <section id="sectionPosts" class="space-y-3 ${isStatsTab || isOrdersTab || isReviewsTab ? 'hidden' : ''}">
      
      <!-- BỘ LỌC TRẠNG THÁI BÀI ĐĂNG -->
      <div class="flex items-center justify-between text-xs">
        <div class="flex items-center gap-2">
          <span class="text-slate-500">Xem theo:</span>
          <select id="postStatusFilter" onchange="filterPosts(this.value)" class="px-3 py-1.5 bg-white border border-slate-200 rounded-lg text-slate-700 focus:outline-none focus:ring-1 focus:ring-slate-400">
            <option value="all" selected>Đang rao bán</option>
            <option value="active">Đang hiển thị</option>
            <option value="pending">Chờ duyệt</option>
            <option value="sold">Đã bán xong</option>
          </select>
        </div>

        <a href="post-ad" class="px-3 py-1.5 bg-amber-500 hover:bg-amber-600 text-slate-900 font-bold rounded-lg transition">
          + Đăng món đồ mới
        </a>
      </div>



      <c:choose>
        <c:when test="${not empty myPosts}">
          <c:forEach var="post" items="${myPosts}">
            <div class="post-item bg-white rounded-xl border border-slate-200 p-4 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3"
                 data-status="${post.status}">
              <div class="flex items-center gap-3">
                <c:choose>
                  <c:when test="${not empty post.primaryImage}">
                    <img src="${post.primaryImage}" alt="${post.title}" class="w-14 h-14 rounded-lg object-cover shrink-0 border border-slate-200">
                  </c:when>
                  <c:otherwise>
                    <div class="w-14 h-14 rounded-lg bg-slate-100 flex items-center justify-center shrink-0 border border-slate-200">
                      <span class="text-slate-300 text-[10px]">No img</span>
                    </div>
                  </c:otherwise>
                </c:choose>
                <div>
                  <span class="font-semibold text-slate-900 text-sm block">${post.title}</span>
                  <div class="flex items-center gap-2 text-xs mt-1 text-slate-500 flex-wrap">
                    <c:choose>
                      <c:when test="${post.price == 0}">
                        <span class="text-slate-700 font-semibold">Miễn phí</span>
                      </c:when>
                      <c:otherwise>
                        <span class="text-slate-800 font-semibold"><fmt:formatNumber value="${post.price}" type="number" groupingUsed="true" maxFractionDigits="0"/> đ</span>
                      </c:otherwise>
                    </c:choose>
                    <span>•</span>
                    <fmt:formatDate value="${post.createdAt}" pattern="dd/MM/yyyy"/>
                    <span>•</span>
                    <c:choose>
                      <c:when test="${post.status == 'ACTIVE'}">
                        <span class="text-teal-700 font-medium">Đang hiển thị</span>
                      </c:when>
                      <c:when test="${post.status == 'PENDING'}">
                        <span class="text-amber-600 font-medium">Chờ duyệt</span>
                      </c:when>
                      <c:when test="${post.status == 'SOLD'}">
                        <span class="text-slate-400 font-medium">Đã bán</span>
                      </c:when>
                      <c:when test="${post.status == 'HIDDEN'}">
                        <span class="text-red-500 font-medium">Đã ẩn</span>
                      </c:when>
                      <c:otherwise>
                        <span>${post.status}</span>
                      </c:otherwise>
                    </c:choose>
                  </div>
                </div>
              </div>

              <div class="flex items-center gap-2 shrink-0 flex-wrap">
                <a href="product-detail?id=${post.id}" class="px-3 py-1.5 border border-slate-200 hover:bg-slate-50 rounded-lg text-xs text-slate-600">
                  Xem bài
                </a>
                <a href="edit-post?id=${post.id}" class="px-3 py-1.5 border border-slate-200 hover:bg-slate-50 rounded-lg text-xs text-slate-700 font-medium">
                  Sửa Tin
                </a>
                <c:if test="${post.status != 'SOLD'}">
                  <form action="update-post-status" method="post" style="display:inline" onsubmit="return confirm('Đánh dấu đã bán bài đăng này?')">
                    <input type="hidden" name="productId" value="${post.id}">
                    <input type="hidden" name="status" value="SOLD">
                    <button type="submit" class="px-3 py-1.5 border border-slate-200 hover:bg-slate-50 text-slate-600 rounded-lg text-xs">
                      Đã Bán
                    </button>
                  </form>
                </c:if>
                <form action="delete-post" method="post" style="display:inline" onsubmit="return confirm('Xóa bài đăng này?')">
                  <input type="hidden" name="productId" value="${post.id}">
                  <button type="submit" class="px-3 py-1.5 text-red-500 hover:text-red-700 hover:bg-red-50 rounded-lg text-xs">
                    Xóa
                  </button>
                </form>
              </div>
            </div>
          </c:forEach>
        </c:when>
        <c:otherwise>
          <div class="bg-white rounded-xl border border-slate-200 p-10 text-center">
            <p class="text-sm text-slate-400">Chưa có bài đăng nào trong mục này.</p>
          </div>
        </c:otherwise>
      </c:choose>

    </section>

    <!-- PHẦN: LỊCH SỬ MUA HÀNG (CÁC ĐƠN HÀNG ĐÃ MUA) -->
    <%
      java.util.List<OrderSummary> buyerOrders =
          (java.util.List<OrderSummary>) request.getAttribute("buyerOrders");
      if (buyerOrders == null) buyerOrders = java.util.Collections.emptyList();
      java.text.NumberFormat nfOrder = java.text.NumberFormat.getNumberInstance(new java.util.Locale("vi","VN"));
      java.text.SimpleDateFormat sdfOrder = new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm");
    %>
    <section id="sectionOrders" class="space-y-4 ${isOrdersTab ? '' : 'hidden'}">
      
      <!-- BỘ LỌC ĐƠN HÀNG MUA -->
      <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-3 text-xs">
        <div class="flex items-center gap-2">
          <span class="text-slate-500 font-medium">Trạng thái:</span>
          <select id="buyerOrderStatusFilter" onchange="filterBuyerOrders(this.value)" class="px-3 py-1.5 bg-white border border-slate-200 rounded-lg text-slate-700 focus:outline-none focus:ring-1 focus:ring-blue-500">
            <option value="all" selected>Tất cả đơn mua (<%= buyerOrders.size() %>)</option>
            <option value="deposit">Đang giữ cọc bảo chứng</option>
            <option value="completed">Đã hoàn tất giao dịch</option>
            <option value="canceled">Đã hủy / khiếu nại</option>
          </select>
        </div>
        <a href="05-quan-ly-don-hang.jsp" class="text-blue-600 hover:underline font-semibold flex items-center gap-1">
          <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/></svg>
          Mở Trung tâm Quản lý Đơn hàng &amp; Ký quỹ &rarr;
        </a>
      </div>

      <% if (buyerOrders.isEmpty()) { %>
        <!-- EMPTY STATE KHI CHƯA CÓ ĐƠN MUA -->
        <div class="bg-white rounded-xl border border-slate-200 p-12 text-center">
          <div class="w-14 h-14 rounded-full bg-slate-100 text-slate-400 flex items-center justify-center mx-auto mb-3">
            <svg class="w-7 h-7" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.8" d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z"/></svg>
          </div>
          <h3 class="text-sm font-bold text-slate-800">Bạn chưa có đơn mua hàng nào</h3>
          <p class="text-xs text-slate-400 mt-1 max-w-sm mx-auto">Khi bạn đặt cọc mua sản phẩm, thông tin giao dịch và số tiền bảo chứng sẽ được lưu và theo dõi tại đây.</p>
          <a href="01-trang-chu.jsp" class="inline-flex items-center gap-1.5 mt-4 px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white text-xs font-semibold rounded-lg transition shadow-xs">
            <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/></svg>
            Khám phá món đồ ngay
          </a>
        </div>
      <% } else { %>
        <!-- DANH SÁCH CÁC ĐƠN MUA -->
        <div class="space-y-3.5" id="buyerOrdersList">
          <% for (OrderSummary bo : buyerOrders) {
            double finalPrice = bo.agreedPrice > 0 ? bo.agreedPrice : bo.productPrice;
            double remainPrice = Math.max(0, finalPrice - bo.depositAmount);
            String st = bo.status != null ? bo.status.toLowerCase() : "";
            String filterCategory = "other";
            if ("completed".equals(st)) filterCategory = "completed";
            else if ("deposit_confirmed".equals(st) || "deposit_pending".equals(st) || "shipping".equals(st) || "deposited".equals(st)) filterCategory = "deposit";
            else if ("canceled".equals(st) || "cancelled".equals(st) || "disputed".equals(st)) filterCategory = "canceled";
          %>
            <div class="buyer-order-card bg-white rounded-xl border border-slate-200 p-4 sm:p-5 hover:border-slate-300 transition shadow-xs" data-status-group="<%= filterCategory %>">
              
              <!-- ĐẦU CARD: MÃ ĐƠN, NGÀY ĐẶT, TRẠNG THÁI -->
              <div class="flex flex-wrap items-center justify-between gap-2 pb-3 border-b border-slate-100 text-xs">
                <div class="flex items-center gap-2">
                  <span class="px-2 py-0.5 rounded text-[10px] font-bold bg-blue-50 text-blue-700 border border-blue-200 uppercase tracking-wide">
                    Đơn Tôi Mua
                  </span>
                  <span class="font-mono font-bold text-slate-800">#MN-<%= bo.id %></span>
                  <span class="text-slate-400">&bull;</span>
                  <span class="text-slate-500"><%= bo.createdAt != null ? sdfOrder.format(bo.createdAt) : "" %></span>
                </div>
                <div class="flex items-center gap-2">
                  <span class="px-2.5 py-0.5 rounded-full text-xs font-semibold border <%= orderBadgeClass(bo.status) %>">
                    <%= orderStatusText(bo.status) %>
                  </span>
                </div>
              </div>

              <!-- THÂN CARD: ẢNH, TÊN SẢN PHẨM, NGƯỜI BÁN, GIÁ CẢ -->
              <div class="py-3 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                <div class="flex items-start gap-3.5 min-w-0">
                  <div class="w-16 h-16 rounded-lg bg-slate-100 overflow-hidden shrink-0 border border-slate-200">
                    <img src="<%= h(bo.productImage != null && !bo.productImage.trim().isEmpty() ? bo.productImage : "assets/images/products/iphone-13-pro-max.jpg") %>"
                         alt="<%= h(bo.productTitle) %>"
                         class="w-full h-full object-cover">
                  </div>
                  <div class="min-w-0">
                    <a href="product-detail?id=<%= bo.productId %>" class="font-bold text-sm text-slate-900 hover:text-blue-600 line-clamp-1 transition">
                      <%= h(bo.productTitle) %>
                    </a>
                    <div class="text-xs text-slate-500 mt-1 flex items-center gap-1.5">
                      <svg class="w-3.5 h-3.5 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/></svg>
                      Người bán: <strong class="text-slate-700 font-semibold"><%= h(bo.sellerName != null ? bo.sellerName : "Người bán") %></strong>
                    </div>
                    <div class="text-[11px] text-emerald-600 font-medium mt-1 flex items-center gap-1">
                      <svg class="w-3 h-3 text-emerald-500" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/></svg>
                      Đã đặt cọc qua SePay: <strong><%= nfOrder.format(bo.depositAmount) %> đ</strong> (Được sàn bảo chứng)
                    </div>
                  </div>
                </div>

                <!-- TỔNG TIỀN VÀ TIỀN CÒN LẠI -->
                <div class="text-left sm:text-right shrink-0 border-t sm:border-t-0 pt-2 sm:pt-0 border-slate-100">
                  <div class="text-[11px] text-slate-400">Tổng giá chốt mua</div>
                  <div class="text-base font-bold text-blue-600"><%= nfOrder.format(finalPrice) %> đ</div>
                  <div class="text-[11px] text-slate-500 mt-0.5">
                    Còn lại trả khi nhận: <strong class="text-slate-800"><%= nfOrder.format(remainPrice) %> đ</strong>
                  </div>
                </div>
              </div>

              <!-- CHÂN CARD: CÁC NÚT THAO TÁC -->
              <div class="pt-3 border-t border-slate-100 flex flex-wrap items-center justify-between gap-2 text-xs">
                <div class="text-[11px] text-slate-400">
                  Mã giao dịch bảo vệ: <span class="font-mono text-slate-600">SEP-ORD-<%= bo.id %></span>
                </div>
                <div class="flex items-center gap-2">
                  <a href="04-chat-tra-gia-vietqr.jsp?productId=<%= bo.productId %>" class="px-3 py-1.5 rounded-lg border border-slate-200 text-slate-700 hover:bg-slate-50 font-semibold transition flex items-center gap-1">
                    <svg class="w-3 h-3 text-slate-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"/></svg>
                    Nhắn tin
                  </a>
                  <button type="button"
                    onclick='openBuyerOrderDetail({
                      id: <%= bo.id %>,
                      productId: <%= bo.productId %>,
                      productTitle: "<%= h(bo.productTitle).replace("\"", "\\\"") %>",
                      productImage: "<%= h(bo.productImage != null && !bo.productImage.trim().isEmpty() ? bo.productImage : "assets/images/products/iphone-13-pro-max.jpg") %>",
                      sellerName: "<%= h(bo.sellerName != null ? bo.sellerName : "Người bán").replace("\"", "\\\"") %>",
                      finalPrice: "<%= nfOrder.format(finalPrice) %>",
                      depositAmount: "<%= nfOrder.format(bo.depositAmount) %>",
                      remainPrice: "<%= nfOrder.format(remainPrice) %>",
                      status: "<%= bo.status %>",
                      statusText: "<%= orderStatusText(bo.status) %>",
                      badgeClass: "<%= orderBadgeClass(bo.status) %>",
                      createdAt: "<%= bo.createdAt != null ? sdfOrder.format(bo.createdAt) : "" %>"
                    })'
                    class="px-3.5 py-1.5 rounded-lg bg-blue-600 hover:bg-blue-700 text-white font-semibold transition flex items-center gap-1 shadow-xs">
                    <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/></svg>
                    Xem Chi Tiết Đơn Hàng
                  </button>
                </div>
              </div>

            </div>
          <% } %>
        </div>
      <% } %>

    </section>

    <!-- PHẦN 2: THỐNG KÊ DOANH THU & ĐƠN BÁN -->
    <%
      java.util.List<OrderSummary> sellerOrders =
          (java.util.List<OrderSummary>) request.getAttribute("sellerOrders");
      if (sellerOrders == null) sellerOrders = java.util.Collections.emptyList();

      double totalRevenue = 0, totalDeposit = 0, holdingDeposit = 0;
      int completedOrders = 0;
      for (OrderSummary o : sellerOrders) {
        if ("COMPLETED".equals(o.status)) {
          totalRevenue += o.agreedPrice > 0 ? o.agreedPrice : o.productPrice;
          totalDeposit += o.depositAmount;
          completedOrders++;
        } else if ("DEPOSIT_CONFIRMED".equals(o.status) || "DEPOSIT_PENDING".equals(o.status) || "DEPOSITED".equals(o.status)) {
          holdingDeposit += o.depositAmount;
        }
      }
      int totalOrders = sellerOrders.size();
      java.text.NumberFormat nfStat = java.text.NumberFormat.getNumberInstance(new java.util.Locale("vi","VN"));
      String fmtRevenue = nfStat.format(totalRevenue);
      String fmtDeposit = nfStat.format(totalDeposit);
      String fmtHolding = nfStat.format(holdingDeposit);
    %>
    <section id="sectionStats" class="space-y-4 ${isStatsTab ? '' : 'hidden'}">

      <!-- 4 METRIC CARDS -->
      <div class="grid grid-cols-2 lg:grid-cols-4 gap-3">
        <div class="bg-white rounded-xl border border-slate-200 p-4">
          <div class="text-[10px] font-bold uppercase tracking-wide text-slate-400 mb-2">TỔNG DOANH THU ĐÃ BÁN</div>
          <div class="text-2xl font-bold text-blue-600"><%= fmtRevenue %> đ</div>
          <div class="text-[11px] text-slate-400 mt-1">Các đơn hàng hoàn tất bàn giao</div>
        </div>
        <div class="bg-white rounded-xl border border-slate-200 p-4">
          <div class="text-[10px] font-bold uppercase tracking-wide text-slate-400 mb-2">TIỀN CỌC ĐÃ GIẢI NGÂN</div>
          <div class="text-2xl font-bold text-blue-600"><%= fmtDeposit %> đ</div>
          <div class="text-[11px] text-slate-400 mt-1">Đã chuyển về tài khoản người bán</div>
        </div>
        <div class="bg-white rounded-xl border border-slate-200 p-4">
          <div class="text-[10px] font-bold uppercase tracking-wide text-slate-400 mb-2">TIỀN CỌC XÁC NHẬN ĐANG GIỮ</div>
          <div class="text-2xl font-bold text-amber-500"><%= fmtHolding %> đ</div>
          <div class="text-[11px] text-slate-400 mt-1">Chỉ tính đơn đã được SePay xác nhận cọc</div>
        </div>
        <div class="bg-white rounded-xl border border-slate-200 p-4">
          <div class="text-[10px] font-bold uppercase tracking-wide text-slate-400 mb-2">ĐƠN HÀNG THÀNH CÔNG</div>
          <div class="text-2xl font-bold text-slate-800"><%= completedOrders %> / <%= totalOrders %> đơn</div>
          <% if (totalOrders == 0) { %>
            <div class="text-[11px] text-blue-600 mt-1 font-medium">Chưa có đơn hàng để tính tỷ lệ</div>
          <% } else { %>
            <div class="text-[11px] text-teal-600 mt-1 font-medium"><%= Math.round(100.0 * completedOrders / totalOrders) %>% hoàn tất</div>
          <% } %>
        </div>
      </div>

      <!-- BIỂU ĐỒ DOANH THU + DONUT CƠ CẤU -->
      <div class="grid grid-cols-1 lg:grid-cols-3 gap-4">
        <div class="lg:col-span-2 bg-white rounded-xl border border-slate-200 p-5">
          <div class="flex items-start justify-between mb-3">
            <div>
              <div class="text-xs font-bold text-slate-800 uppercase tracking-wide">BIỂU ĐỒ DOANH THU GIAO DỊCH (VNĐ)</div>
              <div class="text-[11px] text-slate-400 mt-0.5">Theo dõi dòng tiền thu được từ giao dịch sản phẩm</div>
            </div>
            <span class="px-2.5 py-1 text-[11px] font-semibold bg-slate-100 text-slate-600 rounded-lg">Dữ liệu thực tế</span>
          </div>
          <div style="position:relative;height:210px">
            <canvas id="revenueChart"></canvas>
          </div>
          <% if (totalOrders == 0) { %>
            <div class="text-center text-xs text-slate-400 mt-2">Chưa có đơn</div>
          <% } %>
        </div>

        <div class="bg-white rounded-xl border border-slate-200 p-5">
          <div class="text-xs font-bold text-slate-800 uppercase tracking-wide mb-0.5">CƠ CẤU ĐƠN BÁN RA</div>
          <div class="text-[11px] text-slate-400 mb-3">Tỷ lệ đơn hoàn tất, đang cọc và khiếu nại</div>
          <div style="position:relative;height:170px">
            <canvas id="structureChart"></canvas>
          </div>
          <div class="flex flex-col gap-1.5 mt-3 text-[11px]">
            <div class="flex items-center gap-2"><span class="w-3 h-3 rounded-sm" style="background:#14b8a6"></span> Đã hoàn tất</div>
            <div class="flex items-center gap-2"><span class="w-3 h-3 rounded-sm" style="background:#f59e0b"></span> Đang giữ cọc</div>
            <div class="flex items-center gap-2"><span class="w-3 h-3 rounded-sm" style="background:#f87171"></span> Đã hủy/khiếu nại</div>
          </div>
        </div>
      </div>

      <!-- BẢNG ĐƠN HÀNG CHI TIẾT -->
      <div class="bg-white rounded-xl border border-slate-200 p-5">
        <div class="flex items-center justify-between mb-4">
          <div class="text-xs font-bold text-slate-800 uppercase tracking-wide">ĐƠN HÀNG BÁN CỦA BẠN (CHI TIẾT)</div>
          <a href="05-quan-ly-don-hang.jsp" class="text-xs text-blue-600 hover:underline font-semibold">Xem tất cả tại Quản lý đơn hàng</a>
        </div>
        <% if (sellerOrders.isEmpty()) { %>
          <div class="text-center py-8 text-xs text-slate-400">Bạn chưa có đơn hàng bán nào phát sinh trên sàn.</div>
        <% } else { %>
          <div class="overflow-x-auto">
            <table class="w-full text-xs">
              <thead>
                <tr class="border-b border-slate-100 text-[11px] text-slate-400 uppercase tracking-wide">
                  <th class="pb-2 text-left font-semibold">Sản phẩm</th>
                  <th class="pb-2 text-left font-semibold">Người mua</th>
                  <th class="pb-2 text-right font-semibold">Giá thỏa</th>
                  <th class="pb-2 text-right font-semibold">Tiền cọc</th>
                  <th class="pb-2 text-center font-semibold">Trạng thái</th>
                  <th class="pb-2 text-right font-semibold">Ngày</th>
                </tr>
              </thead>
              <tbody class="divide-y divide-slate-50">
                <%
                  java.text.NumberFormat nf2 = java.text.NumberFormat.getNumberInstance(new java.util.Locale("vi","VN"));
                  java.text.SimpleDateFormat sdf2 = new java.text.SimpleDateFormat("dd/MM/yyyy");
                  int shown = 0;
                  for (OrderSummary ord : sellerOrders) {
                    if (shown >= 10) break; shown++;
                    String bCls, bTxt;
                    if ("COMPLETED".equalsIgnoreCase(ord.status)) {
                      bCls = "bg-teal-50 text-teal-700";
                      bTxt = "Hoàn tất";
                    } else if ("DEPOSIT_CONFIRMED".equalsIgnoreCase(ord.status) || "DEPOSITED".equalsIgnoreCase(ord.status)) {
                      bCls = "bg-amber-50 text-amber-600";
                      bTxt = "Đang giữ cọc";
                    } else if ("DEPOSIT_PENDING".equalsIgnoreCase(ord.status)) {
                      bCls = "bg-blue-50 text-blue-600";
                      bTxt = "Chờ cọc";
                    } else if ("SHIPPING".equalsIgnoreCase(ord.status)) {
                      bCls = "bg-blue-50 text-blue-600";
                      bTxt = "Đang giao hàng";
                    } else if ("CANCELED".equalsIgnoreCase(ord.status) || "CANCELLED".equalsIgnoreCase(ord.status)) {
                      bCls = "bg-slate-100 text-slate-500";
                      bTxt = "Đã hủy";
                    } else if ("DISPUTED".equalsIgnoreCase(ord.status)) {
                      bCls = "bg-red-50 text-red-600";
                      bTxt = "Khiếu nại";
                    } else {
                      bCls = "bg-amber-50 text-amber-600";
                      bTxt = orderStatusText(ord.status);
                    }
                    double pr = ord.agreedPrice > 0 ? ord.agreedPrice : ord.productPrice;
                %>
                <tr class="hover:bg-slate-50 transition">
                  <td class="py-2.5 pr-3">
                    <div class="flex items-center gap-2">
                      <img src="<%= ord.productImage %>" alt="" class="w-8 h-8 rounded object-cover border border-slate-100 shrink-0">
                      <span class="line-clamp-1 font-medium text-slate-800"><%= h(ord.productTitle) %></span>
                    </div>
                  </td>
                  <td class="py-2.5 pr-3 text-slate-500"><%= h(ord.buyerName != null ? ord.buyerName : "N/A") %></td>
                  <td class="py-2.5 pr-3 text-right font-semibold text-slate-800"><%= nf2.format(pr) %> đ</td>
                  <td class="py-2.5 pr-3 text-right text-slate-500"><%= nf2.format(ord.depositAmount) %> đ</td>
                  <td class="py-2.5 pr-3 text-center">
                    <span class="px-2 py-0.5 rounded-md text-[10px] font-semibold <%= bCls %>"><%= bTxt %></span>
                  </td>
                  <td class="py-2.5 text-right text-slate-400"><%= ord.createdAt != null ? sdf2.format(ord.createdAt) : "" %></td>
                </tr>
                <% } %>
              </tbody>
            </table>
          </div>
        <% } %>
      </div>

    </section>

    <!-- PHẦN 3: TIN ĐÃ LƯU YÊU THÍCH (WISHLIST) -->

    <section id="sectionSaved" class="space-y-4 hidden">
      <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
        <div class="bg-white rounded-xl border border-slate-200 p-4 shadow-xs flex gap-3.5">
          <img src="assets/images/products/honda-vision-2021.jpg" alt="Vision" class="w-20 h-20 rounded-lg object-cover shrink-0 border border-slate-200">
          <div class="space-y-1">
            <span class="font-bold text-slate-900 text-xs block line-clamp-1">Honda Vision bản Cá Tính 2021 màu xám xi măng</span>
            <span class="text-green-600 font-extrabold text-sm block">26.500.000 đ</span>
            <div class="flex items-center gap-2 pt-1">
              <a href="02-chi-tiet-san-pham.jsp" class="text-xs text-blue-600 font-bold hover:underline">Xem ngay</a>
              <button onclick="removeSaved(this)" class="text-xs text-slate-400 hover:text-red-600">Bỏ lưu</button>
            </div>
          </div>
        </div>
        <div class="bg-white rounded-xl border border-slate-200 p-4 shadow-xs flex gap-3.5">
          <img src="assets/images/products/tu-lanh-panasonic.jpg" alt="Tủ lạnh" class="w-20 h-20 rounded-lg object-cover shrink-0 border border-slate-200">
          <div class="space-y-1">
            <span class="font-bold text-slate-900 text-xs block line-clamp-1">Tủ lạnh Aqua 90 lít làm lạnh nhanh</span>
            <span class="text-green-600 font-extrabold text-sm block">1.350.000 đ</span>
            <div class="flex items-center gap-2 pt-1">
              <a href="02-chi-tiet-san-pham.jsp" class="text-xs text-blue-600 font-bold hover:underline">Xem ngay</a>
              <button onclick="removeSaved(this)" class="text-xs text-slate-400 hover:text-red-600">Bỏ lưu</button>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- PHẦN 3: ĐÁNH GIÁ TỪ KHÁCH HÀNG -->
    <section id="sectionReviews" class="space-y-4 ${isReviewsTab ? '' : 'hidden'}">
      <!-- THẺ TỔNG QUAN ĐÁNH GIÁ -->
      <div class="bg-white rounded-xl border border-slate-200 p-5 shadow-xs space-y-4">
        <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div>
            <h2 class="text-sm font-bold text-slate-900 uppercase tracking-wide flex items-center gap-2">
              <span>⭐</span> Đánh Giá Thực Tế Từ Khách Hàng Đã Mua
            </h2>
            <p class="text-xs text-slate-500 mt-1">
              Khách hàng chỉ có thể đánh giá bạn sau khi đã hoàn tất nhận hàng từ đơn cọc. Mỗi đơn hàng chỉ được đánh giá 1 lần.
            </p>
          </div>

          <div class="text-center sm:text-right shrink-0">
            <div class="text-3xl font-extrabold text-slate-900">
              <%= String.format(Locale.US, "%.1f", sellerRatingSummary.averageRating) %><span class="text-base text-slate-400 font-normal"> / 5.0</span>
            </div>
            <div class="text-amber-400 text-base tracking-wider">
              ★★★★★
            </div>
            <div class="text-[11px] text-slate-500 mt-0.5">Dựa trên <%= sellerRatingSummary.totalReviews %> lượt đánh giá</div>
          </div>
        </div>

        <% if (sellerRatingSummary.totalReviews > 0) { %>
        <div class="grid grid-cols-1 sm:grid-cols-5 gap-2 pt-3 border-t border-slate-100 text-xs">
          <div class="flex items-center gap-1.5">
            <span class="text-[11px] text-slate-600 w-10">5 sao:</span>
            <div class="flex-1 h-2 bg-slate-100 rounded-full overflow-hidden">
              <div class="h-full bg-amber-400 rounded-full" style="width: <%= (sellerRatingSummary.count5Star * 100 / sellerRatingSummary.totalReviews) %>%"></div>
            </div>
            <span class="text-[10px] text-slate-400 w-6 text-right"><%= sellerRatingSummary.count5Star %></span>
          </div>

          <div class="flex items-center gap-1.5">
            <span class="text-[11px] text-slate-600 w-10">4 sao:</span>
            <div class="flex-1 h-2 bg-slate-100 rounded-full overflow-hidden">
              <div class="h-full bg-amber-400 rounded-full" style="width: <%= (sellerRatingSummary.count4Star * 100 / sellerRatingSummary.totalReviews) %>%"></div>
            </div>
            <span class="text-[10px] text-slate-400 w-6 text-right"><%= sellerRatingSummary.count4Star %></span>
          </div>

          <div class="flex items-center gap-1.5">
            <span class="text-[11px] text-slate-600 w-10">3 sao:</span>
            <div class="flex-1 h-2 bg-slate-100 rounded-full overflow-hidden">
              <div class="h-full bg-amber-400 rounded-full" style="width: <%= (sellerRatingSummary.count3Star * 100 / sellerRatingSummary.totalReviews) %>%"></div>
            </div>
            <span class="text-[10px] text-slate-400 w-6 text-right"><%= sellerRatingSummary.count3Star %></span>
          </div>

          <div class="flex items-center gap-1.5">
            <span class="text-[11px] text-slate-600 w-10">2 sao:</span>
            <div class="flex-1 h-2 bg-slate-100 rounded-full overflow-hidden">
              <div class="h-full bg-amber-400 rounded-full" style="width: <%= (sellerRatingSummary.count2Star * 100 / sellerRatingSummary.totalReviews) %>%"></div>
            </div>
            <span class="text-[10px] text-slate-400 w-6 text-right"><%= sellerRatingSummary.count2Star %></span>
          </div>

          <div class="flex items-center gap-1.5">
            <span class="text-[11px] text-slate-600 w-10">1 sao:</span>
            <div class="flex-1 h-2 bg-slate-100 rounded-full overflow-hidden">
              <div class="h-full bg-amber-400 rounded-full" style="width: <%= (sellerRatingSummary.count1Star * 100 / sellerRatingSummary.totalReviews) %>%"></div>
            </div>
            <span class="text-[10px] text-slate-400 w-6 text-right"><%= sellerRatingSummary.count1Star %></span>
          </div>
        </div>
        <% } %>
      </div>

      <!-- DANH SÁCH CHI TIẾT CÁC ĐÁNH GIÁ -->
      <% if (customerReviews.isEmpty()) { %>
        <div class="bg-white rounded-xl border border-slate-200 p-12 text-center space-y-2 shadow-xs">
          <div class="w-12 h-12 rounded-full bg-amber-50 text-amber-500 flex items-center justify-center mx-auto text-xl font-bold">★</div>
          <h3 class="text-sm font-bold text-slate-800">Chưa có đánh giá nào từ khách hàng</h3>
          <p class="text-xs text-slate-500 max-w-sm mx-auto">
            Khi người mua xác nhận đã nhận hàng thành công và gửi đánh giá cho bạn, nhận xét và số sao sẽ xuất hiện tại đây.
          </p>
        </div>
      <% } else { %>
        <div class="space-y-3">
          <% for (ReviewDetail r : customerReviews) {
            String rInitial = r.reviewerName != null && !r.reviewerName.isEmpty() ? r.reviewerName.substring(0, 1).toUpperCase() : "K";
          %>
          <div class="bg-white rounded-xl border border-slate-200 p-4 shadow-xs space-y-2.5">
            <div class="flex items-start justify-between gap-3">
              <div class="flex items-center gap-3">
                <div class="w-10 h-10 rounded-full bg-teal-50 text-teal-700 font-bold flex items-center justify-center text-sm border border-teal-200 shrink-0">
                  <%= rInitial %>
                </div>
                <div>
                  <div class="flex items-center gap-2">
                    <span class="font-bold text-xs text-slate-900"><%= h(r.reviewerName) %></span>
                    <span class="px-2 py-0.5 rounded-full text-[10px] font-semibold bg-emerald-50 text-emerald-700 border border-emerald-200">Đã mua hàng</span>
                  </div>
                  <span class="text-[11px] text-slate-500 block mt-0.5">
                    Sản phẩm: <strong class="text-slate-700"><%= h(r.productTitle) %></strong> (Đơn #MN-<%= r.orderId %>)
                  </span>
                </div>
              </div>

              <div class="text-right shrink-0">
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

            <div class="bg-slate-50 rounded-lg p-3 text-xs text-slate-700 leading-relaxed border border-slate-100">
              <%= h(r.comment) %>
            </div>
          </div>
          <% } %>
        </div>
      <% } %>
    </section>

  </main>

  <!-- MODAL CHỈNH SỬA THÔNG TIN CÁ NHÂN -->
  <div id="editProfileModal" class="fixed inset-0 bg-slate-900/60 z-50 hidden flex items-center justify-center p-4 overflow-y-auto">
    <form id="profileForm" action="${pageContext.request.contextPath}/update-profile" method="post" novalidate class="bg-white rounded-xl max-w-md w-full p-6 shadow-2xl space-y-4 text-left my-auto">
      <div class="flex items-center justify-between border-b border-slate-100 pb-3">
        <h3 class="font-bold text-slate-900 text-sm uppercase">Chỉnh Sửa Hồ Sơ Cá Nhân</h3>
        <button type="button" onclick="closeModal('editProfileModal')" class="text-slate-400 hover:text-slate-600 font-bold text-lg px-2">✕</button>
      </div>

      <div class="space-y-3 text-xs">
        <div>
          <label class="block font-bold text-slate-700 mb-1">Họ và tên:</label>
          <input id="inputFullName" name="fullName" type="text" required value="<%= h(editName) %>" class="w-full p-2.5 bg-slate-50 border border-slate-300 rounded-lg text-xs font-semibold focus:ring-2 focus:ring-blue-500 <%= profileFieldErrors.containsKey("fullName") ? "border-red-500 ring-1 ring-red-500" : "" %>" <%= profileFieldErrors.containsKey("fullName") ? "aria-invalid=\"true\"" : "" %>>
          <p data-error-for="inputFullName" role="alert" class="mt-1 text-[11px] text-red-600 <%= profileFieldErrors.containsKey("fullName") ? "" : "hidden" %>"><%= h(profileFieldErrors.get("fullName")) %></p>
        </div>
        <div class="grid grid-cols-2 gap-3">
          <div>
            <label class="block font-bold text-slate-700 mb-1">Số điện thoại:</label>
            <input id="inputPhone" name="phone" type="tel" inputmode="numeric" maxlength="10" pattern="0[0-9]{9}" required value="<%= h(editPhone) %>" placeholder="0xxxxxxxxx" class="w-full p-2.5 bg-slate-50 border border-slate-300 rounded-lg text-xs focus:ring-2 focus:ring-blue-500 <%= profileFieldErrors.containsKey("phone") ? "border-red-500 ring-1 ring-red-500" : "" %>" <%= profileFieldErrors.containsKey("phone") ? "aria-invalid=\"true\"" : "" %>>
            <p data-error-for="inputPhone" role="alert" class="mt-1 text-[11px] text-red-600 <%= profileFieldErrors.containsKey("phone") ? "" : "hidden" %>"><%= h(profileFieldErrors.get("phone")) %></p>
          </div>
          <div>
            <label class="block font-bold text-slate-700 mb-1">Email:</label>
            <input id="inputEmail" name="email" type="email" required value="<%= h(editEmail) %>" class="w-full p-2.5 bg-slate-50 border border-slate-300 rounded-lg text-xs focus:ring-2 focus:ring-blue-500 <%= profileFieldErrors.containsKey("email") ? "border-red-500 ring-1 ring-red-500" : "" %>" <%= profileFieldErrors.containsKey("email") ? "aria-invalid=\"true\"" : "" %>>
            <p data-error-for="inputEmail" role="alert" class="mt-1 text-[11px] text-red-600 <%= profileFieldErrors.containsKey("email") ? "" : "hidden" %>"><%= h(profileFieldErrors.get("email")) %></p>
          </div>
        </div>
        <div>
          <label for="inputProvince" class="block font-bold text-slate-700 mb-1">Tỉnh/thành phố:</label>
          <select id="inputProvince" name="province" data-saved-province="<%= h(editProvince) %>" required class="w-full p-2.5 bg-slate-50 border border-slate-300 rounded-lg text-xs focus:ring-2 focus:ring-blue-500 <%= profileFieldErrors.containsKey("province") ? "border-red-500 ring-1 ring-red-500" : "" %>" <%= profileFieldErrors.containsKey("province") ? "aria-invalid=\"true\"" : "" %>>
            <option value="">Đang tải tỉnh/thành...</option>
            <% if (!editProvince.isEmpty()) { %><option value="<%= h(editProvince) %>" selected><%= h(editProvince) %></option><% } %>
          </select>
          <p data-error-for="inputProvince" role="alert" class="mt-1 text-[11px] text-red-600 <%= profileFieldErrors.containsKey("province") ? "" : "hidden" %>"><%= h(profileFieldErrors.get("province")) %></p>
        </div>
        <div>
          <label for="inputWard" class="block font-bold text-slate-700 mb-1">Phường/xã:</label>
          <select id="inputWard" name="ward" data-saved-ward="<%= h(editWard) %>" required disabled class="w-full p-2.5 bg-slate-50 border border-slate-300 rounded-lg text-xs focus:ring-2 focus:ring-blue-500 <%= profileFieldErrors.containsKey("ward") ? "border-red-500 ring-1 ring-red-500" : "" %>" <%= profileFieldErrors.containsKey("ward") ? "aria-invalid=\"true\"" : "" %>>
            <option value=""><%= editWard.isEmpty() ? "Chọn tỉnh/thành trước" : h(editWard) %></option>
            <% if (!editWard.isEmpty()) { %><option value="<%= h(editWard) %>" selected><%= h(editWard) %></option><% } %>
          </select>
          <p data-error-for="inputWard" role="alert" class="mt-1 text-[11px] text-red-600 <%= profileFieldErrors.containsKey("ward") ? "" : "hidden" %>"><%= h(profileFieldErrors.get("ward")) %></p>
        </div>
        <div>
          <label for="inputAddressDetail" class="block font-bold text-slate-700 mb-1">Địa chỉ chi tiết (số nhà, tên đường):</label>
          <input id="inputAddressDetail" name="addressDetail" type="text" maxlength="255" required value="<%= h(editAddressDetail) %>" placeholder="Ví dụ: 12 Nguyễn Huệ" class="w-full p-2.5 bg-slate-50 border border-slate-300 rounded-lg text-xs focus:ring-2 focus:ring-blue-500 <%= profileFieldErrors.containsKey("addressDetail") ? "border-red-500 ring-1 ring-red-500" : "" %>" <%= profileFieldErrors.containsKey("addressDetail") ? "aria-invalid=\"true\"" : "" %>>
          <p data-error-for="inputAddressDetail" role="alert" class="mt-1 text-[11px] text-red-600 <%= profileFieldErrors.containsKey("addressDetail") ? "" : "hidden" %>"><%= h(profileFieldErrors.get("addressDetail")) %></p>
        </div>
        <div class="p-2.5 bg-emerald-50 border border-emerald-200 rounded-lg text-[11px] text-emerald-900">
          Số điện thoại tài khoản: <strong class="font-mono"><%= maskPhone(phone) %></strong>.
        </div>
      </div>

      <div class="pt-2 flex gap-2">
        <button type="button" onclick="closeModal('editProfileModal')" class="flex-1 py-2 border border-slate-300 rounded-lg text-xs font-semibold hover:bg-slate-100">
          Hủy Bỏ
        </button>
        <button type="submit" class="flex-1 py-2 bg-blue-600 hover:bg-blue-700 font-bold text-xs text-white rounded-lg shadow-sm">
          Lưu Thay Đổi
        </button>
      </div>
    </form>
  </div>

  <!-- MODAL ĐỔI MẬT KHẨU -->
  <div id="changePasswordModal" class="fixed inset-0 bg-slate-900/60 z-50 hidden flex items-center justify-center p-4">
    <form action="${pageContext.request.contextPath}/change-password" method="post" class="bg-white rounded-xl max-w-sm w-full p-6 shadow-2xl space-y-4">
      <div class="flex items-center justify-between border-b border-slate-100 pb-3">
        <h3 class="font-bold text-slate-900 text-sm">Đổi Mật Khẩu Đăng Nhập</h3>
        <button type="button" onclick="closeModal('changePasswordModal')" class="text-slate-400 hover:text-slate-600 font-bold text-lg px-2">✕</button>
      </div>
      <div class="space-y-3 text-xs">
        <% if (request.getAttribute("oldPassword_error") != null) { %>
          <div class="p-3 bg-red-50 border border-red-200 text-red-700 rounded-lg text-[11px] font-semibold"><%= h((String) request.getAttribute("oldPassword_error")) %></div>
        <% } %>
        <% if (request.getAttribute("newPassword_error") != null) { %>
          <div class="p-3 bg-red-50 border border-red-200 text-red-700 rounded-lg text-[11px] font-semibold"><%= h((String) request.getAttribute("newPassword_error")) %></div>
        <% } %>
        <% if (request.getAttribute("confirmPassword_error") != null) { %>
          <div class="p-3 bg-red-50 border border-red-200 text-red-700 rounded-lg text-[11px] font-semibold"><%= h((String) request.getAttribute("confirmPassword_error")) %></div>
        <% } %>
        <div>
          <label class="block font-bold text-slate-700 mb-1">Mật khẩu hiện tại:</label>
          <div class="relative">
            <input type="password" name="oldPassword" autocomplete="current-password" required class="w-full pl-2.5 pr-10 py-2.5 border border-slate-300 rounded-lg text-xs focus:ring-2 focus:ring-blue-500">
            <button type="button" class="password-toggle" onclick="togglePasswordVisibility(this)" aria-label="Hiện mật khẩu">
              <i class="fa-solid fa-eye"></i>
            </button>
          </div>
        </div>
        <div>
          <label class="block font-bold text-slate-700 mb-1">Mật khẩu mới:</label>
          <div class="relative">
            <input type="password" name="newPassword" autocomplete="new-password" required placeholder="Ít nhất 8 ký tự, có hoa/thường/số/ký tự đặc biệt" class="w-full pl-2.5 pr-10 py-2.5 border border-slate-300 rounded-lg text-xs focus:ring-2 focus:ring-blue-500">
            <button type="button" class="password-toggle" onclick="togglePasswordVisibility(this)" aria-label="Hiện mật khẩu">
              <i class="fa-solid fa-eye"></i>
            </button>
          </div>
        </div>
        <div>
          <label class="block font-bold text-slate-700 mb-1">Nhập lại mật khẩu mới:</label>
          <div class="relative">
            <input type="password" name="confirmPassword" autocomplete="new-password" required class="w-full pl-2.5 pr-10 py-2.5 border border-slate-300 rounded-lg text-xs focus:ring-2 focus:ring-blue-500">
            <button type="button" class="password-toggle" onclick="togglePasswordVisibility(this)" aria-label="Hiện mật khẩu">
              <i class="fa-solid fa-eye"></i>
            </button>
          </div>
        </div>
      </div>
      <div class="pt-2 flex gap-2">
        <button type="button" onclick="closeModal('changePasswordModal')" class="flex-1 py-2 border border-slate-300 rounded-lg text-xs font-semibold hover:bg-slate-100">Hủy</button>
        <button type="submit" class="flex-1 py-2 bg-blue-600 hover:bg-blue-700 font-bold text-xs text-white rounded-lg">Lưu Mật Khẩu</button>
      </div>
    </form>
  </div>

  <!-- MODAL XEM CHI TIẾT ĐƠN HÀNG ĐÃ MUA -->
  <div id="buyerOrderDetailModal" class="fixed inset-0 bg-slate-900/60 z-50 hidden flex items-center justify-center p-4">
    <div class="bg-white rounded-2xl max-w-lg w-full p-5 sm:p-6 shadow-2xl space-y-4 max-h-[90vh] overflow-y-auto">
      
      <!-- HEADER MODAL -->
      <div class="flex items-center justify-between border-b border-slate-100 pb-3">
        <div>
          <div class="text-[10px] font-bold uppercase tracking-wider text-blue-600">CHI TIẾT ĐƠN HÀNG MUA</div>
          <h3 id="modalOrderCode" class="text-base font-bold text-slate-900">#MN-000</h3>
        </div>
        <button type="button" onclick="closeBuyerOrderDetail()" class="w-8 h-8 rounded-full hover:bg-slate-100 text-slate-400 hover:text-slate-600 flex items-center justify-center font-bold text-sm transition">✕</button>
      </div>

      <!-- TRẠNG THÁI & NGÀY ĐẶT -->
      <div class="flex items-center justify-between bg-slate-50 p-3 rounded-xl border border-slate-100 text-xs">
        <div>
          <span class="text-slate-400 block text-[10px] uppercase font-bold">Ngày đặt cọc</span>
          <span id="modalOrderDate" class="font-semibold text-slate-700">--/--/----</span>
        </div>
        <div>
          <span id="modalOrderStatusBadge" class="px-2.5 py-1 rounded-full font-bold border text-xs">--</span>
        </div>
      </div>

      <!-- SẢN PHẨM & NGƯỜI BÁN -->
      <div class="flex items-center gap-3.5 p-3 rounded-xl border border-slate-200">
        <img id="modalProductImage" src="" alt="" class="w-16 h-16 rounded-lg object-cover bg-slate-100 shrink-0 border border-slate-200">
        <div class="min-w-0 flex-1">
          <a id="modalProductLink" href="#" class="font-bold text-sm text-slate-900 hover:text-blue-600 line-clamp-1 transition block"></a>
          <div class="text-xs text-slate-500 mt-1 flex items-center justify-between gap-1">
            <span>Người bán: <strong id="modalSellerName" class="text-slate-800 font-semibold"></strong></span>
            <a id="modalChatSellerLink" href="#" class="text-blue-600 hover:underline font-semibold text-[11px] flex items-center gap-1">
              <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"/></svg>
              Nhắn tin
            </a>
          </div>
        </div>
      </div>

      <!-- CHI TIẾT THANH TOÁN & BẢO CHỨNG -->
      <div class="bg-blue-50/50 rounded-xl border border-blue-100 p-4 space-y-2 text-xs">
        <div class="font-bold text-slate-800 mb-2 flex items-center justify-between">
          <span>Thông tin thanh toán &amp; Tiền cọc</span>
          <span class="text-[10px] text-blue-600 font-semibold bg-white px-2 py-0.5 rounded border border-blue-200">Bảo chứng SePay</span>
        </div>
        <div class="flex items-center justify-between text-slate-600">
          <span>Tổng giá mua đã chốt:</span>
          <strong id="modalFinalPrice" class="text-slate-900 font-bold">0 đ</strong>
        </div>
        <div class="flex items-center justify-between text-emerald-700">
          <span class="flex items-center gap-1">
            <svg class="w-3.5 h-3.5" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/></svg>
            Tiền cọc đã giữ bảo đảm:
          </span>
          <strong id="modalDepositAmount" class="font-bold">0 đ</strong>
        </div>
        <div class="flex items-center justify-between text-slate-700 pt-1.5 border-t border-blue-100">
          <span>Số tiền còn lại trả khi nhận máy:</span>
          <strong id="modalRemainPrice" class="text-blue-600 font-bold text-sm">0 đ</strong>
        </div>
      </div>

      <!-- HƯỚNG DẪN AN TOÀN -->
      <div class="p-3 bg-amber-50 border border-amber-200/80 rounded-xl text-[11px] text-amber-800 space-y-1">
        <div class="font-bold flex items-center gap-1 text-amber-900">
          <svg class="w-3.5 h-3.5 shrink-0" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd"/></svg>
          Lưu ý khi nhận hàng và thanh toán:
        </div>
        <p class="leading-relaxed">Khi gặp người bán hoặc nhận hàng, bạn hãy kiểm tra ngoại hình và chức năng máy cẩn thận trước khi trả nốt số tiền mặt còn lại. Tiền cọc chỉ được chuyển cho người bán khi giao dịch thành công.</p>
      </div>

      <!-- NÚT THAO TÁC MODAL -->
      <div class="pt-2 flex flex-col sm:flex-row gap-2">
        <a id="modalManageLink" href="05-quan-ly-don-hang.jsp" class="flex-1 py-2.5 bg-blue-600 hover:bg-blue-700 text-white font-bold text-xs rounded-xl transition text-center shadow-xs">
          Mở tại Quản Lý Đơn Hàng &amp; Ký Quỹ &rarr;
        </a>
        <button type="button" onclick="closeBuyerOrderDetail()" class="px-5 py-2.5 border border-slate-200 rounded-xl text-xs font-semibold text-slate-700 hover:bg-slate-50 transition">
          Đóng
        </button>
      </div>

    </div>
  </div>

  <!-- TOAST THÔNG BÁO TỨC THÌ -->
  <div id="toastNotification" class="fixed bottom-6 right-6 bg-slate-900 text-white text-xs px-4 py-3 rounded-lg shadow-lg border border-slate-700 hidden z-50 flex items-center gap-3">
    <div class="w-2 h-2 rounded-full bg-emerald-400"></div>
    <span id="toastMsg" class="font-medium">Thông báo</span>
  </div>

  <!-- CHÂN TRANG ĐẦY ĐỦ 8 MÀN HÌNH -->
  <jsp:include page="includes/footer.jsp" />

  <script>
    function switchProfileSection(sec, updateUrl) {
      if (typeof updateUrl === 'undefined') updateUrl = true;
      ['sectionPosts','sectionOrders','sectionStats','sectionSaved','sectionReviews'].forEach(id => {
        const el = document.getElementById(id);
        if (el) el.classList.add('hidden');
      });
      ['profileTabPosts','profileTabOrders','profileTabStats','profileTabSaved','profileTabReviews'].forEach(id => {
        const el = document.getElementById(id);
        if (el) el.className = 'pb-3 px-3 text-slate-500 hover:text-slate-800 transition whitespace-nowrap';
      });

      const activeClass = 'pb-3 px-3 text-blue-600 border-b-2 border-blue-600 transition whitespace-nowrap';
      if (sec === 'posts') {
        const secEl = document.getElementById('sectionPosts');
        if (secEl) secEl.classList.remove('hidden');
        const tabEl = document.getElementById('profileTabPosts');
        if (tabEl) tabEl.className = activeClass;
      } else if (sec === 'orders') {
        const secEl = document.getElementById('sectionOrders');
        if (secEl) secEl.classList.remove('hidden');
        const tabEl = document.getElementById('profileTabOrders');
        if (tabEl) tabEl.className = activeClass;
      } else if (sec === 'stats') {
        const secEl = document.getElementById('sectionStats');
        if (secEl) secEl.classList.remove('hidden');
        const tabEl = document.getElementById('profileTabStats');
        if (tabEl) tabEl.className = activeClass;
        initCharts();
      } else if (sec === 'saved') {
        const secEl = document.getElementById('sectionSaved');
        if (secEl) secEl.classList.remove('hidden');
        const tabEl = document.getElementById('profileTabSaved');
        if (tabEl) tabEl.className = activeClass;
      } else if (sec === 'reviews') {
        const secEl = document.getElementById('sectionReviews');
        if (secEl) secEl.classList.remove('hidden');
        const tabEl = document.getElementById('profileTabReviews');
        if (tabEl) tabEl.className = activeClass;
      }

      if (updateUrl && window.history && window.history.replaceState) {
        try {
          const url = new URL(window.location);
          url.searchParams.set('tab', sec);
          window.history.replaceState(null, '', url);
        } catch (e) {}
      }
    }

    function filterBuyerOrders(cat) {
      const cards = document.querySelectorAll('.buyer-order-card');
      cards.forEach(card => {
        const group = card.dataset.statusGroup || '';
        if (cat === 'all' || group === cat) {
          card.style.display = '';
        } else {
          card.style.display = 'none';
        }
      });
    }

    function openBuyerOrderDetail(order) {
      document.getElementById('modalOrderCode').textContent = '#MN-' + order.id;
      document.getElementById('modalOrderDate').textContent = order.createdAt || 'Mới đặt gần đây';

      const badge = document.getElementById('modalOrderStatusBadge');
      badge.textContent = order.statusText || 'Đang xử lý';
      badge.className = 'px-2.5 py-1 rounded-full font-bold border text-xs ' + (order.badgeClass || 'text-slate-700 bg-slate-50 border-slate-200');

      document.getElementById('modalProductImage').src = order.productImage;
      document.getElementById('modalProductLink').textContent = order.productTitle;
      document.getElementById('modalProductLink').href = 'product-detail?id=' + order.productId;
      document.getElementById('modalSellerName').textContent = order.sellerName;
      document.getElementById('modalChatSellerLink').href = '04-chat-tra-gia-vietqr.jsp?productId=' + order.productId;

      document.getElementById('modalFinalPrice').textContent = order.finalPrice + ' đ';
      document.getElementById('modalDepositAmount').textContent = order.depositAmount + ' đ';
      document.getElementById('modalRemainPrice').textContent = order.remainPrice + ' đ';

      document.getElementById('modalManageLink').href = '05-quan-ly-don-hang.jsp#order-card-db-' + order.id;
      document.getElementById('buyerOrderDetailModal').classList.remove('hidden');
    }

    function closeBuyerOrderDetail() {
      document.getElementById('buyerOrderDetailModal').classList.add('hidden');
    }

    function filterPosts(statusValue) {
      const items = document.querySelectorAll('.post-item');
      items.forEach(function(item) {
        const status = (item.dataset.status || '').toLowerCase();
        if (statusValue === 'all') {
          item.style.display = '';
        } else if (statusValue === 'active' && status === 'active') {
          item.style.display = '';
        } else if (statusValue === 'pending' && status === 'pending') {
          item.style.display = '';
        } else if (statusValue === 'sold' && status === 'sold') {
          item.style.display = '';
        } else {
          item.style.display = 'none';
        }
      });
    }

    function toggleSold(btn) {
      btn.textContent = 'Đã bán';
      btn.disabled = true;
      btn.className = 'px-3 py-1.5 bg-slate-200 text-slate-400 rounded-lg text-xs font-semibold cursor-not-allowed';
      showToast('Đã chuyển trạng thái món đồ sang Đã bán.');
    }

    function removeSaved(btn) {
      btn.closest('.bg-white').remove();
      showToast('Đã xóa món đồ khỏi danh sách yêu thích.');
    }

    function boostPostModal(title) {
      showToast('Đã kích hoạt gói đẩy tin nổi bật 24h cho: ' + title);
    }

    function openEditProfileModal() { 
      document.getElementById('editProfileModal').classList.remove('hidden'); 
    }
    function openChangePasswordModal() { 
      document.getElementById('changePasswordModal').classList.remove('hidden'); 
    }
    function closeModal(id) { 
      document.getElementById(id).classList.add('hidden'); 
    }
    function togglePasswordVisibility(button) {
      const input = button.parentElement.querySelector('input');
      const icon = button.querySelector('i');
      const shouldShow = input.type === 'password';

      input.type = shouldShow ? 'text' : 'password';
      icon.className = shouldShow ? 'fa-solid fa-eye-slash' : 'fa-solid fa-eye';
      button.setAttribute('aria-label', shouldShow ? 'Ẩn mật khẩu' : 'Hiện mật khẩu');
    }

    const provinceSelect = document.getElementById('inputProvince');
    const wardSelect = document.getElementById('inputWard');
    const savedProvince = provinceSelect.dataset.savedProvince;
    const savedWard = wardSelect.dataset.savedWard;

    function normalizeLocationName(value) {
      return (value || '').trim().replace(/^(tỉnh|thành phố|tp\.?|t\.?p\.?)\s+/i, '').toLocaleLowerCase('vi');
    }

    function setFieldError(inputId, message) {
      const input = document.getElementById(inputId);
      const error = document.querySelector('[data-error-for="' + inputId + '"]');
      if (!input || !error) return;
      error.textContent = message || '';
      error.classList.toggle('hidden', !message);
      input.classList.toggle('border-red-500', Boolean(message));
      input.classList.toggle('ring-1', Boolean(message));
      input.classList.toggle('ring-red-500', Boolean(message));
      if (message) input.setAttribute('aria-invalid', 'true');
      else input.removeAttribute('aria-invalid');
    }

    document.getElementById('profileForm').addEventListener('submit', (event) => {
      const name = document.getElementById('inputFullName').value.trim();
      const email = document.getElementById('inputEmail');
      const phone = document.getElementById('inputPhone').value.trim();
      const detail = document.getElementById('inputAddressDetail').value.trim();
      const phonePattern = /^(03[2-9]|05[25689]|07[06789]|08[1-9]|09[0-9])[0-9]{7}$/;
      const checks = [
        ['inputFullName', /^\S+(?:\s+\S+)+$/.test(name) ? '' : 'Nhập họ và tên gồm ít nhất hai từ, có khoảng trắng ở giữa.'],
        ['inputEmail', email.value.trim() && email.validity.valid ? '' : 'Vui lòng nhập email hợp lệ.'],
        ['inputPhone', phonePattern.test(phone) ? '' : 'Số điện thoại phải có 10 số và là đầu số di động Việt Nam hợp lệ.'],
        ['inputProvince', provinceSelect.value ? '' : 'Vui lòng chọn tỉnh/thành phố.'],
        ['inputWard', wardSelect.value ? '' : 'Vui lòng chọn phường/xã.'],
        ['inputAddressDetail', detail ? '' : 'Vui lòng nhập số nhà, tên đường hoặc địa chỉ chi tiết.']
      ];
      let firstInvalid = null;
      checks.forEach(([id, message]) => {
        setFieldError(id, message);
        if (message && !firstInvalid) firstInvalid = document.getElementById(id);
      });
      if (firstInvalid) {
        event.preventDefault();
        firstInvalid.focus();
      }
    });

    ['inputFullName', 'inputEmail', 'inputPhone', 'inputProvince', 'inputWard', 'inputAddressDetail'].forEach((id) => {
      const input = document.getElementById(id);
      input.addEventListener(input.tagName === 'SELECT' ? 'change' : 'input', () => setFieldError(id, ''));
    });

    async function loadProvinces() {
      try {
        const response = await fetch('https://provinces.open-api.vn/api/v2/');
        if (!response.ok) throw new Error('API tỉnh/thành không phản hồi');
        const provinces = await response.json();
        provinceSelect.innerHTML = '<option value="">Chọn tỉnh/thành phố</option>';
        provinces.forEach((item) => {
          const option = new Option(item.name, item.name);
          option.dataset.name = item.name;
          option.dataset.code = item.code;
          provinceSelect.add(option);
        });
        const saved = savedProvince ? [...provinceSelect.options].find((option) =>
          option.dataset.name === savedProvince || option.value === savedProvince ||
          normalizeLocationName(option.dataset.name || option.value) === normalizeLocationName(savedProvince)) : null;
        if (saved) {
          saved.selected = true;
          await loadWards(saved.dataset.code, savedWard);
        } else if (savedProvince) {
          // Keep addresses saved under an older province name after boundary changes.
          provinceSelect.add(new Option(savedProvince + ' (địa chỉ đã lưu)', savedProvince, true, true));
          if (savedWard) wardSelect.disabled = false;
        }
      } catch (error) {
        // Keep the saved address selectable when the third-party list is unavailable.
        if (savedProvince && ![...provinceSelect.options].some((option) => option.value === savedProvince)) {
          provinceSelect.add(new Option(savedProvince, savedProvince, true, true));
        }
        setFieldError('inputProvince', 'Không tải được danh sách tỉnh/thành. Hãy tải lại trang.');
        showToast('Không tải được địa chỉ từ API. Hãy thử tải lại trang.');
        if (savedWard) wardSelect.disabled = false;
      }
    }

    async function loadWards(provinceCode, selectedWard = '') {
      wardSelect.disabled = true;
      wardSelect.innerHTML = '<option value="">Đang tải phường/xã...</option>';
      try {
        const response = await fetch('https://provinces.open-api.vn/api/v2/w/?province=' + encodeURIComponent(provinceCode));
        if (!response.ok) throw new Error('API phường/xã không phản hồi');
        const wards = await response.json();
        wardSelect.innerHTML = '<option value="">Chọn phường/xã</option>';
        (wards || []).forEach((item) => {
          const option = new Option(item.name, item.name);
          wardSelect.add(option);
        });
        if (selectedWard && ![...wardSelect.options].some((option) => option.value === selectedWard)) {
          wardSelect.add(new Option(selectedWard + ' (địa chỉ đã lưu)', selectedWard));
        }
        wardSelect.disabled = false;
        if (selectedWard) wardSelect.value = selectedWard;
      } catch (error) {
        if (selectedWard && ![...wardSelect.options].some((option) => option.value === selectedWard)) {
          wardSelect.add(new Option(selectedWard, selectedWard, true, true));
        }
        wardSelect.disabled = !selectedWard;
        setFieldError('inputWard', 'Không tải được phường/xã. Hãy kiểm tra kết nối mạng.');
        showToast('Không tải được phường/xã. Hãy kiểm tra kết nối mạng.');
      }
    }

    provinceSelect.addEventListener('change', () => {
      const selected = provinceSelect.selectedOptions[0];
      setFieldError('inputProvince', '');
      setFieldError('inputWard', '');
      if (!selected || !selected.value) {
        wardSelect.disabled = true;
        wardSelect.innerHTML = '<option value="">Chọn tỉnh/thành trước</option>';
        return;
      }
      selected.dataset.name = selected.dataset.name || selected.textContent;
      loadWards(selected.dataset.code || selected.value);
    });

    function showToast(msg) {
      const toast = document.getElementById('toastNotification');
      document.getElementById('toastMsg').textContent = msg;
      toast.classList.remove('hidden');
      setTimeout(() => { toast.classList.add('hidden'); }, 3000);
    }

    window.addEventListener('DOMContentLoaded', () => {
      loadProvinces();
      <% if (request.getAttribute("oldPassword_error") != null || request.getAttribute("newPassword_error") != null || request.getAttribute("confirmPassword_error") != null) { %>
        openChangePasswordModal();
      <% } %>
      <% if (authMessage != null) { %>
        showToast('<%= h(authMessage) %>');
      <% } %>
      <% if (changePassSuccess != null) { %>
        showToast('<%= h(changePassSuccess) %>');
      <% } %>
      <% if (profileMessage != null) { %>
        showToast('<%= h(profileMessage) %>');
        <% if (profileMessageError || !profileFieldErrors.isEmpty()) { %>openEditProfileModal();<% } %>
      <% } %>
    });
  </script>

  <!-- CHART.JS -->
  <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
  <script>
    let chartsInited = false;
    function initCharts() {
      if (chartsInited) return;
      chartsInited = true;

      // Dữ liệu thực tế từ server
      const completed = <%= completedOrders %>;
      const depositOrders = <%
        int dOrd = 0;
        for (OrderSummary o : sellerOrders) {
          if ("DEPOSIT_CONFIRMED".equals(o.status) || "DEPOSIT_PENDING".equals(o.status) || "DEPOSITED".equals(o.status)) dOrd++;
        }
        out.print(dOrd);
      %>;
      const canceledOrders = <%
        int cOrd = 0;
        for (OrderSummary o : sellerOrders) {
          if ("CANCELED".equals(o.status) || "DISPUTED".equals(o.status)) cOrd++;
        }
        out.print(cOrd);
      %>;

      // Biểu đồ doanh thu + cọc theo ngày — gom tất cả ngày có đơn (cả COMPLETED và DEPOSIT)
      <%
        java.util.LinkedHashMap<String,Double> revByDay = new java.util.LinkedHashMap<>();
        java.util.LinkedHashMap<String,Double> depByDay = new java.util.LinkedHashMap<>();
        java.util.LinkedHashSet<String> allDays = new java.util.LinkedHashSet<>();
        java.text.SimpleDateFormat sdfDay = new java.text.SimpleDateFormat("dd/MM");
        for (OrderSummary o : sellerOrders) {
          if (o.createdAt == null) continue;
          String day = sdfDay.format(o.createdAt);
          allDays.add(day);
          if ("COMPLETED".equals(o.status)) {
            revByDay.merge(day, o.agreedPrice > 0 ? o.agreedPrice : o.productPrice, Double::sum);
          }
          if ("DEPOSIT_CONFIRMED".equals(o.status) || "DEPOSIT_PENDING".equals(o.status) || "DEPOSITED".equals(o.status)) {
            depByDay.merge(day, o.depositAmount, Double::sum);
          }
        }
      %>
      const chartLabels = [<% if (allDays.isEmpty()) { out.print("''"); } else { out.print(allDays.stream().map(k -> "'" + k + "'").collect(java.util.stream.Collectors.joining(","))); } %>];
      const revenueData  = [<% if (allDays.isEmpty()) { out.print("0"); } else { out.print(allDays.stream().map(k -> String.valueOf(revByDay.getOrDefault(k,0.0))).collect(java.util.stream.Collectors.joining(","))); } %>];
      const depositData  = [<% if (allDays.isEmpty()) { out.print("0"); } else { out.print(allDays.stream().map(k -> String.valueOf(depByDay.getOrDefault(k,0.0))).collect(java.util.stream.Collectors.joining(","))); } %>];

      // Biểu đồ bar nhóm: doanh thu hoàn tất + tiền cọc đang giữ
      const rCtx = document.getElementById('revenueChart').getContext('2d');
      new Chart(rCtx, {
        type: 'bar',
        data: {
          labels: chartLabels,
          datasets: [
            {
              label: 'Doanh thu hoàn tất (đ)',
              data: revenueData,
              backgroundColor: 'rgba(20,184,166,0.75)',
              borderColor: '#14b8a6',
              borderWidth: 1,
              borderRadius: 4
            },
            {
              label: 'Tiền cọc đang giữ (đ)',
              data: depositData,
              backgroundColor: 'rgba(245,158,11,0.65)',
              borderColor: '#f59e0b',
              borderWidth: 1,
              borderRadius: 4
            }
          ]
        },
        options: {
          responsive: true, maintainAspectRatio: false,
          plugins: {
            legend: {
              display: true,
              position: 'top',
              labels: { font: { size: 10 }, boxWidth: 12, padding: 10 }
            },
            tooltip: {
              callbacks: {
                label: ctx => {
                  const v = ctx.parsed.y;
                  const fmt = v >= 1e6 ? (v/1e6).toFixed(1)+'M đ' : v >= 1e3 ? (v/1e3).toFixed(0)+'K đ' : v + ' đ';
                  return ' ' + ctx.dataset.label.split(' (')[0] + ': ' + fmt;
                }
              }
            }
          },
          scales: {
            x: { grid: { display: false }, ticks: { font: { size: 10 } } },
            y: {
              beginAtZero: true,
              ticks: {
                font: { size: 10 },
                callback: v => (v >= 1e6 ? (v/1e6).toFixed(1)+'M' : v >= 1e3 ? (v/1e3).toFixed(0)+'K' : v) + ' đ'
              },
              grid: { color: '#f1f5f9' }
            }
          }
        }
      });

      // Biểu đồ donut cơ cấu — khi chưa có đơn hiển thị vòng xám trung tính
      const sCtx = document.getElementById('structureChart').getContext('2d');
      const total = completed + depositOrders + canceledOrders;
      new Chart(sCtx, {
        type: 'doughnut',
        data: {
          labels: total > 0 ? ['Đã hoàn tất', 'Đang giữ cọc', 'Đã hủy/khiếu nại'] : ['Chưa có đơn hàng'],
          datasets: [{
            data: total > 0 ? [completed, depositOrders, canceledOrders] : [1],
            backgroundColor: total > 0 ? ['#14b8a6', '#f59e0b', '#f87171'] : ['#e2e8f0'],
            borderWidth: total > 0 ? 2 : 0,
            borderColor: '#fff'
          }]
        },
        options: {
          responsive: true, maintainAspectRatio: false,
          cutout: '60%',
          plugins: {
            legend: { display: false },
            tooltip: {
              callbacks: {
                label: ctx => total > 0
                  ? ' ' + ctx.label + ': ' + ctx.parsed + ' đơn'
                  : ' Chưa có đơn hàng nào'
              }
            }
          }
        }
      });
    }

    // Tự động kích hoạt tab dựa vào URL parameter ?tab= hoặc #hash
    document.addEventListener('DOMContentLoaded', function() {
      const urlParams = new URLSearchParams(window.location.search);
      const tab = urlParams.get('tab') || (window.location.hash ? window.location.hash.replace('#', '') : null);
      if (tab === 'stats') {
        switchProfileSection('stats', false);
      } else if (tab === 'orders') {
        switchProfileSection('orders', false);
      } else if (tab === 'saved') {
        switchProfileSection('saved', false);
      } else if (tab === 'reviews') {
        switchProfileSection('reviews', false);
        setTimeout(() => {
          const revSec = document.getElementById('sectionReviews');
          if (revSec) {
            revSec.scrollIntoView({ behavior: 'smooth', block: 'start' });
            revSec.classList.add('ring-4', 'ring-amber-400', 'ring-offset-2', 'rounded-2xl', 'transition-all', 'duration-500');
            setTimeout(() => {
              revSec.classList.remove('ring-4', 'ring-amber-400', 'ring-offset-2');
            }, 3000);
          }
        }, 200);
      } else if (tab === 'posts') {
        switchProfileSection('posts', false);
      } else {
        // Nếu server-side đã render tab stats (isStatsTab = true)
        <c:if test="${isStatsTab}">
          initCharts();
        </c:if>
      }
    });
  </script>
</body>
</html>
