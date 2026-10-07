<%@ page contentType="text/html;charset=UTF-8" language="java" %>
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

  private String js(String value) {
    if (value == null) {
      return "";
    }
    return value
            .replace("\\", "\\\\")
            .replace("'", "\\'")
            .replace("\r", "")
            .replace("\n", "\\n");
  }
%>
<%
  String loginError = (String) request.getAttribute("loginError");
  String registerError = (String) request.getAttribute("registerError");
  String forgotError = (String) request.getAttribute("forgotError");
  String authMessage = (String) session.getAttribute("authMessage");
  String activeAuthTab = (String) request.getAttribute("activeAuthTab");
  String accountValue = request.getAttribute("accountValue") != null ? (String) request.getAttribute("accountValue") : "";
  String registerNameValue = request.getAttribute("registerNameValue") != null ? (String) request.getAttribute("registerNameValue") : "";
  String registerEmailValue = request.getAttribute("registerEmailValue") != null ? (String) request.getAttribute("registerEmailValue") : "";
  String forgotEmailValue = request.getAttribute("forgotEmailValue") != null ? (String) request.getAttribute("forgotEmailValue") : "";
  boolean showRegisterOtp = Boolean.TRUE.equals(request.getAttribute("showRegisterOtp")) || session.getAttribute("registerOtpEmail") != null;
  boolean hasPendingRegisterPassword = session.getAttribute("pendingRegisterPassword") != null;
  boolean showResetPasswordForm = Boolean.TRUE.equals(request.getAttribute("showResetPasswordForm")) || session.getAttribute("resetOtpEmail") != null;
  if (forgotEmailValue.isEmpty() && session.getAttribute("resetOtpEmail") != null) {
    forgotEmailValue = (String) session.getAttribute("resetOtpEmail");
  }
  if (authMessage != null) {
    session.removeAttribute("authMessage");
  }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Đăng Nhập & Đăng Ký Tài Khoản - MuaNgay</title>
  <link rel="icon" type="image/svg+xml" href="assets/logos/muangay-logo-icon.svg">
  <script src="https://cdn.tailwindcss.com"></script>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="css/style.css">
  <link rel="stylesheet" href="css/07-dang-nhap-xac-thuc.css">
</head>
<body class="bg-slate-50 text-slate-900 min-h-screen flex flex-col">

  <!-- THANH ĐIỀU HƯỚNG CHÍNH (HEADER) -->
  <jsp:include page="includes/header.jsp" />

  <!-- NỘI DUNG CHÍNH: KHUNG ĐĂNG NHẬP / ĐĂNG KÝ VỚI TABS CHUYỂN ĐỔI -->
  <main class="max-w-md mx-auto px-4 py-10 flex-1 w-full flex flex-col justify-center">
    
    <div class="bg-white rounded-xl border border-slate-200 shadow-sm p-6 sm:p-8 space-y-6">
      
      <!-- TIÊU ĐỀ & TABS CHUYỂN ĐỔI GIỮA ĐĂNG NHẬP VÀ ĐĂNG KÝ -->
      <div class="text-center space-y-1.5">
        <h1 id="authTitle" class="text-xl font-bold text-slate-900">Đăng Nhập Tài Khoản</h1>
        <p id="authSubtitle" class="text-xs text-slate-500">Đăng nhập để nhắn tin, đặt cọc giữ chỗ và quản lý đồ bán</p>
      </div>

      <!-- TABS CHỌN ĐĂNG NHẬP HOẶC ĐĂNG KÝ -->
      <div class="flex p-1 bg-slate-100 rounded-lg text-xs font-bold">
        <button id="tabLogin" onclick="switchAuthTab('login')" class="flex-1 py-2 rounded-md bg-white text-slate-900 shadow-xs transition">
          Đăng Nhập
        </button>
        <button id="tabRegister" onclick="switchAuthTab('register')" class="flex-1 py-2 rounded-md text-slate-600 hover:text-slate-900 transition">
          Tạo Tài Khoản Mới
        </button>
      </div>

      <!-- ĐĂNG NHẬP NHANH BẰNG GOOGLE (OAUTH 1 CHẠM) -->
      <div class="space-y-3">
        <a href="${pageContext.request.contextPath}/login-google" class="w-full py-2.5 px-4 bg-white border border-slate-300 hover:bg-slate-50 text-slate-800 text-xs font-bold rounded-lg flex items-center justify-center gap-2 transition shadow-xs">
          <svg class="w-4 h-4" viewBox="0 0 24 24">
            <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
            <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
            <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l2.85-2.22.81-.63z"/>
            <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.84c.87-2.6 3.3-4.52 6.16-4.52z"/>
          </svg>
          <span>Đăng nhập 1 chạm với tài khoản Google</span>
        </a>

        <div class="relative flex items-center justify-center">
          <div class="border-t border-slate-200 w-full"></div>
          <span class="bg-white px-3 text-[11px] text-slate-400 absolute">hoặc dùng Email / Số điện thoại</span>
        </div>
      </div>

      <!-- FORM 1: ĐĂNG NHẬP -->
      <form id="loginForm" action="${pageContext.request.contextPath}/login" method="post" class="space-y-4 text-xs">
        <% if (loginError != null) { %>
          <div class="p-3 bg-red-50 border border-red-200 text-red-700 rounded-lg text-[11px] font-semibold"><%= h(loginError) %></div>
        <% } %>
        <div>
          <label class="block font-bold text-slate-700 mb-1">Email hoặc Số điện thoại:</label>
          <input 
            type="text" 
            id="loginAccount" 
            name="account"
            value="<%= h(accountValue) %>" 
            required 
            placeholder="Ví dụ: 0988123456 hoặc email của bạn"
            class="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-300 rounded-lg text-xs font-medium focus:bg-white focus:outline-none focus:ring-2 focus:ring-blue-500"
          >
        </div>

        <div>
          <div class="flex items-center justify-between mb-1">
            <label class="font-bold text-slate-700">Mật khẩu:</label>
            <a href="javascript:void(0)" onclick="openForgotPasswordModal()" class="text-blue-600 hover:underline text-[11px] font-semibold">
              Quên mật khẩu?
            </a>
          </div>
          <div class="relative">
            <input 
              type="password" 
              id="loginPassword" 
              name="password"
              required 
              class="w-full pl-3.5 pr-10 py-2.5 bg-slate-50 border border-slate-300 rounded-lg text-xs font-medium focus:bg-white focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
            <button type="button" class="password-toggle" onclick="togglePasswordVisibility(this)" aria-label="Hiện mật khẩu">
              <i class="fa-solid fa-eye"></i>
            </button>
          </div>
        </div>

        <div class="flex items-center gap-2">
          <input type="checkbox" id="rememberMe" checked class="rounded border-slate-300 text-blue-600">
          <label for="rememberMe" class="text-slate-600 cursor-pointer">Ghi nhớ đăng nhập trên thiết bị này</label>
        </div>

        <button type="submit" class="w-full py-2.5 bg-blue-600 hover:bg-blue-700 text-white font-bold text-xs rounded-lg shadow-sm transition">
          ĐĂNG NHẬP VÀO SÀN
        </button>
      </form>

      <!-- FORM 2: ĐĂNG KÝ CÓ MÃ XÁC THỰC OTP -->
      <form id="registerForm" action="${pageContext.request.contextPath}/signup" method="post" class="space-y-3.5 text-xs hidden">
        <input type="hidden" id="registerAction" name="action" value="register">
        <% if (registerError != null) { %>
          <div class="p-3 bg-red-50 border border-red-200 text-red-700 rounded-lg text-[11px] font-semibold"><%= h(registerError) %></div>
        <% } %>
        <div>
          <label class="block font-bold text-slate-700 mb-1">Họ và tên của bạn:</label>
          <input 
            type="text" 
            id="regFullName" 
            name="fullName"
            value="<%= h(registerNameValue) %>"
            placeholder="Ví dụ: Trần Văn Nam" 
            required
            class="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-300 rounded-lg text-xs font-medium focus:bg-white focus:outline-none focus:ring-2 focus:ring-blue-500"
          >
        </div>

        <div>
          <label class="block font-bold text-slate-700 mb-1">Email nhận mã xác thực:</label>
          <div class="flex gap-2">
            <input 
              type="email" 
              id="regEmail" 
              name="email"
              value="<%= h(registerEmailValue) %>"
              placeholder="name@gmail.com" 
              required
              class="flex-1 px-3.5 py-2.5 bg-slate-50 border border-slate-300 rounded-lg text-xs font-medium focus:bg-white focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
            <button type="button" onclick="sendOtpCode()" id="btnSendOtp" class="px-3 py-2.5 bg-slate-100 hover:bg-slate-200 border border-slate-300 text-slate-700 font-bold rounded-lg text-[11px] whitespace-nowrap transition">
              <%= showRegisterOtp ? "Gửi Lại OTP" : "Gửi Mã OTP" %>
            </button>
          </div>
        </div>

        <!-- Ô NHẬP MÃ OTP 6 SỐ -->
        <div id="otpInputGroup" class="p-3 bg-blue-50 border border-blue-200 rounded-lg space-y-1.5 <%= showRegisterOtp ? "" : "hidden" %>">
          <label class="block font-bold text-blue-900 text-[11px]">Nhập mã OTP 6 số vừa gửi vào email:</label>
          <div class="flex gap-1.5">
            <input type="text" maxlength="6" id="otpValue" name="otp" placeholder="123456" class="w-full p-2 text-center text-sm font-mono tracking-widest font-black bg-white border border-blue-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500">
          </div>
          <span class="text-[10px] text-blue-700 block">Mã có hiệu lực trong 5 phút. Hãy kiểm tra cả hộp thư Spam.</span>
        </div>

        <div>
          <label class="block font-bold text-slate-700 mb-1">Mật khẩu mới:</label>
          <div class="relative">
            <input 
              type="password" 
              id="regPassword" 
              name="password"
              placeholder="<%= showRegisterOtp && hasPendingRegisterPassword ? "Mật khẩu đã được lưu, không cần nhập lại" : "Ít nhất 8 ký tự, có hoa/thường/số/ký tự đặc biệt" %>" 
              <%= showRegisterOtp && hasPendingRegisterPassword ? "" : "required" %>
              class="w-full pl-3.5 pr-10 py-2.5 bg-slate-50 border border-slate-300 rounded-lg text-xs font-medium focus:bg-white focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
            <button type="button" class="password-toggle" onclick="togglePasswordVisibility(this)" aria-label="Hiện mật khẩu">
              <i class="fa-solid fa-eye"></i>
            </button>
          </div>
        </div>

        <div class="flex items-start gap-2">
          <input type="checkbox" id="agreeTerms" required checked class="mt-0.5 rounded border-slate-300 text-blue-600">
          <label for="agreeTerms" class="text-slate-600 text-[11px] leading-tight">
            Tôi đồng ý với Quy chế hoạt động và Điều khoản bảo vệ tiền cọc của sàn MuaNgay.
          </label>
        </div>

        <button type="submit" class="w-full py-2.5 bg-blue-600 hover:bg-blue-700 text-white font-bold text-xs rounded-lg shadow-sm transition">
          XÁC THỰC VÀ TẠO TÀI KHOẢN
        </button>
      </form>

    </div>

  </main>

  <!-- MODAL QUÊN MẬT KHẨU -->
  <div id="forgotPasswordModal" class="fixed inset-0 bg-slate-900/60 z-50 hidden flex items-center justify-center p-4">
    <form action="${pageContext.request.contextPath}/forgot-password" method="post" class="bg-white rounded-xl max-w-sm w-full p-6 shadow-2xl space-y-4">
      <input type="hidden" name="action" value="<%= showResetPasswordForm ? "reset" : "sendOtp" %>">
      <div class="flex items-center justify-between border-b border-slate-100 pb-3">
        <h3 class="font-bold text-slate-900 text-sm">Lấy Lại Mật Khẩu</h3>
        <button type="button" onclick="closeForgotPasswordModal()" class="text-slate-400 hover:text-slate-600 font-bold text-lg px-2">X</button>
      </div>

      <div class="space-y-3 text-xs">
        <% if (forgotError != null) { %>
          <div class="p-3 bg-red-50 border border-red-200 text-red-700 rounded-lg text-[11px] font-semibold"><%= h(forgotError) %></div>
        <% } %>
        <p class="text-slate-600 leading-relaxed">
          <%= showResetPasswordForm
                  ? "Nhập mã OTP trong email và mật khẩu mới để hoàn tất đặt lại mật khẩu."
                  : "Nhập địa chỉ email đăng ký tài khoản của bạn. MuaNgay sẽ gửi mã OTP đặt lại mật khẩu." %>
        </p>
        <div>
          <label class="block font-bold text-slate-700 mb-1">Email của bạn:</label>
          <input type="email" id="forgotEmailInput" name="email" value="<%= h(forgotEmailValue) %>" class="w-full p-2.5 border border-slate-300 rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-blue-500">
        </div>
        <% if (showResetPasswordForm) { %>
          <div>
            <label class="block font-bold text-slate-700 mb-1">Mã OTP:</label>
            <input type="text" maxlength="6" name="otp" class="w-full p-2.5 text-center font-mono tracking-widest border border-slate-300 rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-blue-500">
          </div>
          <div>
            <label class="block font-bold text-slate-700 mb-1">Mật khẩu mới:</label>
            <div class="relative">
              <input type="password" name="password" autocomplete="new-password" required placeholder="Ít nhất 8 ký tự, có hoa/thường/số/ký tự đặc biệt" class="w-full pl-2.5 pr-10 py-2.5 border border-slate-300 rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-blue-500">
              <button type="button" class="password-toggle" onclick="togglePasswordVisibility(this)" aria-label="Hiện mật khẩu">
                <i class="fa-solid fa-eye"></i>
              </button>
            </div>
          </div>
          <div>
            <label class="block font-bold text-slate-700 mb-1">Nhập lại mật khẩu mới:</label>
            <div class="relative">
              <input type="password" name="confirmPassword" autocomplete="new-password" required class="w-full pl-2.5 pr-10 py-2.5 border border-slate-300 rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-blue-500">
              <button type="button" class="password-toggle" onclick="togglePasswordVisibility(this)" aria-label="Hiện mật khẩu">
                <i class="fa-solid fa-eye"></i>
              </button>
            </div>
          </div>
        <% } %>
      </div>

      <div class="pt-2 flex gap-2">
        <button type="button" onclick="closeForgotPasswordModal()" class="flex-1 py-2 border border-slate-300 rounded-lg text-xs font-semibold hover:bg-slate-100">
          Hủy
        </button>
        <button type="submit" class="flex-1 py-2 bg-blue-600 hover:bg-blue-700 font-bold text-xs text-white rounded-lg transition">
          <%= showResetPasswordForm ? "Đổi Mật Khẩu" : "Gửi OTP" %>
        </button>
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
    function switchAuthTab(type) {
      const tabLogin = document.getElementById('tabLogin');
      const tabRegister = document.getElementById('tabRegister');
      const loginForm = document.getElementById('loginForm');
      const registerForm = document.getElementById('registerForm');
      const title = document.getElementById('authTitle');
      const subtitle = document.getElementById('authSubtitle');

      if (type === 'login') {
        tabLogin.className = 'flex-1 py-2 rounded-md bg-white text-slate-900 shadow-xs transition';
        tabRegister.className = 'flex-1 py-2 rounded-md text-slate-600 hover:text-slate-900 transition';
        loginForm.classList.remove('hidden');
        registerForm.classList.add('hidden');
        title.textContent = 'Đăng Nhập Tài Khoản';
        subtitle.textContent = 'Đăng nhập để nhắn tin, đặt cọc giữ chỗ và quản lý đồ bán';
      } else {
        tabRegister.className = 'flex-1 py-2 rounded-md bg-white text-slate-900 shadow-xs transition';
        tabLogin.className = 'flex-1 py-2 rounded-md text-slate-600 hover:text-slate-900 transition';
        registerForm.classList.remove('hidden');
        loginForm.classList.add('hidden');
        title.textContent = 'Tạo Tài Khoản Mới';
        subtitle.textContent = 'Đăng ký nhanh với mã OTP gửi về email trong 30 giây';
      }
    }

    function sendOtpCode() {
      const email = document.getElementById('regEmail').value.trim();
      const fullName = document.getElementById('regFullName').value.trim();
      const password = document.getElementById('regPassword').value.trim();
      const otpInputGroup = document.getElementById('otpInputGroup');
      const isOtpStep = !otpInputGroup.classList.contains('hidden');
      const registerAction = document.getElementById('registerAction');
      if (!email) {
        showToast('Vui lòng nhập địa chỉ email trước khi nhận mã OTP.');
        return;
      }
      if (!fullName || (!password && !isOtpStep)) {
        showToast('Vui lòng nhập đầy đủ họ tên và mật khẩu trước khi gửi OTP.');
        return;
      }
      registerAction.value = 'sendOtp';
      document.getElementById('registerForm').submit();
    }

    function openForgotPasswordModal() {
      document.getElementById('forgotPasswordModal').classList.remove('hidden');
    }
    function closeForgotPasswordModal() {
      document.getElementById('forgotPasswordModal').classList.add('hidden');
    }
    function togglePasswordVisibility(button) {
      const input = button.parentElement.querySelector('input');
      const icon = button.querySelector('i');
      const shouldShow = input.type === 'password';

      input.type = shouldShow ? 'text' : 'password';
      icon.className = shouldShow ? 'fa-solid fa-eye-slash' : 'fa-solid fa-eye';
      button.setAttribute('aria-label', shouldShow ? 'Ẩn mật khẩu' : 'Hiện mật khẩu');
    }
    function showToast(msg) {
      const toast = document.getElementById('toastNotification');
      document.getElementById('toastMsg').textContent = msg;
      toast.classList.remove('hidden');
      setTimeout(() => {
        toast.classList.add('hidden');
      }, 3500);
    }

    window.addEventListener('DOMContentLoaded', () => {
      <% if ("register".equals(activeAuthTab)) { %>
        switchAuthTab('register');
      <% } %>
      <% if (forgotError != null || showResetPasswordForm) { %>
        openForgotPasswordModal();
      <% } %>
      <% if (authMessage != null) { %>
        showToast('<%= js(authMessage) %>');
      <% } %>
    });
  </script>
</body>
</html>
