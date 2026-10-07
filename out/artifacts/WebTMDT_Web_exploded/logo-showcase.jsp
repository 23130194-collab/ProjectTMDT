<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Bộ Nhận Diện Logo - Sàn Thương Mại Điện Tử MuaNgay</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="css/style.css">
  <link rel="stylesheet" href="css/logo-showcase.css">
</head>
<body class="bg-slate-50 text-slate-900 min-h-screen">

  <!-- PHẦN ĐẦU TRANG SHOWCASE -->
  <jsp:include page="includes/header.jsp" />

  <!-- NỘI DUNG CHÍNH -->
  <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 space-y-12">

    <!-- BỐI CẢNH VÀ NGUYÊN LÝ THIẾT KẾ -->
    <section class="bg-white rounded-xl border border-slate-200 p-6 shadow-sm">
      <h2 class="text-lg font-bold text-slate-900 mb-3 border-b border-slate-100 pb-2">1. Bối Cảnh Nghiệp Vụ và Định Hướng Thiết Kế</h2>
      <div class="grid grid-cols-1 md:grid-cols-3 gap-6 text-xs text-slate-600 leading-relaxed">
        <div class="p-4 bg-slate-50 rounded-lg border border-slate-200">
          <div class="font-bold text-slate-800 text-sm mb-1.5 text-blue-700">Giá Trị Cốt Lõi: Re-Commerce Tuần Hoàn</div>
          <p>Thúc đẩy kinh tế tuần hoàn (Circular Economy), tái định hình vòng đời đồ dùng cũ. Người thừa thì pass nhanh giải phóng không gian, người thiếu thì mua ngay với mức giá tiết kiệm.</p>
        </div>
        <div class="p-4 bg-slate-50 rounded-lg border border-slate-200">
          <div class="font-bold text-slate-800 text-sm mb-1.5 text-blue-700">Bảo Chứng Sàn: B2C Market Creator</div>
          <p>Sàn đóng vai trò trung gian bảo lãnh ký quỹ (Escrow Agent), giữ tiền an toàn qua VietQR và kiểm tra 48 giờ đối với hàng bưu điện, xóa tan nỗi lo lừa đảo trên thị trường C2C.</p>
        </div>
        <div class="p-4 bg-slate-50 rounded-lg border border-slate-200">
          <div class="font-bold text-slate-800 text-sm mb-1.5 text-blue-700">Tốc Độ và Sự Dứt Khoát: Mua Ngay</div>
          <p>Yếu tố "Ngay" thể hiện tính thanh khoản cao, trả giá tức thời (Make an Offer) và quy trình cọc khóa bài đăng nhanh chóng trong 1 thao tác quét mã thanh toán tự động.</p>
        </div>
      </div>
    </section>

    <!-- KHU VỰC PHIÊN BẢN CẢI TIẾN THEO YÊU CẦU -->
    <section class="bg-gradient-to-r from-blue-50 via-indigo-50 to-slate-50 rounded-2xl border-2 border-blue-500 p-6 sm:p-8 shadow-md space-y-6">
      <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4 border-b border-blue-200 pb-4">
        <div>
          <span class="bg-blue-600 text-white text-[11px] font-bold uppercase tracking-wider px-3 py-1 rounded-full inline-block mb-1.5">
            Phiên Bản Cập Nhật Mới Nhất
          </span>
          <h2 class="text-xl sm:text-2xl font-black text-slate-900 tracking-tight">Logo Cải Tiến: Phóng To Icon &amp; Phối Màu Tươi Sáng</h2>
          <p class="text-xs text-slate-600 mt-1">Icon túi hàng và chữ M-N được mở rộng từ 45% lên 80% diện tích khung nền, nét viền dày dặn và màu sắc tươi sáng, tương phản vượt trội.</p>
        </div>
      </div>

      <!-- SO SÁNH TRỰC QUAN TRƯỚC VÀ SAU CẢI TIẾN -->
      <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        <!-- Bản Cũ (Trước) -->
        <div class="bg-white rounded-xl p-5 border border-slate-200 opacity-70">
          <div class="text-xs font-bold text-slate-500 uppercase tracking-wide mb-1">Phiên Bản Trước (Bản Cũ)</div>
          <div class="text-[11px] text-slate-500 mb-3">Icon còn nhỏ lọt thỏm trong khung nền (45% diện tích), màu nền tím chàm bị trầm tối, khó nhận diện khi thu nhỏ:</div>
          <div class="bg-slate-100 p-6 rounded-lg flex items-center justify-center gap-4">
            <img src="assets/logos/concept-3-icon.svg" alt="Old Logo Icon" class="w-14 h-14 rounded-xl shadow-xs">
            <img src="assets/logos/concept-3-full.svg" alt="Old Logo Full" class="h-10">
          </div>
          <div class="mt-3 text-[11px] text-slate-500 italic">- Hạn chế: Nét mảnh 2px, màu sắc chưa nổi bật trên thanh Header sáng.</div>
        </div>

        <!-- Bản Mới (Sau Cải Tiến - Khuyên Dùng) -->
        <div class="bg-white rounded-xl p-5 border-2 border-emerald-500 shadow-sm relative">
          <div class="absolute -top-3 right-4 bg-emerald-600 text-white text-[10px] font-bold uppercase px-2.5 py-0.5 rounded-full">
            Đã Áp Dụng Toàn Hệ Thống
          </div>
          <div class="text-xs font-bold text-emerald-700 uppercase tracking-wide mb-1">Phiên Bản Mới (Đã Cải Tiến)</div>
          <div class="text-[11px] text-slate-600 mb-3">Icon mở rộng 80% diện tích, viền trắng tinh dày dặn 3.5px, nền Xanh hoàng gia rực rỡ và điểm nhấn Vàng Cam nổi bần bật:</div>
          <div class="bg-slate-50 p-6 rounded-lg border border-slate-200 flex items-center justify-center gap-4 grid-pattern">
            <img src="assets/logos/muangay-logo-icon.svg" alt="New Logo Icon" class="w-14 h-14 rounded-xl shadow-md">
            <img src="assets/logos/muangay-logo-full.svg" alt="New Logo Full" class="h-10">
          </div>
          <div class="mt-3 text-[11px] text-emerald-700 font-semibold">- Ưu điểm: Độ tương phản cực cao, rõ nét ở mọi kích cỡ 16px - 64px, phong cách TMĐT tươi sáng, hiện đại.</div>
        </div>
      </div>

      <!-- BA PHƯƠNG ÁN MÀU SẮC TƯƠI SÁNG ĐỂ LỰA CHỌN -->
      <div class="pt-4 border-t border-blue-200">
        <h3 class="text-sm font-bold text-slate-900 mb-3">Các Biến Thể Màu Sắc Tươi Sáng Đã Thiết Lập:</h3>
        <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
          
          <!-- Biến thể 1: Xanh Hoàng Gia + Vàng Cam (Đã chốt chính thức) -->
          <div class="bg-white p-4 rounded-xl border-2 border-blue-600 shadow-md flex flex-col items-center text-center relative">
            <span class="text-[10px] font-bold text-white bg-blue-600 px-2.5 py-0.5 rounded-full uppercase mb-2">Biến Thể 1 (Đã Chốt Chính Thức)</span>
            <img src="assets/logos/muangay-logo-icon.svg" alt="V1 Icon" class="w-12 h-12 rounded-xl shadow-sm mb-2">
            <div class="font-bold text-xs text-slate-800">Xanh Hoàng Gia &amp; Vàng Cam</div>
            <div class="text-[10px] text-slate-500 mt-1">Nền Xanh tươi sáng kết hợp điểm nhấn Vàng Cam tạo tính kích hoạt hành động mua sắm ngay.</div>
          </div>

          <!-- Biến thể 2: Xanh Đại Dương + Trắng Tuyết -->
          <div class="bg-white p-4 rounded-xl border border-slate-200 shadow-xs flex flex-col items-center text-center">
            <div class="text-[10px] font-bold text-slate-500 uppercase mb-2">Biến Thể 2</div>
            <img src="assets/logos/muangay-logo-v2-cyan-white.svg" alt="V2 Icon" class="w-12 h-12 rounded-xl shadow-sm mb-2">
            <div class="font-bold text-xs text-slate-800">Xanh Đại Dương &amp; Trắng Tuyết</div>
            <div class="text-[10px] text-slate-500 mt-1">Toàn bộ chi tiết màu trắng tinh khiết trên nền xanh đại dương, phong cách tối giản công nghệ.</div>
          </div>

          <!-- Biến thể 3: Nền Cam Năng Động -->
          <div class="bg-white p-4 rounded-xl border border-slate-200 shadow-xs flex flex-col items-center text-center">
            <div class="text-[10px] font-bold text-slate-500 uppercase mb-2">Biến Thể 3</div>
            <img src="assets/logos/muangay-logo-v3-amber.svg" alt="V3 Icon" class="w-12 h-12 rounded-xl shadow-sm mb-2">
            <div class="font-bold text-xs text-slate-800">Nền Cam Rực Rỡ TMĐT</div>
            <div class="text-[10px] text-slate-500 mt-1">Tone màu cam ấm áp tương tự phong cách sàn TMĐT sôi động, nổi bật tuyệt đối trên nền trắng.</div>
          </div>

        </div>
      </div>
    </section>

    <!-- 3 PHƯƠNG ÁN THIẾT KẾ LOGO CHÍNH BAN ĐẦU -->
    <section class="space-y-6">
      <div class="flex items-center justify-between">
        <div>
          <h2 class="text-xl font-bold text-slate-900 tracking-tight">2. Lưu Trữ Ba Định Hướng Thiết Kế Ban Đầu</h2>
          <p class="text-xs text-slate-500">So sánh kiểu dáng, bảng mã màu và ý nghĩa biểu tượng</p>
        </div>
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">

        <!-- CONCEPT 1 -->
        <div class="bg-white rounded-xl border-2 border-blue-600 p-6 shadow-md flex flex-col justify-between relative">
          <div class="absolute -top-3 right-4 bg-blue-600 text-white text-[10px] font-bold uppercase tracking-wider px-2.5 py-0.5 rounded-full">
            Khuyên Dùng Cho Đề Tài
          </div>
          <div>
            <div class="text-xs font-bold text-blue-600 uppercase tracking-wide">Phương Án 1</div>
            <h3 class="text-base font-bold text-slate-900 mt-1">Kinh Tế Tuần Hoàn & Luân Chuyển Giá Trị</h3>
            <p class="text-xs text-slate-500 mt-1 mb-4 leading-normal">
              Biểu tượng chữ M lồng ghép chu trình vô cực và mũi tên hướng lên, đại diện cho việc kéo dài vòng đời sản phẩm từ người bán sang người mua.
            </p>

            <!-- Khung Logo Xem Trước -->
            <div class="bg-slate-50 border border-slate-200 rounded-lg p-6 flex flex-col items-center justify-center gap-4 grid-pattern">
              <img src="assets/logos/concept-1-icon.svg" alt="Concept 1 Icon" class="w-16 h-16 shadow-sm rounded-xl">
              <img src="assets/logos/concept-1-full.svg" alt="Concept 1 Full" class="h-12 max-w-full">
            </div>

            <!-- Bảng màu và Thông số kỹ thuật -->
            <div class="mt-4 pt-4 border-t border-slate-100 space-y-2">
              <div class="text-[11px] font-semibold text-slate-700">Thông Số Màu Sắc (Color Palette):</div>
              <div class="flex items-center gap-2">
                <div class="flex items-center gap-1.5 text-[11px]">
                  <span class="w-4 h-4 rounded bg-[#2563EB] inline-block border border-slate-300"></span>
                  <span class="font-mono text-slate-600">#2563EB (Xanh Lam Tín Nhiệm)</span>
                </div>
              </div>
              <div class="flex items-center gap-2">
                <div class="flex items-center gap-1.5 text-[11px]">
                  <span class="w-4 h-4 rounded bg-[#0D9488] inline-block border border-slate-300"></span>
                  <span class="font-mono text-slate-600">#0D9488 (Xanh Ngọc Tuần Hoàn)</span>
                </div>
              </div>
            </div>

            <!-- Phân tích ưu nhược điểm -->
            <div class="mt-4 text-xs space-y-1.5 bg-blue-50/50 p-3 rounded-lg border border-blue-100">
              <div class="font-bold text-blue-900 text-[11px]">Đặc điểm nổi bật:</div>
              <div class="text-slate-700 text-[11px]">- Thể hiện trực diện tinh thần Re-Commerce và bảo vệ môi trường.</div>
              <div class="text-slate-700 text-[11px]">- Đường nét thanh thoát, hiện đại, nhận diện tốt ở kích cỡ Favicon 16px.</div>
              <div class="text-slate-700 text-[11px]">- Rất phù hợp với bài thuyết trình đồ án bảo vệ trước giảng viên.</div>
            </div>
          </div>
        </div>

        <!-- CONCEPT 2 -->
        <div class="bg-white rounded-xl border border-slate-200 p-6 shadow-sm flex flex-col justify-between">
          <div>
            <div class="text-xs font-bold text-slate-500 uppercase tracking-wide">Phương Án 2</div>
            <h3 class="text-base font-bold text-slate-900 mt-1">Bảo Chứng Escrow & Tốc Độ "Ngay"</h3>
            <p class="text-xs text-slate-500 mt-1 mb-4 leading-normal">
              Hình tượng khiên bảo vệ giao dịch (Escrow Protection) lồng ghép tia chớp năng động biểu thị tốc độ chốt đơn tức thì và cọc nhanh qua VietQR.
            </p>

            <!-- Khung Logo Xem Trước -->
            <div class="bg-slate-50 border border-slate-200 rounded-lg p-6 flex flex-col items-center justify-center gap-4 grid-pattern">
              <img src="assets/logos/concept-2-icon.svg" alt="Concept 2 Icon" class="w-16 h-16 shadow-sm rounded-xl">
              <img src="assets/logos/concept-2-full.svg" alt="Concept 2 Full" class="h-12 max-w-full">
            </div>

            <!-- Bảng màu và Thông số kỹ thuật -->
            <div class="mt-4 pt-4 border-t border-slate-100 space-y-2">
              <div class="text-[11px] font-semibold text-slate-700">Thông Số Màu Sắc (Color Palette):</div>
              <div class="flex items-center gap-2">
                <div class="flex items-center gap-1.5 text-[11px]">
                  <span class="w-4 h-4 rounded bg-[#1E3A8A] inline-block border border-slate-300"></span>
                  <span class="font-mono text-slate-600">#1E3A8A (Xanh Đậm An Toàn)</span>
                </div>
              </div>
              <div class="flex items-center gap-2">
                <div class="flex items-center gap-1.5 text-[11px]">
                  <span class="w-4 h-4 rounded bg-[#EA580C] inline-block border border-slate-300"></span>
                  <span class="font-mono text-slate-600">#EA580C (Cam Kích Hoạt Mua Ngay)</span>
                </div>
              </div>
            </div>

            <!-- Phân tích ưu nhược điểm -->
            <div class="mt-4 text-xs space-y-1.5 bg-slate-50 p-3 rounded-lg border border-slate-200">
              <div class="font-bold text-slate-800 text-[11px]">Đặc điểm nổi bật:</div>
              <div class="text-slate-700 text-[11px]">- Nhấn mạnh cơ chế an toàn, giải quyết tâm lý sợ bị lừa đảo của người dùng.</div>
              <div class="text-slate-700 text-[11px]">- Màu cam tạo điểm nhấn tương phản mạnh mẽ, thôi thúc bấm nút mua.</div>
              <div class="text-slate-700 text-[11px]">- Phong cách dứt khoát, mang dáng dấp công nghệ tài chính (Fintech).</div>
            </div>
          </div>
        </div>

        <!-- CONCEPT 3 -->
        <div class="bg-white rounded-xl border border-slate-200 p-6 shadow-sm flex flex-col justify-between">
          <div>
            <div class="text-xs font-bold text-slate-500 uppercase tracking-wide">Phương Án 3</div>
            <h3 class="text-base font-bold text-slate-900 mt-1">Kiện Hàng & Giao Nhận Trao Đổi Đa Chiều</h3>
            <p class="text-xs text-slate-500 mt-1 mb-4 leading-normal">
              Hình tượng túi mua hàng và kiện hàng Re-Commerce mở ra, cấu trúc chữ M và mũi tên đa chiều kết nối việc mua bán, trao đổi và tặng đồ 0 đồng.
            </p>

            <!-- Khung Logo Xem Trước -->
            <div class="bg-slate-50 border border-slate-200 rounded-lg p-6 flex flex-col items-center justify-center gap-4 grid-pattern">
              <img src="assets/logos/concept-3-icon.svg" alt="Concept 3 Icon" class="w-16 h-16 shadow-sm rounded-xl">
              <img src="assets/logos/concept-3-full.svg" alt="Concept 3 Full" class="h-12 max-w-full">
            </div>

            <!-- Bảng màu và Thông số kỹ thuật -->
            <div class="mt-4 pt-4 border-t border-slate-100 space-y-2">
              <div class="text-[11px] font-semibold text-slate-700">Thông Số Màu Sắc (Color Palette):</div>
              <div class="flex items-center gap-2">
                <div class="flex items-center gap-1.5 text-[11px]">
                  <span class="w-4 h-4 rounded bg-[#4F46E5] inline-block border border-slate-300"></span>
                  <span class="font-mono text-slate-600">#4F46E5 (Tím Chàm Hiện Đại)</span>
                </div>
              </div>
              <div class="flex items-center gap-2">
                <div class="flex items-center gap-1.5 text-[11px]">
                  <span class="w-4 h-4 rounded bg-[#38BDF8] inline-block border border-slate-300"></span>
                  <span class="font-mono text-slate-600">#38BDF8 (Xanh Da Trời Năng Động)</span>
                </div>
              </div>
            </div>

            <!-- Phân tích ưu nhược điểm -->
            <div class="mt-4 text-xs space-y-1.5 bg-slate-50 p-3 rounded-lg border border-slate-200">
              <div class="font-bold text-slate-800 text-[11px]">Đặc điểm nổi bật:</div>
              <div class="text-slate-700 text-[11px]">- Tượng trưng rõ nét cho hàng hóa thương mại điện tử và đóng gói vận chuyển 3PL.</div>
              <div class="text-slate-700 text-[11px]">- Tone màu tím chàm mang phong cách nền tảng ứng dụng số thế hệ mới.</div>
              <div class="text-slate-700 text-[11px]">- Độc đáo, dễ phân biệt với các sàn truyền thống.</div>
            </div>
          </div>
        </div>

      </div>
    </section>

    <!-- KIỂM THỬ TRONG CÁC NGỮ CẢNH THỰC TẾ (REAL-WORLD CONTEXT SIMULATION) -->
    <section class="bg-white rounded-xl border border-slate-200 p-6 shadow-sm space-y-6">
      <div>
        <h2 class="text-lg font-bold text-slate-900 tracking-tight">3. Thử Nghiệm Ứng Dụng Trên Giao Diện Thực Tế</h2>
        <p class="text-xs text-slate-500">Mô phỏng hiển thị trên thanh Header trình duyệt, chế độ nền tối và biểu tượng ứng dụng</p>
      </div>

      <!-- MÔ PHỎNG HEADER CỦA PHƯƠNG ÁN 1 (KHUYÊN DÙNG) -->
      <div class="space-y-3">
        <div class="text-xs font-bold text-slate-700 flex items-center justify-between">
          <span>A. Hiển Thị Trên Thanh Điều Hướng Header Thực Tế (Phiên Bản Mới Nhất):</span>
          <span class="text-blue-600 text-[11px] font-normal">Chiều cao 48px chuẩn Desktop</span>
        </div>
        <div class="border border-slate-200 rounded-xl overflow-hidden shadow-sm bg-white">
          <div class="bg-slate-100 px-4 py-2 border-b border-slate-200 flex items-center gap-2">
            <span class="w-2.5 h-2.5 rounded-full bg-slate-300"></span>
            <span class="w-2.5 h-2.5 rounded-full bg-slate-300"></span>
            <span class="w-2.5 h-2.5 rounded-full bg-slate-300"></span>
            <span class="text-[11px] text-slate-400 font-mono ml-2">https://muangay.vn/</span>
          </div>
          <div class="px-6 py-3 flex items-center justify-between gap-4">
            <!-- Logo Header Thực Tế -->
            <a href="01-trang-chu.jsp" class="flex items-center gap-2.5">
              <img src="assets/logos/muangay-logo-icon.svg" alt="MuaNgay Logo" class="w-10 h-10 rounded-xl shadow-xs">
              <div>
                <span class="text-xl font-extrabold text-slate-900 tracking-tight leading-none block">Mua<span class="text-blue-600">Ngay</span></span>
                <span class="text-[10px] text-slate-500 font-medium block mt-0.5">Cần là Mua Ngay, thừa thì Pass Luôn</span>
              </div>
            </a>

            <!-- Giả lập Search Bar -->
            <div class="flex-1 max-w-md hidden md:block">
              <div class="relative">
                <input type="text" placeholder="Tìm xe máy, iPhone, tủ lạnh, phòng trọ..." class="w-full pl-3 pr-20 py-1.5 bg-slate-100 border border-slate-200 rounded-lg text-xs" readonly>
                <span class="absolute right-2 top-1.5 text-xs text-blue-600 font-semibold">Tìm kiếm</span>
              </div>
            </div>

            <!-- Nút Đăng Tin -->
            <div class="flex items-center gap-3">
              <button class="px-3.5 py-1.5 bg-blue-600 text-white rounded-lg text-xs font-bold shadow-xs">Đăng Tin Miễn Phí</button>
            </div>
          </div>
        </div>
      </div>

      <!-- MÔ PHỎNG NỀN TỐI (DARK MODE) VÀ KHUNG THẺ DI ĐỘNG -->
      <div class="grid grid-cols-1 md:grid-cols-2 gap-6 pt-4 border-t border-slate-100">
        
        <!-- Nền Tối (Dark Theme) -->
        <div class="space-y-2">
          <div class="text-xs font-bold text-slate-700">B. Khả Năng Tương Thích Giao Diện Tối (Dark Mode):</div>
          <div class="bg-slate-900 rounded-xl p-6 border border-slate-800 flex items-center justify-around gap-4">
            <div class="flex items-center gap-3">
              <img src="assets/logos/muangay-logo-icon.svg" alt="Concept 1 Dark" class="w-12 h-12 rounded-xl">
              <div>
                <span class="text-xl font-extrabold text-white tracking-tight leading-none block">Mua<span class="text-blue-400">Ngay</span></span>
                <span class="text-[10px] text-slate-400 font-medium block mt-0.5">Cần là Mua Ngay, thừa thì Pass Luôn</span>
              </div>
            </div>
          </div>
        </div>

        <!-- Biểu Tượng Ứng Dụng & Favicon -->
        <div class="space-y-2">
          <div class="text-xs font-bold text-slate-700">C. Khả Năng Nhận Diện Ở Kích Thước Nhỏ (Favicon & App Icon):</div>
          <div class="bg-slate-50 border border-slate-200 rounded-xl p-6 flex items-center justify-around">
            <div class="text-center space-y-1">
              <img src="assets/logos/muangay-logo-icon.svg" alt="Icon 16" class="w-4 h-4 mx-auto">
              <div class="text-[10px] font-mono text-slate-400">16x16px</div>
            </div>
            <div class="text-center space-y-1">
              <img src="assets/logos/muangay-logo-icon.svg" alt="Icon 32" class="w-8 h-8 mx-auto rounded-md shadow-xs">
              <div class="text-[10px] font-mono text-slate-400">32x32px</div>
            </div>
            <div class="text-center space-y-1">
              <img src="assets/logos/muangay-logo-icon.svg" alt="Icon 48" class="w-12 h-12 mx-auto rounded-xl shadow-xs">
              <div class="text-[10px] font-mono text-slate-400">48x48px (Mobile)</div>
            </div>
            <div class="text-center space-y-1">
              <img src="assets/logos/muangay-logo-icon.svg" alt="Icon 64" class="w-16 h-16 mx-auto rounded-2xl shadow-sm">
              <div class="text-[10px] font-mono text-slate-400">64x64px (App)</div>
            </div>
          </div>
        </div>

      </div>
    </section>

    <!-- TÀI NGUYÊN VECTOR VÀ HƯỚNG DẪN TÍCH HỢP -->
    <section class="bg-white rounded-xl border border-slate-200 p-6 shadow-sm space-y-4">
      <h2 class="text-lg font-bold text-slate-900 tracking-tight">4. Danh Mục Tệp Nguồn Vector Đã Tạo Lập</h2>
      <div class="overflow-x-auto">
        <table class="w-full text-left text-xs border-collapse">
          <thead>
            <tr class="border-b border-slate-200 bg-slate-50 text-slate-700">
              <th class="py-2.5 px-3 font-semibold">Tên Tệp</th>
              <th class="py-2.5 px-3 font-semibold">Định Dạng</th>
              <th class="py-2.5 px-3 font-semibold">Mục Đích Ứng Dụng</th>
              <th class="py-2.5 px-3 font-semibold">Trạng Thái</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-slate-100 text-slate-600">
            <tr class="bg-blue-50/50">
              <td class="py-2.5 px-3 font-mono text-blue-700 font-bold">assets/logos/muangay-logo-icon.svg</td>
              <td class="py-2.5 px-3 font-semibold text-blue-700">SVG Vector</td>
              <td class="py-2.5 px-3 text-slate-800 font-medium">Biểu tượng chính thức cải tiến (Icon 80%, Xanh hoàng gia &amp; Vàng Cam)</td>
              <td class="py-2.5 px-3 text-emerald-600 font-bold">Đang áp dụng</td>
            </tr>
            <tr class="bg-blue-50/50">
              <td class="py-2.5 px-3 font-mono text-blue-700 font-bold">assets/logos/muangay-logo-full.svg</td>
              <td class="py-2.5 px-3 font-semibold text-blue-700">SVG Vector</td>
              <td class="py-2.5 px-3 text-slate-800 font-medium">Bản ngang đầy đủ chính thức (Icon cải tiến + MuaNgay + Slogan)</td>
              <td class="py-2.5 px-3 text-emerald-600 font-bold">Đang áp dụng</td>
            </tr>
            <tr>
              <td class="py-2 px-3 font-mono text-slate-700">assets/logos/muangay-logo-v2-cyan-white.svg</td>
              <td class="py-2 px-3">SVG Vector</td>
              <td class="py-2 px-3">Biến thể V2: Xanh đại dương &amp; Trắng tuyết tối giản</td>
              <td class="py-2 px-3 text-blue-600 font-semibold">Dự phòng</td>
            </tr>
            <tr>
              <td class="py-2 px-3 font-mono text-slate-700">assets/logos/muangay-logo-v3-amber.svg</td>
              <td class="py-2 px-3">SVG Vector</td>
              <td class="py-2 px-3">Biến thể V3: Nền Cam rực rỡ phong cách sàn TMĐT sôi động</td>
              <td class="py-2 px-3 text-blue-600 font-semibold">Dự phòng</td>
            </tr>
            <tr>
              <td class="py-2 px-3 font-mono text-slate-400">assets/logos/concept-1-icon.svg</td>
              <td class="py-2 px-3 text-slate-400">SVG Vector</td>
              <td class="py-2 px-3 text-slate-400">Lưu trữ Phương án 1 (Kinh tế tuần hoàn M-N)</td>
              <td class="py-2 px-3 text-slate-400">Lưu trữ</td>
            </tr>
            <tr>
              <td class="py-2 px-3 font-mono text-slate-400">assets/logos/concept-2-icon.svg</td>
              <td class="py-2 px-3 text-slate-400">SVG Vector</td>
              <td class="py-2 px-3 text-slate-400">Lưu trữ Phương án 2 (Khiên bảo chứng &amp; Tia chớp)</td>
              <td class="py-2 px-3 text-slate-400">Lưu trữ</td>
            </tr>
          </tbody>
        </table>
      </div>
    </section>

  </main>

  <!-- CHÂN TRANG SHOWCASE -->
  <jsp:include page="includes/footer.jsp" />

</body>
</html>
