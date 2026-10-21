<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%@ page import="dao.OrderDAO" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
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
                class="w-full pl-4 pr-24 py-2 bg-slate-100 border border-slate-200 rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-blue-500 focus:bg-white transition"
        >
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

      <a href="04-chat-tra-gia-vietqr.jsp" class="flex items-center gap-1.5 px-2.5 py-1.5 text-xs font-semibold text-slate-600 hover:text-slate-900 hover:bg-slate-100 rounded-lg transition relative">
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"/></svg>
        Tin nhắn
        <span class="absolute top-1 right-1 w-1.5 h-1.5 rounded-full bg-red-500"></span>
      </a>

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
    const btn = document.getElementById('userMenuBtn');
    const isHidden = dropdown.classList.contains('hidden');
    dropdown.classList.toggle('hidden', !isHidden);
    btn.setAttribute('aria-expanded', String(isHidden));
  }
  document.addEventListener('click', function(e) {
    const wrapper = document.getElementById('userMenuWrapper');
    if (wrapper && !wrapper.contains(e.target)) {
      document.getElementById('userMenuDropdown').classList.add('hidden');
      document.getElementById('userMenuBtn').setAttribute('aria-expanded', 'false');
    }
  });
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
