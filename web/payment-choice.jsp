<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%
  User paymentChoiceUser = (User) session.getAttribute("user");
  Integer choiceOrderId = (Integer) request.getAttribute("balanceChoiceOrderId");
  String resultMessage = (String) request.getAttribute("paymentMessage");
  String safeResultMessage = resultMessage == null ? "Đặt cọc thành công" : resultMessage.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
  if (paymentChoiceUser == null || choiceOrderId == null || choiceOrderId <= 0) {
    response.sendRedirect("05-quan-ly-don-hang.jsp");
    return;
  }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Chọn cách thanh toán phần còn lại - MuaNgay</title>
  <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="min-h-screen bg-slate-100 text-slate-900 flex items-center justify-center p-4">
  <main class="w-full max-w-xl rounded-2xl border border-slate-200 bg-white p-6 sm:p-8 shadow-lg">
    <div class="mx-auto mb-4 flex h-14 w-14 items-center justify-center rounded-full bg-emerald-100 text-2xl text-emerald-700">✓</div>
    <p class="text-center text-sm font-semibold text-emerald-700"><%= safeResultMessage %></p>
    <h1 class="mt-2 text-center text-2xl font-bold">Chọn cách thanh toán phần còn lại</h1>
    <p class="mt-2 text-center text-sm text-slate-600">Đơn hàng #<%= choiceOrderId %> đã được giữ. Chọn một phương thức để tiếp tục:</p>

    <div class="mt-6 grid gap-4 sm:grid-cols-2">
      <form method="post" action="order-action" class="rounded-xl border border-blue-200 bg-blue-50 p-5 flex flex-col">
        <input type="hidden" name="action" value="choose_balance_payment">
        <input type="hidden" name="orderId" value="<%= choiceOrderId %>">
        <input type="hidden" name="paymentMethod" value="TRANSFER">
        <div class="text-lg font-bold text-blue-900">Chuyển khoản</div>
        <p class="mt-2 flex-1 text-sm text-slate-600">Thanh toán phần còn lại qua VNPay. Bạn có 24 giờ kể từ lúc chọn; quá hạn đơn bị hủy và tiền cọc không được hoàn lại.</p>
        <button class="mt-5 w-full rounded-lg bg-blue-600 px-4 py-3 text-sm font-bold text-white hover:bg-blue-700">Chọn chuyển khoản</button>
      </form>

      <form method="post" action="order-action" class="rounded-xl border border-emerald-200 bg-emerald-50 p-5 flex flex-col">
        <input type="hidden" name="action" value="choose_balance_payment">
        <input type="hidden" name="orderId" value="<%= choiceOrderId %>">
        <input type="hidden" name="paymentMethod" value="COD">
        <div class="text-lg font-bold text-emerald-900">Thanh toán khi nhận hàng</div>
        <p class="mt-2 flex-1 text-sm text-slate-600">Bạn thanh toán số tiền còn lại trực tiếp cho người bán hoặc khi nhận hàng qua đơn vị vận chuyển.</p>
        <button class="mt-5 w-full rounded-lg bg-emerald-600 px-4 py-3 text-sm font-bold text-white hover:bg-emerald-700">Chọn thanh toán khi nhận</button>
      </form>
    </div>
    <p class="mt-5 text-center text-xs text-slate-500">Tiền cọc đã được xác nhận qua VNPay. Mã đơn hàng: #<%= choiceOrderId %>.</p>
  </main>
</body>
</html>
