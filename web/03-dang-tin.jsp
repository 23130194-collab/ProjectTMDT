<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Đăng Tin Mua Bán & Thanh Lý - MuaNgay</title>
  <link rel="icon" type="image/svg+xml" href="assets/logos/muangay-logo-icon.svg">
  <script src="https://cdn.tailwindcss.com"></script>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="css/style.css">
  <link rel="stylesheet" href="css/03-dang-tin.css">
</head>
<body class="bg-slate-50 text-slate-900 min-h-screen flex flex-col">

  <!-- THANH ĐIỀU HƯỚNG -->
  <jsp:include page="includes/header.jsp" />

  <!-- BIỂU MẪU ĐĂNG TIN C2C ĐA NĂNG -->
  <main class="max-w-3xl mx-auto px-4 py-8 flex-1 w-full relative">
    
    <form action="post-ad" method="POST" enctype="multipart/form-data" class="bg-white rounded-xl border border-slate-200 shadow-sm p-6 sm:p-8 space-y-8">
      
      <div>
        <h1 class="text-xl sm:text-2xl font-bold text-slate-900">Đăng Tin Mua Bán & Thanh Lý Đồ Dùng</h1>
        <p class="text-xs text-slate-500 mt-1">Tiếp cận hàng ngàn người mua trong khu vực với cơ chế đặt cọc giữ chỗ an tâm</p>
      </div>

      <!-- BƯỚC 1: HÌNH THỨC ĐĂNG TIN -->
      <div class="space-y-3">
        <label class="block text-xs font-bold uppercase tracking-wider text-slate-700">
          Bước 1: Chọn hình thức đăng tin <span class="text-red-500">*</span>
        </label>
        <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
          
          <label class="flex flex-col p-3.5 border-2 border-blue-600 bg-blue-50/50 rounded-xl cursor-pointer">
            <div class="flex items-center justify-between">
              <span class="text-xs font-bold text-blue-900">Bán Thanh Lý</span>
              <input type="radio" name="deal_type" value="sell" checked class="w-4 h-4 text-blue-600">
            </div>
            <span class="text-[11px] text-blue-700 mt-1">Bán lấy tiền với giá niêm yết (hỗ trợ người mua trả giá)</span>
          </label>

          <label class="flex flex-col p-3.5 border-2 border-slate-200 hover:border-slate-300 rounded-xl cursor-pointer">
            <div class="flex items-center justify-between">
              <span class="text-xs font-bold text-slate-800">Tặng Miễn Phí (0đ)</span>
              <input type="radio" name="deal_type" value="give" class="w-4 h-4 text-blue-600">
            </div>
            <span class="text-[11px] text-slate-500 mt-1">Tặng miễn phí cho người thực sự có nhu cầu</span>
          </label>

        </div>
      </div>

                  <!-- BƯỚC 2: HÌNH ẢNH THỰC TẾ -->
      <div class="space-y-3">
        <label class="block text-xs font-bold uppercase tracking-wider text-slate-700">
          Bước 2: Hình ảnh thực tế (Tối đa 6 ảnh chụp rõ nét) <span class="text-red-500">*</span>
        </label>
        <label class="block border-2 border-dashed border-slate-300 rounded-xl p-6 text-center hover:border-blue-500 transition cursor-pointer bg-slate-50 relative">
          <input type="file" name="images" multiple accept="image/*" class="absolute inset-0 w-full h-full opacity-0 cursor-pointer z-0" onchange="previewImages(this)">
          <div class="text-xs font-semibold text-blue-600">Bấm để tải ảnh chụp món đồ lên hoặc kéo thả tệp vào đây</div>
          <p class="text-[11px] text-slate-500 mt-1">Chụp đủ các góc cạnh, tem thông số, các vết trầy xước (nếu có) để người mua yên tâm</p>
          <div id="previewContainer" class="mt-4 flex flex-wrap justify-center gap-2.5 relative z-10">
          </div>
        </label>
      </div>

      <!-- BƯỚC 3: THÔNG TIN CHI TIẾT VÀ GIÁ BÁN -->
      <div class="space-y-4">
        <label class="block text-xs font-bold uppercase tracking-wider text-slate-700">
          Bước 3: Thông tin món đồ đăng bán <span class="text-red-500">*</span>
        </label>

        <div>
          <label class="block text-xs font-medium text-slate-700 mb-1">Tiêu đề bài đăng</label>
          <input 
            type="text" 
            name="title" placeholder="Ví dụ: iPhone 18 Pro Max Đỏ Burgundy 256GB chính hãng hoặc MacBook Pro M3" 
            required
            value="iPhone 18 Pro Max Đỏ Burgundy 256GB chính hãng VN/A, pin 100% fullbox"
            class="w-full px-3.5 py-2 bg-white border border-slate-300 rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-blue-500"
          >
        </div>

        <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div>
            <label class="block text-xs font-medium text-slate-700 mb-1">Danh mục hàng hóa</label>
            <select name="categoryId" class="w-full px-3.5 py-2 bg-white border border-slate-300 rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-blue-500">
              <option selected>Điện Tử & Thiết Bị Số</option>
              <option>Xe Cộ & Phương Tiện</option>
              <option>Điện Lạnh & Gia Dụng</option>
              <option>Nội Thất & Đồ Gia Đình</option>
              <option>Thời Trang & Đồ Cá Nhân</option>
            </select>
          </div>

          <div>
            <label class="block text-xs font-medium text-slate-700 mb-1">Giá bán mong muốn (VNĐ)</label>
            <input 
              type="text" 
              name="price" value="38000000"
              required
              class="w-full px-3.5 py-2 bg-white border border-slate-300 rounded-lg text-xs font-bold text-red-600 focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
          </div>
        </div>

        <div>
          <label class="block text-xs font-medium text-slate-700 mb-1">Mô tả tình trạng chi tiết</label>
          <textarea name="description" rows="4" 
            class="w-full px-3.5 py-2 bg-white border border-slate-300 rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-blue-500 leading-relaxed"
          >Cần pass lại iPhone 18 Pro Max 256GB màu Đỏ Burgundy cực đẹp keng 99.9% không một vết xước. Máy mua chính hãng mã VN/A, pin chuẩn 100%, bảo hành Apple Care dài hạn, fullbox trùng IMEI.</textarea>
        </div>
      </div>

      <!-- BƯỚC 4: LỰA CHỌN PHƯƠNG THỨC GIAO NHẬN -->
      <div class="space-y-3">
        <label class="block text-xs font-bold uppercase tracking-wider text-slate-700">
          Bước 4: Chọn phương thức giao nhận <span class="text-red-500">*</span>
        </label>
        
        <div class="space-y-2.5">
          <label class="flex items-start gap-3 p-3.5 border-2 border-blue-600 bg-blue-50/50 rounded-xl cursor-pointer">
            <input type="radio" name="delivery_method" value="1" checked class="mt-0.5 w-4 h-4 text-blue-600 rounded">
            <div>
              <span class="text-xs font-bold text-slate-900 block">1. Hẹn gặp trực tiếp (Người mua cọc giữ chỗ 10%)</span>
              <p class="text-[11px] text-slate-600 mt-0.5">Phù hợp với mặt hàng Xe cộ, Đồ cồng kềnh. Người mua đặt cọc trước qua VietQR để hẹn giờ xem đồ, chống bỏ hẹn.</p>
            </div>
          </label>

          <label class="flex items-start gap-3 p-3.5 border border-slate-200 rounded-xl cursor-pointer">
            <input type="radio" name="delivery_method" value="2" class="mt-0.5 w-4 h-4 text-slate-600 rounded">
            <div>
              <span class="text-xs font-bold text-slate-900 block">2. Giao hàng qua bưu điện / shipper (Khách được dùng thử 48h)</span>
              <p class="text-[11px] text-slate-600 mt-0.5">Mặt hàng Xe cộ yêu cầu thử xe trực tiếp nên phương thức này được tạm tắt.</p>
            </div>
          </label>
        </div>
      </div>

      <!-- BƯỚC 5: KHU VỰC VÀ ĐỊA CHỈ HẸN GẶP -->
      <div class="space-y-3">
        <label class="block text-xs font-bold uppercase tracking-wider text-slate-700">
          Bước 5: Địa điểm xem hàng & giao dịch <span class="text-red-500">*</span>
        </label>

        <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
          <div>
            <label class="block text-[11px] font-medium text-slate-700 mb-1">Tỉnh / Thành phố</label>
            <select class="w-full px-3 py-2 bg-white border border-slate-300 rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-blue-500">
              <option selected>TP. Hồ Chí Minh</option>
              <option>Hà Nội</option>
              <option>Đà Nẵng</option>
              <option>Bình Dương</option>
              <option>Cần Thơ</option>
            </select>
          </div>

          <div>
            <label class="block text-[11px] font-medium text-slate-700 mb-1">Quận / Huyện</label>
            <select class="w-full px-3 py-2 bg-white border border-slate-300 rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-blue-500">
              <option selected>Quận 10</option>
              <option>Quận 1</option>
              <option>Quận Bình Thạnh</option>
              <option>TP. Thủ Đức</option>
              <option>Quận Tân Bình</option>
            </select>
          </div>
        </div>

        <div>
          <label class="block text-[11px] font-medium text-slate-700 mb-1">Địa chỉ cụ thể (Đường, Phường/Xã)</label>
          <input 
            type="text" 
            value="Đường Tô Hiến Thành, Phường 13"
            class="w-full px-3.5 py-2 bg-white border border-slate-300 rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-blue-500"
          >
        </div>
      </div>

      <!-- BƯỚC 6: ĐẨY TIN NỔI BẬT (VIP BOOST) -->
      <div class="space-y-3 p-4 bg-amber-50/70 border-2 border-amber-300 rounded-xl">
        <div class="flex items-center justify-between">
          <label class="block text-xs font-bold uppercase tracking-wider text-amber-900">
            Bước 6: Gói đẩy tin nổi bật (VIP Boost) - Bán nhanh trong 24h
          </label>
          <span class="text-[10px] font-bold text-amber-700 bg-amber-200 px-2 py-0.5 rounded">
            Tùy Chọn
          </span>
        </div>

        <div class="grid grid-cols-1 sm:grid-cols-3 gap-3 pt-1">
          <label class="p-3 bg-white border-2 border-blue-500 rounded-lg cursor-pointer flex flex-col justify-between shadow-sm">
            <div>
              <input type="radio" name="vip_boost" value="normal" checked class="text-blue-600">
              <span class="font-bold text-xs text-slate-800 block mt-1">Tin Thường</span>
              <p class="text-[10px] text-slate-500 mt-1">Hiển thị theo luồng thời gian tự nhiên.</p>
            </div>
            <div class="font-bold text-xs text-slate-700 mt-2">0 đ (Miễn phí)</div>
          </label>

          <label class="p-3 bg-white border border-slate-200 rounded-lg cursor-pointer flex flex-col justify-between">
            <div>
              <div class="flex items-center justify-between">
                <input type="radio" name="vip_boost" value="hot" class="text-amber-600">
                <span class="text-[9px] font-bold text-amber-700 bg-amber-100 px-1.5 py-0.5 rounded">HOT</span>
              </div>
              <span class="font-bold text-xs text-amber-900 block mt-1">Gói Nổi Bật Danh Mục</span>
              <p class="text-[10px] text-slate-500 mt-1">Ghim đầu danh mục Xe cộ trong 24h, tăng gấp 5 lần lượt xem.</p>
            </div>
            <div class="font-bold text-xs text-amber-700 mt-2">15.000 đ / ngày</div>
          </label>

          <label class="p-3 bg-white border border-slate-200 rounded-lg cursor-pointer flex flex-col justify-between">
            <div>
              <div class="flex items-center justify-between">
                <input type="radio" name="vip_boost" value="vip" class="text-purple-600">
                <span class="text-[9px] font-bold text-purple-700 bg-purple-100 px-1.5 py-0.5 rounded">VIP</span>
              </div>
              <span class="font-bold text-xs text-purple-900 block mt-1">Gói VIP Toàn Sàn</span>
              <p class="text-[10px] text-slate-500 mt-1">Ghim vị trí ưu tiên đầu Trang Chủ toàn quốc kèm viền cam nổi bật.</p>
            </div>
            <div class="font-bold text-xs text-purple-700 mt-2">30.000 đ / ngày</div>
          </label>
        </div>
      </div>

      <!-- NÚT XUẤT BẢN BÀI ĐĂNG -->
      <div class="pt-4 border-t border-slate-200 flex items-center justify-end gap-3">
        <a href="home" class="px-4 py-2 text-xs font-semibold text-slate-600 hover:bg-slate-100 rounded-lg transition">
          Hủy bỏ
        </a>
        <button type="submit" class="px-6 py-2.5 bg-amber-500 hover:bg-amber-600 text-slate-900 text-xs font-bold rounded-lg shadow-sm transition">
          Đăng Tin Miễn Phí Ngay
        </button>
      </div>

    </form>

    <!-- MODAL THÀNH CÔNG -->
    <div id="successModal" class="hidden fixed inset-0 bg-slate-900/50 backdrop-blur-xs z-50 flex items-center justify-center p-4">
      <div class="bg-white rounded-2xl shadow-2xl border border-slate-200 max-w-sm w-full p-6 text-center space-y-4">
        <div class="w-14 h-14 bg-green-100 rounded-full flex items-center justify-center mx-auto text-green-600 font-bold text-2xl">
          ✓
        </div>
        <div>
          <h3 class="font-bold text-base text-slate-900">Đăng Tin Thành Công!</h3>
          <p class="text-xs text-slate-500 mt-1">Tin đăng của bạn đã được kiểm duyệt tự động bằng AI và xuất bản lên sàn MuaNgay.</p>
        </div>
        <div class="pt-2">
          <a href="home" class="block w-full py-2 bg-blue-600 hover:bg-blue-700 text-white font-bold text-xs rounded-lg transition">
            Về Trang Chủ Xem Tin Đăng
          </a>
        </div>
      </div>
    </div>

  </main>

  <!-- CHÂN TRANG ĐẦY ĐỦ 8 MÀN HÌNH -->
  <jsp:include page="includes/footer.jsp" />

  <script>
    function handlePostSubmit(e) {
      e.preventDefault();
      document.getElementById('successModal').classList.remove('hidden');
      setTimeout(() => {
        window.location.href = '01-trang-chu.jsp';
      }, 2000);
    }
  </script>

      <script>
    let selectedFiles = [];
    let dragStartIndex = null;

    function previewImages(input) {
      if (input.files && input.files.length > 0) {
        for (let i = 0; i < input.files.length; i++) {
          if (selectedFiles.length < 6) { 
            selectedFiles.push(input.files[i]);
          }
        }
      }
      input.value = ''; 
      renderPreview();
    }

    function updateFileInput() {
      const dt = new DataTransfer();
      selectedFiles.forEach(file => dt.items.add(file));
      document.querySelector('input[type="file"][name="images"]').files = dt.files;
    }

    function renderPreview() {
      const container = document.getElementById('previewContainer');
      container.innerHTML = '';
      
      if (selectedFiles.length === 0) {
        // Giao diện gốc ban đầu khi chưa có ảnh
        container.innerHTML = `
            <div class="w-16 h-16 bg-slate-200 rounded-lg flex items-center justify-center text-[10px] text-slate-600 font-medium pointer-events-none">Ảnh chính</div>
            <div class="w-16 h-16 bg-slate-200 rounded-lg flex items-center justify-center text-[10px] text-slate-600 font-medium pointer-events-none">Góc nghiêng</div>
            <div class="w-16 h-16 bg-slate-200 rounded-lg flex items-center justify-center text-[10px] text-slate-600 font-medium pointer-events-none">Lốc máy / Tem</div>
            <div class="w-16 h-16 border-2 border-dashed border-slate-300 rounded-lg flex items-center justify-center text-[10px] text-slate-400 font-medium pointer-events-none">+ Thêm ảnh</div>
        `;
        updateFileInput();
        return;
      }
      
      selectedFiles.forEach((file, index) => {
        const url = URL.createObjectURL(file);
        
        const wrapper = document.createElement('div');
        wrapper.className = 'relative group w-16 h-16 flex-shrink-0 cursor-grab active:cursor-grabbing transition-transform duration-200 bg-white rounded-lg hover:-translate-y-1';
        wrapper.draggable = true;
        
        wrapper.addEventListener('dragstart', function(e) {
          dragStartIndex = index;
          e.dataTransfer.effectAllowed = 'move';
          // Fix issue HTML5 drag drop on same element
          setTimeout(() => this.classList.add('opacity-40'), 0);
        });
        
        wrapper.addEventListener('dragover', function(e) {
          e.preventDefault(); 
          e.dataTransfer.dropEffect = 'move';
        });
        
        wrapper.addEventListener('drop', function(e) {
          e.preventDefault();
          e.stopPropagation(); // Ngăn chặn trigger chọn file của label cha
          const dragEndIndex = index;
          if (dragStartIndex !== null && dragStartIndex !== dragEndIndex) {
            const draggedItem = selectedFiles.splice(dragStartIndex, 1)[0];
            selectedFiles.splice(dragEndIndex, 0, draggedItem);
            renderPreview();
          }
        });
        
        wrapper.addEventListener('dragend', function(e) {
          this.classList.remove('opacity-40');
        });

        const img = document.createElement('img');
        img.src = url;
        img.className = 'w-full h-full object-cover rounded-lg border-2 ' + (index === 0 ? 'border-amber-500 shadow-sm' : 'border-slate-200');
        
        const label = document.createElement('div');
        if (index === 0) {
          label.className = 'absolute bottom-0 left-0 right-0 bg-amber-500 text-white text-[9px] text-center font-bold py-0.5 rounded-b-md shadow-sm truncate px-1';
          label.innerText = 'Ảnh đại diện';
        } else {
          label.className = 'absolute bottom-0 left-0 right-0 bg-slate-800/70 backdrop-blur-sm text-white text-[9px] text-center font-medium py-0.5 rounded-b-md truncate px-1';
          label.innerText = 'Chi tiết ' + index;
        }
        
        const removeBtn = document.createElement('div');
        removeBtn.innerHTML = '✕';
        removeBtn.className = 'absolute -top-1.5 -right-1.5 w-5 h-5 bg-red-500 text-white rounded-full text-[9px] font-bold flex items-center justify-center opacity-0 group-hover:opacity-100 hover:bg-red-600 hover:scale-110 shadow-md transition-all z-20 cursor-pointer';
        
        // Ngăn chặn nổi bọt event lên label cha khi click nút xóa (ngăn mở file dialog)
        removeBtn.onclick = function(e) {
          e.preventDefault(); 
          e.stopPropagation();
          selectedFiles.splice(index, 1);
          renderPreview();
        };
        
        wrapper.appendChild(img);
        wrapper.appendChild(label);
        wrapper.appendChild(removeBtn);
        container.appendChild(wrapper);
      });
      
      updateFileInput();
    }
  </script>
  <script>
    document.addEventListener("DOMContentLoaded", function() {
      // BƯỚC 1: HÌNH THỨC ĐĂNG TIN
      const dealRadios = document.querySelectorAll('input[name="deal_type"]');
      const priceInput = document.querySelector('input[name="price"]');
      dealRadios.forEach(radio => {
        radio.addEventListener('change', function() {
          // Reset style
          dealRadios.forEach(r => {
            const label = r.closest('label');
            label.className = 'flex flex-col p-3.5 border-2 border-slate-200 hover:border-slate-300 rounded-xl cursor-pointer';
            label.querySelector('span:first-child').className = 'text-xs font-bold text-slate-800';
          });
          // Set active style
          const activeLabel = this.closest('label');
          activeLabel.className = 'flex flex-col p-3.5 border-2 border-blue-600 bg-blue-50/50 rounded-xl cursor-pointer';
          activeLabel.querySelector('span:first-child').className = 'text-xs font-bold text-blue-900';

          // BƯỚC 3: Giá bán mong muốn
          if (this.value === 'give') {
            priceInput.value = '0';
            priceInput.readOnly = true;
            priceInput.className = 'w-full px-3.5 py-2 bg-slate-100 border border-slate-300 rounded-lg text-xs font-bold text-slate-400 cursor-not-allowed';
          } else {
            priceInput.value = '';
            priceInput.readOnly = false;
            priceInput.className = 'w-full px-3.5 py-2 bg-white border border-slate-300 rounded-lg text-xs font-bold text-red-600 focus:outline-none focus:ring-2 focus:ring-blue-500';
          }
        });
      });

      // BƯỚC 4: PHƯƠNG THỨC GIAO NHẬN
      const deliveryChecks = document.querySelectorAll('input[name="delivery_method"]');
      deliveryChecks.forEach(check => {
        check.addEventListener('change', function() {
          // Reset all
          deliveryChecks.forEach(c => {
             const lbl = c.closest('label');
             lbl.className = 'flex items-start gap-3 p-3.5 border border-slate-200 rounded-xl cursor-pointer';
          });
          // Highlight active
          if (this.checked) {
            const label = this.closest('label');
            label.className = 'flex items-start gap-3 p-3.5 border-2 border-blue-600 bg-blue-50/50 rounded-xl cursor-pointer';
          }
        });
      });

      // BƯỚC 6: GÓI ĐẨY TIN VIP
      const vipRadios = document.querySelectorAll('input[name="vip_boost"]');
      vipRadios.forEach(radio => {
        radio.addEventListener('change', function() {
          // Tắt hết
          vipRadios.forEach(r => {
            const label = r.closest('label');
            label.className = 'p-3 bg-white border border-slate-200 rounded-lg cursor-pointer flex flex-col justify-between';
          });
          
          // Bật cái được chọn
          const activeLabel = this.closest('label');
          const isHot = activeLabel.querySelector('span.text-amber-700');
          const isVip = activeLabel.querySelector('span.text-purple-700');
          
          if (isVip) {
            activeLabel.className = 'p-3 bg-white border-2 border-purple-500 rounded-lg cursor-pointer flex flex-col justify-between shadow-sm';
          } else if (isHot) {
            activeLabel.className = 'p-3 bg-white border-2 border-amber-500 rounded-lg cursor-pointer flex flex-col justify-between shadow-sm';
          } else {
            activeLabel.className = 'p-3 bg-white border-2 border-blue-500 rounded-lg cursor-pointer flex flex-col justify-between shadow-sm';
          }
        });
      });
    });
  </script>
</body>
</html>
