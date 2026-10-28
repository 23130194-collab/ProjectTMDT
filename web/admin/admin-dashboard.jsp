<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="model.ProductBoost" %>
<%
    String selectedRange = (String) request.getAttribute("selectedRange");
    String fromDate      = (String) request.getAttribute("fromDate");
    String toDate        = (String) request.getAttribute("toDate");
    long daysCount       = request.getAttribute("daysCount") != null ? (long) request.getAttribute("daysCount") : 7;

    Map<String,Integer> postsChartData   = (Map<String,Integer>) request.getAttribute("postsChartData");
    Map<String,Double>  revenueChartData = (Map<String,Double>) request.getAttribute("revenueChartData");
    List<Object[]> topUsers              = (List<Object[]>) request.getAttribute("topUsers");
    List<Object[]> catStats              = (List<Object[]>) request.getAttribute("catStats");
    List<ProductBoost> recentBoosts      = (List<ProductBoost>) request.getAttribute("recentBoosts");

    int totalPosts        = request.getAttribute("totalPosts") != null ? (int) request.getAttribute("totalPosts") : 0;
    int pendingPosts      = request.getAttribute("pendingPosts") != null ? (int) request.getAttribute("pendingPosts") : 0;
    int activePosts       = request.getAttribute("activePosts") != null ? (int) request.getAttribute("activePosts") : 0;
    int rejectedPosts     = request.getAttribute("rejectedPosts") != null ? (int) request.getAttribute("rejectedPosts") : 0;
    int totalUsers        = request.getAttribute("totalUsers") != null ? (int) request.getAttribute("totalUsers") : 0;
    int lockedUsers       = request.getAttribute("lockedUsers") != null ? (int) request.getAttribute("lockedUsers") : 0;
    int pendingReports    = request.getAttribute("pendingReports") != null ? (int) request.getAttribute("pendingReports") : 0;
    int activeVipPosts    = request.getAttribute("activeVipPosts") != null ? (int) request.getAttribute("activeVipPosts") : 0;
    double allTimeRevenue = request.getAttribute("allTimeRevenue") != null ? (double) request.getAttribute("allTimeRevenue") : 0;
    int totalBoostOrders  = request.getAttribute("totalBoostOrders") != null ? (int) request.getAttribute("totalBoostOrders") : 0;

    int periodPosts       = request.getAttribute("periodPosts") != null ? (int) request.getAttribute("periodPosts") : 0;
    double periodRevenue  = request.getAttribute("periodRevenue") != null ? (double) request.getAttribute("periodRevenue") : 0;
    int periodBoostOrders = request.getAttribute("periodBoostOrders") != null ? (int) request.getAttribute("periodBoostOrders") : 0;
    double approvalRate   = request.getAttribute("approvalRate") != null ? (double) request.getAttribute("approvalRate") : 100.0;

    NumberFormat nf = NumberFormat.getNumberInstance(new Locale("vi", "VN"));
    String fmtPeriodRevenue  = nf.format(periodRevenue);
    String fmtAllTimeRevenue = nf.format(allTimeRevenue);

    // JSON cho biểu đồ Tin đăng
    StringBuilder chartLabels = new StringBuilder("[");
    StringBuilder chartValues = new StringBuilder("[");
    if (postsChartData != null) {
        boolean first = true;
        for (Map.Entry<String,Integer> e : postsChartData.entrySet()) {
            if (!first) { chartLabels.append(","); chartValues.append(","); }
            chartLabels.append("\"").append(e.getKey()).append("\"");
            chartValues.append(e.getValue());
            first = false;
        }
    }
    chartLabels.append("]"); chartValues.append("]");

    // JSON cho biểu đồ Doanh thu
    StringBuilder revLabels = new StringBuilder("[");
    StringBuilder revValues = new StringBuilder("[");
    if (revenueChartData != null) {
        boolean first = true;
        for (Map.Entry<String,Double> e : revenueChartData.entrySet()) {
            if (!first) { revLabels.append(","); revValues.append(","); }
            revLabels.append("\"").append(e.getKey()).append("\"");
            revValues.append(Math.round(e.getValue()));
            first = false;
        }
    }
    revLabels.append("]"); revValues.append("]");

    // JSON cho biểu đồ Danh mục
    StringBuilder catLabels = new StringBuilder("[");
    StringBuilder catValues = new StringBuilder("[");
    if (catStats != null) {
        boolean f2 = true;
        for (Object[] c : catStats) {
            if (!f2) { catLabels.append(","); catValues.append(","); }
            catLabels.append("\"").append(c[0]).append("\"");
            catValues.append(c[1]);
            f2 = false;
        }
    }
    catLabels.append("]"); catValues.append("]");
%>
<%@ include file="admin-header.jsp" %>

<div class="main-content" style="padding:24px;max-width:1440px;margin:0 auto;display:flex;flex-direction:column;gap:20px;">
  <!-- PAGE HEADER -->
  <div style="display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:12px;">
    <div>
      <h1 class="page-title" style="font-size:22px;font-weight:800;color:#0f172a;">Executive Dashboard</h1>
      <p class="page-sub" style="font-size:13px;color:#64748b;">Trung tâm phân tích tăng trưởng, dòng tiền và kiểm duyệt MuaNgay</p>
    </div>
    <div style="display:flex;align-items:center;gap:8px;">
      <a href="<%= request.getContextPath() %>/admin/boost-packages" class="btn btn-primary btn-sm" style="background:#7c3aed;padding:8px 14px;border-radius:10px;text-decoration:none;font-weight:700;">
        Quản lý Gói VIP &amp; Đẩy tin
      </a>
      <a href="<%= request.getContextPath() %>/admin/posts?status=PENDING" class="btn btn-primary btn-sm" style="padding:8px 14px;border-radius:10px;text-decoration:none;font-weight:700;">
        Duyệt tin (<%= pendingPosts %>)
      </a>
    </div>
  </div>

  <!-- DATE FILTER TOOLBAR (BỘ LỌC THỜI GIAN ĐA NĂNG) -->
  <div style="background:#fff;border-radius:14px;border:1px solid #e2e8f0;padding:14px 18px;box-shadow:0 1px 4px rgba(0,0,0,.04);display:flex;flex-wrap:wrap;align-items:center;justify-content:space-between;gap:14px;">
    <!-- Nút bấm chọn nhanh Preset -->
    <div style="display:flex;align-items:center;gap:6px;flex-wrap:wrap;">
      <span style="font-size:12px;font-weight:700;color:#475569;margin-right:4px;">Khung thời gian:</span>
      <a href="?range=7days" class="tab-btn <%= "7days".equals(selectedRange) ? "active" : "" %>" style="padding:5px 12px;border-radius:8px;font-size:12px;">7 ngày qua</a>
      <a href="?range=30days" class="tab-btn <%= "30days".equals(selectedRange) ? "active" : "" %>" style="padding:5px 12px;border-radius:8px;font-size:12px;">30 ngày qua</a>
      <a href="?range=this_month" class="tab-btn <%= "this_month".equals(selectedRange) ? "active" : "" %>" style="padding:5px 12px;border-radius:8px;font-size:12px;">Tháng này</a>
      <a href="?range=last_month" class="tab-btn <%= "last_month".equals(selectedRange) ? "active" : "" %>" style="padding:5px 12px;border-radius:8px;font-size:12px;">Tháng trước</a>
    </div>

    <!-- Tùy chỉnh khoảng ngày bất kỳ -->
    <form action="<%= request.getContextPath() %>/admin/dashboard" method="GET" style="display:flex;align-items:center;gap:8px;flex-wrap:wrap;">
      <input type="hidden" name="range" value="custom">
      <span style="font-size:12px;color:#64748b;font-weight:600;">Tùy chọn:</span>
      <input type="date" name="from" value="<%= fromDate %>" required
             style="padding:6px 10px;border-radius:8px;border:1px solid #cbd5e1;font-size:12px;color:#0f172a;font-family:inherit;outline:none;">
      <span style="font-size:12px;color:#94a3b8;font-weight:600;">—</span>
      <input type="date" name="to" value="<%= toDate %>" required
             style="padding:6px 10px;border-radius:8px;border:1px solid #cbd5e1;font-size:12px;color:#0f172a;font-family:inherit;outline:none;">
      <button type="submit" class="btn btn-primary btn-sm" style="padding:6px 14px;border-radius:8px;cursor:pointer;font-weight:700;">
        Áp dụng
      </button>
    </form>
  </div>

  <!-- DÒNG THÔNG BÁO KHOẢNG THỜI GIAN ĐANG ÁP DỤNG -->
  <div style="font-size:12px;color:#64748b;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:8px;margin-top:-8px;">
    <span>Đang phân tích từ ngày <strong><%= fromDate %></strong> đến <strong><%= toDate %></strong> (<%= daysCount %> ngày).</span>
    <span style="color:#059669;font-weight:600;display:flex;align-items:center;gap:4px;">
      <span style="width:8px;height:8px;border-radius:50%;background:#10b981;display:inline-block;"></span>
      Dữ liệu thời gian thực
    </span>
  </div>

  <!-- ROW 1: DOANH THU & DỊCH VỤ VIP -->
  <div>
    <div style="font-size:12px;font-weight:700;text-transform:uppercase;letter-spacing:.06em;color:#64748b;margin-bottom:10px;">
      Doanh Thu &amp; Dịch Vụ Gói Đẩy / VIP
    </div>
    <div class="grid-4" style="gap:16px;">
      <div class="stat-card" style="border-left:4px solid #10b981;background:linear-gradient(135deg, #ffffff 0%, #f0fdf4 100%);">
        <div class="stat-label" style="color:#047857;font-weight:600;">DOANH THU TRONG KỲ</div>
        <div class="stat-value" style="color:#047857;font-size:24px;"><%= fmtPeriodRevenue %> đ</div>
        <div class="stat-sub">Khoảng thời gian <%= daysCount %> ngày đã chọn</div>
      </div>
      <div class="stat-card" style="border-left:4px solid #7c3aed;background:linear-gradient(135deg, #ffffff 0%, #faf5ff 100%);">
        <div class="stat-label" style="color:#6d28d9;font-weight:600;">TỔNG DOANH THU TÍCH LŨY</div>
        <div class="stat-value" style="color:#6d28d9;font-size:24px;"><%= fmtAllTimeRevenue %> đ</div>
        <div class="stat-sub">Toàn thời gian từ Gói VIP &amp; Đẩy tin</div>
      </div>
      <div class="stat-card" style="border-left:4px solid #3b82f6;">
        <div class="stat-label">LƯỢT MUA GÓI DỊCH VỤ</div>
        <div class="stat-value"><%= periodBoostOrders %> <span style="font-size:13px;font-weight:500;color:#64748b;">lượt</span></div>
        <div class="stat-sub">Tổng toàn thời gian: <%= totalBoostOrders %> lượt</div>
      </div>
      <div class="stat-card" style="border-left:4px solid #f59e0b;background:linear-gradient(135deg, #ffffff 0%, #fffbeb 100%);">
        <div class="stat-label" style="color:#b45309;font-weight:600;">TIN ĐANG GHIM VIP</div>
        <div class="stat-value" style="color:#b45309;"><%= activeVipPosts %> <span style="font-size:13px;font-weight:500;color:#92400e;">tin</span></div>
        <a href="<%= request.getContextPath() %>/admin/posts" class="stat-link" style="color:#b45309;font-weight:600;">Đang giữ top đầu →</a>
      </div>
    </div>
  </div>

  <!-- ROW 2: NỘI DUNG & KIỂM DUYỆT -->
  <div>
    <div style="font-size:12px;font-weight:700;text-transform:uppercase;letter-spacing:.06em;color:#64748b;margin-bottom:10px;">
      Nội Dung &amp; Vận Hành Kiểm Duyệt
    </div>
    <div class="grid-4" style="gap:16px;">
      <div class="stat-card">
        <div class="stat-label">TIN ĐĂNG MỚI TRONG KỲ</div>
        <div class="stat-value"><%= periodPosts %> <span style="font-size:13px;font-weight:500;color:#64748b;">tin</span></div>
        <div class="stat-sub">Tổng tin hệ thống: <%= totalPosts %></div>
      </div>
      <div class="stat-card" style="border-color:#fde68a;background:#fffbeb;">
        <div class="stat-label" style="color:#d97706;font-weight:700;">CHỜ DUYỆT CẦN XỬ LÝ</div>
        <div class="stat-value" style="color:#d97706;"><%= pendingPosts %></div>
        <a href="<%= request.getContextPath() %>/admin/posts?status=PENDING" class="stat-link" style="color:#d97706;font-weight:700;">Kiểm duyệt ngay →</a>
      </div>
      <div class="stat-card" style="border-color:#fed7aa;background:#fff7ed;">
        <div class="stat-label" style="color:#ea580c;font-weight:700;">BÁO CÁO VI PHẠM</div>
        <div class="stat-value" style="color:#ea580c;"><%= pendingReports %></div>
        <a href="<%= request.getContextPath() %>/admin/reports?status=PENDING" class="stat-link" style="color:#ea580c;font-weight:700;">Xử lý báo cáo →</a>
      </div>
      <div class="stat-card" style="border-color:#bfdbfe;background:#eff6ff;">
        <div class="stat-label" style="color:#2563eb;font-weight:700;">TỶ LỆ DUYỆT BÀI</div>
        <div class="stat-value" style="color:#2563eb;"><%= String.format("%.0f%%", approvalRate) %></div>
        <div class="stat-sub">Đã duyệt / Tổng đã kiểm duyệt</div>
      </div>
    </div>
  </div>

  <!-- ROW 3: HAI BIỂU ĐỒ SONG SONG THEO KHOẢNG THỜI GIAN ĐÃ CHỌN -->
  <div class="grid-2-1" style="display:grid;grid-template-columns:1fr 1fr;gap:20px;">
    <!-- Biểu đồ 1: Tin đăng mới theo ngày -->
    <div class="info-card">
      <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:14px;">
        <div class="info-card-title" style="margin-bottom:0;">Tin đăng mới theo ngày (<%= daysCount %> ngày)</div>
        <span style="font-size:11px;font-weight:700;color:#2563eb;background:#eff6ff;padding:3px 8px;border-radius:6px;">Tổng: <%= periodPosts %> tin</span>
      </div>
      <canvas id="postsLineChart" height="130"></canvas>
    </div>

    <!-- Biểu đồ 2: Doanh thu dịch vụ theo ngày -->
    <div class="info-card">
      <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:14px;">
        <div class="info-card-title" style="margin-bottom:0;color:#047857;">Doanh thu dịch vụ theo ngày (VNĐ)</div>
        <span style="font-size:11px;font-weight:700;color:#047857;background:#ecfdf5;padding:3px 8px;border-radius:6px;">Tổng: <%= fmtPeriodRevenue %> đ</span>
      </div>
      <canvas id="revenueBarChart" height="130"></canvas>
    </div>
  </div>

  <!-- ROW 4: GIAO DỊCH GẦN NHẤT & TOP NGƯỜI ĐĂNG & PHÂN BỔ DANH MỤC -->
  <div style="display:grid;grid-template-columns:1.4fr 1fr;gap:20px;">
    <!-- BẢNG 5 GIAO DỊCH GÓI DỊCH VỤ MỚI NHẤT -->
    <div class="info-card">
      <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:14px;">
        <div class="info-card-title" style="margin-bottom:0;">Giao Dịch Dịch Vụ Mới Nhất</div>
        <a href="<%= request.getContextPath() %>/admin/boost-packages" style="font-size:11px;color:#7c3aed;font-weight:700;text-decoration:none;">Xem tất cả lịch sử →</a>
      </div>
      <% if (recentBoosts != null && !recentBoosts.isEmpty()) { %>
        <div style="overflow-x:auto;">
          <table class="admin-table">
            <thead>
              <tr>
                <th>Khách hàng</th>
                <th>Gói dịch vụ</th>
                <th>Loại</th>
                <th class="text-right">Số tiền</th>
                <th>Thời gian</th>
              </tr>
            </thead>
            <tbody>
              <% for (ProductBoost b : recentBoosts) { 
                   String typeBadge = "VIP_PIN".equals(b.getPackageType()) 
                       ? "<span class='badge' style='background:#f3e8ff;color:#7e22ce;'>Ghim VIP</span>"
                       : "<span class='badge' style='background:#eff6ff;color:#1d4ed8;'>Đẩy Tin</span>";
              %>
                <tr>
                  <td>
                    <div style="font-weight:600;color:#0f172a;"><%= b.getUserFullName() != null ? b.getUserFullName() : "User #" + b.getUserId() %></div>
                    <% if (b.getProductTitle() != null) { %>
                      <div style="font-size:11px;color:#64748b;max-width:160px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">
                        <%= b.getProductTitle() %>
                      </div>
                    <% } else { %>
                      <div style="font-size:11px;color:#94a3b8;">Ví chung tài khoản</div>
                    <% } %>
                  </td>
                  <td>
                    <span style="font-weight:600;font-size:12px;color:#334155;"><%= b.getPackageName() != null ? b.getPackageName() : "Gói #" + b.getPackageId() %></span>
                  </td>
                  <td><%= typeBadge %></td>
                  <td class="text-right" style="font-weight:700;color:#059669;">
                    <%= nf.format(b.getAmountPaid()) %> đ
                  </td>
                  <td style="font-size:11px;color:#64748b;">
                    <%= b.getCreatedAt() != null ? new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(b.getCreatedAt()) : "-" %>
                  </td>
                </tr>
              <% } %>
            </tbody>
          </table>
        </div>
      <% } else { %>
        <div style="text-align:center;padding:32px 16px;color:#94a3b8;font-size:13px;">
          Chưa có giao dịch gói dịch vụ nào phát sinh.
        </div>
      <% } %>
    </div>

    <!-- CỘT PHẢI: TOP USERS & PHÂN BỔ DANH MỤC -->
    <div style="display:flex;flex-direction:column;gap:20px;">
      <!-- Phân bổ danh mục trong kỳ -->
      <div class="info-card">
        <div class="info-card-title">Phân Bổ Theo Danh Mục Trong Kỳ</div>
        <canvas id="donutChart" height="190"></canvas>
      </div>

      <!-- Top 5 người đăng trong kỳ -->
      <div class="info-card">
        <div class="info-card-title">Top Người Đăng Tin Trong Kỳ</div>
        <div style="display:flex;flex-direction:column;gap:10px;">
          <% if (topUsers != null && !topUsers.isEmpty()) { int rank = 1; for (Object[] u : topUsers) { %>
          <div class="flex items-center gap-3" style="display:flex;align-items:center;gap:10px;">
            <div style="width:24px;height:24px;border-radius:50%;background:#dbeafe;color:#1d4ed8;font-size:11px;font-weight:700;display:flex;align-items:center;justify-content:center;flex-shrink:0;">
              <%= rank++ %>
            </div>
            <div style="min-width:0;flex:1;">
              <div style="font-weight:600;font-size:13px;color:#0f172a;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;"><%= u[0] %></div>
              <div style="font-size:11px;color:#94a3b8;">@<%= u[1] %></div>
            </div>
            <div style="font-weight:700;font-size:13px;color:#334155;"><%= u[2] %> tin</div>
          </div>
          <% } } else { %>
          <p style="font-size:12px;color:#94a3b8;text-align:center;padding:12px 0;">Không có bài đăng mới trong khoảng thời gian này</p>
          <% } %>
        </div>
      </div>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
<script>
  // 1. BIỂU ĐỒ TIN ĐĂNG MỚI (LINE CHART)
  new Chart(document.getElementById('postsLineChart'), {
    type: 'line',
    data: {
      labels: <%= chartLabels %>,
      datasets: [{
        label: 'Tin đăng mới',
        data: <%= chartValues %>,
        fill: true,
        backgroundColor: 'rgba(37,99,235,0.08)',
        borderColor: '#2563eb',
        borderWidth: 2,
        tension: 0.35,
        pointBackgroundColor: '#2563eb',
        pointRadius: <%= daysCount > 31 ? 2 : 4 %>,
        pointHoverRadius: 6
      }]
    },
    options: {
      responsive: true,
      plugins: {
        legend: { display: false },
        tooltip: {
          callbacks: {
            label: function(ctx) { return ' ' + ctx.raw + ' tin đăng mới'; }
          }
        }
      },
      scales: {
        y: {
          beginAtZero: true,
          ticks: { stepSize: 1 }
        },
        x: {
          ticks: {
            maxTicksLimit: 14,
            font: { size: 10 }
          }
        }
      }
    }
  });

  // 2. BIỂU ĐỒ DOANH THU DỊCH VỤ (BAR CHART)
  new Chart(document.getElementById('revenueBarChart'), {
    type: 'bar',
    data: {
      labels: <%= revLabels %>,
      datasets: [{
        label: 'Doanh thu (VNĐ)',
        data: <%= revValues %>,
        backgroundColor: 'rgba(16,185,129,0.75)',
        hoverBackgroundColor: '#059669',
        borderColor: '#10b981',
        borderWidth: 1,
        borderRadius: 4
      }]
    },
    options: {
      responsive: true,
      plugins: {
        legend: { display: false },
        tooltip: {
          callbacks: {
            label: function(ctx) {
              return ' ' + new Intl.NumberFormat('vi-VN').format(ctx.raw) + ' đ';
            }
          }
        }
      },
      scales: {
        y: {
          beginAtZero: true,
          ticks: {
            callback: function(value) {
              if (value >= 1000000) return (value / 1000000).toFixed(1) + 'M';
              if (value >= 1000) return (value / 1000).toFixed(0) + 'k';
              return value;
            }
          }
        },
        x: {
          ticks: {
            maxTicksLimit: 14,
            font: { size: 10 }
          }
        }
      }
    }
  });

  // 3. BIỂU ĐỒ PHÂN BỔ THEO DANH MỤC (DOUGHNUT)
  new Chart(document.getElementById('donutChart'), {
    type: 'doughnut',
    data: {
      labels: <%= catLabels %>,
      datasets: [{
        data: <%= catValues %>,
        backgroundColor: ['#2563eb','#10b981','#f59e0b','#ef4444','#8b5cf6','#06b6d4','#ec4899','#64748b'],
        borderWidth: 2,
        borderColor: '#fff'
      }]
    },
    options: {
      responsive: true,
      plugins: {
        legend: {
          position: 'bottom',
          labels: { font: { size: 11, family: 'Inter' }, padding: 10 }
        }
      }
    }
  });
</script>

<%@ include file="admin-footer.jsp" %>
