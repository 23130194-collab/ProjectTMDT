<%@ page contentType="text/html;charset=UTF-8" language="java" %>
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
          VB
        </div>
        <div>
          <div class="flex items-center gap-2">
            <h1 id="profileDisplayName" class="text-lg font-bold text-slate-900">Nguyễn Văn Bình</h1>
            <span class="px-2 py-0.5 rounded bg-emerald-100 text-emerald-800 text-[10px] font-bold">
              Tài Khoản Đã Xác Thực SĐT
            </span>
          </div>
          <div id="profileMetaText" class="text-xs text-slate-500 mt-1">
            Thành viên MuaNgay từ tháng 04/2023 • Quận 10, TP. Hồ Chí Minh
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
  <div id="editProfileModal" class="fixed inset-0 bg-slate-900/60 z-50 hidden flex items-center justify-center p-4">
    <div class="bg-white rounded-xl max-w-md w-full p-6 shadow-2xl space-y-4 text-left">
      <div class="flex items-center justify-between border-b border-slate-100 pb-3">
        <h3 class="font-bold text-slate-900 text-sm uppercase">Chỉnh Sửa Hồ Sơ Cá Nhân</h3>
        <button onclick="closeModal('editProfileModal')" class="text-slate-400 hover:text-slate-600 font-bold text-lg px-2">✕</button>
      </div>

      <div class="space-y-3 text-xs">
        <div>
          <label class="block font-bold text-slate-700 mb-1">Họ và tên:</label>
          <input id="inputFullName" type="text" value="Nguyễn Văn Bình" class="w-full p-2.5 bg-slate-50 border border-slate-300 rounded-lg text-xs font-semibold focus:ring-2 focus:ring-blue-500">
        </div>
        <div class="grid grid-cols-2 gap-3">
          <div>
            <label class="block font-bold text-slate-700 mb-1">Số điện thoại:</label>
            <input id="inputPhone" type="text" value="0988 123 456" class="w-full p-2.5 bg-slate-50 border border-slate-300 rounded-lg text-xs focus:ring-2 focus:ring-blue-500">
          </div>
          <div>
            <label class="block font-bold text-slate-700 mb-1">Email:</label>
            <input id="inputEmail" type="email" value="binh.nguyen@gmail.com" class="w-full p-2.5 bg-slate-50 border border-slate-300 rounded-lg text-xs focus:ring-2 focus:ring-blue-500">
          </div>
        </div>
        <div>
          <label class="block font-bold text-slate-700 mb-1">Địa chỉ mặc định (Gặp mặt/Nhận hàng):</label>
          <input id="inputAddress" type="text" value="142 Tô Hiến Thành, Phường 13, Quận 10, TP.HCM" class="w-full p-2.5 bg-slate-50 border border-slate-300 rounded-lg text-xs focus:ring-2 focus:ring-blue-500">
        </div>
        <div class="p-2.5 bg-emerald-50 border border-emerald-200 rounded-lg text-[11px] text-emerald-900">
          Tài khoản chính chủ đã liên kết số điện thoại: <strong class="font-mono">0988***456</strong> (Đã cấp huy hiệu Người Bán Uy Tín).
        </div>
      </div>

      <div class="pt-2 flex gap-2">
        <button onclick="closeModal('editProfileModal')" class="flex-1 py-2 border border-slate-300 rounded-lg text-xs font-semibold hover:bg-slate-100">
          Hủy Bỏ
        </button>
        <button onclick="saveProfileInfo()" class="flex-1 py-2 bg-blue-600 hover:bg-blue-700 font-bold text-xs text-white rounded-lg shadow-sm">
          Lưu Thay Đổi
        </button>
      </div>
    </div>
  </div>

  <!-- MODAL ĐỔI MẬT KHẨU -->
  <div id="changePasswordModal" class="fixed inset-0 bg-slate-900/60 z-50 hidden flex items-center justify-center p-4">
    <div class="bg-white rounded-xl max-w-sm w-full p-6 shadow-2xl space-y-4">
      <div class="flex items-center justify-between border-b border-slate-100 pb-3">
        <h3 class="font-bold text-slate-900 text-sm">Đổi Mật Khẩu Đăng Nhập</h3>
        <button onclick="closeModal('changePasswordModal')" class="text-slate-400 hover:text-slate-600 font-bold text-lg px-2">✕</button>
      </div>
      <div class="space-y-3 text-xs">
        <div>
          <label class="block font-bold text-slate-700 mb-1">Mật khẩu hiện tại:</label>
          <input type="password" value="12345678" class="w-full p-2.5 border border-slate-300 rounded-lg text-xs focus:ring-2 focus:ring-blue-500">
        </div>
        <div>
          <label class="block font-bold text-slate-700 mb-1">Mật khẩu mới:</label>
          <input type="password" placeholder="Nhập mật khẩu mới..." class="w-full p-2.5 border border-slate-300 rounded-lg text-xs focus:ring-2 focus:ring-blue-500">
        </div>
      </div>
      <div class="pt-2 flex gap-2">
        <button onclick="closeModal('changePasswordModal')" class="flex-1 py-2 border border-slate-300 rounded-lg text-xs font-semibold hover:bg-slate-100">Hủy</button>
        <button onclick="saveNewPassword()" class="flex-1 py-2 bg-blue-600 hover:bg-blue-700 font-bold text-xs text-white rounded-lg">Lưu Mật Khẩu</button>
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

    function saveProfileInfo() {
      const newName = document.getElementById('inputFullName').value.trim();
      const newAddress = document.getElementById('inputAddress').value.trim();
      if (newName) {
        document.getElementById('profileDisplayName').innerText = newName;
      }
      if (newAddress) {
        document.getElementById('profileMetaText').innerText = 'Thành viên MuaNgay từ tháng 04/2023 • ' + newAddress;
      }
      closeModal('editProfileModal');
      showToast('Cập nhật thông tin hồ sơ cá nhân thành công!');
    }

    function saveNewPassword() {
      closeModal('changePasswordModal');
      showToast('Đổi mật khẩu tài khoản thành công!');
    }

    function showToast(msg) {
      const toast = document.getElementById('toastNotification');
      document.getElementById('toastMsg').textContent = msg;
      toast.classList.remove('hidden');
      setTimeout(() => { toast.classList.add('hidden'); }, 3000);
    }
  </script>
</body>
</html>
