<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Map" %>
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
%>
<%
  User currentUser = (User) session.getAttribute("user");
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
    <div class="bg-white rounded-xl border border-slate-200 p-6 shadow-xs flex flex-col sm:flex-row sm:items-center justify-between gap-4">
      <div class="flex items-center gap-4">
        <div id="profileAvatarBig" class="w-16 h-16 rounded-xl bg-blue-600 text-white font-black text-2xl flex items-center justify-center shadow-xs shrink-0">
          <%= h(avatarText) %>
        </div>
        <div>
          <div class="flex items-center gap-2">
            <h1 id="profileDisplayName" class="text-lg font-bold text-slate-900"><%= h(displayName) %></h1>
            <span class="px-2 py-0.5 rounded bg-emerald-100 text-emerald-800 text-[10px] font-bold">
              <%= phone.trim().isEmpty() ? "Tài Khoản Chưa Cập Nhật SĐT" : "Tài Khoản Đã Cập Nhật SĐT" %>
            </span>
          </div>
          <div id="profileMetaText" class="text-xs text-slate-500 mt-1">
            Thành viên MuaNgay từ <%= h(createdText) %> • <%= h(email) %> • Trạng thái: <%= h(statusText) %><%= fullAddress.isEmpty() ? "" : " • " + h(fullAddress) %>
          </div>
          <div class="flex items-center gap-3 text-xs mt-2 font-medium">
            <span class="text-amber-800 font-bold bg-amber-50 px-2 py-0.5 rounded">
              Điểm Uy Tín: 4.9 / 5.0 (24 Đánh Giá Tốt)
            </span>
            <span class="text-emerald-700 font-semibold">
              Tỷ lệ hoàn thành đơn: 100%
            </span>
          </div>
        </div>
      </div>

      <div class="flex sm:flex-col gap-2 shrink-0">
        <button onclick="openEditProfileModal()" class="px-3.5 py-2 border border-slate-300 hover:bg-slate-100 text-slate-700 font-bold text-xs rounded-lg transition text-center shadow-xs">
          Chỉnh sửa thông tin
        </button>
        <button onclick="openChangePasswordModal()" class="px-3.5 py-2 border border-slate-300 hover:bg-slate-100 text-slate-700 font-bold text-xs rounded-lg transition text-center">
          Đổi mật khẩu
        </button>
      </div>
    </div>

    <!-- TABS ĐIỀU HƯỚNG NỘI DUNG TRANG CÁ NHÂN -->
    <div class="flex border-b border-slate-200 space-x-2 text-xs font-bold">
      <button id="profileTabPosts" onclick="switchProfileSection('posts')" class="pb-3 px-3 text-blue-600 border-b-2 border-blue-600 transition">
        Tin Tôi Đang Đăng Bán (2)
      </button>
      <button id="profileTabSaved" onclick="switchProfileSection('saved')" class="pb-3 px-3 text-slate-500 hover:text-slate-900 transition">
        Tin Đã Lưu Yêu Thích (2)
      </button>
      <button id="profileTabReviews" onclick="switchProfileSection('reviews')" class="pb-3 px-3 text-slate-500 hover:text-slate-900 transition">
        Đánh Giá Từ Khách Hàng (24)
      </button>
    </div>

    <!-- PHẦN 1: QUẢN LÝ BÀI ĐĂNG CỦA TÔI -->
    <section id="sectionPosts" class="space-y-4">
      
      <!-- BỘ LỌC TRẠNG THÁI BÀI ĐĂNG -->
      <div class="flex items-center justify-between text-xs">
        <div class="flex items-center gap-2">
          <span class="text-slate-500">Xem theo:</span>
          <select id="postStatusFilter" class="px-3 py-1.5 bg-white border border-slate-300 rounded-lg font-semibold focus:outline-none focus:ring-2 focus:ring-blue-500">
            <option value="all">Tất cả bài đăng</option>
            <option value="active" selected>Đang rao bán</option>
            <option value="sold">Đã bán xong</option>
          </select>
        </div>

        <a href="03-dang-tin.jsp" class="px-3 py-1.5 bg-amber-500 hover:bg-amber-600 text-slate-900 font-bold rounded-lg transition shadow-xs">
          + Đăng món đồ mới
        </a>
      </div>

      <!-- DANH SÁCH BÀI ĐĂNG 1 -->
      <div class="bg-white rounded-xl border border-slate-200 p-4 shadow-xs flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
        <div class="flex items-center gap-3.5">
          <img src="assets/images/products/iphone-13-pro-max.jpg" alt="iPhone 13 Pro Max" class="w-16 h-16 rounded-lg object-cover shrink-0 border border-slate-200">
          <div>
            <span class="font-bold text-slate-900 text-sm block">iPhone 13 Pro Max 128GB Xanh Sierra bản VN/A</span>
            <div class="flex items-center gap-2 text-xs mt-1">
              <span class="text-green-600 font-bold">14.800.000 đ</span>
              <span>•</span>
              <span class="text-slate-500">Đăng 25 phút trước</span>
              <span>•</span>
              <span class="px-2 py-0.5 rounded bg-emerald-100 text-emerald-800 text-[10px] font-bold">Đang hiển thị</span>
            </div>
          </div>
        </div>

        <div class="flex items-center gap-2 shrink-0">
          <a href="02-chi-tiet-san-pham.jsp" class="px-3 py-1.5 border border-slate-300 hover:bg-slate-100 rounded-lg text-xs font-semibold text-slate-700">
            Xem bài
          </a>
          <button onclick="boostPostModal('iPhone 13 Pro Max')" class="px-3 py-1.5 bg-blue-50 text-blue-700 hover:bg-blue-100 rounded-lg text-xs font-bold border border-blue-200">
            Đẩy Tin
          </button>
          <button onclick="toggleSold(this)" class="px-3 py-1.5 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-lg text-xs font-medium">
            Đã Bán
          </button>
        </div>
      </div>

      <!-- DANH SÁCH BÀI ĐĂNG 2 -->
      <div class="bg-white rounded-xl border border-slate-200 p-4 shadow-xs flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
        <div class="flex items-center gap-3.5">
          <img src="assets/images/products/ban-go-thong.jpg" alt="Bàn làm việc gỗ" class="w-16 h-16 rounded-lg object-cover shrink-0 border border-slate-200">
          <div>
            <span class="font-bold text-slate-900 text-sm block">Bàn làm việc gỗ thông 1m2 tháo lắp gọn gàng</span>
            <div class="flex items-center gap-2 text-xs mt-1">
              <span class="text-amber-600 font-bold">Miễn phí 0 đ</span>
              <span>•</span>
              <span class="text-slate-500">Đăng hôm qua</span>
              <span>•</span>
              <span class="px-2 py-0.5 rounded bg-emerald-100 text-emerald-800 text-[10px] font-bold">Đang hiển thị</span>
            </div>
          </div>
        </div>

        <div class="flex items-center gap-2 shrink-0">
          <a href="02-chi-tiet-san-pham.jsp" class="px-3 py-1.5 border border-slate-300 hover:bg-slate-100 rounded-lg text-xs font-semibold text-slate-700">
            Xem bài
          </a>
          <button onclick="boostPostModal('Bàn làm việc gỗ')" class="px-3 py-1.5 bg-blue-50 text-blue-700 hover:bg-blue-100 rounded-lg text-xs font-bold border border-blue-200">
            Đẩy Tin
          </button>
          <button onclick="toggleSold(this)" class="px-3 py-1.5 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-lg text-xs font-medium">
            Đã Bán
          </button>
        </div>
      </div>

    </section>

    <!-- PHẦN 2: TIN ĐÃ LƯU YÊU THÍCH (WISHLIST) -->
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
    <section id="sectionReviews" class="space-y-3 hidden">
      <div class="bg-white rounded-xl border border-slate-200 p-4 shadow-xs space-y-2">
        <div class="flex items-center justify-between text-xs">
          <span class="font-bold text-slate-900">Lê Minh Khang (Mua laptop cũ)</span>
          <span class="text-amber-800 font-bold bg-amber-50 px-2 py-0.5 rounded">5 / 5 sao</span>
        </div>
        <p class="text-xs text-slate-600 leading-relaxed">
          Anh chủ nhiệt tình, cho hẹn gặp tại nhà ở Quận 10 test máy thoải mái. Máy dùng rất tốt đúng như mô tả. Đã cọc qua sàn 10% rất yên tâm.
        </p>
        <span class="text-[10px] text-slate-400 block">Đánh giá ngày 20/09/2026</span>
      </div>
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

  <!-- TOAST THÔNG BÁO TỨC THÌ -->
  <div id="toastNotification" class="fixed bottom-6 right-6 bg-slate-900 text-white text-xs px-4 py-3 rounded-lg shadow-lg border border-slate-700 hidden z-50 flex items-center gap-3">
    <div class="w-2 h-2 rounded-full bg-emerald-400"></div>
    <span id="toastMsg" class="font-medium">Thông báo</span>
  </div>

  <!-- CHÂN TRANG ĐẦY ĐỦ 8 MÀN HÌNH -->
  <jsp:include page="includes/footer.jsp" />

  <script>
    function switchProfileSection(sec) {
      document.getElementById('sectionPosts').classList.add('hidden');
      document.getElementById('sectionSaved').classList.add('hidden');
      document.getElementById('sectionReviews').classList.add('hidden');
      document.getElementById('profileTabPosts').className = 'pb-3 px-3 text-slate-500 hover:text-slate-900 transition';
      document.getElementById('profileTabSaved').className = 'pb-3 px-3 text-slate-500 hover:text-slate-900 transition';
      document.getElementById('profileTabReviews').className = 'pb-3 px-3 text-slate-500 hover:text-slate-900 transition';

      if (sec === 'posts') {
        document.getElementById('sectionPosts').classList.remove('hidden');
        document.getElementById('profileTabPosts').className = 'pb-3 px-3 text-blue-600 border-b-2 border-blue-600 transition';
      } else if (sec === 'saved') {
        document.getElementById('sectionSaved').classList.remove('hidden');
        document.getElementById('profileTabSaved').className = 'pb-3 px-3 text-blue-600 border-b-2 border-blue-600 transition';
      } else {
        document.getElementById('sectionReviews').classList.remove('hidden');
        document.getElementById('profileTabReviews').className = 'pb-3 px-3 text-blue-600 border-b-2 border-blue-600 transition';
      }
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
        const saved = [...provinceSelect.options].find((option) => option.dataset.name === savedProvince || option.value === savedProvince);
        if (saved) {
          saved.selected = true;
          await loadWards(saved.dataset.code, savedWard);
        }
      } catch (error) {
        provinceSelect.innerHTML = '<option value="">Không tải được danh sách tỉnh/thành</option>';
        setFieldError('inputProvince', 'Không tải được danh sách tỉnh/thành. Hãy tải lại trang.');
        showToast('Không tải được địa chỉ từ API. Hãy thử tải lại trang.');
      }
    }

    async function loadWards(provinceCode, selectedWard = '') {
      wardSelect.disabled = true;
      wardSelect.innerHTML = '<option value="">Đang tải phường/xã...</option>';
      try {
        const response = await fetch('https://provinces.open-api.vn/api/v2/p/' + encodeURIComponent(provinceCode) + '?depth=2');
        if (!response.ok) throw new Error('API phường/xã không phản hồi');
        const provinceData = await response.json();
        wardSelect.innerHTML = '<option value="">Chọn phường/xã</option>';
        (provinceData.wards || []).forEach((item) => {
          const option = new Option(item.name, item.name);
          wardSelect.add(option);
        });
        wardSelect.disabled = false;
        if (selectedWard) wardSelect.value = selectedWard;
      } catch (error) {
        wardSelect.innerHTML = '<option value="">Không tải được phường/xã</option>';
        wardSelect.disabled = true;
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
</body>
</html>
