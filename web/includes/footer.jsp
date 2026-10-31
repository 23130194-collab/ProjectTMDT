<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<footer class="mt-16 bg-slate-900 text-slate-300">
  <div class="mx-auto max-w-7xl px-4 py-10 sm:px-6 lg:px-8">
    <div class="grid gap-9 sm:grid-cols-2 lg:grid-cols-4">
      <div>
        <a href="01-trang-chu.jsp" class="inline-flex items-center gap-3" aria-label="MuaNgay - Trang chủ">
          <img src="assets/logos/muangay-logo-icon.svg" alt="" class="h-10 w-10 rounded-xl">
          <span class="text-2xl font-extrabold tracking-tight text-white">Mua<span class="text-blue-400">Ngay</span></span>
        </a>
        <p class="mt-4 max-w-sm text-sm leading-6 text-slate-400">
          Sàn mua bán và thanh lý đồ đã qua sử dụng an toàn, tiện lợi. Giúp bạn tìm món đồ tốt với giá gần nhà và nhượng lại những món đồ ít dùng một cách nhanh chóng.
        </p>
      </div>

      <div>
        <h2 class="text-sm font-bold uppercase tracking-wide text-white">Về MuaNgay</h2>
        <ul class="mt-4 space-y-3 text-sm text-slate-400">
          <li><a href="01-trang-chu.jsp" class="transition hover:text-white">Giới thiệu về MuaNgay</a></li>
          <li><a href="03-dang-tin.jsp" class="transition hover:text-white">Quy định đăng tin & mua bán</a></li>
          <li><a href="05-quan-ly-don-hang.jsp" class="transition hover:text-white">Cơ chế sàn giữ tiền cọc an toàn</a></li>
          <li><a href="01-trang-chu.jsp" class="transition hover:text-white">Mẹo kiểm tra đồ cũ khi gặp mặt</a></li>
        </ul>
      </div>

      <div>
        <h2 class="text-sm font-bold uppercase tracking-wide text-white">Hỗ trợ mua bán</h2>
        <ul class="mt-4 space-y-3 text-sm text-slate-400">
          <li><a href="04-chat-tra-gia-vietqr.jsp" class="transition hover:text-white">Hướng dẫn nhắn tin & thương lượng giá</a></li>
          <li><a href="05-quan-ly-don-hang.jsp" class="transition hover:text-white">Cách thức gặp mặt & nhận hàng</a></li>
          <li><a href="05-quan-ly-don-hang.jsp" class="transition hover:text-white">Chính sách hoàn cọc & giải quyết tranh chấp</a></li>
          <li><a href="08-ho-so-ca-nhan.jsp" class="transition hover:text-white">Kiểm tra độ tin cậy của người bán</a></li>
        </ul>
      </div>

      <div>
        <h2 class="text-sm font-bold uppercase tracking-wide text-white">Thanh toán & giao nhận</h2>
        <ul class="mt-4 space-y-3 text-sm leading-5 text-slate-400">
          <li>Đặt cọc giữ đồ nhanh chóng và an toàn qua VNPay.</li>
          <li>Gặp mặt trực tiếp, kiểm tra đồ kỹ trước khi nhận.</li>
          <li>Nhận hàng qua bưu cục với chính sách hỗ trợ rõ ràng.</li>
        </ul>
      </div>
    </div>

    <div class="mt-10 flex flex-col gap-4 border-t border-slate-700 pt-6 text-xs text-slate-500 sm:flex-row sm:items-center sm:justify-between">
      <p>© <%= java.time.Year.now() %> MuaNgay.vn - Mua bán đồ cũ an toàn, thuận tiện cho mọi người.</p>
      <div class="flex gap-5">
        <a href="07-dang-nhap-xac-thuc.jsp" class="transition hover:text-slate-300">Điều khoản sử dụng</a>
        <a href="07-dang-nhap-xac-thuc.jsp" class="transition hover:text-slate-300">Chính sách bảo mật</a>
      </div>
    </div>
  </div>
</footer>
