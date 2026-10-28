<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Product" %>
<%@ page import="model.ProductImage" %>
<%@ page import="model.BoostPackage" %>
<%@ page import="util.JsonUtil" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.List" %>
<%@ page import="model.User" %>
<%!
  private String h(String value) {
    if (value == null) return "";
    return value.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
            .replace("\"", "&quot;").replace("'", "&#39;");
  }
%>
<%
  Product editProduct = (Product) request.getAttribute("editProduct");
  boolean isEditMode = (editProduct != null);
  @SuppressWarnings("unchecked")
  List<ProductImage> editProductImages = (List<ProductImage>) request.getAttribute("editProductImages");
  if (editProductImages == null) editProductImages = new java.util.ArrayList<>();
  // Build JSON array of existing image URLs for JS
  StringBuilder existingImagesJsonSb = new StringBuilder("[");
  for (int i = 0; i < editProductImages.size(); i++) {
    if (i > 0) existingImagesJsonSb.append(",");
    existingImagesJsonSb.append("{\"url\":\"").append(editProductImages.get(i).getImageUrl().replace("\\", "\\\\").replace("\"", "\\\"")).append("\",\"primary\":").append(editProductImages.get(i).isPrimary()).append("}");
  }
  existingImagesJsonSb.append("]");
  String existingImagesJson = existingImagesJsonSb.toString();

  // Kiểm tra trạng thái đăng nhập để truyền vào JS
  boolean isLoggedIn = (session != null && session.getAttribute("user") != null);
  User sessionUser = session != null ? (User) session.getAttribute("user") : null;
  if (sessionUser == null && session != null) sessionUser = (User) session.getAttribute("currentUser");

  // Đọc dữ liệu form trả về khi có lỗi validate (hoặc lấy từ editProduct / sessionUser)
  String reqTitle = (String) request.getAttribute("formTitle");
  String formTitle = reqTitle != null ? reqTitle : (isEditMode ? editProduct.getTitle() : "");
  String reqPrice = (String) request.getAttribute("formPrice");
  String formPrice = reqPrice != null ? reqPrice : (isEditMode ? (editProduct.getPrice() == 0 ? "" : String.valueOf((long)editProduct.getPrice())) : "");
  String reqDesc = (String) request.getAttribute("formDesc");
  String formDesc = reqDesc != null ? reqDesc : (isEditMode ? (editProduct.getDescription() != null ? editProduct.getDescription() : "") : "");
  Integer reqCatId = (Integer) request.getAttribute("formCatId");
  int formCatId = reqCatId != null ? reqCatId : (isEditMode ? editProduct.getCategoryId() : 1);
  Integer reqDelivery = (Integer) request.getAttribute("formDelivery");
  int formDelivery = reqDelivery != null ? reqDelivery : (isEditMode ? editProduct.getDeliveryMethod() : 1);
  String reqProvince = (String) request.getAttribute("formProvince");
  String formProvince = reqProvince != null ? reqProvince : (isEditMode ? editProduct.getProvince() : (sessionUser != null && sessionUser.getProvince() != null ? sessionUser.getProvince() : ""));
  String reqWard = (String) request.getAttribute("formWard");
  String formWard = reqWard != null ? reqWard : (isEditMode ? editProduct.getWard() : (sessionUser != null && sessionUser.getWard() != null ? sessionUser.getWard() : ""));
  String reqAddr = (String) request.getAttribute("formAddressDetail");
  String formAddressDetail = reqAddr != null ? reqAddr : (isEditMode ? editProduct.getAddressDetail() : (sessionUser != null && sessionUser.getAddressDetail() != null ? sessionUser.getAddressDetail() : ""));
  String reqDeal = (String) request.getAttribute("formDealType");
  String formDealType = reqDeal != null ? reqDeal : (isEditMode && "GIVE".equals(editProduct.getDealType()) ? "give" : "sell");

  String reqSpecsJson = (String) request.getAttribute("formSpecsJson");
  Map<String,String> editSpecs = reqSpecsJson != null ? JsonUtil.jsonToMap(reqSpecsJson) : (isEditMode ? JsonUtil.jsonToMap(editProduct.getSpecifications()) : new java.util.HashMap<>());
  if (editSpecs == null) editSpecs = new java.util.HashMap<>();
  String specsJsObj = JsonUtil.mapToJson(editSpecs);

  String moderationError = (String) request.getAttribute("moderationError");
  String imageError = (String) request.getAttribute("imageError");
  String generalError = (String) request.getAttribute("generalError");

  @SuppressWarnings("unchecked")
  List<BoostPackage> boostPackages = (List<BoostPackage>) request.getAttribute("boostPackages");
  if (boostPackages == null) {
      try { boostPackages = new dao.BoostPackageDAO().getAllActivePackages(); } catch (Exception ignored) {}
  }
  Integer userBumpCredits = (Integer) request.getAttribute("userBumpCredits");
  if (userBumpCredits == null && sessionUser != null) {
      try { userBumpCredits = new dao.UserDao().getUserBumpCredits(sessionUser.getId()); } catch (Exception ignored) {}
  }
  if (userBumpCredits == null) userBumpCredits = 0;
%>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title><%= isEditMode ? "Sửa Tin Đăng - MuaNgay" : "Đăng Tin Mua Bán & Thanh Lý - MuaNgay" %></title>
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
    
    <form id="postAdForm" action="<%= isEditMode ? "edit-post" : "post-ad" %>" method="POST" enctype="multipart/form-data" class="bg-white rounded-xl border border-slate-200 shadow-sm p-6 sm:p-8 space-y-8">
      <% if (isEditMode) { %>
        <input type="hidden" name="productId" value="<%= editProduct.getId() %>">
        <script type="application/json" id="editSpecsJson"><%= specsJsObj %></script>
      <% } else { %>
        <script type="application/json" id="editSpecsJson">{}</script>
      <% } %>
      <div class="space-y-3">
        <h1 class="text-xl sm:text-2xl font-bold text-slate-900"><%= isEditMode ? "Sửa Tin Đăng" : "Đăng Tin Mua Bán & Thanh Lý Đồ Dùng" %></h1>
        <p class="text-xs text-slate-500 mt-1"><%= isEditMode ? "Cập nhật thông tin bài đăng của bạn" : "Tiếp cận hàng ngàn người mua trong khu vực với cơ chế đặt cọc giữ chỗ an tâm" %></p>

        <% if (moderationError != null && !moderationError.isEmpty()) { %>
          <div class="p-3.5 bg-red-50 border-l-4 border-red-500 rounded-r-xl flex items-start gap-3 shadow-xs">
            <svg class="w-5 h-5 text-red-500 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/></svg>
            <div class="text-xs text-red-800">
              <span class="font-bold block text-sm mb-0.5">Nội dung chưa được duyệt:</span>
              <%= h(moderationError) %>
            </div>
          </div>
        <% } %>

        <% if (imageError != null && !imageError.isEmpty()) { %>
          <div class="p-3.5 bg-amber-50 border-l-4 border-amber-500 rounded-r-xl flex items-start gap-3 shadow-xs">
            <svg class="w-5 h-5 text-amber-500 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"/></svg>
            <div class="text-xs text-amber-800">
              <span class="font-bold block text-sm mb-0.5">Yêu cầu hình ảnh:</span>
              <%= h(imageError) %>
            </div>
          </div>
        <% } %>

        <% if (generalError != null && !generalError.isEmpty()) { %>
          <div class="p-3.5 bg-red-50 border-l-4 border-red-500 rounded-r-xl flex items-start gap-3 shadow-xs">
            <svg class="w-5 h-5 text-red-500 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
            <div class="text-xs text-red-800">
              <span class="font-bold block text-sm mb-0.5">Thông báo:</span>
              <%= h(generalError) %>
            </div>
          </div>
        <% } %>
      </div>

      <!-- BƯỚC 1: HÌNH THỨC ĐĂNG TIN -->
      <div class="space-y-3">
        <label class="block text-xs font-bold uppercase tracking-wider text-slate-700">
          Bước 1: Chọn hình thức đăng tin <span class="text-red-500">*</span>
        </label>
        <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
          <label class="flex flex-col p-3.5 border-2 <%= "sell".equals(formDealType) ? "border-blue-600 bg-blue-50/50" : "border-slate-200 hover:border-slate-300" %> rounded-xl cursor-pointer">
            <div class="flex items-center justify-between">
              <span class="text-xs font-bold <%= "sell".equals(formDealType) ? "text-blue-900" : "text-slate-800" %>">Bán Thanh Lý</span>
              <input type="radio" name="deal_type" value="sell" <%= "sell".equals(formDealType) ? "checked" : "" %> class="w-4 h-4 text-blue-600">
            </div>
            <span class="text-[11px] text-blue-700 mt-1">Bán lấy tiền với giá niêm yết (hỗ trợ người mua trả giá)</span>
          </label>
          <label class="flex flex-col p-3.5 border-2 <%= "give".equals(formDealType) ? "border-blue-600 bg-blue-50/50" : "border-slate-200 hover:border-slate-300" %> rounded-xl cursor-pointer">
            <div class="flex items-center justify-between">
              <span class="text-xs font-bold text-slate-800">Tặng Miễn Phí (0đ)</span>
              <input type="radio" name="deal_type" value="give" <%= "give".equals(formDealType) ? "checked" : "" %> class="w-4 h-4 text-blue-600">
            </div>
            <span class="text-[11px] text-slate-500 mt-1">Tặng miễn phí cho người thực sự có nhu cầu</span>
          </label>
        </div>
      </div>

      <!-- BƯỚC 2: HÌNH ẢNH THỰC TẾ -->
      <div class="space-y-3">
        <div class="flex items-center justify-between">
          <label class="block text-xs font-bold uppercase tracking-wider text-slate-700">
            Bước 2: Hình ảnh thực tế (Tối thiểu 1 ảnh, tối đa 6 ảnh) <span class="text-red-500">*</span>
          </label>
          <span class="text-[10px] text-slate-400">JPG, PNG, WEBP &lt; 10MB</span>
        </div>
        <% if (isEditMode && !editProductImages.isEmpty()) { %>
        <div class="p-3 bg-blue-50 border border-blue-200 rounded-lg text-xs text-blue-700 mb-2">
          Đang hiển thị <strong><%= editProductImages.size() %> ảnh</strong> hiện tại của tin đăng.
          Nếu bạn chọn ảnh mới bên dưới, ảnh cũ sẽ được <strong>thay thế hoàn toàn</strong>.
          Nếu không chọn ảnh mới, ảnh cũ sẽ được giữ nguyên.
        </div>
        <!-- Hiển thị ảnh cũ hiện tại -->
        <div class="flex flex-wrap gap-2 p-3 bg-white border border-slate-200 rounded-xl">
          <% for (ProductImage img : editProductImages) { %>
          <div class="relative w-20 h-20 flex-shrink-0">
            <img src="<%= request.getContextPath() %>/<%= h(img.getImageUrl()) %>"
                 alt="Ảnh sản phẩm"
                 class="w-full h-full object-cover rounded-lg border-2 <%= img.isPrimary() ? "border-amber-500" : "border-slate-200" %>"
                 onerror="this.src='<%= request.getContextPath() %>/assets/images/no-image.png'">
            <% if (img.isPrimary()) { %>
            <div class="absolute bottom-0 left-0 right-0 bg-amber-500 text-white text-[9px] text-center font-bold py-0.5 rounded-b-lg">Ảnh đại diện</div>
            <% } %>
          </div>
          <% } %>
        </div>
        <% } %>
        <label id="uploadDropZone" class="block border-2 border-dashed border-slate-300 rounded-xl p-6 text-center hover:border-blue-500 transition cursor-pointer bg-slate-50 relative">
          <input type="file" id="imagesInput" name="images" multiple accept="image/jpeg,image/png,image/webp,image/gif" class="absolute inset-0 w-full h-full opacity-0 cursor-pointer z-0" onchange="previewImages(this)">
          <div class="text-xs font-semibold text-blue-600"><%= isEditMode ? "Bấm để tải ảnh MỚI lên (bỏ qua nếu giữ ảnh cũ)" : "Bấm để tải ảnh chụp món đồ lên hoặc kéo thả tệp vào đây" %></div>
          <p class="text-[11px] text-slate-500 mt-1">Chụp đủ các góc cạnh, tem thông số, các vết trầy xước (nếu có) để người mua yên tâm</p>
          <div id="previewContainer" class="mt-4 flex flex-wrap justify-center gap-3 relative z-10">
          </div>
        </label>
        <div id="imageValidationError" class="hidden text-xs text-red-600 font-medium flex items-center gap-1.5 mt-1.5 p-2 bg-red-50 rounded-lg border border-red-200">
          <svg class="w-4 h-4 text-red-500 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
          <span id="imageValidationText">Vui lòng chọn ít nhất 1 ảnh chụp thực tế của sản phẩm trước khi xuất bản.</span>
        </div>
        <!-- Lưu danh sách ảnh cũ để server giữ nguyên nếu không upload ảnh mới -->
        <script type="application/json" id="existingImagesJson"><%= existingImagesJson %></script>
      </div>

      <!-- BƯỚC 3: THÔNG TIN CHI TIẾT VÀ GIÁ BÁN -->
      <div class="space-y-4">
        <label class="block text-xs font-bold uppercase tracking-wider text-slate-700">
          Bước 3: Thông tin món đồ đăng bán <span class="text-red-500">*</span>
        </label>

        <div>
          <div class="flex items-center justify-between mb-1">
            <label class="block text-xs font-medium text-slate-700">Tiêu đề bài đăng <span class="text-red-500">*</span></label>
            <span id="titleCounter" class="text-[10px] text-slate-400">0/100 ký tự</span>
          </div>
          <input 
            type="text" 
            id="postTitleInput"
            name="title" placeholder="Ví dụ: iPhone 15 Pro Max Đỏ Burgundy 256GB chính hãng hoặc MacBook Pro M3" 
            maxlength="100"
            required
            value="<%= formTitle %>"
            class="w-full px-3.5 py-2 bg-white border border-slate-300 rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-blue-500 shadow-2xs"
          >
          <p class="text-[10px] text-slate-400 mt-1">Gợi ý: [Hãng] + [Tên máy / Model] + [Dung lượng / Tình trạng] để người mua tìm thấy ngay</p>
        </div>

        <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div>
            <label class="block text-xs font-medium text-slate-700 mb-1">Danh mục hàng hóa <span class="text-red-500">*</span></label>
            <select id="categorySelect" name="categoryId" class="w-full px-3.5 py-2 bg-white border border-slate-300 rounded-lg text-xs font-medium text-slate-800 focus:outline-none focus:ring-2 focus:ring-blue-500 shadow-2xs" onchange="renderCategorySpecs(this.value, IS_EDIT_MODE ? window._editSpecsFromServer : {})">  
              <option value="1" <%= formCatId == 1 ? "selected" : "" %>>Điện Tử & Thiết Bị Số</option>
              <option value="2" <%= formCatId == 2 ? "selected" : "" %>>Xe Cộ & Phương Tiện</option>
              <option value="3" <%= formCatId == 3 ? "selected" : "" %>>Điện Lạnh & Gia Dụng</option>
              <option value="4" <%= formCatId == 4 ? "selected" : "" %>>Nội Thất & Đồ Gia Đình</option>
            </select>
          </div>

          <div>
            <label class="block text-xs font-medium text-slate-700 mb-1">Giá bán mong muốn (VNĐ) <span class="text-red-500">*</span></label>
            <div class="relative">
              <input 
                type="text" 
                id="postPriceInput"
                name="price" value="<%= formPrice %>"
                placeholder="Ví dụ: 15.000.000"
                required
                autocomplete="off"
                oninput="formatPriceInput(this)"
                class="w-full px-3.5 py-2 bg-white border border-slate-300 rounded-lg text-xs font-bold text-red-600 focus:outline-none focus:ring-2 focus:ring-blue-500 pr-8 shadow-2xs"
              >
              <span class="absolute right-3 top-2 text-xs font-bold text-slate-400 pointer-events-none">₫</span>
            </div>
            <div id="priceInWords" class="text-[11px] text-blue-700 font-medium mt-1 min-h-[16px]"></div>
          </div>
        </div>

        <!-- THÔNG SỐ ĐẶC THÙ THEO DANH MỤC (DYNAMIC SPECIFICATIONS) -->
        <div id="dynamicSpecsWrapper" class="p-4 bg-slate-50 border border-slate-200 rounded-xl space-y-3.5 transition-all">
          <div class="flex flex-wrap items-center justify-between pb-2.5 border-b border-slate-200 gap-2">
            <span class="text-xs font-bold text-slate-900 flex items-center gap-1.5">
              <svg class="w-4 h-4 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 9l2 2 4-4"></path></svg>
              Kê khai thông số & Tình trạng chi tiết: <span id="categoryNameTitle" class="text-blue-600 ml-1">Điện Tử & Thiết Bị Số</span>
            </span>
            <span class="text-[11px] text-slate-500 font-medium">Mục có dấu <span class="text-red-500 font-bold">*</span> là bắt buộc</span>
          </div>

          <div id="specsContainer" class="grid grid-cols-1 sm:grid-cols-2 gap-3.5">
          </div>
        </div>

        <div>
          <label class="block text-xs font-medium text-slate-700 mb-1">Mô tả tình trạng chi tiết</label>
          <textarea name="description" rows="4" 
            class="w-full px-3.5 py-2 bg-white border border-slate-300 rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-blue-500 leading-relaxed shadow-2xs"
          ><%= formDesc %></textarea>
        </div>
      </div>

      <!-- BƯỚC 4: LỰA CHỌN PHƯƠNG THỨC GIAO NHẬN -->
      <div class="space-y-3">
        <label class="block text-xs font-bold uppercase tracking-wider text-slate-700">
          Bước 4: Chọn phương thức giao nhận <span class="text-red-500">*</span>
        </label>
        
        <div class="space-y-2.5">
          <label class="flex items-start gap-3 p-3.5 border-2 <%= formDelivery == 1 ? "border-blue-600 bg-blue-50/50" : "border border-slate-200" %> rounded-xl cursor-pointer">
            <input type="radio" name="delivery_method" value="1" <%= formDelivery == 1 ? "checked" : "" %> class="mt-0.5 w-4 h-4 text-blue-600 rounded">
            <div>
              <span class="text-xs font-bold text-slate-900 block">1. Hẹn gặp trực tiếp (Người mua cọc giữ chỗ 10%)</span>
              <p class="text-[11px] text-slate-600 mt-0.5">Phù hợp với mặt hàng Xe cộ, Đồ cồng kềnh. Người mua đặt cọc trước qua VNPay để hẹn giờ xem đồ, chống bỏ hẹn.</p>
            </div>
          </label>

          <label class="flex items-start gap-3 p-3.5 border <%= formDelivery == 2 ? "border-2 border-blue-600 bg-blue-50/50" : "border-slate-200" %> rounded-xl cursor-pointer">
            <input type="radio" name="delivery_method" value="2" <%= formDelivery == 2 ? "checked" : "" %> class="mt-0.5 w-4 h-4 text-slate-600 rounded">
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
            <select id="postProvince" name="province" data-saved-province="<%= h(formProvince) %>" required class="w-full px-3 py-2 bg-white border border-slate-300 rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-blue-500">
              <option value="">Đang tải tỉnh/thành...</option>
              <% if (formProvince != null && !formProvince.isEmpty()) { %><option value="<%= h(formProvince) %>" selected><%= h(formProvince) %></option><% } %>
            </select>
          </div>

          <div>
            <label class="block text-[11px] font-medium text-slate-700 mb-1">Phường / Xã</label>
            <select id="postWard" name="ward" data-saved-ward="<%= h(formWard) %>" required disabled class="w-full px-3 py-2 bg-white border border-slate-300 rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-blue-500">
              <option value=""><%= formWard == null || formWard.isEmpty() ? "Chọn tỉnh/thành trước" : h(formWard) %></option>
              <% if (formWard != null && !formWard.isEmpty()) { %><option value="<%= h(formWard) %>" selected><%= h(formWard) %></option><% } %>
            </select>
          </div>
        </div>

        <div>
          <label class="block text-[11px] font-medium text-slate-700 mb-1">Địa chỉ chi tiết (số nhà, tên đường)</label>
          <input 
            type="text"
            name="address_detail"
            value="<%= h(formAddressDetail) %>"
            maxlength="255"
            required
            class="w-full px-3.5 py-2 bg-white border border-slate-300 rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-blue-500"
          >
        </div>
      </div>

      <!-- BƯỚC 6: TÙY CHỌN ĐẨY TIN (VIP BOOST) -->
      <div class="space-y-4 p-4 sm:p-5 bg-amber-50/40 border-2 border-amber-400 rounded-2xl shadow-2xs">
        <div class="flex items-center justify-between pb-1">
          <div>
            <h3 class="text-xs sm:text-sm font-bold text-amber-900 flex items-center gap-1.5 uppercase tracking-wide">
              <span class="w-5 h-5 rounded-md bg-amber-500/20 text-amber-700 flex items-center justify-center text-xs">⚡</span>
              Bước 6: Tùy Chọn Đẩy Tin (Bán Nhanh Hơn)
            </h3>
            <p class="text-[11px] text-amber-700/80 mt-0.5">Tiếp cận nhiều người mua hơn bằng lượt đẩy sẵn có hoặc gói VIP</p>
          </div>
          <span class="text-[11px] font-semibold text-amber-800 bg-amber-100/90 border border-amber-200 px-3 py-1 rounded-lg shadow-2xs">
            Tùy chọn
          </span>
        </div>

        <!-- PHẦN 1: DỊCH VỤ SẴN CÓ CỦA BẠN -->
        <div class="space-y-2">
          <div class="flex items-center justify-between">
            <span class="text-xs font-semibold text-slate-700">
              1. Dịch vụ sẵn có của bạn
            </span>
            <span class="text-[11px] text-slate-400">Không tốn phí</span>
          </div>

          <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <!-- Gói Tin Thường Miễn Phí -->
            <label class="vip-option-card p-3.5 bg-white border-2 border-blue-500 bg-blue-50/20 rounded-xl cursor-pointer flex flex-col justify-between shadow-2xs transition hover:border-blue-400" data-card-type="free" data-submit-text="Đăng Tin Miễn Phí Ngay">
              <div>
                <div class="flex items-center justify-between">
                  <div class="flex items-center gap-2">
                    <input type="radio" name="vip_boost" value="normal" checked class="w-4 h-4 text-blue-600 focus:ring-blue-500">
                    <span class="font-semibold text-xs text-slate-800">Tin Thường</span>
                  </div>
                  <span class="text-[10px] font-medium text-blue-700 bg-blue-50 px-2 py-0.5 rounded-md border border-blue-100">Miễn phí</span>
                </div>
                <p class="text-[11px] text-slate-500 mt-2 leading-relaxed">Hiển thị theo thứ tự thời gian tự nhiên của sàn.</p>
              </div>
              <div class="font-semibold text-xs text-slate-800 mt-3 pt-2 border-t border-slate-100 flex items-center justify-between">
                <span>0 đ</span>
                <span class="text-[10px] text-slate-400 font-normal">Mặc định</span>
              </div>
            </label>

            <!-- Dùng lượt đẩy từ Ví Lượt Đẩy -->
            <% if (userBumpCredits > 0) { %>
            <label class="vip-option-card p-3.5 bg-white border border-slate-200 rounded-xl cursor-pointer flex flex-col justify-between shadow-2xs transition hover:border-emerald-400" data-card-type="wallet" data-submit-text="Đăng Tin & Đẩy Lên Đầu (Trừ 1 Lượt Ví)">
              <div>
                <div class="flex items-center justify-between">
                  <div class="flex items-center gap-2">
                    <input type="radio" name="vip_boost" value="use_bump" class="w-4 h-4 text-emerald-600 focus:ring-emerald-500">
                    <span class="font-semibold text-xs text-slate-800">Dùng 1 Lượt Đẩy Tin</span>
                  </div>
                  <span class="text-[10px] font-medium text-emerald-700 bg-emerald-50 px-2 py-0.5 rounded-md border border-emerald-100">Ví có <%= userBumpCredits %> lượt</span>
                </div>
                <p class="text-[11px] text-slate-500 mt-2 leading-relaxed">Đưa tin lên đầu danh mục ngay sau khi được duyệt.</p>
              </div>
              <div class="font-semibold text-xs text-emerald-700 mt-3 pt-2 border-t border-slate-100 flex items-center justify-between">
                <span>Trừ 1 lượt ví</span>
                <span class="text-[10px] text-slate-400 font-normal">Còn lại <%= (userBumpCredits - 1) %> lượt</span>
              </div>
            </label>
            <% } else { %>
            <div class="p-3.5 bg-white border border-slate-200/70 rounded-xl flex flex-col justify-between opacity-60">
              <div>
                <div class="flex items-center justify-between">
                  <div class="flex items-center gap-2">
                    <span class="w-4 h-4 rounded-full border border-slate-300 bg-slate-100 inline-block"></span>
                    <span class="font-semibold text-xs text-slate-600">Dùng 1 Lượt Đẩy Tin</span>
                  </div>
                  <span class="text-[10px] text-slate-500 bg-slate-100 px-2 py-0.5 rounded-md">Ví có 0 lượt</span>
                </div>
                <p class="text-[11px] text-slate-400 mt-2 leading-relaxed">Ví của bạn chưa có lượt đẩy sẵn. Bạn có thể chọn gói mua thêm bên dưới.</p>
              </div>
              <div class="text-[11px] text-slate-400 mt-3 pt-2 border-t border-slate-100 flex items-center justify-between">
                <span>0 lượt</span>
                <span class="text-[10px] text-slate-400">Xem gói bên dưới ↓</span>
              </div>
            </div>
            <% } %>
          </div>
        </div>

        <!-- PHÂN CÁCH NHẸ NHÀNG GIỮA 2 PHẦN -->
        <div class="relative py-1">
          <div class="absolute inset-0 flex items-center"><div class="w-full border-t border-amber-200"></div></div>
          <div class="relative flex justify-center">
            <span class="bg-amber-50/90 px-3 text-[11px] text-amber-700/80 font-medium">Hoặc nâng cấp để bán nhanh hơn</span>
          </div>
        </div>

        <!-- PHẦN 2: CÁC GÓI DỊCH VỤ CÓ THỂ MUA THÊM -->
        <div class="space-y-2">
          <div class="flex items-center justify-between">
            <span class="text-xs font-semibold text-slate-700">
              2. Gói dịch vụ đẩy tin & VIP
            </span>
            <span class="text-[11px] text-slate-400">Thanh toán an toàn qua VNPay</span>
          </div>

          <div class="grid grid-cols-1 sm:grid-cols-3 gap-3">
          <% if (boostPackages != null && !boostPackages.isEmpty()) { %>
            <% for (model.BoostPackage pkg : boostPackages) { 
                 String badgeBg = "bg-amber-50 text-amber-700 border-amber-200";
                 if ("purple".equalsIgnoreCase(pkg.getBadgeColor())) {
                     badgeBg = "bg-purple-50 text-purple-700 border-purple-200";
                 } else if ("emerald".equalsIgnoreCase(pkg.getBadgeColor())) {
                     badgeBg = "bg-emerald-50 text-emerald-700 border-emerald-200";
                 } else if ("blue".equalsIgnoreCase(pkg.getBadgeColor())) {
                     badgeBg = "bg-blue-50 text-blue-700 border-blue-200";
                 }
                 String submitLabel = "Đăng Tin & Mua Gói " + h(pkg.getName()) + " (" + String.format("%,.0f đ", pkg.getPrice()) + ")";
            %>
            <label class="vip-option-card p-3.5 bg-white border border-slate-200 rounded-xl cursor-pointer flex flex-col justify-between shadow-2xs transition hover:border-slate-300" data-card-type="paid" data-submit-text="<%= submitLabel %>">
              <div>
                <div class="flex items-center justify-between gap-1">
                  <div class="flex items-center gap-2">
                    <input type="radio" name="vip_boost" value="<%= pkg.getId() %>" class="w-4 h-4 text-amber-600 focus:ring-amber-500">
                    <span class="font-semibold text-xs text-slate-800 line-clamp-1"><%= h(pkg.getName()) %></span>
                  </div>
                  <span class="text-[10px] font-medium <%= badgeBg %> px-1.5 py-0.5 rounded-md border flex-shrink-0"><%= h(pkg.getBadgeLabel()) %></span>
                </div>
                <p class="text-[11px] text-slate-500 mt-2 line-clamp-2 leading-relaxed"><%= h(pkg.getDescription()) %></p>
              </div>
              <div class="font-semibold text-xs text-amber-600 mt-3 pt-2 border-t border-slate-100 flex items-center justify-between">
                <span><%= String.format("%,.0f đ", pkg.getPrice()) %></span>
                <% if (pkg.getDurationDays() > 0) { %>
                  <span class="text-[10px] text-slate-400 font-normal"><%= pkg.getDurationDays() %> ngày</span>
                <% } else if (pkg.getBumpCount() > 0) { %>
                  <span class="text-[10px] text-slate-400 font-normal"><%= pkg.getBumpCount() %> lượt</span>
                <% } %>
              </div>
            </label>
            <% } %>
          <% } else { %>
            <div class="col-span-3 text-center py-4 text-xs text-slate-400 bg-white rounded-xl border border-slate-200">
              Hiện chưa có gói đẩy tin mở bán thêm.
            </div>
          <% } %>
          </div>
        </div>
      </div>

      <!-- NÚT XUẤT BẢN BÀI ĐĂNG -->
      <div class="pt-4 border-t border-slate-200 flex items-center justify-end gap-3">
        <a href="my-posts" class="px-4 py-2 text-xs font-semibold text-slate-600 hover:bg-slate-100 rounded-lg transition">
          Hủy bỏ
        </a>
        <button type="submit" id="submitPostBtn" class="px-6 py-2.5 bg-amber-500 hover:bg-amber-600 text-slate-900 text-xs font-bold rounded-lg shadow-sm transition flex items-center gap-2">
          <span id="submitBtnText"><%= isEditMode ? "Lưu Thay Đổi" : "Đăng Tin Miễn Phí Ngay" %></span>
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
    // =====================================================================
    // LUỒNG LƯU & PHỤC HỒI FORM KHI CHƯA ĐĂNG NHẬP
    // =====================================================================
    const POST_AD_DRAFT_KEY = 'muangay_post_ad_draft';
    const IS_LOGGED_IN = <%= isLoggedIn %>;
    const IS_EDIT_MODE = <%= isEditMode %>;
    const CONTEXT_PATH = '${pageContext.request.contextPath}';

    function normalizePostLocation(value) {
      return (value || '').trim().replace(/^(tỉnh|thành phố|tp\.?|t\.?p\.?)\s+/i, '').toLocaleLowerCase('vi');
    }

    async function loadPostLocationOptions(savedProvince, savedWard) {
      const provinceSelect = document.getElementById('postProvince');
      const wardSelect = document.getElementById('postWard');
      if (!provinceSelect || !wardSelect) return;
      try {
        const response = await fetch('https://provinces.open-api.vn/api/v2/p/');
        if (!response.ok) throw new Error('Không tải được tỉnh/thành');
        const provinces = await response.json();
        provinceSelect.innerHTML = '<option value="">Chọn tỉnh/thành phố</option>';
        provinces.forEach((item) => {
          const option = new Option(item.name, item.name);
          option.dataset.code = item.code;
          provinceSelect.add(option);
        });
        let saved = savedProvince ? [...provinceSelect.options].find((option) =>
          normalizePostLocation(option.value) === normalizePostLocation(savedProvince)) : null;
        if (!saved && savedProvince) {
          saved = new Option(savedProvince + ' (địa chỉ đã lưu)', savedProvince, true, true);
          provinceSelect.add(saved);
        }
        if (saved) {
          saved.selected = true;
          if (saved.dataset.code) await loadPostWards(saved.dataset.code, savedWard);
          else if (savedWard) {
            wardSelect.innerHTML = '';
            wardSelect.add(new Option(savedWard, savedWard, true, true));
            wardSelect.disabled = false;
          }
        }
      } catch (error) {
        if (savedProvince && ![...provinceSelect.options].some((option) => option.value === savedProvince)) {
          provinceSelect.add(new Option(savedProvince, savedProvince, true, true));
        }
        if (savedWard) {
          wardSelect.innerHTML = '';
          wardSelect.add(new Option(savedWard, savedWard, true, true));
          wardSelect.disabled = false;
        } else {
          provinceSelect.options[0].textContent = 'Không tải được tỉnh/thành';
        }
      }
    }

    async function loadPostWards(provinceCode, savedWard) {
      const wardSelect = document.getElementById('postWard');
      wardSelect.disabled = true;
      wardSelect.innerHTML = '<option value="">Đang tải phường/xã...</option>';
      try {
        const response = await fetch('https://provinces.open-api.vn/api/v2/w/?province=' + encodeURIComponent(provinceCode));
        if (!response.ok) throw new Error('Không tải được phường/xã');
        const wards = await response.json();
        wardSelect.innerHTML = '<option value="">Chọn phường/xã</option>';
        (wards || []).forEach((item) => wardSelect.add(new Option(item.name, item.name)));
        if (savedWard && ![...wardSelect.options].some((option) => option.value === savedWard)) {
          wardSelect.add(new Option(savedWard + ' (địa chỉ đã lưu)', savedWard));
        }
        wardSelect.disabled = false;
        if (savedWard) wardSelect.value = savedWard;
      } catch (error) {
        wardSelect.innerHTML = '<option value="">Không tải được phường/xã</option>';
        if (savedWard) {
          wardSelect.add(new Option(savedWard, savedWard, true, true));
          wardSelect.disabled = false;
        }
      }
    }

    // --- HÀM LƯU TOÀN BỘ FORM VÀO localStorage ---
    function saveFormDraft() {
      const form = document.querySelector('form[action="post-ad"]');
      if (!form) return;

      const draft = {};

      // Thu thập tất cả input/textarea/select có name
      form.querySelectorAll('input[name], textarea[name], select[name]').forEach(el => {
        const name = el.name;
        if (!name || name === 'images') return; // Bỏ qua file upload

        if (el.type === 'radio' || el.type === 'checkbox') {
          if (el.checked) draft[name] = el.value;
        } else {
          draft[name] = el.value;
        }
      });

      try {
        console.log('[MuaNgay] Đang lưu draft form:', draft);
        localStorage.setItem(POST_AD_DRAFT_KEY, JSON.stringify(draft));
        console.log('[MuaNgay] Lưu draft thành công.');
      } catch (e) {
        console.warn('Không thể lưu draft:', e);
      }
    }

    // --- HÀM PHỤC HỒI FORM TỪ localStorage ---
    function restoreFormDraft() {
      let draft;
      try {
        const raw = localStorage.getItem(POST_AD_DRAFT_KEY);
        if (!raw) return false;
        draft = JSON.parse(raw);
      } catch (e) {
        localStorage.removeItem(POST_AD_DRAFT_KEY);
        return false;
      }

      if (!draft || Object.keys(draft).length === 0) return false;
      console.log('[MuaNgay] Đang phục hồi draft form:', draft);

      // ── BƯỚC 1: Phục hồi radio buttons ──────────────────────────────────
      // deal_type (Bán / Tặng)
      if (draft.deal_type) {
        const dealEl = document.querySelector('input[name="deal_type"][value="' + draft.deal_type + '"]');
        if (dealEl) dealEl.checked = true;
      }
      // delivery_method
      if (draft.delivery_method) {
        const deliveryEl = document.querySelector('input[name="delivery_method"][value="' + draft.delivery_method + '"]');
        if (deliveryEl) deliveryEl.checked = true;
      }
      // vip_boost
      if (draft.vip_boost) {
        const vipEl = document.querySelector('input[name="vip_boost"][value="' + draft.vip_boost + '"]');
        if (vipEl) vipEl.checked = true;
      }

      // ── BƯỚC 2: Dispatch change events để cập nhật styling UI ────────────
      const checkedDeal = document.querySelector('input[name="deal_type"]:checked');
      if (checkedDeal) checkedDeal.dispatchEvent(new Event('change', { bubbles: true }));

      const checkedDelivery = document.querySelector('input[name="delivery_method"]:checked');
      if (checkedDelivery) checkedDelivery.dispatchEvent(new Event('change', { bubbles: true }));

      // ── BƯỚC 3: Phục hồi danh mục & render specs ────────────────────────
      const catEl = document.getElementById('categorySelect');
      if (catEl && draft.categoryId) {
        catEl.value = draft.categoryId;
        window._pendingSpecsDraft = draft;
        renderCategorySpecs(catEl.value, {});
      }

      // ── BƯỚC 4: Phục hồi các text fields TÁC BIỆT sau cùng ──────────────
      // (Phải đặt SAU dispatch events vì event handlers có thể reset giá trị)
      function setField(name, value) {
        if (value === undefined || value === null) return;
        const el = document.querySelector('[name="' + name + '"]');
        if (el) {
          el.value = value;
          console.log('[MuaNgay] Đã phục hồi [' + name + '] = "' + value + '"');
        } else {
          console.warn('[MuaNgay] Không tìm thấy field [' + name + ']');
        }
      }

      setField('title',          draft.title);
      setField('description',    draft.description);
      setField('address_detail', draft.address_detail);
      window._pendingPostAddress = {
        province: draft.province || '',
        ward: draft.ward || draft.district || ''
      };

      // Giá: chỉ set nếu không phải chế độ Tặng (chế độ Tặng thì event đã set = '0')
      if (draft.deal_type !== 'give') {
        setField('price', draft.price);
      }

      // Xóa draft sau khi đã phục hồi xong
      localStorage.removeItem(POST_AD_DRAFT_KEY);
      console.log('[MuaNgay] Phục hồi draft hoàn tất.');
      return true;
    }

    // --- HÀM ĐỌC TIỀN THÀNH CHỮ TIẾNG VIỆT ---
    function numberToVietnameseWords(n) {
      if (!n || n <= 0) return '';
      const digits = ['không', 'một', 'hai', 'ba', 'bốn', 'năm', 'sáu', 'bảy', 'tám', 'chín'];
      const units = ['', 'nghìn', 'triệu', 'tỷ', 'nghìn tỷ', 'triệu tỷ'];

      function readGroup(group, showZeroHundred) {
        let a = Math.floor(group / 100);
        let b = Math.floor((group % 100) / 10);
        let c = group % 10;
        let res = '';
        if (a > 0 || showZeroHundred) {
          res += digits[a] + ' trăm ';
          if (b === 0 && c > 0) res += 'lẻ ';
        }
        if (b > 1) {
          res += digits[b] + ' mươi ';
          if (c === 1) res += 'mốt ';
          else if (c === 5) res += 'lăm ';
          else if (c > 0) res += digits[c] + ' ';
        } else if (b === 1) {
          res += 'mười ';
          if (c === 5) res += 'lăm ';
          else if (c > 0) res += digits[c] + ' ';
        } else if (b === 0 && c > 0) {
          res += digits[c] + ' ';
        }
        return res.trim();
      }

      let num = Math.floor(n);
      let groups = [];
      while (num > 0) {
        groups.push(num % 1000);
        num = Math.floor(num / 1000);
      }

      let result = '';
      for (let i = groups.length - 1; i >= 0; i--) {
        let grp = groups[i];
        if (grp > 0) {
          let showZero = (i < groups.length - 1);
          let s = readGroup(grp, showZero);
          if (s) {
            result += s + ' ' + units[i] + ' ';
          }
        }
      }
      result = result.trim();
      if (!result) return '';
      return result.charAt(0).toUpperCase() + result.slice(1) + ' đồng';
    }

    function formatPriceInput(input) {
      if (!input) return;
      let raw = input.value.replace(/\D/g, '');
      const wordsEl = document.getElementById('priceInWords');
      if (raw) {
        let num = parseInt(raw, 10);
        input.value = num.toLocaleString('vi-VN');
        if (wordsEl) {
          wordsEl.textContent = 'Bằng chữ: ' + numberToVietnameseWords(num);
          wordsEl.style.display = 'block';
        }
      } else {
        input.value = '';
        if (wordsEl) {
          wordsEl.textContent = '';
          wordsEl.style.display = 'none';
        }
      }
    }

    // --- CHẶN SUBMIT: KIỂM TRA ẢNH & ĐĂNG NHẬP ---
    document.addEventListener('DOMContentLoaded', function () {
      const form = document.getElementById('postAdForm') || document.querySelector('form[action="post-ad"]');
      if (!form) return;

      form.addEventListener('submit', function (e) {
        // 1. Kiểm tra bắt buộc ảnh (chỉ với tin đăng mới)
        if (!IS_EDIT_MODE && selectedFiles.length === 0) {
          e.preventDefault();
          const errBox = document.getElementById('imageValidationError');
          if (errBox) errBox.classList.remove('hidden');
          const dropZone = document.getElementById('uploadDropZone');
          if (dropZone) {
            dropZone.scrollIntoView({ behavior: 'smooth', block: 'center' });
            dropZone.classList.add('border-red-500', 'bg-red-50/50');
            setTimeout(() => dropZone.classList.remove('border-red-500', 'bg-red-50/50'), 3000);
          }
          return false;
        }

        // 2. Chặn submit nếu chưa đăng nhập
        if (!IS_EDIT_MODE && !IS_LOGGED_IN) {
          e.preventDefault();
          saveFormDraft();
          window.location.href = CONTEXT_PATH + '/login?redirect=post-ad';
          return false;
        }

        // 3. Nếu hợp lệ và đã đăng nhập, xóa draft cũ
        if (!IS_EDIT_MODE && IS_LOGGED_IN) {
          localStorage.removeItem(POST_AD_DRAFT_KEY);
        }
      });
    });

    // --- PHỤC HỒI FORM KHI VỪA ĐĂNG NHẬP THÀNH CÔNG ---
    if (IS_LOGGED_IN && !IS_EDIT_MODE && localStorage.getItem(POST_AD_DRAFT_KEY)) {
      window._needRestoreDraft = true;
    }
  </script>

  <script>
    let selectedFiles = [];
    let dragStartIndex = null;

    function previewImages(input) {
      const errBox = document.getElementById('imageValidationError');
      if (errBox) errBox.classList.add('hidden');

      if (input.files && input.files.length > 0) {
        for (let i = 0; i < input.files.length; i++) {
          const file = input.files[i];
          if (!file.type.startsWith('image/')) {
            alert('Tệp "' + file.name + '" không đúng định dạng ảnh (chỉ chấp nhận JPG, PNG, WEBP, GIF).');
            continue;
          }
          if (file.size > 10 * 1024 * 1024) {
            alert('Ảnh "' + file.name + '" quá lớn (' + (file.size / (1024 * 1024)).toFixed(1) + 'MB). Vui lòng chọn ảnh dưới 10MB.');
            continue;
          }
          if (selectedFiles.length < 6) { 
            selectedFiles.push(file);
          } else {
            alert('Bạn chỉ có thể tải lên tối đa 6 hình ảnh.');
            break;
          }
        }
      }
      input.value = ''; 
      renderPreview();
    }

    function updateFileInput() {
      const dt = new DataTransfer();
      selectedFiles.forEach(file => dt.items.add(file));
      const fileInput = document.getElementById('imagesInput') || document.querySelector('input[type="file"][name="images"]');
      if (fileInput) fileInput.files = dt.files;
    }

    function renderPreview() {
      const container = document.getElementById('previewContainer');
      container.innerHTML = '';
      
      if (selectedFiles.length === 0) {
        container.innerHTML = `
            <div class="w-16 h-16 bg-slate-200 rounded-lg flex items-center justify-center text-[10px] text-slate-600 font-medium pointer-events-none">Ảnh chính</div>
            <div class="w-16 h-16 bg-slate-200 rounded-lg flex items-center justify-center text-[10px] text-slate-600 font-medium pointer-events-none">Góc nghiêng</div>
            <div class="w-16 h-16 bg-slate-200 rounded-lg flex items-center justify-center text-[10px] text-slate-600 font-medium pointer-events-none">Tem / Thông số</div>
            <div class="w-16 h-16 border-2 border-dashed border-slate-300 rounded-lg flex items-center justify-center text-[10px] text-slate-400 font-medium pointer-events-none">+ Thêm ảnh</div>
        `;
        updateFileInput();
        return;
      }
      
      selectedFiles.forEach((file, index) => {
        const url = URL.createObjectURL(file);
        
        const wrapper = document.createElement('div');
        wrapper.className = 'relative group w-20 h-20 flex-shrink-0 cursor-grab active:cursor-grabbing transition-transform duration-200 bg-white rounded-lg hover:-translate-y-0.5 shadow-xs';
        wrapper.draggable = true;
        
        wrapper.addEventListener('dragstart', function(e) {
          dragStartIndex = index;
          e.dataTransfer.effectAllowed = 'move';
          setTimeout(() => this.classList.add('opacity-40'), 0);
        });
        
        wrapper.addEventListener('dragover', function(e) {
          e.preventDefault(); 
          e.dataTransfer.dropEffect = 'move';
        });
        
        wrapper.addEventListener('drop', function(e) {
          e.preventDefault();
          e.stopPropagation();
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
        img.className = 'w-full h-full object-cover rounded-lg border-2 ' + (index === 0 ? 'border-amber-500 shadow-xs' : 'border-slate-200');
        
        const label = document.createElement('div');
        if (index === 0) {
          label.className = 'absolute bottom-0 left-0 right-0 bg-amber-500 text-white text-[9px] text-center font-bold py-0.5 rounded-b-md shadow-xs truncate px-1';
          label.innerText = 'Ảnh đại diện';
        } else {
          label.className = 'absolute bottom-0 left-0 right-0 bg-slate-800/70 backdrop-blur-xs text-white text-[9px] text-center font-medium py-0.5 rounded-b-md truncate px-1';
          label.innerText = 'Ảnh ' + (index + 1);
        }

        // Nút đặt làm ảnh đại diện cho index > 0
        if (index > 0) {
          const setPrimaryBtn = document.createElement('button');
          setPrimaryBtn.type = 'button';
          setPrimaryBtn.innerHTML = '★ Chính';
          setPrimaryBtn.title = 'Đặt làm ảnh đại diện (đưa lên vị trí đầu tiên)';
          setPrimaryBtn.className = 'absolute top-1 left-1 bg-amber-500 hover:bg-amber-600 text-white rounded px-1 py-0.5 text-[8px] font-bold opacity-0 group-hover:opacity-100 transition shadow-xs z-20 cursor-pointer';
          setPrimaryBtn.onclick = function(e) {
            e.preventDefault();
            e.stopPropagation();
            const chosen = selectedFiles.splice(index, 1)[0];
            selectedFiles.unshift(chosen);
            renderPreview();
          };
          wrapper.appendChild(setPrimaryBtn);
        }
        
        const removeBtn = document.createElement('div');
        removeBtn.innerHTML = '✕';
        removeBtn.className = 'absolute -top-1.5 -right-1.5 w-5 h-5 bg-red-500 text-white rounded-full text-[9px] font-bold flex items-center justify-center opacity-0 group-hover:opacity-100 hover:bg-red-600 hover:scale-110 shadow-md transition-all z-20 cursor-pointer';
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
      // KHỞI TẠO BỘ ĐẾM TIÊU ĐỀ
      const titleInput = document.getElementById('postTitleInput');
      const titleCounter = document.getElementById('titleCounter');
      if (titleInput && titleCounter) {
        const updateCount = () => {
          const len = titleInput.value.length;
          titleCounter.textContent = len + "/100 ký tự";
          if (len >= 20) {
            titleCounter.className = 'text-green-600 font-semibold text-[10px]';
          } else {
            titleCounter.className = 'text-slate-400 font-normal text-[10px]';
          }
        };
        titleInput.addEventListener('input', updateCount);
        updateCount();
      }

      // KHỞI TẠO ĐỊNH DẠNG GIÁ TIỀN & ĐỌC CHỮ
      const priceInput = document.getElementById('postPriceInput');
      if (priceInput && priceInput.value) {
        formatPriceInput(priceInput);
      }

      // BƯỚC 1: HÌNH THỨC ĐĂNG TIN
      const dealRadios = document.querySelectorAll('input[name="deal_type"]');
      dealRadios.forEach(radio => {
        radio.addEventListener('change', function() {
          dealRadios.forEach(r => {
            const label = r.closest('label');
            label.className = 'flex flex-col p-3.5 border-2 border-slate-200 hover:border-slate-300 rounded-xl cursor-pointer';
            label.querySelector('span:first-child').className = 'text-xs font-bold text-slate-800';
          });
          const activeLabel = this.closest('label');
          activeLabel.className = 'flex flex-col p-3.5 border-2 border-blue-600 bg-blue-50/50 rounded-xl cursor-pointer';
          activeLabel.querySelector('span:first-child').className = 'text-xs font-bold text-blue-900';

          const pi = document.getElementById('postPriceInput');
          const wordsEl = document.getElementById('priceInWords');
          if (this.value === 'give') {
            if (pi) {
              pi.value = '0';
              pi.readOnly = true;
              pi.className = 'w-full px-3.5 py-2 bg-slate-100 border border-slate-300 rounded-lg text-xs font-bold text-slate-400 cursor-not-allowed pr-8 shadow-2xs';
            }
            if (wordsEl) wordsEl.textContent = 'Bằng chữ: Miễn phí (0 đồng)';
          } else {
            if (pi) {
              pi.value = '';
              pi.readOnly = false;
              pi.className = 'w-full px-3.5 py-2 bg-white border border-slate-300 rounded-lg text-xs font-bold text-red-600 focus:outline-none focus:ring-2 focus:ring-blue-500 pr-8 shadow-2xs';
            }
            if (wordsEl) wordsEl.textContent = '';
          }
        });
      });

      // BƯỚC 4: PHƯƠNG THỨC GIAO NHẬN
      const deliveryChecks = document.querySelectorAll('input[name="delivery_method"]');
      deliveryChecks.forEach(check => {
        check.addEventListener('change', function() {
          deliveryChecks.forEach(c => {
             const lbl = c.closest('label');
             lbl.className = 'flex items-start gap-3 p-3.5 border border-slate-200 rounded-xl cursor-pointer';
          });
          if (this.checked) {
            const label = this.closest('label');
            label.className = 'flex items-start gap-3 p-3.5 border-2 border-blue-600 bg-blue-50/50 rounded-xl cursor-pointer';
          }
        });
      });

      // BƯỚC 6: GÓI ĐẨY TIN VIP ACTIVE STYLING & DYNAMIC SUBMIT BUTTON
      const vipCards = document.querySelectorAll('.vip-option-card');
      const vipRadios = document.querySelectorAll('input[name="vip_boost"]');
      const submitBtnText = document.getElementById('submitBtnText');
      const isPostEditMode = <%= isEditMode ? "true" : "false" %>;

      function updateVipCardStyles() {
        vipRadios.forEach(radio => {
          const card = radio.closest('.vip-option-card');
          if (!card) return;
          const cardType = card.dataset.cardType || 'free';

          if (radio.checked) {
            if (cardType === 'free') {
              card.className = 'vip-option-card p-3.5 bg-white border-2 border-blue-500 bg-blue-50/20 rounded-xl cursor-pointer flex flex-col justify-between shadow-2xs transition';
            } else if (cardType === 'wallet') {
              card.className = 'vip-option-card p-3.5 bg-white border-2 border-emerald-500 bg-emerald-50/20 rounded-xl cursor-pointer flex flex-col justify-between shadow-2xs transition';
            } else {
              card.className = 'vip-option-card p-3.5 bg-white border-2 border-amber-500 bg-amber-50/25 rounded-xl cursor-pointer flex flex-col justify-between shadow-2xs transition';
            }

            if (submitBtnText && !isPostEditMode) {
              const text = card.dataset.submitText;
              if (text) submitBtnText.textContent = text;
            }
          } else {
            card.className = 'vip-option-card p-3.5 bg-white border border-slate-200 rounded-xl cursor-pointer flex flex-col justify-between shadow-2xs transition hover:border-slate-300';
          }
        });
      }

      vipRadios.forEach(radio => {
        radio.addEventListener('change', updateVipCardStyles);
      });
      updateVipCardStyles();

      // KHỞI TẠO THÔNG SỐ DANH MỤC BAN ĐẦU
      const catSelect = document.getElementById('categorySelect');
      if (catSelect) {
        // Dùng JSON.parse để tránh HTML-escaping ký tự & thành &amp; khi JSP render trực tiếp
        try {
          window._editSpecsFromServer = JSON.parse(document.getElementById('editSpecsJson').textContent);
        } catch(e) {
          window._editSpecsFromServer = {};
        }
        renderCategorySpecs(catSelect.value, window._editSpecsFromServer);
      }

      // PHỤC HỒI DRAFT SAU KHI ĐÃ ĐĂNG NHẬP THÀNH CÔNG
      if (window._needRestoreDraft) {
        const restored = restoreFormDraft();
        if (restored) {
          // Hiển thị banner thông báo phục hồi nội dung
          showDraftRestoredBanner();
        }
        window._needRestoreDraft = false;
      }
      const provinceSelect = document.getElementById('postProvince');
      if (provinceSelect) {
        const savedProvince = window._pendingPostAddress ? window._pendingPostAddress.province : provinceSelect.dataset.savedProvince;
        const savedWard = window._pendingPostAddress ? window._pendingPostAddress.ward : document.getElementById('postWard').dataset.savedWard;
        provinceSelect.addEventListener('change', () => {
          const selected = provinceSelect.selectedOptions[0];
          const wardSelect = document.getElementById('postWard');
          if (selected && selected.dataset.code) {
            loadPostWards(selected.dataset.code, '');
          } else {
            wardSelect.disabled = true;
            wardSelect.innerHTML = '<option value="">Chọn tỉnh/thành trước</option>';
          }
        });
        loadPostLocationOptions(savedProvince, savedWard);
      }
    });

    // --- BANNER THÔNG BÁO KHI FORM ĐƯỢC PHỤC HỒI ---
    function showDraftRestoredBanner() {
      const banner = document.createElement('div');
      banner.id = 'draftRestoredBanner';
      banner.style.cssText = 'position:fixed;top:80px;left:50%;transform:translateX(-50%);z-index:9999;display:flex;align-items:center;gap:10px;padding:10px 20px;background:#1e3a5f;color:#fff;border-radius:12px;box-shadow:0 4px 20px rgba(0,0,0,0.25);font-size:12px;font-weight:600;max-width:90vw;animation:slideDown 0.35s ease';
      banner.innerHTML = `
        <svg style="flex-shrink:0" width="18" height="18" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
        <span>✔ Nội dung bạn đã nhập trước đó đã được khôi phục tự động!</span>
        <button onclick="this.parentElement.remove()" style="margin-left:8px;background:rgba(255,255,255,0.2);border:none;color:#fff;border-radius:6px;padding:2px 8px;cursor:pointer;font-size:12px">×</button>
      `;
      document.body.appendChild(banner);
      // CSS animation
      const style = document.createElement('style');
      style.textContent = '@keyframes slideDown{from{opacity:0;transform:translateX(-50%) translateY(-20px)}to{opacity:1;transform:translateX(-50%) translateY(0)}}';
      document.head.appendChild(style);
      // Tự động đóng sau 5 giây
      setTimeout(() => { if (banner.parentElement) banner.remove(); }, 5000);
    }

    // DỮ LIỆU CẤU HÌNH CÁC DROPDOWN CHO TỪNG DANH MỤC
    const categorySpecsData = {
      '1': {
        title: 'Điện Tử & Thiết Bị Số',
        fields: [
          {
            name: 'spec_device_type',
            label: 'Loại thiết bị',
            required: true,
            options: ['-- Chọn loại thiết bị --', 'Điện thoại thông minh', 'Máy tính bảng (Tablet)', 'Laptop / Máy tính xách tay', 'Máy tính để bàn (PC)', 'Đồng hồ thông minh (Smartwatch)', 'Tai nghe & Âm thanh', 'Thiết bị số khác']
          },
          {
            name: 'spec_brand',
            label: 'Hãng sản xuất',
            required: true,
            options: ['-- Chọn hãng sản xuất --', 'Apple', 'Samsung', 'Xiaomi', 'OPPO', 'Dell', 'Asus', 'Lenovo / ThinkPad', 'HP', 'Sony', 'Acer', 'Hãng khác']
          },
          {
            name: 'spec_model',
            label: 'Dòng máy',
            required: true,
            options: ['-- Chọn dòng máy --', 'iPhone 18 Pro Max', 'iPhone 18 Pro', 'iPhone 18', 'iPhone 17 Pro Max', 'iPhone 16 Pro Max', 'iPhone 15 Pro Max', 'iPhone 14 / 13 Pro Max', 'Galaxy S24 Ultra', 'Galaxy S23 / S22', 'Galaxy Z Fold / Flip', 'MacBook Pro M3 / M2', 'MacBook Air M3 / M2 / M1', 'iPad Pro / Air', 'Dell XPS / Inspiron', 'Asus ROG / Zenbook', 'ThinkPad X1 / T Series', 'Dòng máy khác']
          },
          {
            name: 'spec_condition',
            label: 'Tình trạng ngoại quan',
            required: true,
            options: ['-- Chọn tình trạng máy --', 'Mới 100% (Nguyên seal)', 'Đẹp keng 99% (Không trầy xước)', 'Đẹp 98% - 95% (Xước lông mèo nhẹ)', 'Cũ 90% (Cấn móp góc nhẹ)', 'Cũ nhiều theo thời gian']
          },
          {
            name: 'spec_capacity',
            label: 'Dung lượng / RAM',
            required: false,
            options: ['-- Chọn dung lượng / RAM --', '64GB', '128GB', '256GB', '512GB', '1TB', 'RAM 8GB / SSD 256GB', 'RAM 16GB / SSD 512GB', 'RAM 32GB trở lên']
          },
          {
            name: 'spec_color',
            label: 'Màu sắc',
            required: false,
            options: ['-- Chọn màu sắc --', 'Đỏ Burgundy', 'Titan Tự Nhiên / Xám Titan', 'Đen Phantom / Space Black', 'Trắng Starlight / Bạc Silver', 'Xanh Midnight / Xanh Dương', 'Vàng Gold', 'Màu khác']
          },
          {
            name: 'spec_battery',
            label: 'Tình trạng Pin',
            required: false,
            options: ['-- Chọn tình trạng pin --', 'Pin 100% hoàn hảo', 'Pin 95% - 99%', 'Pin 90% - 94%', 'Pin 80% - 89%', 'Pin dưới 80% (Báo bảo trì)', 'Đã thay pin mới chính hãng']
          },
          {
            name: 'spec_warranty',
            label: 'Phụ kiện & Bảo hành',
            required: false,
            options: ['-- Chọn phụ kiện & bảo hành --', 'Fullbox đầy đủ hộp & sạc cáp zin', 'Có sạc cáp zin, không hộp', 'Chỉ có máy trần', 'Còn bảo hành Apple Care / Hãng dài hạn', 'Hết bảo hành hãng']
          }
        ]
      },
      '2': {
        title: 'Xe Cộ & Phương Tiện',
        fields: [
          {
            name: 'spec_vehicle_type',
            label: 'Loại phương tiện',
            required: true,
            options: ['-- Chọn loại phương tiện --', 'Xe máy tay ga', 'Xe máy số', 'Xe máy côn tay', 'Xe máy điện', 'Xe đạp điện', 'Ô tô con (4 - 7 chỗ)', 'Xe đạp thể thao']
          },
          {
            name: 'spec_vehicle_brand',
            label: 'Hãng xe',
            required: true,
            options: ['-- Chọn hãng xe --', 'Honda', 'Yamaha', 'Piaggio / Vespa', 'VinFast', 'Suzuki', 'Toyota', 'Hyundai', 'Kia', 'Mazda', 'Hãng khác']
          },
          {
            name: 'spec_vehicle_model',
            label: 'Dòng xe / Đời xe',
            required: true,
            options: ['-- Chọn dòng xe --', 'Honda SH (125i / 150i / 160i / 350i)', 'Honda Vision', 'Honda Air Blade (125 / 160)', 'Honda Lead', 'Honda Wave Alpha / RSX', 'Yamaha Exciter (150 / 155 VVA)', 'Yamaha Grande / Janus', 'Vespa Sprint / Primavera', 'VinFast Klara / Feliz / Evo', 'VinFast VF3 / VF5', 'Dòng xe khác']
          },
          {
            name: 'spec_reg_year',
            label: 'Năm đăng ký',
            required: true,
            options: ['-- Chọn năm đăng ký cavet --', '2026', '2025', '2024', '2023', '2022', '2021', '2020', '2018 - 2019', 'Trước 2018']
          },
          {
            name: 'spec_legal_status',
            label: 'Tình trạng giấy tờ',
            required: true,
            options: ['-- Chọn tình trạng giấy tờ --', 'Chính chủ - Công chứng sang tên ngay', 'Giấy tờ hợp lệ (Cavet gốc)', 'Xe biển số đẹp / Đã rút hồ sơ gốc', 'Xe không chính chủ']
          },
          {
            name: 'spec_odo',
            label: 'Số km đã đi (Odo)',
            required: false,
            options: ['-- Chọn số km đã đi --', 'Dưới 5.000 km (Xe lướt như mới)', '5.000 km - 10.000 km', '10.000 km - 20.000 km', '20.000 km - 40.000 km', 'Trên 40.000 km']
          },
          {
            name: 'spec_engine_capacity',
            label: 'Dung tích động cơ',
            required: false,
            options: ['-- Chọn dung tích động cơ --', 'Dưới 50cc (Không cần bằng lái)', '110cc', '125cc', '150cc - 160cc', 'Phân khối lớn (>175cc)', 'Động cơ điện']
          },
          {
            name: 'spec_engine_condition',
            label: 'Tình trạng máy móc',
            required: false,
            options: ['-- Chọn tình trạng máy móc --', 'Máy nguyên zin 100%, ốc tán chưa mở', 'Máy êm ái, bảo dưỡng định kỳ', 'Có dán keo trong bảo vệ từ lúc mua', 'Dàn áo có xước nhẹ theo thời gian']
          }
        ]
      },
      '3': {
        title: 'Điện Lạnh & Gia Dụng',
        fields: [
          {
            name: 'spec_appliance_type',
            label: 'Loại thiết bị',
            required: true,
            options: ['-- Chọn loại thiết bị --', 'Tủ lạnh', 'Máy giặt', 'Máy sấy quần áo', 'Máy lạnh (Điều hòa nhiệt độ)', 'Nồi chiên không dầu', 'Lò vi sóng / Lò nướng', 'Máy lọc nước', 'Máy lọc không khí', 'Bếp điện từ / Bếp hồng ngoại', 'Thiết bị gia dụng khác']
          },
          {
            name: 'spec_appliance_brand',
            label: 'Thương hiệu',
            required: true,
            options: ['-- Chọn thương hiệu --', 'Panasonic', 'Toshiba', 'Electrolux', 'LG', 'Samsung', 'Daikin', 'Casper', 'Philips', 'Sunhouse', 'Hãng khác']
          },
          {
            name: 'spec_appliance_power',
            label: 'Công suất / Dung tích',
            required: true,
            options: ['-- Chọn dung tích / công suất --', 'Tủ lạnh: Dưới 200 Lít (1 - 2 người)', 'Tủ lạnh: 200 - 350 Lít (3 - 5 người)', 'Tủ lạnh: Trên 350 Lít (Side-by-Side)', 'Máy giặt: Dưới 8.5 kg', 'Máy giặt: 9 kg - 10.5 kg', 'Máy giặt: Trên 11 kg', 'Máy lạnh: 1.0 HP (Ngựa)', 'Máy lạnh: 1.5 HP (Ngựa)', 'Máy lạnh: 2.0 HP (Ngựa)', 'Khác']
          },
          {
            name: 'spec_operation_status',
            label: 'Tình trạng hoạt động',
            required: true,
            options: ['-- Chọn tình trạng hoạt động --', 'Đang dùng cực tốt, làm lạnh / giặt cực êm', 'Công nghệ Inverter tiết kiệm điện', 'Nguyên bản 100%, chưa từng sửa chữa', 'Đã vệ sinh sạch sẽ, nạp đầy đủ gas']
          },
          {
            name: 'spec_appliance_condition',
            label: 'Tình trạng ngoại quan',
            required: true,
            options: ['-- Chọn ngoại quan --', 'Mới keng 98% - 99% không tì vết', 'Còn đẹp 90% - 95%', 'Có ố vàng hoặc trầy xước nhẹ ngoài vỏ', 'Cũ bình thường theo thời gian']
          },
          {
            name: 'spec_appliance_support',
            label: 'Chính sách hỗ trợ',
            required: false,
            options: ['-- Chọn hỗ trợ của người bán --', 'Bao test tại nhà 7 ngày, lỗi hoàn tiền', 'Có hỗ trợ công lắp đặt hoặc tiền chở', 'Tặng kèm dây cấp, ống đồng, phụ kiện', 'Người mua tự vận chuyển']
          }
        ]
      },
      '4': {
        title: 'Nội Thất & Đồ Gia Đình',
        fields: [
          {
            name: 'spec_furniture_type',
            label: 'Loại đồ dùng',
            required: true,
            options: ['-- Chọn loại đồ nội thất --', 'Bàn làm việc / Bàn gaming', 'Ghế công thái học (Ergonomic) / Ghế văn phòng', 'Sofa & Bàn trà phòng khách', 'Tủ quần áo', 'Giường ngủ & Nệm', 'Kệ tivi / Kệ sách', 'Bàn ăn & Ghế ăn', 'Đồ nội thất khác']
          },
          {
            name: 'spec_material',
            label: 'Chất liệu chính',
            required: true,
            options: ['-- Chọn chất liệu chính --', 'Gỗ tự nhiên (Sồi, Xoan đào, Cao su...)', 'Gỗ công nghiệp MDF lõi xanh chống ẩm', 'Khung sắt sơn tĩnh điện chắc chắn', 'Lưới thoáng khí cao cấp (Ghế Ergonomic)', 'Da PU / Da microfiber', 'Vải nỉ / Vải bố mềm mại', 'Chất liệu khác']
          },
          {
            name: 'spec_dimensions',
            label: 'Kích thước',
            required: true,
            options: ['-- Chọn kích thước --', 'Bàn 100 x 50 x 75 cm (Gọn gàng)', 'Bàn 120 x 60 x 75 cm (Tiêu chuẩn)', 'Bàn 140 x 70 x 75 cm (Rộng rãi)', 'Giường 1m2 x 2m (Đơn)', 'Giường 1m6 x 2m (Đôi)', 'Giường 1m8 x 2m (King size)', 'Tủ quần áo 2 - 3 cánh', 'Kích thước khác (Ghi rõ trong mô tả)']
          },
          {
            name: 'spec_furniture_color',
            label: 'Màu sắc',
            required: true,
            options: ['-- Chọn tông màu chính --', 'Màu vân gỗ sồi tự nhiên', 'Màu nâu cafe / Cánh gián', 'Màu trắng hiện đại', 'Màu đen sang trọng', 'Màu xám ghi / Ghi sáng', 'Màu be / Kem nhã nhặn', 'Màu khác']
          },
          {
            name: 'spec_furniture_condition',
            label: 'Tình trạng ngoại quan',
            required: true,
            options: ['-- Chọn tình trạng sản phẩm --', 'Đẹp keng 99% như vừa khui thùng', 'Đẹp 95% không trầy xước bề mặt', 'Còn tốt 90% (Có cấn góc hoặc sờn nhẹ)', 'Kết cấu vững chãi, không lung lay ọp ẹp']
          },
          {
            name: 'spec_transport',
            label: 'Tháo lắp & Vận chuyển',
            required: false,
            options: ['-- Chọn cách vận chuyển --', 'Đã tháo rời gọn gàng, chở được bằng xe máy', 'Có thể hỗ trợ người mua tháo lắp tại chỗ', 'Đồ nguyên khối, cần chở bằng xe ba gác / xe tải']
          }
        ]
      }
    };

    function renderCategorySpecs(catId, preSelectedSpecs) {
      const data = categorySpecsData[catId];
      const titleEl = document.getElementById('categoryNameTitle');
      const container = document.getElementById('specsContainer');
      if (!data || !container) return;

      if (titleEl) titleEl.textContent = data.title;
      container.innerHTML = '';

      // Nếu không truyền preSelectedSpecs thì dùng object rỗng
      const specs = preSelectedSpecs || {};

      // Lấy draft (lưu theo field.name) nếu có để phục hồi specs
      const draftSpecs = window._pendingSpecsDraft || null;

      data.fields.forEach(field => {
        const div = document.createElement('div');
        div.className = 'flex flex-col relative combobox-field';

        const label = document.createElement('label');
        label.className = 'block text-[11px] font-semibold text-slate-700 mb-1';
        label.innerHTML = field.label + (field.required ? ' <span class="text-red-500 font-bold">*</span>' : ' <span class="text-slate-400 font-normal text-[10px]">(Tùy chọn)</span>');

        // Bọc input và dropdown menu gợi ý
        const wrapper = document.createElement('div');
        wrapper.className = 'relative w-full';

        const input = document.createElement('input');
        input.type = 'text';
        input.name = field.name;
        input.autocomplete = 'off';
        input.className = 'w-full px-3.5 py-2 bg-white border border-slate-300 rounded-lg text-xs text-slate-800 pr-9 focus:outline-none focus:ring-2 focus:ring-blue-500 transition shadow-2xs placeholder:text-slate-400';
        
        // Placeholder gợi ý: "Chọn hoặc tự nhập..."
        const defaultPlaceholder = field.options && field.options[0] ? field.options[0].replace(/^--\s*|\s*--$/g, '') : 'Chọn hoặc tự nhập...';
        input.placeholder = defaultPlaceholder.includes('Chọn') ? defaultPlaceholder.replace('Chọn', 'Chọn hoặc tự nhập') : ('Chọn hoặc tự nhập ' + field.label.toLowerCase() + '...');
        
        if (field.required) {
          input.required = true;
        }

        const savedValue = specs[field.label] || '';
        const draftValue = draftSpecs ? (draftSpecs[field.name] || '') : '';
        const initialVal = savedValue || draftValue || '';
        if (initialVal) {
          input.value = initialVal;
        }

        // Nút mũi tên dropdown
        const toggleBtn = document.createElement('button');
        toggleBtn.type = 'button';
        toggleBtn.tabIndex = -1;
        toggleBtn.title = 'Bấm để chọn từ danh sách';
        toggleBtn.className = 'absolute right-0 top-0 bottom-0 px-2.5 flex items-center justify-center text-slate-400 hover:text-slate-600 transition cursor-pointer';
        toggleBtn.innerHTML = '<svg class="w-4 h-4 transition-transform duration-200" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path></svg>';

        // Menu danh sách gợi ý
        const dropdownMenu = document.createElement('div');
        dropdownMenu.className = 'hidden absolute left-0 right-0 top-full mt-1 bg-white border border-slate-200 rounded-lg shadow-xl z-50 max-h-56 overflow-y-auto py-1 divide-y divide-slate-50 transition-all';

        // Lấy danh sách các options (bỏ phần tử đầu tiên là placeholder -- Chọn... --)
        const rawOptions = field.options.slice(1);

        function filterOptions(searchTerm) {
          dropdownMenu.innerHTML = '';
          const term = (searchTerm || '').toLowerCase().trim();
          const matched = rawOptions.filter(opt => !term || opt.toLowerCase().includes(term));

          if (matched.length === 0) {
            const emptyTip = document.createElement('div');
            emptyTip.className = 'px-3 py-2 text-[11px] text-slate-500 italic bg-slate-50 flex items-center gap-1.5';
            emptyTip.innerHTML = '<span class="text-blue-500 font-bold">✎</span> Đang dùng thông tin tự nhập: "<span class="text-slate-800 font-semibold truncate">' + (input.value || '') + '</span>"';
            dropdownMenu.appendChild(emptyTip);
            return;
          }

          matched.forEach(opt => {
            const item = document.createElement('div');
            item.className = 'px-3 py-2 text-xs text-slate-700 hover:bg-blue-50 hover:text-blue-700 cursor-pointer flex items-center justify-between transition group';
            
            // Highlight text nếu trùng khớp
            if (term) {
              const escapedTerm = term.split('').map(c => ['*','+','?','^','$','{','}','(',')','|','[',']','\\','.','/'].includes(c) ? '\\' + c : c).join('');
              const regex = new RegExp('(' + escapedTerm + ')', 'gi');
              item.innerHTML = opt.replace(regex, '<span class="text-blue-600 font-bold bg-blue-100/60 rounded px-0.5">$1</span>');
            } else {
              item.textContent = opt;
            }

            // Đánh dấu nếu trùng với giá trị đang chọn
            if (input.value && input.value.trim().toLowerCase() === opt.trim().toLowerCase()) {
              item.classList.add('bg-blue-50/70', 'font-semibold', 'text-blue-700');
              const checkIcon = document.createElement('span');
              checkIcon.className = 'text-blue-600 text-xs font-bold';
              checkIcon.textContent = '✓';
              item.appendChild(checkIcon);
            }

            const selectThisOption = (e) => {
              if (e) {
                e.preventDefault();
                e.stopPropagation();
              }
              input.value = opt;
              closeMenu();
              input.dispatchEvent(new Event('change', { bubbles: true }));
            };

            item.addEventListener('mousedown', selectThisOption);
            item.addEventListener('click', selectThisOption);

            dropdownMenu.appendChild(item);
          });
        }

        function openMenu() {
          // Đóng tất cả các combobox khác đang mở
          document.querySelectorAll('.combobox-field div.absolute').forEach(m => {
            if (m !== dropdownMenu) m.classList.add('hidden');
          });
          document.querySelectorAll('.combobox-field button svg').forEach(svg => {
            if (!toggleBtn.contains(svg)) svg.classList.remove('rotate-180');
          });

          filterOptions(input.value);
          dropdownMenu.classList.remove('hidden');
          const svg = toggleBtn.querySelector('svg');
          if (svg) svg.classList.add('rotate-180');
        }

        function closeMenu() {
          dropdownMenu.classList.add('hidden');
          const svg = toggleBtn.querySelector('svg');
          if (svg) svg.classList.remove('rotate-180');
        }

        // Sự kiện mở/lọc
        input.addEventListener('focus', openMenu);
        input.addEventListener('click', openMenu);
        input.addEventListener('input', () => {
          openMenu();
          filterOptions(input.value);
        });

        toggleBtn.addEventListener('click', (e) => {
          e.preventDefault();
          e.stopPropagation();
          if (dropdownMenu.classList.contains('hidden')) {
            input.focus();
            openMenu();
          } else {
            closeMenu();
          }
        });

        input.addEventListener('keydown', (e) => {
          if (e.key === 'Escape') {
            closeMenu();
          }
        });

        wrapper.appendChild(input);
        wrapper.appendChild(toggleBtn);
        wrapper.appendChild(dropdownMenu);

        div.appendChild(label);
        div.appendChild(wrapper);
        container.appendChild(div);
      });

      // Bắt sự kiện click ra ngoài để đóng menu
      if (!window._comboboxGlobalClickHandlerAdded) {
        document.addEventListener('click', (e) => {
          if (!e.target.closest('.combobox-field')) {
            document.querySelectorAll('.combobox-field div.absolute').forEach(m => m.classList.add('hidden'));
            document.querySelectorAll('.combobox-field button svg').forEach(svg => svg.classList.remove('rotate-180'));
          }
        });
        window._comboboxGlobalClickHandlerAdded = true;
      }

      if (window._pendingSpecsDraft) {
        window._pendingSpecsDraft = null;
      }
    }
  </script>
</body>
</html>

