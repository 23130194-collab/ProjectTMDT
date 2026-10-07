<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
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
%>
<%
  User currentUser = (User) session.getAttribute("user");
  String avatarText = "";
  String avatarImage = "";
  if (currentUser != null) {
    avatarImage = currentUser.getAvatar() != null ? currentUser.getAvatar().trim() : "";
    String displayName = currentUser.getFullName() != null && !currentUser.getFullName().trim().isEmpty()
            ? currentUser.getFullName().trim()
            : currentUser.getUsername();
    if (displayName != null && !displayName.trim().isEmpty()) {
      String[] nameParts = displayName.trim().split("\\s+");
      String first = nameParts[0].substring(0, 1);
      String last = nameParts.length > 1 ? nameParts[nameParts.length - 1].substring(0, 1) : "";
      avatarText = (first + last).toUpperCase();
    }
  }
%>
<header class="bg-white border-b border-slate-200 sticky top-0 z-50">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-18 flex items-center justify-between gap-4 py-3">
      
      <!-- LOGO SÀN GIAO DỊCH B2C MARKET CREATOR -->
      <div class="flex items-center gap-3 shrink-0">
        <a href="01-trang-chu.jsp" class="flex items-center gap-2.5">
          <img src="assets/logos/muangay-logo-icon.svg" alt="MuaNgay Logo" class="w-10 h-10 rounded-xl shadow-xs">
          <div>
            <span class="text-xl font-extrabold text-slate-900 tracking-tight block">Mua<span class="text-blue-600">Ngay</span></span>
            <span class="text-[11px] text-slate-500 block -mt-0.5 font-medium">Cần là Mua Ngay, thừa thì Pass Luôn</span>
          </div>
        </a>
      </div>

      <!-- Ô TÌM KIẾM TỪ KHÓA ĐA NĂNG (TÍCH HỢP TÌM KIẾM HOẠT ĐỘNG) -->
      <form onsubmit="handleSearch(event)" class="flex-1 max-w-lg hidden sm:block">
        <div class="relative">
          <input 
            id="searchInput"
            type="text" 
            placeholder="Tìm xe máy, iPhone, tủ lạnh, bàn ghế, laptop, máy ảnh..." 
            class="w-full pl-4 pr-24 py-2 bg-slate-100 border border-slate-200 rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-blue-500 focus:bg-white transition"
          >
          <button type="submit" class="absolute right-1 top-1 bottom-1 px-3 bg-blue-600 text-white rounded-md text-xs font-semibold hover:bg-blue-700 transition">
            Tìm kiếm
          </button>
        </div>
      </form>

      <!-- BỘ CHỌN KHU VỰC ĐỊA LÝ (TỈNH / THÀNH PHỐ) -->
      <div class="hidden lg:flex items-center">
        <select id="provinceSelect" onchange="applyFilters()" class="bg-slate-100 border border-slate-200 text-xs font-semibold rounded-lg px-2.5 py-2 text-slate-700 focus:outline-none focus:ring-2 focus:ring-blue-500 cursor-pointer">
          <option value="all">Toàn Quốc</option>
          <option value="hcm" selected>TP. Hồ Chí Minh</option>
          <option value="hn">Hà Nội</option>
          <option value="dn">Đà Nẵng</option>
          <option value="bd">Bình Dương</option>
          <option value="ct">Cần Thơ</option>
        </select>
      </div>

      <!-- CỤM TÀI KHOẢN, QUẢN LÝ ĐƠN HÀNG VÀ ĐĂNG TIN -->
      <div class="flex items-center gap-2 sm:gap-3">
        <a href="<%= currentUser == null ? "07-dang-nhap-xac-thuc.jsp" : "logout" %>" class="hidden sm:inline-block px-2 py-1 text-xs text-slate-600 hover:text-blue-600 font-semibold">
          <%= currentUser == null ? "Đăng nhập" : "Đăng xuất" %>
        </a>
        <a href="05-quan-ly-don-hang.jsp" class="px-2.5 py-1.5 text-xs font-semibold text-slate-700 hover:text-blue-600 hover:bg-slate-100 rounded-lg transition border border-slate-200">
          Đơn hàng (2)
        </a>
        <a href="04-chat-tra-gia-vietqr.jsp" class="px-2.5 py-1.5 text-xs font-semibold text-slate-700 hover:text-blue-600 hover:bg-slate-100 rounded-lg transition relative">
          Tin nhắn
          <span class="inline-block w-2 h-2 rounded-full bg-red-500 ml-0.5"></span>
        </a>
        <a href="06-quan-tri-admin.jsp" class="hidden md:inline-block px-2.5 py-1.5 text-xs font-semibold text-purple-700 hover:bg-purple-50 rounded-lg transition border border-purple-200">
          Admin Sàn
        </a>
        <a href="03-dang-tin.jsp" class="px-3.5 py-2 bg-amber-500 hover:bg-amber-600 text-slate-900 text-xs font-bold rounded-lg shadow-sm transition">
          Đăng Tin Miễn Phí
        </a>
        <a href="08-ho-so-ca-nhan.jsp" title="Hồ sơ cá nhân" class="w-8 h-8 rounded-full bg-blue-600 text-white flex items-center justify-center text-xs font-bold hover:ring-2 hover:ring-blue-400 transition shrink-0">
          <% if (currentUser == null) { %>
            <i class="fa-solid fa-user text-sm"></i>
          <% } else if (!avatarImage.isEmpty()) { %>
            <img src="<%= h(avatarImage) %>" alt="Ảnh đại diện" class="w-full h-full rounded-full object-cover">
          <% } else { %>
            <%= h(avatarText) %>
          <% } %>
        </a>
      </div>

    </div>
  </header>
