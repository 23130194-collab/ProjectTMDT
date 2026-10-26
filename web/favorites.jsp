<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Tin yêu thích | MuaNgay</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <style>
    .favorite-card { transition: transform .18s ease, box-shadow .18s ease; }
    .favorite-card:hover { transform: translateY(-3px); box-shadow: 0 14px 30px rgba(15,23,42,.10); }
    .favorite-card.is-sold img { filter: grayscale(.72); }
  </style>
</head>
<body class="min-h-screen bg-slate-50 text-slate-800">
<jsp:include page="includes/header.jsp" />
<main class="mx-auto max-w-6xl px-4 py-8 sm:px-6 sm:py-10">
  <section class="mb-7 flex flex-col gap-4 rounded-2xl border border-slate-200 bg-white p-5 shadow-sm sm:flex-row sm:items-center sm:justify-between sm:p-7">
    <div class="flex items-center gap-4">
      <div class="flex h-12 w-12 shrink-0 items-center justify-center rounded-2xl bg-rose-50 text-rose-500">
        <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" aria-hidden="true"><path stroke-linecap="round" stroke-linejoin="round" d="M20.8 8.8c0 5.2-8.8 10.1-8.8 10.1S3.2 14 3.2 8.8A4.6 4.6 0 0 1 12 6.5a4.6 4.6 0 0 1 8.8 2.3Z"/></svg>
      </div>
      <div><h1 class="text-xl font-extrabold tracking-tight text-slate-900 sm:text-2xl">Tin đăng yêu thích</h1><p class="mt-1 text-sm text-slate-500">Những món đồ bạn muốn xem lại</p></div>
    </div>
    <button id="clearSold" type="button" class="inline-flex items-center justify-center gap-2 rounded-xl border border-rose-200 bg-white px-4 py-2.5 text-sm font-semibold text-rose-600 transition hover:bg-rose-50">
      <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" aria-hidden="true"><path stroke-linecap="round" stroke-linejoin="round" d="M4 7h16M10 11v6m4-6v6M5 7l1 13h12l1-13M9 7V4h6v3"/></svg>
      Xóa sản phẩm đã hết
    </button>
  </section>

  <c:choose>
    <c:when test="${not empty favorites}">
      <div class="mb-4 text-sm font-medium text-slate-500"><span class="text-slate-900"><c:out value="${favorites.size()}"/></span> tin đã lưu</div>
      <div class="grid grid-cols-1 items-stretch gap-5 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4">
        <c:forEach var="p" items="${favorites}">
          <article class="favorite-card ${p.status eq 'SOLD' ? 'is-sold' : ''} group flex h-full cursor-pointer flex-col overflow-hidden rounded-xl border border-slate-200 bg-white shadow-sm hover:shadow-md" data-favorite="${p.id}" data-detail-url="${pageContext.request.contextPath}/product-detail?id=${p.id}" role="link" tabindex="0" aria-label="Xem chi tiết ${p.title}" onclick="window.location.href=this.dataset.detailUrl" onkeydown="if(event.key==='Enter'||event.key===' '){event.preventDefault();window.location.href=this.dataset.detailUrl}">
              <div class="relative h-48 w-full shrink-0 overflow-hidden bg-slate-100 sm:h-52">
                <c:choose><c:when test="${not empty p.primaryImage}"><img class="h-full w-full object-cover transition duration-300 group-hover:scale-105" src="<c:out value='${p.primaryImage}'/>" alt="<c:out value='${p.title}'/>" loading="lazy"></c:when><c:otherwise><div class="flex h-full items-center justify-center bg-slate-200 text-xs text-slate-400">Không có ảnh</div></c:otherwise></c:choose>
                <c:choose>
                  <c:when test="${p.status eq 'SOLD'}"><span class="absolute left-3 top-3 rounded-full bg-slate-900/85 px-3 py-1.5 text-xs font-bold text-white">Sản phẩm đã hết</span></c:when>
                  <c:otherwise><span class="absolute left-3 top-3 rounded-full bg-white/95 px-3 py-1.5 text-xs font-semibold text-emerald-700 shadow-sm">Còn hàng</span></c:otherwise>
                </c:choose>
              </div>
              <div class="flex flex-1 flex-col justify-between p-4">
                <div><p class="text-base font-bold <c:out value='${p.status eq "SOLD" ? "text-slate-400" : "text-emerald-600"}'/>"><fmt:formatNumber value="${p.price}" pattern="#,###"/> đ</p>
                <h2 class="mt-1.5 line-clamp-2 h-10 text-xs font-semibold leading-relaxed text-slate-900 group-hover:text-blue-600"><c:out value="${p.title}"/></h2></div>
              </div>
            <div class="mt-auto flex items-center justify-between border-t border-slate-100 px-4 py-3 text-[11px]">
              <span class="font-semibold text-blue-600">Xem chi tiết <span aria-hidden="true">→</span></span>
              <button class="removeFavorite inline-flex items-center gap-1.5 rounded-lg px-2 py-1.5 text-xs font-medium text-slate-500 transition hover:bg-rose-50 hover:text-rose-600" type="button" data-id="${p.id}" onclick="event.stopPropagation()" onkeydown="event.stopPropagation()">
                <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" aria-hidden="true"><path stroke-linecap="round" stroke-linejoin="round" d="M4 7h16M10 11v6m4-6v6M5 7l1 13h12l1-13M9 7V4h6v3"/></svg>Xóa
              </button>
            </div>
          </article>
        </c:forEach>
      </div>
    </c:when>
    <c:otherwise>
      <section class="rounded-2xl border border-dashed border-slate-300 bg-white px-6 py-16 text-center">
        <div class="mx-auto flex h-16 w-16 items-center justify-center rounded-full bg-rose-50 text-rose-400"><svg class="h-8 w-8" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" aria-hidden="true"><path stroke-linecap="round" stroke-linejoin="round" d="M20.8 8.8c0 5.2-8.8 10.1-8.8 10.1S3.2 14 3.2 8.8A4.6 4.6 0 0 1 12 6.5a4.6 4.6 0 0 1 8.8 2.3Z"/></svg></div>
        <h2 class="mt-4 text-lg font-bold text-slate-900">Danh sách yêu thích đang trống</h2><p class="mt-1 text-sm text-slate-500">Lưu những tin bạn quan tâm để tiện xem lại nhé.</p>
        <a href="${pageContext.request.contextPath}/home" class="mt-5 inline-flex rounded-xl bg-blue-600 px-5 py-2.5 text-sm font-bold text-white transition hover:bg-blue-700">Khám phá tin đăng</a>
      </section>
    </c:otherwise>
  </c:choose>
</main>
<script>
const endpoint='${pageContext.request.contextPath}/favorites';
async function favoritePost(action,id){const data=new URLSearchParams({action});if(id)data.set('productId',id);const response=await fetch(endpoint,{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},body:data});return response.json();}
document.querySelectorAll('.removeFavorite').forEach(button=>button.addEventListener('click',async()=>{button.disabled=true;try{const result=await favoritePost('remove',button.dataset.id);if(result.success){const card=button.closest('[data-favorite]');card.remove();if(!document.querySelector('[data-favorite]'))location.reload();}else alert('Không thể xóa tin khỏi danh sách.');}catch(e){alert('Không thể kết nối tới máy chủ.');}finally{button.disabled=false;}}));
document.getElementById('clearSold').addEventListener('click',async()=>{if(!confirm('Xóa tất cả sản phẩm đã hết khỏi danh sách yêu thích?'))return;try{const result=await favoritePost('clearSold');if(result.success)location.reload();else alert('Không thể xóa sản phẩm đã hết.');}catch(e){alert('Không thể kết nối tới máy chủ.');}});
</script>
</body></html>
