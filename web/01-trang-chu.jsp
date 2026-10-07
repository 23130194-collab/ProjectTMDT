<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Trang Chủ - MuaNgay | Sàn Thương Mại Điện Tử B2C Market Creator</title>
  <link rel="icon" type="image/svg+xml" href="assets/logos/muangay-logo-icon.svg">
  <script src="https://cdn.tailwindcss.com"></script>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="css/style.css">
  <link rel="stylesheet" href="css/01-trang-chu.css">
  <style>
.new-products-shell {
      position: relative;
      background: #ffd3ea;
      border: 1px solid #ffc2df;
      box-shadow: 0 14px 34px rgba(244, 114, 182, 0.18);
      padding-top: 42px;
    }

    .new-products-title-tab {
      position: absolute;
      top: -14px;
      left: 50%;
      transform: translateX(-50%);
      min-width: 260px;
      padding: 10px 30px 12px;
      text-align: center;
      color: #ffffff;
      font-weight: 800;
      font-size: 18px;
      line-height: 1;
      background: linear-gradient(180deg, #ff1a13 0%, #e70000 100%);
      border-radius: 0 0 42px 42px;
      box-shadow: 0 8px 18px rgba(220, 38, 38, 0.22);
    }
    .new-products-title-tab::before,
    .new-products-title-tab::after {
      content: "";
      position: absolute;
      top: 0;
      width: 28px;
      height: 28px;
      background: #e70000;
    }
    .new-products-title-tab::before {
      left: -28px;
      border-top-left-radius: 14px;
      clip-path: polygon(100% 0, 100% 100%, 0 0);
    }
    .new-products-title-tab::after {
      right: -28px;
      border-top-right-radius: 14px;
      clip-path: polygon(0 0, 100% 0, 0 100%);
    }
    .new-products-wrap {
      position: relative;
    }
    .new-products-marquee {
      overflow-x: auto;
      overflow-y: hidden;
      scroll-snap-type: x mandatory;
      scroll-behavior: smooth;
      scrollbar-width: none;
      padding: 0 42px;
    }
    .new-products-marquee::-webkit-scrollbar {
      display: none;
    }
    .new-products-track {
      display: flex;
      width: 100%;
    }
    .new-product-slide {
      flex: 0 0 calc((100% - 48px) / 4);
      width: calc((100% - 48px) / 4);
      min-width: calc((100% - 48px) / 4);
      scroll-snap-align: start;
      border-radius: 14px;
      border-color: #ffe1f0 !important;
      box-shadow: 0 8px 18px rgba(15, 23, 42, 0.08);
    }
    .new-products-nav {
      position: absolute;
      top: 50%;
      z-index: 10;
      width: 42px;
      height: 42px;
      transform: translateY(-50%);
      border-radius: 999px;
      border: 1px solid #e5e7eb;
      background: #ffffff;
      color: #2563eb;
      font-size: 24px;
      font-weight: 800;
      line-height: 1;
      box-shadow: 0 10px 26px rgba(15, 23, 42, 0.14);
      transition: color 150ms ease, transform 150ms ease, box-shadow 150ms ease;
    }
    .new-products-nav:hover {
      color: #1d4ed8;
      transform: translateY(-50%) scale(1.05);
      box-shadow: 0 12px 28px rgba(37, 99, 235, 0.22);
    }
    .new-products-nav.prev {
      left: 8px;
    }
    .new-products-nav.next {
      right: 8px;
    }
  </style>
</head>
<body class="bg-slate-50 text-slate-900 min-h-screen flex flex-col">

  <!-- THANH ĐIỀU HƯỚNG CHÍNH (HEADER) -->
  <jsp:include page="includes/header.jsp" />

  <!-- BANNER TỔNG QUAN VÀ BẢO CHỨNG 2 KÊNH GIAO NHẬN -->
  <section class="bg-gradient-to-r from-blue-700 to-indigo-900 text-white py-8">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 flex flex-col lg:flex-row items-center justify-between gap-6">
      <div>
        <div class="inline-flex items-center gap-2 px-3 py-1 rounded-full text-xs font-semibold bg-blue-500 bg-opacity-30 border border-blue-400 mb-3">
          <span>Sàn Mua Bán Đồ Cũ An Toàn & Đảm Bảo</span>
        </div>
        <h1 class="text-2xl sm:text-3xl font-bold tracking-tight">Cần Là Mua Ngay, Thừa Thì Pass Luôn</h1>
        <p class="text-blue-100 text-xs sm:text-sm mt-2 max-w-2xl leading-relaxed">
          Mua bán đồ cũ an tâm tuyệt đối: Hẹn gặp đặt cọc giữ chỗ chống bỏ hẹn, hoặc Giao hàng tận nhà được dùng thử kiểm tra trong 2 ngày trước khi thanh toán.
        </p>
      </div>
      
      <!-- KHỐI CHỈ SỐ BẢO CHỨNG -->
      <div class="grid grid-cols-3 gap-3 w-full lg:w-auto">
        <div class="bg-white/10 backdrop-blur rounded-lg p-3 text-center border border-white/20">
          <div class="text-lg sm:text-xl font-bold text-amber-300">100%</div>
          <div class="text-[11px] text-blue-100 mt-0.5">Tài khoản chính chủ</div>
        </div>
        <div class="bg-white/10 backdrop-blur rounded-lg p-3 text-center border border-white/20">
          <div class="text-lg sm:text-xl font-bold text-emerald-300">48 Giờ</div>
          <div class="text-[11px] text-blue-100 mt-0.5">Dùng thử tại nhà</div>
        </div>
        <div class="bg-white/10 backdrop-blur rounded-lg p-3 text-center border border-white/20">
          <div class="text-lg sm:text-xl font-bold text-cyan-300">0 Đồng</div>
          <div class="text-[11px] text-blue-100 mt-0.5">Đăng tin miễn phí</div>
        </div>
      </div>
    </div>
  </section>

  <!-- THANH DANH MỤC NHANH (CATEGORY QUICK BAR - TẤT CẢ NÚT ĐỀU LỌC ĐƯỢC) -->
  <section class="bg-white border-b border-slate-200 py-3 shadow-2xs">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 flex items-center gap-3 overflow-x-auto text-xs no-scrollbar">
      <button onclick="selectCategory('all', this)" class="cat-btn px-3.5 py-1.5 rounded-lg text-xs font-bold bg-blue-600 text-white whitespace-nowrap shadow-xs transition">
        Tất Cả Danh Mục
      </button>
      <button onclick="selectCategory('dientu', this)" class="cat-btn px-3.5 py-1.5 rounded-lg text-xs font-medium bg-slate-100 hover:bg-slate-200 text-slate-700 whitespace-nowrap transition">
        Điện Tử & Thiết Bị Số
      </button>
      <button onclick="selectCategory('xeco', this)" class="cat-btn px-3.5 py-1.5 rounded-lg text-xs font-medium bg-slate-100 hover:bg-slate-200 text-slate-700 whitespace-nowrap transition">
        Xe Cộ & Phương Tiện
      </button>
      <button onclick="selectCategory('dienlanh', this)" class="cat-btn px-3.5 py-1.5 rounded-lg text-xs font-medium bg-slate-100 hover:bg-slate-200 text-slate-700 whitespace-nowrap transition">
        Điện Lạnh & Gia Dụng
      </button>
      <button onclick="selectCategory('noithat', this)" class="cat-btn px-3.5 py-1.5 rounded-lg text-xs font-medium bg-slate-100 hover:bg-slate-200 text-slate-700 whitespace-nowrap transition">
        Nội Thất & Đồ Gia Đình
      </button>
      <button onclick="selectCategory('chotang', this)" class="cat-btn px-3.5 py-1.5 rounded-lg text-xs font-semibold bg-amber-100 hover:bg-amber-200 text-amber-900 whitespace-nowrap transition">
        Tặng Miễn Phí (0đ)
      </button>
    </div>
  </section>

  <!-- NỘI DUNG CHÍNH: BẢNG TIN SẢN PHẨM TOÀN SÀN -->
  <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 flex-1 w-full">
    <!-- TIÊU ĐỀ KHU VỰC VÀ BỘ LỌC ĐA TIÊU CHÍ (THEO USE CASE UC06) -->
    <div class="flex flex-col lg:flex-row items-start lg:items-center justify-between pb-6 border-b border-slate-200 gap-4">
      <div>
        <h2 id="sectionTitle" class="text-xl font-bold text-slate-900">
          <c:choose>
            <c:when test="${not empty searchKeyword}">Kết quả tìm kiếm cho: <c:out value="${searchKeyword}"/></c:when>
            <c:otherwise>Tin Đăng Mới Nhất Quanh Khu Vực Của Bạn</c:otherwise>
          </c:choose>
        </h2>
        <p id="resultCountText" class="text-xs text-slate-500 mt-1">
          <c:choose>
            <c:when test="${not empty searchKeyword}">Tìm thấy ${products.size()} sản phẩm phù hợp</c:when>
            <c:otherwise>Đang hiển thị ${products.size()} tin đăng mới nhất</c:otherwise>
          </c:choose>
        </p>
      </div>

      <div class="flex flex-wrap items-center gap-2 sm:gap-3 text-xs">
        <!-- LỌC PHƯƠNG THỨC GIAO NHẬN -->
        <div class="flex items-center gap-1.5">
          <span class="text-slate-500 font-medium">Giao nhận:</span>
          <select id="shippingFilter" onchange="applyFilters()" class="bg-white border border-slate-300 rounded-lg px-2.5 py-1.5 font-medium text-slate-700 focus:outline-none focus:ring-2 focus:ring-blue-500 cursor-pointer">
            <option value="all">Tất cả phương thức</option>
            <option value="pickup">Hẹn gặp trực tiếp</option>
            <option value="3pl">Giao tận nhà (Dùng thử 2 ngày)</option>
          </select>
        </div>

        <!-- LỌC QUẬN/HUYỆN -->
        <div class="flex items-center gap-1.5">
          <span class="text-slate-500 font-medium">Khu vực:</span>
          <select id="districtFilter" onchange="applyFilters()" class="bg-white border border-slate-300 rounded-lg px-2.5 py-1.5 font-medium text-slate-700 focus:outline-none focus:ring-2 focus:ring-blue-500 cursor-pointer">
            <option value="all">Tất cả Quận/Huyện</option>
            <option value="q1">Quận 1</option>
            <option value="q10">Quận 10</option>
            <option value="binhthanh">Quận Bình Thạnh</option>
            <option value="thuduc">TP. Thủ Đức</option>
            <option value="tanbinh">Quận Tân Bình</option>
            <option value="govap">Quận Gò Vấp</option>
            <option value="q7">Quận 7</option>
          </select>
        </div>

        <!-- SẮP XẾP -->
        <select id="sortOrder" onchange="applyFilters()" class="bg-white border border-slate-300 rounded-lg px-2.5 py-1.5 font-medium text-slate-700 focus:outline-none focus:ring-2 focus:ring-blue-500 cursor-pointer">
          <option value="newest">Mới nhất trước</option>
          <option value="price_asc">Giá tăng dần</option>
          <option value="price_desc">Giá giảm dần</option>
        </select>
      </div>
    </div>

    <!-- LƯỚI BÀI ĐĂNG SẢN PHẨM: ĐỒNG BỘ 100% CHIỀU CAO KHUNG CARD -->
    <div id="productGrid" class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6 mt-6 items-stretch">
      <c:choose>
        <c:when test="${empty products}">
          <div class="col-span-full text-center py-12 text-slate-500">
            <c:choose>
              <c:when test="${not empty searchKeyword}">
                <p>Không tìm thấy sản phẩm phù hợp với từ khóa “<c:out value="${searchKeyword}"/>”.</p>
              </c:when>
              <c:otherwise>
                <p>Chưa có sản phẩm nào trên hệ thống. Hãy là người đầu tiên đăng tin!</p>
              </c:otherwise>
            </c:choose>
          </div>
        </c:when>
        <c:otherwise>
          <c:forEach var="p" items="${products}">
            <div class="product-card bg-white rounded-xl border border-slate-200 overflow-hidden shadow-sm hover:shadow-md transition flex flex-col group h-full cursor-pointer" data-category="${p.categoryId == 3 ? 'xeco' : 'dientu'}" data-shipping="${p.deliveryMethod == 2 ? '3pl' : 'pickup'}" data-district="all" data-price="${p.price}" onclick="window.location.href='product-detail?id=${p.id}'">
              <div class="relative w-full h-48 sm:h-52 bg-slate-100 overflow-hidden shrink-0">
                <c:choose>
                  <c:when test="${not empty p.primaryImage}">
                    <img src="${p.primaryImage}" alt="${p.title}" class="w-full h-full object-cover group-hover:scale-105 transition duration-300">
                  </c:when>
                  <c:otherwise>
                    <div class="w-full h-full flex items-center justify-center text-slate-400 bg-slate-200 text-xs">Không có ảnh</div>
                  </c:otherwise>
                </c:choose>
                <c:if test="${p.newProduct}"><span class="absolute top-2.5 left-2.5 bg-red-600 text-white text-[10px] font-bold px-2 py-0.5 rounded shadow-sm">Mới</span></c:if>
              </div>
              <div class="p-4 flex-1 flex flex-col justify-between">
                <div>
                  <div class="text-base font-bold text-green-600"><fmt:formatNumber value="${p.price}" pattern="#,###"/> đ</div>
                  <h3 class="font-semibold text-slate-900 text-xs mt-1.5 group-hover:text-blue-600 line-clamp-2 leading-relaxed h-9">
                    ${p.title}
                  </h3>
                </div>
                <div class="mt-3 pt-3 border-t border-slate-100 flex items-center justify-between text-[11px] text-slate-500">
                  <span class="truncate pr-2">${p.location}</span>
                  <span class="whitespace-nowrap flex-shrink-0">Vừa xong</span>
                </div>
              </div>
            </div>
          </c:forEach>
        </c:otherwise>
      </c:choose>
    </div>

    <!-- NÚT XEM THÊM (CÓ LOGIC NẠP THÊM CARD MẪU) -->
    <div class="text-center mt-10">
      <button id="loadMoreBtn" onclick="loadMoreProducts()" class="px-6 py-2.5 bg-white border border-slate-300 rounded-lg text-xs font-semibold text-slate-700 hover:bg-slate-50 shadow-sm transition">
        Xem Thêm Tin Đăng Khác
      </button>
    </div>
    <c:if test="${not empty newProducts}">
      <section class="new-products-shell rounded-2xl p-4 sm:p-5 mt-12">
        <div class="new-products-title-tab">Sản phẩm mới</div>

        <div class="new-products-wrap">
          <button type="button" onclick="scrollNewProducts(-1)" class="new-products-nav prev" aria-label="Xem sản phẩm mới trước">‹</button>
          <div id="newProductsScroller" class="new-products-marquee">
            <div class="new-products-track gap-4 pb-1">
              <c:forEach var="p" items="${newProducts}">
                <div class="new-product-slide bg-white overflow-hidden transition flex flex-col group cursor-pointer" onclick="window.location.href='product-detail?id=${p.id}'">
                  <div class="relative w-full h-36 bg-slate-100 overflow-hidden shrink-0">
                    <c:choose>
                      <c:when test="${not empty p.primaryImage}">
                        <img src="${p.primaryImage}" alt="${p.title}" class="w-full h-full object-cover group-hover:scale-105 transition duration-300">
                      </c:when>
                      <c:otherwise>
                        <div class="w-full h-full flex items-center justify-center text-slate-400 bg-slate-200 text-xs">Không có ảnh</div>
                      </c:otherwise>
                    </c:choose>
                    <c:if test="${p.newProduct}">
                      <span class="absolute top-2.5 left-2.5 bg-red-600 text-white text-[10px] font-bold px-2 py-0.5 rounded shadow-sm">Mới</span>
                    </c:if>
                  </div>
                  <div class="p-3 flex-1 flex flex-col justify-between">
                    <div>
                      <div class="text-sm font-bold text-green-600"><fmt:formatNumber value="${p.price}" pattern="#,###"/> đ</div>
                      <h3 class="font-semibold text-slate-900 text-xs mt-1.5 group-hover:text-blue-600 line-clamp-2 leading-relaxed h-9">${p.title}</h3>
                    </div>
                    <div class="mt-3 pt-2 border-t border-slate-100 flex items-center justify-between gap-2 text-[11px] text-slate-500">
                      <span class="truncate">${p.location}</span>
                      <span class="whitespace-nowrap text-red-600 font-semibold">Mới</span>
                    </div>
                  </div>
                </div>
              </c:forEach>
            </div>
          </div>
          <button type="button" onclick="scrollNewProducts(1)" class="new-products-nav next" aria-label="Xem sản phẩm mới tiếp theo">›</button>
        </div>
      </section>
    </c:if>
  </main>

  <!-- CHÂN TRANG ĐỒNG BỘ 8 MÀN HÌNH -->
  <jsp:include page="includes/footer.jsp" />

  <!-- SCRIPT XỬ LÝ TOÀN BỘ BỘ LỌC, TÌM KIẾM, SẮP XẾP VÀ XEM THÊM -->
  <script>
    let activeCategory = 'all';

    function selectCategory(category, btnElement) {
      activeCategory = category;
      
      // Update UI tabs
      document.querySelectorAll('.cat-btn').forEach(btn => {
        btn.className = 'cat-btn px-3.5 py-1.5 rounded-lg text-xs font-medium bg-slate-100 hover:bg-slate-200 text-slate-700 whitespace-nowrap transition';
      });
      if (btnElement) {
        btnElement.className = 'cat-btn px-3.5 py-1.5 rounded-lg text-xs font-bold bg-blue-600 text-white whitespace-nowrap shadow-xs transition';
      }

      applyFilters();
    }

    function handleSearch(e) {
      e.preventDefault();
      applyFilters();
    }

    function applyFilters() {
      const keyword = (document.getElementById('searchInput').value || '').toLowerCase().trim();
      const shipping = document.getElementById('shippingFilter').value;
      const district = document.getElementById('districtFilter').value;
      const sortOrder = document.getElementById('sortOrder').value;

      const grid = document.getElementById('productGrid');
      const cards = Array.from(grid.querySelectorAll('.product-card'));
      let visibleCount = 0;

      cards.forEach(card => {
        const cat = card.getAttribute('data-category');
        const ship = card.getAttribute('data-shipping');
        const dist = card.getAttribute('data-district');
        const title = card.querySelector('h3').innerText.toLowerCase();

        let matchCategory = (activeCategory === 'all') || (cat === activeCategory);
        let matchShipping = (shipping === 'all') || (ship === shipping);
        let matchDistrict = (district === 'all') || (dist === district);
        let matchSearch = !keyword || title.includes(keyword);

        if (matchCategory && matchShipping && matchDistrict && matchSearch) {
          card.style.display = 'flex';
          visibleCount++;
        } else {
          card.style.display = 'none';
        }
      });

      // Sorting visible cards
      if (sortOrder === 'price_asc' || sortOrder === 'price_desc') {
        const sorted = cards.sort((a, b) => {
          const priceA = parseInt(a.getAttribute('data-price')) || 0;
          const priceB = parseInt(b.getAttribute('data-price')) || 0;
          return sortOrder === 'price_asc' ? priceA - priceB : priceB - priceA;
        });
        sorted.forEach(c => grid.appendChild(c));
      }

      // Update count text
      document.getElementById('resultCountText').innerText = `Đang hiển thị \${visibleCount} tin đăng phù hợp với tiêu chí lọc`;
    }


    function scrollNewProducts(direction) {
      const scroller = document.getElementById('newProductsScroller');
      if (!scroller) return;
      const card = scroller.querySelector('.new-product-slide');
      if (!card) return;
      const gap = 16;
      const step = card.getBoundingClientRect().width + gap;
      const maxScroll = scroller.scrollWidth - scroller.clientWidth;
      const nextLeft = scroller.scrollLeft + (direction * step);

      if (nextLeft > maxScroll - 2) {
        scroller.scrollTo({ left: 0, behavior: 'smooth' });
      } else if (nextLeft < 0) {
        scroller.scrollTo({ left: maxScroll, behavior: 'smooth' });
      } else {
        scroller.scrollBy({ left: direction * step, behavior: 'smooth' });
      }
    }

    setInterval(() => scrollNewProducts(1), 4000);
    function loadMoreProducts() {
      const grid = document.getElementById('productGrid');
      const extraCards = [
        {
          cat: 'dientu',
          ship: '3pl',
          dist: 'q10',
          price: '8500000',
          priceStr: '8.500.000 đ',
          img: 'assets/images/products/macbook-pro.jpg',
          title: 'MacBook Air M1 2020 màu Gold 8GB/256GB pin 90% sạc zin',
          loc: 'Quận 10, TP.HCM',
          tag: 'Ship 3PL • Giam tiền 48h'
        },
        {
          cat: 'noithat',
          ship: 'pickup',
          dist: 'binhthanh',
          price: '650000',
          priceStr: '650.000 đ',
          img: 'assets/images/products/ghe-ergonomic.jpg',
          title: 'Kệ sách gỗ 4 tầng để đồ trang trí còn như mới',
          loc: 'Quận Bình Thạnh, TP.HCM',
          tag: 'Chỉ gặp mặt trực tiếp'
        }
      ];

      extraCards.forEach(item => {
        const card = document.createElement('div');
        card.setAttribute('data-category', item.cat);
        card.setAttribute('data-shipping', item.ship);
        card.setAttribute('data-district', item.dist);
        card.setAttribute('data-price', item.price);
        card.className = 'product-card bg-white rounded-xl border border-slate-200 overflow-hidden shadow-sm hover:shadow-md transition flex flex-col group h-full cursor-pointer';
        card.onclick = () => window.location.href = '02-chi-tiet-san-pham.jsp';
        card.innerHTML = `
          <div class="relative w-full h-48 sm:h-52 bg-slate-100 overflow-hidden shrink-0">
            <img src="\${item.img}" alt="\${item.title}" class="w-full h-full object-cover group-hover:scale-105 transition duration-300">
            <span class="absolute top-2.5 left-2.5 bg-red-600 text-white text-[10px] font-bold px-2 py-0.5 rounded shadow-sm">Mới</span>
            <span class="absolute bottom-2.5 right-2.5 bg-slate-900/80 backdrop-blur text-white text-[10px] font-medium px-2 py-0.5 rounded">\${item.tag}</span>
          </div>
          <div class="p-4 flex-1 flex flex-col justify-between">
            <div>
              <div class="text-base font-bold text-green-600">\${item.priceStr}</div>
              <h3 class="font-semibold text-slate-900 text-xs mt-1.5 group-hover:text-blue-600 line-clamp-2 leading-relaxed h-9">
                \${item.title}
              </h3>
            </div>
            <div class="mt-3 pt-3 border-t border-slate-100 flex items-center justify-between text-[11px] text-slate-500">
              <span>\${item.loc}</span>
              <span>Vừa đăng xong</span>
            </div>
          </div>
        `;
        grid.appendChild(card);
      });

      const btn = document.getElementById('loadMoreBtn');
      btn.innerText = 'Đã tải toàn bộ tin đăng hôm nay';
      btn.disabled = true;
      btn.className = 'px-6 py-2.5 bg-slate-100 text-slate-400 border border-slate-200 rounded-lg text-xs font-semibold';
      applyFilters();
    }
  </script>

  <%
      String msg = request.getParameter("message");
      if ("post_success".equals(msg)) {
  %>
  <div id="successToast" class="fixed bottom-5 right-5 bg-green-500 text-white px-6 py-3 rounded-xl shadow-lg z-50 flex items-center gap-3 transition-opacity duration-500">
      <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path></svg>
      <span class="font-medium text-sm">Đăng tin thành công! Chờ admin duyệt nhé.</span>
  </div>
  <script>
      setTimeout(() => {
          const toast = document.getElementById('successToast');
          if(toast) {
              toast.style.opacity = '0';
              setTimeout(() => toast.remove(), 500);
          }
      }, 3000);
  </script>
  <% } %>
</body>
</html>
