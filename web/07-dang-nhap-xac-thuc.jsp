<%@ page contentType="text/html;charset=UTF-8" language="java" %>
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
        <button onclick="simulateGoogleLogin()" class="w-full py-2.5 px-4 bg-white border border-slate-300 hover:bg-slate-50 text-slate-800 text-xs font-bold rounded-lg flex items-center justify-center gap-2 transition shadow-xs">
          <svg class="w-4 h-4" viewBox="0 0 24 24">
            <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
            <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
            <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l2.85-2.22.81-.63z"/>
            <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.84c.87-2.6 3.3-4.52 6.16-4.52z"/>
          </svg>
          <span>Đăng nhập 1 chạm với tài khoản Google</span>
        </button>

        <div class="relative flex items-center justify-center">
          <div class="border-t border-slate-200 w-full"></div>
          <span class="bg-white px-3 text-[11px] text-slate-400 absolute">hoặc dùng Email / Số điện thoại</span>
        </div>
      </div>

      <!-- FORM 1: ĐĂNG NHẬP -->
      <form id="loginForm" onsubmit="handleLoginSubmit(event)" class="space-y-4 text-xs">
        <div>
          <label class="block font-bold text-slate-700 mb-1">Email hoặc Số điện thoại:</label>
          <input 
            type="text" 
            id="loginAccount" 
            value="nguyenvanbinh@gmail.com" 
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
          <input 
            type="password" 
            id="loginPassword" 
            value="12345678" 
            required 
            class="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-300 rounded-lg text-xs font-medium focus:bg-white focus:outline-none focus:ring-2 focus:ring-blue-500"
          >
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
      <form id="registerForm" onsubmit="handleRegisterSubmit(event)" class="space-y-3.5 text-xs hidden">
        <div>
          <label class="block font-bold text-slate-700 mb-1">Họ và tên của bạn:</label>
          <input 
            type="text" 
            id="regFullName" 
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
              placeholder="name@gmail.com" 
              required
              class="flex-1 px-3.5 py-2.5 bg-slate-50 border border-slate-300 rounded-lg text-xs font-medium focus:bg-white focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
            <button type="button" onclick="sendOtpCode()" id="btnSendOtp" class="px-3 py-2.5 bg-slate-100 hover:bg-slate-200 border border-slate-300 text-slate-700 font-bold rounded-lg text-[11px] whitespace-nowrap transition">
              Gửi Mã OTP
            </button>
          </div>
        </div>

        <!-- Ô NHẬP MÃ OTP 6 SỐ -->
        <div id="otpInputGroup" class="p-3 bg-blue-50 border border-blue-200 rounded-lg space-y-1.5 hidden">
          <label class="block font-bold text-blue-900 text-[11px]">Nhập mã OTP 6 số vừa gửi vào email:</label>
          <div class="flex gap-1.5">
            <input type="text" maxlength="6" id="otpValue" placeholder="123456" class="w-full p-2 text-center text-sm font-mono tracking-widest font-black bg-white border border-blue-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500">
          </div>
          <span class="text-[10px] text-blue-700 block">Mã có hiệu lực trong 5 phút. Hãy kiểm tra cả hộp thư Spam.</span>
        </div>

        <div>
          <label class="block font-bold text-slate-700 mb-1">Mật khẩu mới:</label>
          <input 
            type="password" 
            id="regPassword" 
            placeholder="Tối thiểu 6 ký tự" 
            required
            class="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-300 rounded-lg text-xs font-medium focus:bg-white focus:outline-none focus:ring-2 focus:ring-blue-500"
          >
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
    <div class="bg-white rounded-xl max-w-sm w-full p-6 shadow-2xl space-y-4">
      <div class="flex items-center justify-between border-b border-slate-100 pb-3">
        <h3 class="font-bold text-slate-900 text-sm">Lấy Lại Mật Khẩu</h3>
        <button onclick="closeForgotPasswordModal()" class="text-slate-400 hover:text-slate-600 font-bold text-lg px-2">X</button>
      </div>

      <div class="space-y-3 text-xs">
        <p class="text-slate-600 leading-relaxed">
          Nhập địa chỉ email đăng ký tài khoản của bạn. MuaNgay sẽ gửi liên kết đặt lại mật khẩu trong 30 giây.
        </p>
        <div>
          <label class="block font-bold text-slate-700 mb-1">Email của bạn:</label>
          <input type="email" id="forgotEmailInput" value="nguyenvanbinh@gmail.com" class="w-full p-2.5 border border-slate-300 rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-blue-500">
        </div>
      </div>

      <div class="pt-2 flex gap-2">
        <button onclick="closeForgotPasswordModal()" class="flex-1 py-2 border border-slate-300 rounded-lg text-xs font-semibold hover:bg-slate-100">
          Hủy
        </button>
        <button onclick="submitForgotPassword()" class="flex-1 py-2 bg-blue-600 hover:bg-blue-700 font-bold text-xs text-white rounded-lg transition">
          Gửi Yêu Cầu
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

    function handleLoginSubmit(e) {
      e.preventDefault();
      showToast('Đăng nhập thành công! Đang chuyển đến trang cá nhân...');
      setTimeout(() => {
        window.location.href = '08-ho-so-ca-nhan.jsp';
      }, 1200);
    }

    function handleRegisterSubmit(e) {
      e.preventDefault();
      const otp = document.getElementById('otpValue').value.trim();
      if (!otp || otp.length < 6) {
        showToast('Vui lòng nhập đủ 6 chữ số mã OTP đã gửi về email.');
        return;
      }
      showToast('Tạo tài khoản và xác thực thành công!');
      setTimeout(() => {
        window.location.href = '08-ho-so-ca-nhan.jsp';
      }, 1200);
    }

    function sendOtpCode() {
      const email = document.getElementById('regEmail').value.trim();
      if (!email) {
        showToast('Vui lòng nhập địa chỉ email trước khi nhận mã OTP.');
        return;
      }
      document.getElementById('otpInputGroup').classList.remove('hidden');
      document.getElementById('btnSendOtp').textContent = 'Đã gửi lại (60s)';
      showToast('Đã gửi mã xác thực 6 số tới: ' + email);
    }

    function simulateGoogleLogin() {
      showToast('Đang kết nối tài khoản Google...');
      setTimeout(() => {
        showToast('Đăng nhập Google thành công! Chào mừng bạn quay lại.');
        setTimeout(() => {
          window.location.href = '08-ho-so-ca-nhan.jsp';
        }, 1000);
      }, 800);
    }

    function openForgotPasswordModal() {
      document.getElementById('forgotPasswordModal').classList.remove('hidden');
    }
    function closeForgotPasswordModal() {
      document.getElementById('forgotPasswordModal').classList.add('hidden');
    }
    function submitForgotPassword() {
      closeForgotPasswordModal();
      showToast('Đã gửi hướng dẫn đặt lại mật khẩu vào email của bạn.');
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
