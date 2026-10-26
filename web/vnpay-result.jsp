<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Kết quả thanh toán VNPay - MuaNgay</title>
  <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="min-h-screen bg-slate-100 flex items-center justify-center p-4 text-slate-900">
  <main class="w-full max-w-md rounded-2xl border border-slate-200 bg-white p-7 text-center shadow-lg">
    <c:choose>
      <c:when test="${paymentSuccessful}"><div class="mx-auto mb-4 flex h-14 w-14 items-center justify-center rounded-full bg-green-100 text-2xl font-bold text-green-700">✓</div></c:when>
      <c:otherwise><div class="mx-auto mb-4 flex h-14 w-14 items-center justify-center rounded-full bg-red-100 text-2xl font-bold text-red-700">!</div></c:otherwise>
    </c:choose>
    <h1 class="text-lg font-bold"><c:choose><c:when test="${paymentSuccessful}">Đặt cọc thành công</c:when><c:otherwise>Thanh toán chưa hoàn tất</c:otherwise></c:choose></h1>
    <p class="mt-2 text-sm text-slate-600"><c:out value="${paymentMessage}"/></p>
    <p class="mt-3 text-xs text-slate-500">Thanh toán thử nghiệm qua VNPay Sandbox.</p>
    <div class="mt-6 flex flex-col gap-2 sm:flex-row sm:justify-center">
      <c:if test="${!paymentSuccessful}">
        <a href="08-ho-so-ca-nhan.jsp?openEdit=1" class="rounded-lg bg-amber-600 px-4 py-2 text-sm font-semibold text-white hover:bg-amber-700">Cập nhật địa chỉ trong Hồ sơ</a>
      </c:if>
      <a href="04-chat-tra-gia-vietqr.jsp" class="rounded-lg bg-blue-600 px-4 py-2 text-sm font-semibold text-white hover:bg-blue-700">Quay lại chat</a>
      <a href="05-quan-ly-don-hang.jsp" class="rounded-lg border border-slate-300 px-4 py-2 text-sm font-semibold text-slate-700 hover:bg-slate-50">Quản lý đơn hàng</a>
    </div>
  </main>
</body>
</html>
