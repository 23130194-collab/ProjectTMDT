<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%@ page import="model.Notification" %>
<%@ page import="dao.OrderDAO" %>
<%@ page import="dao.ChatDAO" %>
<%@ page import="dao.NotificationDAO" %>
<%@ page import="java.util.List" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<link rel="stylesheet"
      href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">
<script src="https://unpkg.com/lucide@latest"></script>
<style>
  /* Icon thông báo dạng nét viền giống mẫu */
  .notif-outline-icon {
    width: 20px;
    height: 20px;
    color: #94a3b8;
    stroke-width: 2;
    flex-shrink: 0;
  }
</style>
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
  int orderCount = currentUser != null ? new OrderDAO().countOrdersForUser(currentUser.getId()) : 0;
  int unreadChatCount = currentUser != null ? new ChatDAO().countUnreadMessages(currentUser.getId()) : 0;
  NotificationDAO headerNotifDAO = new NotificationDAO();
  int unreadNotifCount = currentUser != null ? headerNotifDAO.countUnreadNotifications(currentUser.getId()) : 0;
  List<Notification> headerNotifs = currentUser != null ? headerNotifDAO.getNotificationsForUser(currentUser.getId(), 15) : java.util.Collections.emptyList();
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
      <a href="home" class="flex items-center gap-2.5">
        <img src="assets/logos/muangay-logo-icon.svg" alt="MuaNgay Logo" class="w-10 h-10 rounded-xl shadow-xs">
        <div>
          <span class="text-xl font-extrabold text-slate-900 tracking-tight block">Mua<span class="text-blue-600">Ngay</span></span>
          <span class="text-[11px] text-slate-500 block -mt-0.5 font-medium">Cần là Mua Ngay, thừa thì Pass Luôn</span>
        </div>
      </a>
    </div>

    <!-- Ô TÌM KIẾM TỪ KHÓA ĐA NĂNG (TÍCH HỢP TÌM KIẾM HOẠT ĐỘNG) -->
    <form id="siteSearchForm" action="${pageContext.request.contextPath}/search" method="get" autocomplete="off" class="flex-1 max-w-lg hidden sm:block">
      <div class="relative">
        <input
                id="searchInput"
                type="text"
                name="q"
                value="<c:out value='${searchKeyword}'/>"
                autocomplete="off"
                aria-label="Tìm kiếm sản phẩm"
                aria-controls="searchDropdown"
                aria-expanded="false"
                placeholder="Tìm xe máy, iPhone, tủ lạnh, bàn ghế, laptop, máy ảnh..."
                class="w-full pl-4 pr-32 py-2 bg-slate-100 border border-slate-200 rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-blue-500 focus:bg-white transition"
        >
        <!-- NÚT TÌM KIẾM BẰNG HÌNH ẢNH (AI CLIP) -->
        <button type="button" id="visualSearchTriggerBtn"
                class="absolute right-20 top-1 bottom-1 px-2.5 text-slate-500 hover:text-blue-600 rounded-md transition flex items-center justify-center group"
                title="Tìm kiếm bằng hình ảnh">
          <svg class="w-4 h-4 transition-transform group-hover:scale-110 text-slate-500 group-hover:text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z" />
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 13a3 3 0 11-6 0 3 3 0 016 0z" />
          </svg>
        </button>
        <input type="file" id="visualSearchFileInput" accept="image/png, image/jpeg, image/webp" class="hidden">

        <button type="submit" class="absolute right-1 top-1 bottom-1 px-3 bg-blue-600 text-white rounded-md text-xs font-semibold hover:bg-blue-700 transition">
          Tìm kiếm
        </button>
        <div id="searchDropdown" class="hidden absolute left-0 right-0 top-full mt-2 bg-white border border-slate-200 rounded-xl shadow-xl z-[60] overflow-hidden" role="listbox"></div>
      </div>
    </form>

    <!-- BỘ CHỌN KHU VỰC ĐỊA LÝ (TỈNH / THÀNH PHỐ) -->
    <div class="hidden lg:flex items-center">
      <select id="provinceSelect" class="bg-slate-100 border border-slate-200 text-xs font-semibold rounded-lg px-2.5 py-2 text-slate-700 focus:outline-none focus:ring-2 focus:ring-blue-500 cursor-pointer">
        <option value="all">Toàn Quốc</option>
      </select>
    </div>

    <!-- CỤM TÀI KHOẢN, QUẢN LÝ ĐƠN HÀNG VÀ ĐĂNG TIN -->
    <div class="flex items-center gap-2 sm:gap-3">

      <% if (currentUser == null) { %>
      <!-- Chưa đăng nhập: Hiện nút đăng nhập -->
      <a href="07-dang-nhap-xac-thuc.jsp" class="hidden sm:inline-block px-3 py-1.5 text-xs text-slate-600 hover:text-blue-600 font-semibold border border-slate-200 rounded-lg hover:bg-slate-50 transition">
        Đăng nhập
      </a>
      <% } %>

      <a href="05-quan-ly-don-hang.jsp" class="flex items-center gap-1.5 px-2.5 py-1.5 text-xs font-semibold text-slate-600 hover:text-slate-900 hover:bg-slate-100 rounded-lg transition">
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z"/></svg>
        Đơn hàng<% if (currentUser != null && orderCount > 0) { %> <span class="inline-flex items-center justify-center w-4 h-4 text-[10px] font-bold bg-blue-600 text-white rounded-full"><%= orderCount %></span><% } %>
      </a>
      <% if (currentUser != null) { %>
      <% } %>

      <a href="04-chat-tra-gia-vietqr.jsp" class="flex items-center gap-1.5 px-2.5 py-1.5 text-xs font-semibold text-slate-600 hover:text-slate-900 hover:bg-slate-100 rounded-lg transition relative">
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"/></svg>
        Tin nhắn
        <span id="chatUnreadBadge" class="<%= unreadChatCount > 0 ? "inline-flex" : "hidden" %> items-center justify-center min-w-[18px] h-[18px] px-1 text-[10px] font-bold bg-red-600 text-white rounded-full"><%= unreadChatCount %></span>
      </a>

      <!-- NÚT THÔNG BÁO VỚI DROPDOWN -->
      <div class="relative" id="notifWrapper">
        <button id="notifBtn" onclick="toggleNotifDropdown(event)"
                class="w-8 h-8 rounded-full hover:bg-slate-100 text-slate-600 hover:text-slate-900 flex items-center justify-center transition shrink-0 relative select-none"
                aria-haspopup="true" aria-expanded="false" title="Thông báo của bạn">
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
          </svg>
          <span id="notifBadge" class="<%= unreadNotifCount > 0 ? "inline-flex" : "hidden" %> items-center justify-center min-w-[18px] h-[18px] px-1 text-[10px] font-bold bg-red-600 text-white rounded-full absolute -top-1 -right-1 ring-2 ring-white shadow-xs">
            <%= unreadNotifCount %>
          </span>
        </button>

        <!-- DROPDOWN DANH SÁCH THÔNG BÁO -->
        <div id="notifDropdown"
             class="hidden absolute right-0 sm:-right-20 top-full mt-2 w-80 sm:w-96 bg-white border border-slate-200 rounded-2xl shadow-2xl z-[120] overflow-hidden"
             role="menu">

          <!-- HEADER DROPDOWN -->
          <div class="px-4 py-3 bg-slate-50 border-b border-slate-100 flex items-center justify-between">
            <div class="flex items-center gap-2">
              <span class="font-bold text-xs text-slate-900 uppercase tracking-wide">Thông Báo</span>
              <span id="notifHeaderCount" class="text-[11px] px-2 py-0.5 rounded-full bg-blue-100 text-blue-700 font-bold <%= unreadNotifCount > 0 ? "" : "hidden" %>">
                <%= unreadNotifCount %> mới
              </span>
            </div>
            <button id="btnMarkAllRead" onclick="markAllNotificationsRead(event)" class="text-[11px] text-blue-600 hover:text-blue-800 font-semibold transition <%= unreadNotifCount > 0 ? "" : "hidden" %>">
              Đánh dấu tất cả đã đọc
            </button>
          </div>

          <!-- DANH SÁCH CÁC MỤC THÔNG BÁO -->
          <div id="notifList" class="max-h-96 overflow-y-auto divide-y divide-slate-100">
            <% if (headerNotifs.isEmpty()) { %>
            <div class="p-8 text-center space-y-2">
              <div class="w-10 h-10 rounded-full bg-slate-100 text-slate-400 flex items-center justify-center mx-auto text-lg">🔔</div>
              <p class="text-xs text-slate-500">Bạn chưa có thông báo nào</p>
            </div>
            <% } else { %>
            <% for (Notification n : headerNotifs) {
              boolean isUnread = !n.isRead();
            %>
            <div id="notif-item-<%= n.getId() %>"
                 data-notif-id="<%= n.getId() %>"
                 data-target-url="<%= n.getTargetUrl() != null ? n.getTargetUrl() : "" %>"
                 data-is-read="<%= !isUnread %>"
                 onclick="handleNotificationClick(event, this)"
                 class="notif-item p-3.5 transition cursor-pointer flex gap-3 items-start <%= isUnread ? "bg-blue-50/80 border-l-4 border-l-blue-600 text-slate-900 font-medium" : "bg-white hover:bg-slate-50 border-l-4 border-l-transparent text-slate-500" %>">

              <!-- ICON THEO LOẠI THÔNG BÁO --><!-- ICON THEO LOẠI THÔNG BÁO -->
              <%
                String badgeBg = "bg-gray-100 text-gray-600";
                String notifIcon = "bell";
                String nType = n.getType() != null ? n.getType() : "";

                if ("ORDER_PLACED".equals(nType) || "NEW_ORDER".equals(nType)) {
                  badgeBg = "bg-gray-100 text-gray-700";
                  notifIcon = "shopping-cart";
                } else if ("ORDER_CANCEL_REQUEST".equals(nType)) {
                  badgeBg = "bg-gray-100 text-gray-700";
                  notifIcon = "clock";
                } else if ("ORDER_CANCELLED".equals(nType)) {
                  badgeBg = "bg-gray-100 text-gray-700";
                  notifIcon = "circle-x";
                } else if ("ORDER_SHIPPING".equals(nType)) {
                  badgeBg = "bg-gray-100 text-gray-700";
                  notifIcon = "package";
                } else if ("REVIEW_RECEIVED".equals(nType)) {
                  badgeBg = "bg-gray-100 text-gray-700";
                  notifIcon = "star";
                }
              %>
              <div class="w-8 h-8 rounded-full flex items-center justify-center text-sm shrink-0 <%= badgeBg %>">
                <i data-lucide="<%= notifIcon %>" class="notif-outline-icon"></i>
              </div>

              <!-- NỘI DUNG THÔNG BÁO -->
              <div class="flex-1 min-w-0 space-y-1">
                <div class="flex items-center justify-between gap-2">
                      <span class="text-xs font-bold <%= isUnread ? "text-slate-900" : "text-slate-700" %> truncate">
                        <%= h(n.getTitle()) %>
                      </span>
                  <span class="text-[10px] text-slate-400 shrink-0"><%= n.getTimeAgo() %></span>
                </div>
                <p class="text-xs <%= isUnread ? "text-slate-700" : "text-slate-500" %> leading-relaxed line-clamp-2">
                  <%= h(n.getMessage()) %>
                </p>
              </div>

              <!-- CHẤM TRÒN CHƯA ĐỌC -->
              <% if (isUnread) { %>
              <span class="notif-dot w-2 h-2 rounded-full bg-blue-600 shrink-0 mt-1.5" title="Chưa đọc"></span>
              <% } %>
            </div>
            <% } %>
            <% } %>
          </div>

          <!-- FOOTER DROPDOWN -->
          <div class="p-2 bg-slate-50 border-t border-slate-100 text-center">
            <a href="05-quan-ly-don-hang.jsp" class="text-xs text-blue-600 hover:text-blue-800 font-semibold block py-1">
              Xem tất cả đơn hàng &rarr;
            </a>
          </div>

        </div>
      </div>

      <a href="${pageContext.request.contextPath}/post-ad" class="px-3.5 py-2 bg-amber-500 hover:bg-amber-600 text-slate-900 text-xs font-bold rounded-lg shadow-sm transition">
        Đăng Tin Miễn Phí
      </a>

      <!-- AVATAR + USER DROPDOWN -->
      <div class="relative" id="userMenuWrapper">
        <button id="userMenuBtn" onclick="toggleUserMenu()"
                class="w-8 h-8 rounded-full bg-teal-600 text-white flex items-center justify-center text-xs font-bold hover:ring-2 hover:ring-teal-400 transition shrink-0 select-none"
                aria-haspopup="true" aria-expanded="false">
          <% if (currentUser == null) { %>
          <i class="fa-solid fa-user text-sm"></i>
          <% } else if (!avatarImage.isEmpty()) { %>
          <img src="<%= h(avatarImage) %>" alt="Ảnh đại diện" referrerpolicy="no-referrer" class="w-full h-full rounded-full object-cover">
          <% } else { %>
          <%= h(avatarText) %>
          <% } %>
        </button>

        <!-- DROPDOWN PANEL -->
        <div id="userMenuDropdown"
             class="hidden absolute right-0 top-full mt-2 w-64 bg-white border border-slate-200 rounded-xl shadow-lg z-[100] overflow-hidden py-1"
             role="menu">

          <% if (currentUser != null) { %>
          <!-- Thông tin user -->
          <div class="flex items-center gap-3 px-4 py-3 border-b border-slate-100">
            <div class="w-9 h-9 rounded-full bg-teal-600 text-white flex items-center justify-center text-sm font-bold shrink-0">
              <% if (!avatarImage.isEmpty()) { %>
              <img src="<%= h(avatarImage) %>" alt="" referrerpolicy="no-referrer" class="w-full h-full rounded-full object-cover">
              <% } else { %>
              <%= h(avatarText) %>
              <% } %>
            </div>
            <div class="min-w-0">
              <div class="text-sm font-bold text-slate-900 truncate">
                <%
                  String _dn = currentUser.getFullName() != null && !currentUser.getFullName().trim().isEmpty()
                          ? currentUser.getFullName().trim() : currentUser.getUsername();
                %>
                <%= h(_dn) %>
              </div>
              <div class="text-[11px] text-slate-500 truncate"><%= h(currentUser.getEmail() != null ? currentUser.getEmail() : "") %></div>
            </div>
          </div>

          <a href="${pageContext.request.contextPath}/my-posts" role="menuitem"
             class="flex items-center gap-2.5 px-4 py-2 text-xs text-slate-700 hover:bg-slate-50 transition"
             onclick="if (typeof switchProfileSection === 'function') { switchProfileSection('posts'); const dd = document.getElementById('userMenuDropdown'); if(dd) dd.classList.add('hidden'); return false; }">
            <svg class="w-3.5 h-3.5 text-slate-400 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/></svg>
            Hồ sơ cá nhân &amp; Điểm uy tín
          </a>
          <a href="${pageContext.request.contextPath}/my-posts?tab=orders" role="menuitem"
             class="flex items-center gap-2.5 px-4 py-2 text-xs text-slate-700 hover:bg-slate-50 transition"
             onclick="if (typeof switchProfileSection === 'function') { switchProfileSection('orders'); const dd = document.getElementById('userMenuDropdown'); if(dd) dd.classList.add('hidden'); return false; }">
            <svg class="w-3.5 h-3.5 text-slate-400 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z"/></svg>
            Lịch sử mua hàng
          </a>
          <a href="${pageContext.request.contextPath}/my-posts?tab=stats" role="menuitem"
             class="flex items-center gap-2.5 px-4 py-2 text-xs text-slate-700 hover:bg-slate-50 transition"
             onclick="if (typeof switchProfileSection === 'function') { switchProfileSection('stats'); const dd = document.getElementById('userMenuDropdown'); if(dd) dd.classList.add('hidden'); return false; }">
            <svg class="w-3.5 h-3.5 text-slate-400 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"/></svg>
            Thống kê doanh thu người bán
          </a>
          <a href="05-quan-ly-don-hang.jsp" role="menuitem"
             class="flex items-center gap-2.5 px-4 py-2 text-xs text-slate-700 hover:bg-slate-50 transition">
            <svg class="w-3.5 h-3.5 text-slate-400 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/></svg>
            Quản lý đơn hàng &amp; Ký quỹ
          </a>
          <a href="${pageContext.request.contextPath}/post-ad" role="menuitem"
             class="flex items-center gap-2.5 px-4 py-2 text-xs text-slate-700 hover:bg-slate-50 transition">
            <svg class="w-3.5 h-3.5 text-slate-400 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/></svg>
            Đăng bán món đồ mới
          </a>
          <div class="border-t border-slate-100 mt-1 pt-1">
            <a href="${pageContext.request.contextPath}/logout" role="menuitem"
               class="flex items-center gap-2.5 px-4 py-2 text-xs text-red-600 hover:bg-red-50 transition font-semibold">
              <svg class="w-3.5 h-3.5 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"/></svg>
              Đăng Xuất Tài Khoản
            </a>
          </div>
          <% } else { %>
          <a href="07-dang-nhap-xac-thuc.jsp" role="menuitem"
             class="flex items-center gap-3 px-4 py-2.5 text-sm text-slate-700 hover:bg-slate-50 transition">
            Đăng nhập
          </a>
          <% } %>
        </div>
      </div>

    </div>

  </div>
</header>


<script>
  function toggleUserMenu() {
    const dropdown = document.getElementById('userMenuDropdown');
    const notifDropdown = document.getElementById('notifDropdown');
    if (notifDropdown) notifDropdown.classList.add('hidden');
    const btn = document.getElementById('userMenuBtn');
    const isHidden = dropdown.classList.contains('hidden');
    dropdown.classList.toggle('hidden', !isHidden);
    btn.setAttribute('aria-expanded', String(isHidden));
  }

  function toggleNotifDropdown(e) {
    if (e) e.stopPropagation();
    const dropdown = document.getElementById('notifDropdown');
    const userDropdown = document.getElementById('userMenuDropdown');
    if (userDropdown) userDropdown.classList.add('hidden');
    const btn = document.getElementById('notifBtn');
    if (dropdown) {
      const isHidden = dropdown.classList.contains('hidden');
      dropdown.classList.toggle('hidden', !isHidden);
      if (btn) btn.setAttribute('aria-expanded', String(isHidden));
    }
  }

  function handleNotificationClick(event, element) {
    if (event) event.stopPropagation();
    const notifId = element.dataset.notifId;
    const targetUrl = element.dataset.targetUrl;
    const isAlreadyRead = element.dataset.isRead === 'true';

    if (!isAlreadyRead) {
      // 1. Đổi màu nền nhạt hơn (đã xem)
      element.className = 'notif-item p-3.5 transition cursor-pointer flex gap-3 items-start bg-white hover:bg-slate-50 border-l-4 border-l-transparent text-slate-500';
      element.dataset.isRead = 'true';
      const dot = element.querySelector('.notif-dot');
      if (dot) dot.remove();

      // 2. Số lượng thông báo -1
      const badge = document.getElementById('notifBadge');
      const headerCount = document.getElementById('notifHeaderCount');
      if (badge) {
        let currentCount = parseInt(badge.textContent.trim()) || 0;
        let newCount = Math.max(0, currentCount - 1);
        if (newCount > 0) {
          badge.textContent = newCount;
          if (headerCount) headerCount.textContent = newCount + ' mới';
        } else {
          badge.textContent = '0';
          badge.classList.add('hidden');
          if (headerCount) headerCount.classList.add('hidden');
          const btnMarkAll = document.getElementById('btnMarkAllRead');
          if (btnMarkAll) btnMarkAll.classList.add('hidden');
        }
      }

      // 3. Gọi server cập nhật trạng thái đã xem
      fetch('${pageContext.request.contextPath}/mark-notification-read?id=' + notifId, {
        method: 'POST'
      }).catch(err => console.error('Lỗi cập nhật đã đọc:', err));
    }

    // 4. Chuyển hướng ngay lập tức tới trang liên quan
    if (targetUrl && targetUrl.trim() !== '') {
      let finalUrl = targetUrl.trim();
      if (!finalUrl.startsWith('http://') && !finalUrl.startsWith('https://') && !finalUrl.startsWith('/')) {
        finalUrl = '${pageContext.request.contextPath}/' + finalUrl;
      }
      window.location.href = finalUrl;
    }
  }

  function markAllNotificationsRead(e) {
    if (e) e.stopPropagation();
    fetch('${pageContext.request.contextPath}/mark-notification-read?action=read_all', {
      method: 'POST'
    }).then(res => res.json()).then(data => {
      // Đổi toàn bộ các mục sang màu nhạt hơn
      const items = document.querySelectorAll('.notif-item');
      items.forEach(el => {
        el.className = 'notif-item p-3.5 transition cursor-pointer flex gap-3 items-start bg-white hover:bg-slate-50 border-l-4 border-l-transparent text-slate-500';
        el.dataset.isRead = 'true';
        const dot = el.querySelector('.notif-dot');
        if (dot) dot.remove();
      });

      // Ẩn badge đếm số lượng
      const badge = document.getElementById('notifBadge');
      if (badge) {
        badge.textContent = '0';
        badge.classList.add('hidden');
      }
      const headerCount = document.getElementById('notifHeaderCount');
      if (headerCount) headerCount.classList.add('hidden');
      const btnMarkAll = document.getElementById('btnMarkAllRead');
      if (btnMarkAll) btnMarkAll.classList.add('hidden');
    }).catch(err => console.error('Lỗi mark all read:', err));
  }

  document.addEventListener('click', function(e) {
    const userWrapper = document.getElementById('userMenuWrapper');
    if (userWrapper && !userWrapper.contains(e.target)) {
      const userDropdown = document.getElementById('userMenuDropdown');
      if (userDropdown) userDropdown.classList.add('hidden');
      const userBtn = document.getElementById('userMenuBtn');
      if (userBtn) userBtn.setAttribute('aria-expanded', 'false');
    }

    const notifWrapper = document.getElementById('notifWrapper');
    if (notifWrapper && !notifWrapper.contains(e.target)) {
      const notifDropdown = document.getElementById('notifDropdown');
      if (notifDropdown) notifDropdown.classList.add('hidden');
      const notifBtn = document.getElementById('notifBtn');
      if (notifBtn) notifBtn.setAttribute('aria-expanded', 'false');
    }
  });
</script>
<script>
  (function () {
    const badge = document.getElementById('chatUnreadBadge');
    if (!badge) return;
    const endpoint = '${pageContext.request.contextPath}/chat-unread-count';
    async function refreshUnreadChatCount() {
      if (document.visibilityState === 'hidden') return;
      try {
        const response = await fetch(endpoint, { headers: { 'Accept': 'application/json' } });
        if (!response.ok) return;
        const data = await response.json();
        if (!data.success) return;
        const count = Number(data.count) || 0;
        badge.textContent = count > 99 ? '99+' : String(count);
        badge.classList.toggle('hidden', count <= 0);
        badge.classList.toggle('inline-flex', count > 0);
      } catch (e) {
        // Keep the server-rendered count when a refresh cannot reach the server.
      }
    }
    window.setInterval(refreshUnreadChatCount, 15000);
    document.addEventListener('visibilitychange', refreshUnreadChatCount);
  })();
</script>

<script>
  (() => {
    const form = document.getElementById('siteSearchForm');
    const input = document.getElementById('searchInput');
    const dropdown = document.getElementById('searchDropdown');
    if (!form || !input || !dropdown) return;

    let suggestionTimer;
    let requestVersion = 0;
    const endpoint = form.action;

    function show() {
      dropdown.classList.remove('hidden');
      input.setAttribute('aria-expanded', 'true');
    }

    function hide() {
      dropdown.classList.add('hidden');
      input.setAttribute('aria-expanded', 'false');
    }

    function addSection(title, values, type) {
      if (!values || !values.length) return;
      const section = document.createElement('div');
      const heading = document.createElement('div');
      heading.className = 'px-4 pt-3 pb-1 text-[10px] font-bold uppercase tracking-wide text-slate-400 flex items-center justify-between';
      heading.textContent = title;
      if (type === 'history') {
        const clear = document.createElement('button');
        clear.type = 'button';
        clear.className = 'normal-case tracking-normal text-blue-600 hover:text-blue-700';
        clear.textContent = 'Xóa lịch sử';
        clear.addEventListener('click', async () => {
          const data = await updateHistory('clear');
          renderHistoryBar(data.history || []);
          await refreshDropdown(input.value.trim());
        });
        heading.appendChild(clear);
      }
      section.appendChild(heading);

      values.forEach(value => {
        const row = document.createElement('div');
        row.className = 'flex items-center gap-2 px-3 py-1 hover:bg-slate-50';
        const choose = document.createElement('button');
        choose.type = 'button';
        choose.className = 'flex-1 min-w-0 py-2 text-left text-xs text-slate-700 truncate';
        choose.textContent = (type === 'history' ? '◷  ' : '⌕  ') + value;
        choose.addEventListener('click', () => {
          input.value = value;
          form.requestSubmit();
        });
        row.appendChild(choose);

        if (type === 'history') {
          const remove = document.createElement('button');
          remove.type = 'button';
          remove.className = 'px-2 py-1 text-slate-400 hover:text-red-600 text-xs';
          remove.setAttribute('aria-label', 'Xóa lịch sử: ' + value);
          remove.textContent = '×';
          remove.addEventListener('click', async () => {
            const data = await updateHistory('delete', value);
            renderHistoryBar(data.history || []);
            await refreshDropdown(input.value.trim());
          });
          row.appendChild(remove);
        }
        section.appendChild(row);
      });
      dropdown.appendChild(section);
    }

    function addProductSuggestions(products) {
      if (!products || !products.length) return;
      const section = document.createElement('div');
      const heading = document.createElement('div');
      heading.className = 'px-4 pt-3 pb-1 text-[10px] font-bold uppercase tracking-wide text-slate-400';
      heading.textContent = 'Sản phẩm phù hợp';
      section.appendChild(heading);
      products.forEach(product => {
        const choose = document.createElement('button');
        choose.type = 'button';
        choose.className = 'w-full flex items-center gap-3 px-4 py-3 text-left hover:bg-slate-50 border-b border-slate-100 last:border-0';
        const icon = document.createElement('span');
        icon.className = 'text-base text-slate-400';
        icon.textContent = '⌕';
        const details = document.createElement('span');
        details.className = 'min-w-0 flex-1';
        const title = document.createElement('span');
        title.className = 'block truncate text-xs font-medium text-slate-800';
        title.textContent = product.title;
        const price = document.createElement('span');
        price.className = 'block mt-0.5 text-xs text-slate-500';
        price.textContent = new Intl.NumberFormat('vi-VN').format(product.price) + ' đ';
        details.append(title, price);
        choose.append(icon, details);
        choose.addEventListener('click', () => {
          input.value = product.title;
          form.requestSubmit();
        });
        section.appendChild(choose);
      });
      dropdown.appendChild(section);
    }

    async function getJson(url) {
      const response = await fetch(url, { credentials: 'same-origin' });
      if (!response.ok) throw new Error('Search request failed');
      return response.json();
    }

    async function updateHistory(action, term) {
      const body = new URLSearchParams({ action });
      if (term) body.set('term', term);
      const response = await fetch(endpoint, {
        method: 'POST',
        credentials: 'same-origin',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8' },
        body
      });
      if (!response.ok) throw new Error('History update failed');
      return response.json();
    }

    async function refreshDropdown(keyword) {
      const version = ++requestVersion;
      const params = new URLSearchParams({ action: 'history' });
      try {
        const historyData = await getJson(endpoint + '?' + params.toString());
        let suggestions = [];
        if (keyword.length >= 2) {
          const suggestParams = new URLSearchParams({ action: 'suggest', q: keyword });
          const suggestionData = await getJson(endpoint + '?' + suggestParams.toString());
          suggestions = suggestionData.suggestions || [];
        }
        if (version !== requestVersion) return;

        dropdown.replaceChildren();
        addProductSuggestions(suggestions);
        addSection('Lịch sử tìm kiếm', historyData.history || [], 'history');

        const recent = historyData.history || [];

        if (!suggestions.length && !recent.length) {
          const empty = document.createElement('div');
          empty.className = 'px-4 py-3 text-xs text-slate-500';
          empty.textContent = keyword.length >= 2 ? 'Chưa có gợi ý phù hợp.' : 'Chưa có lịch sử tìm kiếm.';
          dropdown.appendChild(empty);
        }
        show();
      } catch (error) {
        if (version === requestVersion) hide();
      }
    }

    function renderHistoryBar(values) {
      let bar = document.getElementById('searchHistoryBar');
      if (!values || !values.length) {
        if (bar) bar.remove();
        return;
      }
      if (!bar) {
        bar = document.createElement('div');
        bar.id = 'searchHistoryBar';
        bar.className = 'bg-slate-50 border-b border-slate-200';
        const content = document.createElement('div');
        content.className = 'max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-2 flex flex-wrap items-center gap-2';
        bar.appendChild(content);
        document.querySelector('header').insertAdjacentElement('afterend', bar);
      }
      const content = bar.firstElementChild;
      content.replaceChildren();
      const label = document.createElement('span');
      label.className = 'text-[11px] font-semibold text-slate-500';
      label.textContent = 'Tìm gần đây:';
      content.appendChild(label);
      values.forEach(term => {
        const chip = document.createElement('span');
        chip.className = 'inline-flex items-center gap-1 rounded-full bg-white border border-slate-200 pl-2.5 pr-1 py-1 text-[11px] text-slate-700';
        const link = document.createElement('a');
        link.className = 'max-w-40 truncate hover:text-blue-600';
        link.href = endpoint + '?q=' + encodeURIComponent(term);
        link.textContent = term;
        const remove = document.createElement('button');
        remove.type = 'button';
        remove.className = 'history-bar-delete rounded-full w-5 h-5 text-slate-400 hover:text-red-600 hover:bg-red-50';
        remove.dataset.term = term;
        remove.setAttribute('aria-label', 'Xóa lịch sử: ' + term);
        remove.textContent = '×';
        chip.append(link, remove);
        content.appendChild(chip);
      });
      const clear = document.createElement('button');
      clear.id = 'clearSearchHistoryBar';
      clear.type = 'button';
      clear.className = 'ml-auto text-[11px] font-semibold text-red-600 hover:text-red-700';
      clear.textContent = 'Xóa lịch sử';
      content.appendChild(clear);
    }

    input.addEventListener('focus', () => refreshDropdown(input.value.trim()));
    input.addEventListener('input', () => {
      window.clearTimeout(suggestionTimer);
      suggestionTimer = window.setTimeout(() => refreshDropdown(input.value.trim()), 180);
    });
    input.addEventListener('keydown', event => {
      if (event.key === 'Escape') hide();
    });
    document.addEventListener('click', event => {
      if (!form.contains(event.target)) hide();
      const remove = event.target.closest('.history-bar-delete');
      if (remove) {
        updateHistory('delete', remove.dataset.term).then(data => {
          renderHistoryBar(data.history || []);
          if (!dropdown.classList.contains('hidden')) refreshDropdown(input.value.trim());
        });
      }
      if (event.target.closest('#clearSearchHistoryBar')) {
        updateHistory('clear').then(data => {
          renderHistoryBar(data.history || []);
          if (!dropdown.classList.contains('hidden')) refreshDropdown(input.value.trim());
        });
      }
    });
    form.addEventListener('submit', event => {
      if (!input.value.trim()) {
        event.preventDefault();
        input.focus();
        refreshDropdown('');
      }
    });
  })();
</script>

<!-- MODAL TÌM KIẾM BẰNG HÌNH ẢNH (AI CLIP VISUAL SEARCH) -->
<div id="visualSearchModal" class="hidden fixed inset-0 z-[100] overflow-y-auto bg-slate-900/60 backdrop-blur-xs flex items-center justify-center p-3 sm:p-4">
  <div class="bg-white rounded-2xl shadow-2xl border border-slate-200 w-full max-w-4xl overflow-hidden animate-in fade-in zoom-in-95 duration-200">
    <!-- Header Modal -->
    <div class="px-5 py-3.5 border-b border-slate-100 flex items-center justify-between bg-gradient-to-r from-blue-50 to-indigo-50">
      <div class="flex items-center gap-2.5">
        <div class="w-8 h-8 rounded-lg bg-blue-600 text-white flex items-center justify-center shadow-xs">
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z" />
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 13a3 3 0 11-6 0 3 3 0 016 0z" />
          </svg>
        </div>
        <div>
          <h2 class="text-sm font-bold text-slate-900">Tìm kiếm bằng hình ảnh</h2>
        </div>
      </div>
      <button type="button" id="closeVisualSearchModal" class="w-8 h-8 flex items-center justify-center text-slate-400 hover:text-slate-600 hover:bg-white rounded-lg transition">
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg>
      </button>
    </div>

    <!-- Body Modal -->
    <div class="p-5 max-h-[85vh] overflow-y-auto">

      <!-- Trạng thái Chụp ảnh trực tiếp từ Camera / Webcam -->
      <div id="vsCameraState" class="hidden py-4 text-center">
        <div class="relative w-full max-w-md mx-auto aspect-video rounded-xl overflow-hidden bg-black mb-3.5 shadow-md">
          <video id="vsCameraVideo" autoplay playsinline class="w-full h-full object-cover"></video>
          <canvas id="vsCameraCanvas" class="hidden"></canvas>
          <div class="absolute top-2 left-2 bg-black/60 text-white text-[10px] font-semibold px-2 py-0.5 rounded backdrop-blur-xs flex items-center gap-1.5">
            <span class="w-2 h-2 rounded-full bg-red-500 animate-ping"></span>
            <span>Camera trực tiếp</span>
          </div>
        </div>
        <div class="flex flex-wrap items-center justify-center gap-2.5">
          <button type="button" id="vsCaptureBtn" class="px-5 py-2.5 bg-blue-600 hover:bg-blue-700 text-white text-xs font-bold rounded-lg shadow-xs transition flex items-center gap-1.5">
            <span>Chụp & Tìm kiếm</span>
          </button>
          <button type="button" id="vsSwitchCameraBtn" class="px-3.5 py-2.5 bg-slate-100 hover:bg-slate-200 text-slate-700 text-xs font-semibold rounded-lg transition">
            Đổi Camera
          </button>
          <button type="button" id="vsCloseCameraBtn" class="px-3.5 py-2.5 border border-slate-300 hover:bg-slate-50 text-slate-700 text-xs font-semibold rounded-lg transition">
            Quay lại
          </button>
        </div>
      </div>

      <!-- Trạng thái Đang quét ảnh (Loading) -->
      <div id="vsLoadingState" class="py-12 flex flex-col items-center justify-center text-center">
        <div class="relative w-16 h-16 mb-4">
          <div class="absolute inset-0 rounded-full border-4 border-blue-200 border-t-blue-600 animate-spin"></div>
          <div class="absolute inset-2 rounded-full bg-blue-50 flex items-center justify-center">
            <svg class="w-6 h-6 text-blue-600 animate-pulse" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"/>
            </svg>
          </div>
        </div>
        <h4 class="text-sm font-bold text-slate-800 mb-1">Đang phân tích hình ảnh...</h4>
        <p class="text-xs text-slate-500 max-w-sm">Hệ thống đang tìm các sản phẩm hiện có trên hệ thống MuaNgay.</p>
      </div>

      <!-- Trạng thái Lỗi -->
      <div id="vsErrorState" class="hidden py-8 text-center">
        <div class="w-12 h-12 mx-auto mb-3 rounded-full bg-red-100 text-red-600 flex items-center justify-center">
          <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/></svg>
        </div>
        <h4 id="vsErrorMessage" class="text-xs font-semibold text-red-600 mb-4">Đã xảy ra lỗi khi tìm kiếm hình ảnh</h4>
        <div class="flex items-center justify-center gap-2">
          <button type="button" id="vsRetryBtn" class="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white text-xs font-semibold rounded-lg shadow-xs transition">
            Chọn ảnh khác
          </button>
          <button type="button" id="vsOpenCameraFromErrorBtn" class="px-4 py-2 bg-slate-100 hover:bg-slate-200 text-slate-700 text-xs font-semibold rounded-lg transition">
            Chụp bằng Camera
          </button>
        </div>
      </div>

      <!-- Trạng thái Kết quả -->
      <div id="vsResultState" class="hidden grid grid-cols-1 md:grid-cols-12 gap-5">
        <!-- Cột trái: Ảnh query & Hành động -->
        <div class="md:col-span-4 bg-slate-50 p-4 rounded-xl border border-slate-100 flex flex-col items-center">
          <span class="text-[11px] font-bold text-slate-600 mb-2.5 uppercase tracking-wide">Ảnh bạn vừa tìm kiếm</span>
          <div class="w-full aspect-square rounded-lg overflow-hidden bg-white border border-slate-200 shadow-xs mb-3 flex items-center justify-center">
            <img id="vsPreviewImg" src="" alt="Ảnh tìm kiếm" class="w-full h-full object-cover">
          </div>
          <div class="w-full space-y-2">
            <button type="button" id="vsChangeImgBtn" class="w-full py-2 px-3 border border-slate-200 text-slate-700 hover:bg-white text-xs font-semibold rounded-lg shadow-2xs transition">
              Đổi ảnh từ máy
            </button>
            <button type="button" id="vsOpenCameraFromResultsBtn" class="w-full py-2 px-3 bg-blue-50 border border-blue-200 text-blue-700 hover:bg-blue-100 text-xs font-semibold rounded-lg shadow-2xs transition">
              Chụp ảnh qua Camera
            </button>
          </div>
          <div class="mt-4 pt-3 border-t border-slate-200 w-full text-center">
            <p class="text-[10px] text-slate-400">Mẹo: Bạn có thể nhấn <strong>Ctrl + V</strong> ở bất kỳ đâu để dán ảnh tìm kiếm nhanh!</p>
          </div>
        </div>

        <!-- Cột phải: Bộ lọc kết hợp (Hybrid Search) & Danh sách sản phẩm -->
        <div class="md:col-span-8 flex flex-col">
          <!-- BỘ LỌC HYBRID KẾT HỢP (TỈNH/THÀNH, GIÁ, SẮP XẾP) -->
          <div class="grid grid-cols-1 sm:grid-cols-3 gap-2 mb-3 bg-slate-50 p-2.5 rounded-lg border border-slate-200 text-xs">
            <div>
              <label class="block text-[10px] font-bold text-slate-500 mb-1">Tỉnh / Thành phố:</label>
              <select id="vsProvinceFilter" class="w-full bg-white border border-slate-300 rounded px-2 py-1 text-slate-700 font-medium focus:ring-1 focus:ring-blue-500 cursor-pointer">
                <option value="all">Toàn quốc</option>
              </select>
            </div>
            <div>
              <label class="block text-[10px] font-bold text-slate-500 mb-1">Khoảng giá:</label>
              <select id="vsPriceFilter" class="w-full bg-white border border-slate-300 rounded px-2 py-1 text-slate-700 font-medium focus:ring-1 focus:ring-blue-500 cursor-pointer">
                <option value="all">Tất cả mức giá</option>
                <option value="0-500000">Dưới 500.000 đ</option>
                <option value="500000-2000000">500.000 đ - 2 triệu</option>
                <option value="2000000-5000000">2 triệu - 5 triệu</option>
                <option value="5000000-10000000">5 triệu - 10 triệu</option>
                <option value="10000000-999999999">Trên 10 triệu</option>
              </select>
            </div>
            <div>
              <label class="block text-[10px] font-bold text-slate-500 mb-1">Sắp xếp:</label>
              <select id="vsSortFilter" class="w-full bg-white border border-slate-300 rounded px-2 py-1 text-slate-700 font-medium focus:ring-1 focus:ring-blue-500 cursor-pointer">
                <option value="relevance">Độ khớp cao nhất</option>
                <option value="price_asc">Giá tăng dần</option>
                <option value="price_desc">Giá giảm dần</option>
              </select>
            </div>
          </div>

          <div class="flex items-center justify-between mb-2">
            <div class="flex items-center gap-2 flex-wrap">
              <h4 class="text-xs font-bold text-slate-800">
                Sản phẩm tương đồng: <span id="vsCountText" class="text-blue-600">0</span>
              </h4>
            </div>
          </div>

          <div id="vsProductList" class="grid grid-cols-1 sm:grid-cols-2 gap-3 max-h-[460px] overflow-y-auto pr-1">
            <!-- Render bằng JavaScript -->
          </div>

          <div id="vsEmptyList" class="hidden py-8 px-4 text-center">
            <div class="w-12 h-12 mx-auto mb-2 rounded-full bg-amber-50 text-amber-500 flex items-center justify-center border border-amber-200">
              <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.8" d="M9.172 16.172a4 4 0 015.656 0M9 10h.01M15 10h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
            </div>
            <h4 class="text-xs font-bold text-slate-800 mb-1">Chưa có sản phẩm trùng khớp chính xác</h4>
            <p class="text-[11px] text-slate-500 max-w-sm mx-auto mb-4 leading-relaxed">
             Hệ thống đã đối sánh đặc trưng hình ảnh nhưng các tin đăng hiện có trong kho không đạt chuẩn tương đồng (hệ thống tự động loại bỏ các sản phẩm lệch chủng loại).
            </p>
            <div class="flex items-center justify-center">
              <button type="button" onclick="document.getElementById('vsChangeImgBtn').click()" class="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white text-xs font-semibold rounded-lg shadow-2xs transition">
                Thử ảnh khác
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>

<script>
  (function() {
    const triggerBtn = document.getElementById('visualSearchTriggerBtn');
    const fileInput = document.getElementById('visualSearchFileInput');
    const modal = document.getElementById('visualSearchModal');
    const closeBtn = document.getElementById('closeVisualSearchModal');
    const changeImgBtn = document.getElementById('vsChangeImgBtn');
    const retryBtn = document.getElementById('vsRetryBtn');
    const previewImg = document.getElementById('vsPreviewImg');

    const loadingState = document.getElementById('vsLoadingState');
    const errorState = document.getElementById('vsErrorState');
    const resultState = document.getElementById('vsResultState');
    const cameraState = document.getElementById('vsCameraState');
    const errorMessage = document.getElementById('vsErrorMessage');
    const countText = document.getElementById('vsCountText');
    const intentBadge = document.getElementById('vsIntentBadge');
    const intentText = document.getElementById('vsIntentText');
    const productList = document.getElementById('vsProductList');
    const emptyList = document.getElementById('vsEmptyList');

    // Camera elements
    const cameraVideo = document.getElementById('vsCameraVideo');
    const cameraCanvas = document.getElementById('vsCameraCanvas');
    const captureBtn = document.getElementById('vsCaptureBtn');
    const switchCameraBtn = document.getElementById('vsSwitchCameraBtn');
    const closeCameraBtn = document.getElementById('vsCloseCameraBtn');
    const openCameraFromResultsBtn = document.getElementById('vsOpenCameraFromResultsBtn');
    const openCameraFromErrorBtn = document.getElementById('vsOpenCameraFromErrorBtn');

    // Filter elements
    const provinceFilter = document.getElementById('vsProvinceFilter');
    const priceFilter = document.getElementById('vsPriceFilter');
    const sortFilter = document.getElementById('vsSortFilter');

    // Tự động tải tất cả 63 tỉnh/thành phố từ API giống như trong trang Đăng tin
    const FALLBACK_PROVINCES = [
      'Thành phố Hà Nội', 'Thành phố Hồ Chí Minh', 'Thành phố Đà Nẵng', 'Thành phố Hải Phòng', 'Thành phố Cần Thơ',
      'Thành phố Huế', 'Tỉnh An Giang', 'Tỉnh Bà Rịa - Vũng Tàu', 'Tỉnh Bắc Giang', 'Tỉnh Bắc Kạn', 'Tỉnh Bạc Liêu',
      'Tỉnh Bắc Ninh', 'Tỉnh Bến Tre', 'Tỉnh Bình Định', 'Tỉnh Bình Dương', 'Tỉnh Bình Phước', 'Tỉnh Bình Thuận',
      'Tỉnh Cà Mau', 'Tỉnh Cao Bằng', 'Tỉnh Đắk Lắk', 'Tỉnh Đắk Nông', 'Tỉnh Điện Biên', 'Tỉnh Đồng Nai',
      'Tỉnh Đồng Tháp', 'Tỉnh Gia Lai', 'Tỉnh Hà Giang', 'Tỉnh Hà Nam', 'Tỉnh Hà Tĩnh', 'Tỉnh Hải Dương',
      'Tỉnh Hậu Giang', 'Tỉnh Hòa Bình', 'Tỉnh Hưng Yên', 'Tỉnh Khánh Hòa', 'Tỉnh Kiên Giang', 'Tỉnh Kon Tum',
      'Tỉnh Lai Châu', 'Tỉnh Lâm Đồng', 'Tỉnh Lạng Sơn', 'Tỉnh Lào Cai', 'Tỉnh Long An', 'Tỉnh Nam Định',
      'Tỉnh Nghệ An', 'Tỉnh Ninh Bình', 'Tỉnh Ninh Thuận', 'Tỉnh Phú Thọ', 'Tỉnh Phú Yên', 'Tỉnh Quảng Bình',
      'Tỉnh Quảng Nam', 'Tỉnh Quảng Ngãi', 'Tỉnh Quảng Ninh', 'Tỉnh Quảng Trị', 'Tỉnh Sóc Trăng', 'Tỉnh Sơn La',
      'Tỉnh Tây Ninh', 'Tỉnh Thái Bình', 'Tỉnh Thái Nguyên', 'Tỉnh Thanh Hóa', 'Tỉnh Trà Vinh', 'Tỉnh Tuyên Quang',
      'Tỉnh Vĩnh Long', 'Tỉnh Vĩnh Phúc', 'Tỉnh Yên Bái'
    ];

    async function loadVisualSearchProvinces() {
      if (!provinceFilter) return;
      try {
        const response = await fetch('https://provinces.open-api.vn/api/v2/p/');
        if (!response.ok) throw new Error('Không tải được tỉnh/thành');
        const provinces = await response.json();
        const currentVal = provinceFilter.value || 'all';
        provinceFilter.innerHTML = '<option value="all">Toàn quốc</option>';
        provinces.forEach((item) => {
          const option = new Option(item.name, item.name);
          option.dataset.code = item.code;
          provinceFilter.add(option);
        });
        if (currentVal && [...provinceFilter.options].some(o => o.value === currentVal)) {
          provinceFilter.value = currentVal;
        }
      } catch (error) {
        if (provinceFilter.options.length <= 1) {
          provinceFilter.innerHTML = '<option value="all">Toàn quốc</option>';
          FALLBACK_PROVINCES.forEach(name => provinceFilter.add(new Option(name, name)));
        }
      }
    }
    loadVisualSearchProvinces();

    let currentSearchFile = null;
    let cameraStream = null;
    let currentFacingMode = 'environment'; // Ưu tiên camera sau trên điện thoại

    if (!triggerBtn || !fileInput) return;

    // 1. Mở modal & chọn file
    triggerBtn.addEventListener('click', () => fileInput.click());
    changeImgBtn?.addEventListener('click', () => fileInput.click());
    retryBtn?.addEventListener('click', () => fileInput.click());

    closeBtn?.addEventListener('click', () => {
      closeCamera();
      modal.classList.add('hidden');
    });

    modal?.addEventListener('click', (e) => {
      if (e.target === modal) {
        closeCamera();
        modal.classList.add('hidden');
      }
    });

    // 2. Kéo & Thả ảnh (Drag & Drop)
    const searchForm = document.getElementById('searchForm');
    if (searchForm) {
      ['dragenter', 'dragover'].forEach(evtName => {
        searchForm.addEventListener(evtName, (e) => {
          e.preventDefault();
          e.stopPropagation();
          searchForm.classList.add('ring-2', 'ring-blue-500', 'bg-blue-50/50');
        });
      });

      ['dragleave', 'drop'].forEach(evtName => {
        searchForm.addEventListener(evtName, (e) => {
          e.preventDefault();
          e.stopPropagation();
          searchForm.classList.remove('ring-2', 'ring-blue-500', 'bg-blue-50/50');
        });
      });

      searchForm.addEventListener('drop', (e) => {
        if (e.dataTransfer && e.dataTransfer.files && e.dataTransfer.files.length > 0) {
          const file = e.dataTransfer.files[0];
          if (file.type.startsWith('image/')) {
            executeVisualSearch(file);
          }
        }
      });
    }

    // Modal cũng hỗ trợ kéo thả ảnh vào
    modal.addEventListener('dragover', (e) => e.preventDefault());
    modal.addEventListener('drop', (e) => {
      e.preventDefault();
      if (e.dataTransfer && e.dataTransfer.files && e.dataTransfer.files.length > 0) {
        const file = e.dataTransfer.files[0];
        if (file.type.startsWith('image/')) {
          closeCamera();
          executeVisualSearch(file);
        }
      }
    });

    // 3. Dán ảnh từ Clipboard (Ctrl + V)
    window.addEventListener('paste', (e) => {
      // Tránh can thiệp khi người dùng đang gõ text vào input/textarea thông thường
      const activeTag = document.activeElement ? document.activeElement.tagName.toLowerCase() : '';
      if ((activeTag === 'input' || activeTag === 'textarea') && (!e.clipboardData || !e.clipboardData.files || e.clipboardData.files.length === 0)) {
        return;
      }

      if (e.clipboardData && e.clipboardData.items) {
        for (let i = 0; i < e.clipboardData.items.length; i++) {
          const item = e.clipboardData.items[i];
          if (item.type.indexOf('image') !== -1) {
            const blob = item.getAsFile();
            if (blob) {
              e.preventDefault();
              closeCamera();
              executeVisualSearch(blob);
              break;
            }
          }
        }
      }
    });

    // 4. Khi người dùng chọn file từ Input
    fileInput.addEventListener('change', () => {
      if (!fileInput.files || fileInput.files.length === 0) return;
      const file = fileInput.files[0];
      executeVisualSearch(file);
    });

    // 5. Chụp ảnh từ Camera / Webcam
    function startCamera() {
      loadingState.classList.add('hidden');
      errorState.classList.add('hidden');
      resultState.classList.add('hidden');
      cameraState.classList.remove('hidden');
      modal.classList.remove('hidden');

      if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
        navigator.mediaDevices.getUserMedia({
          video: { facingMode: currentFacingMode, width: { ideal: 1280 }, height: { ideal: 720 } }
        }).then(stream => {
          cameraStream = stream;
          cameraVideo.srcObject = stream;
        }).catch(err => {
          console.error("Lỗi mở camera:", err);
          cameraState.classList.add('hidden');
          errorState.classList.remove('hidden');
          errorMessage.textContent = "Không thể truy cập camera. Vui lòng cấp quyền cho trình duyệt.";
        });
      } else {
        cameraState.classList.add('hidden');
        errorState.classList.remove('hidden');
        errorMessage.textContent = "Thiết bị hoặc trình duyệt không hỗ trợ camera.";
      }
    }

    function closeCamera() {
      if (cameraStream) {
        cameraStream.getTracks().forEach(track => track.stop());
        cameraStream = null;
      }
      cameraState.classList.add('hidden');
    }

    openCameraFromResultsBtn?.addEventListener('click', startCamera);
    openCameraFromErrorBtn?.addEventListener('click', startCamera);

    closeCameraBtn?.addEventListener('click', () => {
      closeCamera();
      if (currentSearchFile) {
        resultState.classList.remove('hidden');
      } else {
        modal.classList.add('hidden');
      }
    });

    switchCameraBtn?.addEventListener('click', () => {
      currentFacingMode = currentFacingMode === 'user' ? 'environment' : 'user';
      closeCamera();
      startCamera();
    });

    captureBtn?.addEventListener('click', () => {
      if (!cameraVideo) return;
      const width = cameraVideo.videoWidth || 640;
      const height = cameraVideo.videoHeight || 480;
      cameraCanvas.width = width;
      cameraCanvas.height = height;
      const ctx = cameraCanvas.getContext('2d');
      ctx.drawImage(cameraVideo, 0, 0, width, height);

      cameraCanvas.toBlob(blob => {
        closeCamera();
        if (blob) {
          executeVisualSearch(blob);
        }
      }, 'image/jpeg', 0.9);
    });

    // 6. Thực thi tìm kiếm bằng hình ảnh (kèm bộ lọc Hybrid)
    function executeVisualSearch(file) {
      currentSearchFile = file;

      // Preview ảnh
      const reader = new FileReader();
      reader.onload = (e) => {
        previewImg.src = e.target.result;
      };
      reader.readAsDataURL(file);

      // Mở modal & chuyển sang trạng thái Loading
      modal.classList.remove('hidden');
      loadingState.classList.remove('hidden');
      errorState.classList.add('hidden');
      resultState.classList.add('hidden');
      cameraState.classList.add('hidden');

      // Đọc bộ lọc
      const province = provinceFilter ? provinceFilter.value : 'all';
      const priceRange = priceFilter ? priceFilter.value : 'all';
      const sort = sortFilter ? sortFilter.value : 'relevance';

      let minPrice = '';
      let maxPrice = '';
      if (priceRange !== 'all') {
        const parts = priceRange.split('-');
        if (parts.length === 2) {
          minPrice = parts[0];
          maxPrice = parts[1];
        }
      }

      // Gửi AJAX lên /visual-search
      const formData = new FormData();
      formData.append('searchImage', file, 'query_image.jpg');
      if (province && province !== 'all') formData.append('province', province);
      if (minPrice) formData.append('minPrice', minPrice);
      if (maxPrice) formData.append('maxPrice', maxPrice);
      if (sort) formData.append('sort', sort);

      fetch('${pageContext.request.contextPath}/visual-search', {
        method: 'POST',
        body: formData
      })
      .then(async res => {
        const data = await res.json();
        if (!res.ok) {
          throw new Error(data.message || 'Lỗi xử lý hình ảnh');
        }
        return data;
      })
      .then(data => {
        loadingState.classList.add('hidden');
        resultState.classList.remove('hidden');

        if (intentBadge && intentText) {
          if (data.predicted_intent_name && data.predicted_intent_name !== 'Sản phẩm khác') {
            intentBadge.classList.remove('hidden');
            intentText.textContent = data.predicted_intent_name;
          } else {
            intentBadge.classList.add('hidden');
          }
        }

        renderVisualResults(data.products || []);
      })
      .catch(err => {
        loadingState.classList.add('hidden');
        errorState.classList.remove('hidden');
        errorMessage.textContent = err.message || 'Không thể kết nối đến hệ thống';
      })
      .finally(() => {
        fileInput.value = '';
      });
    }

    // Khi người dùng thay đổi bộ lọc Hybrid trên modal
    [provinceFilter, priceFilter, sortFilter].forEach(el => {
      el?.addEventListener('change', () => {
        if (currentSearchFile) {
          executeVisualSearch(currentSearchFile);
        }
      });
    });

    // 7. Render danh sách sản phẩm kết quả
    function renderVisualResults(products) {
      productList.innerHTML = '';
      countText.textContent = products.length;

      if (products.length === 0) {
        emptyList.classList.remove('hidden');
        return;
      }
      emptyList.classList.add('hidden');

      products.forEach(p => {
        const card = document.createElement('div');
        card.className = 'flex gap-3 p-2.5 bg-white border border-slate-200 rounded-xl hover:border-blue-400 hover:shadow-sm transition group cursor-pointer';
        card.onclick = () => window.location.href = 'product-detail?id=' + p.id;

        const priceFormatted = new Intl.NumberFormat('vi-VN').format(p.price) + ' đ';
        const imgPath = p.image ? p.image : 'assets/images/no-image.png';

        let badgeColor = 'bg-emerald-100 text-emerald-800 border-emerald-200';
        if (p.similarity_percent < 70) {
          badgeColor = 'bg-blue-100 text-blue-800 border-blue-200';
        }

        card.innerHTML = `
          <div class="w-20 h-20 rounded-lg overflow-hidden bg-slate-100 shrink-0 relative">
            <img src="\${imgPath}" alt="\${escapeHtml(p.title)}" class="w-full h-full object-cover group-hover:scale-105 transition duration-300">
          </div>
          <div class="flex-1 min-w-0 flex flex-col justify-between">
            <div>
              <a href="product-detail?id=\${p.id}" class="text-xs font-bold text-slate-900 hover:text-blue-600 line-clamp-1 transition">
                \${escapeHtml(p.title)}
              </a>
              <div class="text-xs font-extrabold text-blue-600 mt-0.5">\${priceFormatted}</div>
              <div class="text-[10px] text-slate-500 mt-0.5 truncate">\${escapeHtml(p.province || 'Toàn quốc')}</div>
            </div>
            <div class="flex items-center justify-between text-[11px] font-semibold text-blue-600 group-hover:text-blue-700 mt-1">
              <span>Xem chi tiết</span>
              <span>&rarr;</span>
            </div>
          </div>
        `;
        productList.appendChild(card);
      });
    }

    function escapeHtml(text) {
      if (!text) return '';
      return text.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
    }
  })();
</script>


<script>
  if (window.lucide) {
    window.lucide.createIcons();
  }
</script>
