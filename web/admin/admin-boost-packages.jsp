<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, model.BoostPackage, model.ProductBoost, java.text.NumberFormat" %>
<%
    request.setAttribute("adminPage", "boost-packages");
    List<BoostPackage> packages = (List<BoostPackage>) request.getAttribute("packages");
    List<ProductBoost> history = (List<ProductBoost>) request.getAttribute("history");
    Double totalRevenue = (Double) request.getAttribute("totalRevenue");
    Integer totalOrders = (Integer) request.getAttribute("totalOrders");

    if (totalRevenue == null) totalRevenue = 0.0;
    if (totalOrders == null) totalOrders = 0;
    NumberFormat mf = NumberFormat.getInstance(new Locale("vi", "VN"));

    long activeCount = packages != null ? packages.stream().filter(BoostPackage::isActive).count() : 0;
%>
<%@ include file="admin-header.jsp" %>

<div class="main-content">
  <div class="page-header">
    <div>
      <h1 class="page-title">Gói Đẩy Tin &amp; Ghim VIP</h1>
      <p class="page-sub">Quản lý cấu hình gói tăng hiển thị và theo dõi doanh thu</p>
    </div>
    <button onclick="openAddPackageModal()" class="btn btn-primary">
      <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
        <path stroke-linecap="round" stroke-linejoin="round" d="M12 4v16m8-8H4"/>
      </svg>
      Thêm Gói Mới
    </button>
  </div>

  <!-- STAT CARDS -->
  <div style="display:grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap:16px; margin-bottom:24px;">
    <div class="stat-card">
      <div class="stat-label">TỔNG DOANH THU BOOST</div>
      <div class="stat-value" style="color:#d97706"><%= mf.format(totalRevenue) %>đ</div>
      <div class="stat-sub">Thu nhập từ dịch vụ giá trị gia tăng</div>
    </div>
    <div class="stat-card">
      <div class="stat-label">LƯỢT MUA GÓI</div>
      <div class="stat-value" style="color:#2563eb"><%= totalOrders %></div>
      <div class="stat-sub">Tổng giao dịch kích hoạt gói thành công</div>
    </div>
    <div class="stat-card">
      <div class="stat-label">SỐ GÓI ĐANG CHẠY</div>
      <div class="stat-value" style="color:#16a34a"><%= activeCount %> / <%= packages != null ? packages.size() : 0 %></div>
      <div class="stat-sub">Gói sẵn sàng cho người bán lựa chọn</div>
    </div>
  </div>

  <!-- BẢNG 1: DANH SÁCH CÁC GÓI DỊCH VỤ -->
  <div class="table-card" style="margin-bottom:28px">
    <div style="padding:16px 20px; border-bottom:1px solid #e2e8f0; display:flex; justify-content:space-between; align-items:center;">
      <h3 style="font-size:14px; font-weight:700; color:#0f172a; margin:0">Danh mục Gói Dịch Vụ</h3>
      <span style="font-size:12px; color:#64748b">Hiển thị trong Modal Đẩy Tin của Người bán</span>
    </div>
    <table class="admin-table">
      <thead>
        <tr>
          <th>ID</th>
          <th>Tên Gói</th>
          <th>Loại Gói</th>
          <th>Giá Bán</th>
          <th>Thời hạn / Số lượt</th>
          <th>Huy Hiệu</th>
          <th>Trạng Thái</th>
          <th class="text-right">Thao tác</th>
        </tr>
      </thead>
      <tbody>
        <% if (packages != null && !packages.isEmpty()) { 
             for (BoostPackage p : packages) { 
        %>
        <tr>
          <td class="td-mono">#<%= p.getId() %></td>
          <td style="font-weight:700; color:#1e293b">
            <%= p.getName() %>
            <div style="font-size:11px; color:#64748b; font-weight:400"><%= p.getDescription() != null ? p.getDescription() : "" %></div>
          </td>
          <td>
            <span class="badge <%= p.isVipPackage() ? "badge-admin" : "badge-user" %>">
              <%= p.isVipPackage() ? "👑 GHIM VIP" : "🚀 ĐẨY TIN" %>
            </span>
          </td>
          <td style="font-weight:700; color:#ea580c; white-space:nowrap">
            <%= mf.format(p.getPrice()) %> đ
          </td>
          <td style="font-size:12px">
            <%= p.isVipPackage() ? (p.getDurationDays() + " ngày") : (p.getBumpCount() + " lượt đẩy") %>
          </td>
          <td>
            <span style="font-size:10px; font-weight:800; padding:2px 8px; border-radius:999px; background:#fef3c7; color:#92400e; border:1px solid #fde68a">
              <%= p.getBadgeLabel() != null ? p.getBadgeLabel() : "VIP" %>
            </span>
          </td>
          <td>
            <form action="<%= request.getContextPath() %>/admin/boost-packages" method="post" style="display:inline">
              <input type="hidden" name="action" value="toggle">
              <input type="hidden" name="id" value="<%= p.getId() %>">
              <input type="hidden" name="active" value="<%= !p.isActive() %>">
              <button type="submit" class="badge <%= p.isActive() ? "badge-active" : "badge-hidden" %>" style="border:none; cursor:pointer" title="Bấm để bật/tắt">
                <%= p.isActive() ? "● Đang bật" : "○ Đang tắt" %>
              </button>
            </form>
          </td>
          <td class="text-right">
            <button onclick="editPackage(<%= p.getId() %>, '<%= p.getName() %>', '<%= p.getPackageType() %>', <%= p.getPrice() %>, <%= p.getDurationDays() %>, <%= p.getBumpCount() %>, <%= p.getPriorityLevel() %>, '<%= p.getBadgeLabel() %>', '<%= p.getBadgeColor() %>', '<%= p.getDescription() != null ? p.getDescription().replace("'", "\\'") : "" %>', <%= p.isActive() %>, <%= p.getSortOrder() %>)"
                    class="btn btn-ghost btn-sm">
              Sửa
            </button>
          </td>
        </tr>
        <%   } 
           } else { %>
        <tr>
          <td colspan="8" style="text-align:center; padding:32px; color:#94a3b8">Chưa có gói nào. Bấm "Thêm Gói Mới" để tạo.</td>
        </tr>
        <% } %>
      </tbody>
    </table>
  </div>

  <!-- BẢNG 2: LỊCH SỬ MUA GÓI CỦA NGƯỜI BÁN -->
  <div class="table-card">
    <div style="padding:16px 20px; border-bottom:1px solid #e2e8f0; display:flex; justify-content:space-between; align-items:center;">
      <h3 style="font-size:14px; font-weight:700; color:#0f172a; margin:0">Lịch Sử Mua Gói Của Người Bán</h3>
      <span style="font-size:12px; color:#64748b">Giao dịch thanh toán kích hoạt thành công</span>
    </div>
    <table class="admin-table">
      <thead>
        <tr>
          <th>Thời gian</th>
          <th>Sản Phẩm</th>
          <th>Người Bán</th>
          <th>Gói Đã Mua</th>
          <th>Số Tiền</th>
          <th>Hiệu Lực Đến</th>
          <th>Mã VNPay Txn</th>
          <th>Trạng Thái</th>
        </tr>
      </thead>
      <tbody>
        <% if (history != null && !history.isEmpty()) { 
             java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm");
             for (ProductBoost b : history) {
        %>
        <tr>
          <td style="font-size:11px; color:#64748b"><%= b.getCreatedAt() != null ? sdf.format(b.getCreatedAt()) : "" %></td>
          <td style="font-size:12px; font-weight:600">
            <% if (b.getProductId() > 0) { %>
              <a href="<%= request.getContextPath() %>/product-detail?id=<%= b.getProductId() %>" target="_blank" style="color:#2563eb; text-decoration:none">
                #<%= b.getProductId() %> • <%= b.getProductTitle() != null ? b.getProductTitle() : "Tin đăng" %>
              </a>
            <% } else { %>
              <span style="color:#6366f1; font-weight:700">🚀 Nạp Ví Lượt Đẩy</span>
            <% } %>
          </td>
          <td style="font-size:12px"><%= b.getUserFullName() != null ? b.getUserFullName() : ("User #" + b.getUserId()) %></td>
          <td>
            <span class="badge <%= "VIP_PIN".equalsIgnoreCase(b.getPackageType()) ? "badge-admin" : "badge-user" %>">
              <%= b.getPackageName() != null ? b.getPackageName() : b.getPackageType() %>
            </span>
          </td>
          <td style="font-weight:700; color:#16a34a; white-space:nowrap"><%= mf.format(b.getAmountPaid()) %> đ</td>
          <td style="font-size:11px; color:#475569">
            <%= b.getEndTime() != null ? sdf.format(b.getEndTime()) : (b.getRemainingBumps() > 0 ? ("Còn " + b.getRemainingBumps() + " bump") : "Đã kích hoạt") %>
          </td>
          <td class="td-mono" style="font-size:10px"><%= b.getVnpTxnRef() != null ? b.getVnpTxnRef() : "-" %></td>
          <td>
            <span class="badge <%= b.isCurrentlyActive() ? "badge-active" : "badge-hidden" %>">
              <%= b.isCurrentlyActive() ? "Đang hiệu lực" : "Hết hạn" %>
            </span>
          </td>
        </tr>
        <%   }
           } else { %>
        <tr>
          <td colspan="8" style="text-align:center; padding:32px; color:#94a3b8">Chưa có giao dịch mua gói nào.</td>
        </tr>
        <% } %>
      </tbody>
    </table>
  </div>
</div>

<!-- MODAL THÊM / SỬA GÓI DỊCH VỤ -->
<div id="packageModal" class="hidden" style="position:fixed; inset:0; z-index:100; background:rgba(15,23,42,0.5); display:flex; align-items:center; justify-content:center; padding:16px;">
  <div style="background:#fff; border-radius:16px; width:100%; max-width:520px; overflow:hidden; box-shadow:0 20px 25px -5px rgba(0,0,0,0.1);">
    <div style="padding:16px 20px; border-bottom:1px solid #e2e8f0; display:flex; justify-content:space-between; align-items:center; background:#f8fafc;">
      <h3 id="modalTitle" style="font-size:15px; font-weight:700; color:#0f172a; margin:0">Thêm Gói Đẩy Tin Mới</h3>
      <button type="button" onclick="closePackageModal()" style="background:none; border:none; font-size:18px; color:#94a3b8; cursor:pointer">✕</button>
    </div>
    
    <form action="<%= request.getContextPath() %>/admin/boost-packages" method="post" style="padding:20px; display:flex; flex-direction:column; gap:14px;">
      <input type="hidden" name="action" value="save">
      <input type="hidden" id="pkgId" name="id" value="0">

      <div>
        <label style="font-size:12px; font-weight:600; color:#334155; display:block; margin-bottom:4px">Tên Gói</label>
        <input type="text" id="pkgName" name="name" required placeholder="VD: Gói VIP Kim Cương (7 Ngày)" class="form-input" style="width:100%">
      </div>

      <div style="display:grid; grid-template-columns: 1fr 1fr; gap:12px;">
        <div>
          <label style="font-size:12px; font-weight:600; color:#334155; display:block; margin-bottom:4px">Loại Gói</label>
          <select id="pkgType" name="packageType" onchange="toggleTypeFields()" class="form-input" style="width:100%">
            <option value="BUMP">🚀 Đẩy Tin</option>
            <option value="VIP_PIN">👑 Ghim Tin VIP</option>
          </select>
        </div>
        <div>
          <label style="font-size:12px; font-weight:600; color:#334155; display:block; margin-bottom:4px">Giá Bán (VNĐ)</label>
          <input type="number" id="pkgPrice" name="price" required min="0" step="1000" placeholder="VD: 30000" class="form-input" style="width:100%">
        </div>
      </div>

      <div id="vipFields" style="display:grid; grid-template-columns: 1fr 1fr; gap:12px;">
        <div>
          <label style="font-size:12px; font-weight:600; color:#334155; display:block; margin-bottom:4px">Số ngày ghim</label>
          <input type="number" id="pkgDuration" name="durationDays" min="1" value="3" class="form-input" style="width:100%">
        </div>
        <div>
          <label style="font-size:12px; font-weight:600; color:#334155; display:block; margin-bottom:4px">Độ ưu tiên (1-3)</label>
          <input type="number" id="pkgPriority" name="priorityLevel" min="1" max="3" value="1" class="form-input" style="width:100%">
        </div>
      </div>

      <div id="bumpFields" style="display:none">
        <label style="font-size:12px; font-weight:600; color:#334155; display:block; margin-bottom:4px">Số lượt đẩy tin (Bumps)</label>
        <input type="number" id="pkgBumps" name="bumpCount" min="1" value="1" class="form-input" style="width:100%">
      </div>

      <div style="display:grid; grid-template-columns: 1fr 1fr; gap:12px;">
        <div>
          <label style="font-size:12px; font-weight:600; color:#334155; display:block; margin-bottom:4px">Nhãn Huy Hiệu</label>
          <input type="text" id="pkgBadgeLabel" name="badgeLabel" value="⭐ NỔI BẬT" class="form-input" style="width:100%">
        </div>
        <div>
          <label style="font-size:12px; font-weight:600; color:#334155; display:block; margin-bottom:4px">Màu sắc</label>
          <select id="pkgBadgeColor" name="badgeColor" class="form-input" style="width:100%">
            <option value="amber">Vàng Cam (Amber)</option>
            <option value="purple">Tím Kim Cương (Purple)</option>
            <option value="blue">Xanh Dương (Blue)</option>
            <option value="emerald">Xanh Lá (Emerald)</option>
          </select>
        </div>
      </div>

      <div>
        <label style="font-size:12px; font-weight:600; color:#334155; display:block; margin-bottom:4px">Mô tả quyền lợi</label>
        <textarea id="pkgDesc" name="description" rows="2" class="form-input" style="width:100%" placeholder="Quyền lợi hiển thị cho người bán xem..."></textarea>
      </div>

      <div style="display:grid; grid-template-columns: 1fr 1fr; gap:12px;">
        <div>
          <label style="font-size:12px; font-weight:600; color:#334155; display:block; margin-bottom:4px">Thứ tự hiển thị</label>
          <input type="number" id="pkgSort" name="sortOrder" value="1" class="form-input" style="width:100%">
        </div>
        <div>
          <label style="font-size:12px; font-weight:600; color:#334155; display:block; margin-bottom:4px">Trạng thái</label>
          <select id="pkgActive" name="isActive" class="form-input" style="width:100%">
            <option value="1">Kích hoạt (Bật)</option>
            <option value="0">Tạm dừng (Tắt)</option>
          </select>
        </div>
      </div>

      <div style="margin-top:8px; display:flex; justify-content:flex-end; gap:8px;">
        <button type="button" onclick="closePackageModal()" class="btn btn-ghost">Hủy</button>
        <button type="submit" class="btn btn-primary">Lưu Gói</button>
      </div>
    </form>
  </div>
</div>

<script>
  function openAddPackageModal() {
    document.getElementById('modalTitle').textContent = 'Thêm Gói Đẩy Tin Mới';
    document.getElementById('pkgId').value = '0';
    document.getElementById('pkgName').value = '';
    document.getElementById('pkgType').value = 'VIP_PIN';
    document.getElementById('pkgPrice').value = '30000';
    document.getElementById('pkgDuration').value = '3';
    document.getElementById('pkgPriority').value = '1';
    document.getElementById('pkgBumps').value = '0';
    document.getElementById('pkgBadgeLabel').value = '⭐ NỔI BẬT';
    document.getElementById('pkgBadgeColor').value = 'amber';
    document.getElementById('pkgDesc').value = '';
    document.getElementById('pkgSort').value = '1';
    document.getElementById('pkgActive').value = '1';
    toggleTypeFields();
    document.getElementById('packageModal').classList.remove('hidden');
  }

  function editPackage(id, name, type, price, days, bumps, priority, badge, color, desc, active, sort) {
    document.getElementById('modalTitle').textContent = 'Chỉnh Sửa Gói #' + id;
    document.getElementById('pkgId').value = id;
    document.getElementById('pkgName').value = name;
    document.getElementById('pkgType').value = type;
    document.getElementById('pkgPrice').value = price;
    document.getElementById('pkgDuration').value = days;
    document.getElementById('pkgBumps').value = bumps;
    document.getElementById('pkgPriority').value = priority;
    document.getElementById('pkgBadgeLabel').value = badge;
    document.getElementById('pkgBadgeColor').value = color;
    document.getElementById('pkgDesc').value = desc;
    document.getElementById('pkgSort').value = sort;
    document.getElementById('pkgActive').value = active ? '1' : '0';
    toggleTypeFields();
    document.getElementById('packageModal').classList.remove('hidden');
  }

  function closePackageModal() {
    document.getElementById('packageModal').classList.add('hidden');
  }

  function toggleTypeFields() {
    const type = document.getElementById('pkgType').value;
    const vipFields = document.getElementById('vipFields');
    const bumpFields = document.getElementById('bumpFields');
    if (type === 'VIP_PIN') {
      vipFields.style.display = 'grid';
      bumpFields.style.display = 'none';
    } else {
      vipFields.style.display = 'none';
      bumpFields.style.display = 'block';
    }
  }
</script>

<%@ include file="admin-footer.jsp" %>
