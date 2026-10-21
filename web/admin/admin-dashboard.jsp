<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%
    Map<String,Integer> chartData = (Map<String,Integer>) request.getAttribute("chartData");
    List<Object[]> topUsers = (List<Object[]>) request.getAttribute("topUsers");
    List<Object[]> catStats = (List<Object[]>) request.getAttribute("catStats");
    int totalPosts    = (int) request.getAttribute("totalPosts");
    int pendingPosts  = (int) request.getAttribute("pendingPosts");
    int activePosts   = (int) request.getAttribute("activePosts");
    int rejectedPosts = (int) request.getAttribute("rejectedPosts");
    int totalUsers    = (int) request.getAttribute("totalUsers");
    int lockedUsers   = (int) request.getAttribute("lockedUsers");
    int pendingReports= (int) request.getAttribute("pendingReports");

    StringBuilder chartLabels = new StringBuilder("[");
    StringBuilder chartValues = new StringBuilder("[");
    if (chartData != null) {
        boolean first = true;
        for (Map.Entry<String,Integer> e : chartData.entrySet()) {
            if (!first) { chartLabels.append(","); chartValues.append(","); }
            chartLabels.append("\"").append(e.getKey()).append("\"");
            chartValues.append(e.getValue());
            first = false;
        }
    }
    chartLabels.append("]"); chartValues.append("]");

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

    double approvalRate = totalPosts > 0 ? (double)activePosts/totalPosts*100 : 0;
%>
<%@ include file="admin-header.jsp" %>

<div class="main-content">
  <div>
    <h1 class="page-title">Dashboard</h1>
    <p class="page-sub">Tổng quan hoạt động sàn giao dịch MuaNgay</p>
  </div>

  <!-- Stat cards row 1 -->
  <div class="grid-4">
    <div class="stat-card">
      <div class="stat-label">Tổng tin đăng</div>
      <div class="stat-value"><%= totalPosts %></div>
      <div class="stat-sub">Tất cả thời gian</div>
    </div>
    <div class="stat-card" style="border-color:#fde68a">
      <div class="stat-label" style="color:#d97706">Chờ duyệt</div>
      <div class="stat-value" style="color:#d97706"><%= pendingPosts %></div>
      <a href="<%= request.getContextPath() %>/admin/posts?status=PENDING" class="stat-link">Xem ngay →</a>
    </div>
    <div class="stat-card" style="border-color:#bbf7d0">
      <div class="stat-label" style="color:#16a34a">Đang hiển thị</div>
      <div class="stat-value" style="color:#16a34a"><%= activePosts %></div>
      <div class="stat-sub">Tin đã duyệt ACTIVE</div>
    </div>
    <div class="stat-card" style="border-color:#fecaca">
      <div class="stat-label" style="color:#dc2626">Bị từ chối</div>
      <div class="stat-value" style="color:#dc2626"><%= rejectedPosts %></div>
      <a href="<%= request.getContextPath() %>/admin/posts?status=REJECTED" class="stat-link">Xem ngay →</a>
    </div>
  </div>

  <!-- Stat cards row 2 -->
  <div class="grid-4">
    <div class="stat-card">
      <div class="stat-label">Tổng người dùng</div>
      <div class="stat-value"><%= totalUsers %></div>
    </div>
    <div class="stat-card" style="border-color:#fecaca;background:#fff5f5">
      <div class="stat-label" style="color:#dc2626">Tài khoản bị khóa</div>
      <div class="stat-value" style="color:#dc2626"><%= lockedUsers %></div>
    </div>
    <div class="stat-card" style="border-color:#fed7aa;background:#fff7ed">
      <div class="stat-label" style="color:#ea580c">Báo cáo vi phạm mới</div>
      <div class="stat-value" style="color:#ea580c"><%= pendingReports %></div>
      <a href="<%= request.getContextPath() %>/admin/reports?status=PENDING" class="stat-link">Xử lý ngay →</a>
    </div>
    <div class="stat-card" style="border-color:#bfdbfe;background:#eff6ff">
      <div class="stat-label" style="color:#2563eb">Tỷ lệ duyệt</div>
      <div class="stat-value" style="color:#2563eb"><%= String.format("%.0f%%", approvalRate) %></div>
      <div class="stat-sub">Tin được duyệt ACTIVE</div>
    </div>
  </div>

  <!-- Charts row -->
  <div class="grid-3-1">
    <!-- Line chart -->
    <div class="info-card">
      <div class="info-card-title">Tin đăng 7 ngày gần nhất</div>
      <canvas id="lineChart" height="110"></canvas>
    </div>

    <!-- Top users -->
    <div class="info-card">
      <div class="info-card-title">🏆 Top người đăng tin</div>
      <div style="display:flex;flex-direction:column;gap:10px">
        <% if (topUsers != null && !topUsers.isEmpty()) { int rank = 1; for (Object[] u : topUsers) { %>
        <div class="flex items-center gap-3">
          <div style="width:24px;height:24px;border-radius:50%;background:#dbeafe;color:#1d4ed8;
                      font-size:11px;font-weight:700;display:flex;align-items:center;justify-content:center;flex-shrink:0">
            <%= rank++ %>
          </div>
          <div class="min-w-0 flex-1">
            <div class="font-semibold text-sm truncate" style="color:#0f172a"><%= u[0] %></div>
            <div class="text-xs text-slate-400">@<%= u[1] %></div>
          </div>
          <div class="font-bold text-sm text-slate-600"><%= u[2] %> tin</div>
        </div>
        <% } } else { %>
        <p class="text-xs text-slate-400">Chưa có dữ liệu</p>
        <% } %>
      </div>
    </div>
  </div>

  <!-- Donut + Quick actions -->
  <div class="grid-2-1">
    <div class="info-card">
      <div class="info-card-title">Phân bổ theo danh mục</div>
      <canvas id="donutChart" height="200"></canvas>
    </div>
    <div class="info-card">
      <div class="info-card-title">⚡ Thao tác nhanh</div>
      <div class="quick-actions-list">
        <a href="<%= request.getContextPath() %>/admin/posts?status=PENDING"
           class="quick-action qa-amber-bg">
          <div class="qa-icon qa-amber"><%= pendingPosts %></div>
          <span style="color:#92400e">Duyệt tin đang chờ</span>
        </a>
        <a href="<%= request.getContextPath() %>/admin/reports?status=PENDING"
           class="quick-action qa-red-bg">
          <div class="qa-icon qa-red"><%= pendingReports %></div>
          <span style="color:#991b1b">Xử lý báo cáo vi phạm</span>
        </a>
        <a href="<%= request.getContextPath() %>/admin/users?status=locked"
           class="quick-action qa-slate-bg">
          <div class="qa-icon qa-slate"><%= lockedUsers %></div>
          <span style="color:#334155">Tài khoản bị khóa</span>
        </a>
        <a href="<%= request.getContextPath() %>/admin/keywords"
           class="quick-action qa-blue-bg">
          <div class="qa-icon qa-blue">🚫</div>
          <span style="color:#1e40af">Quản lý từ khóa cấm</span>
        </a>
      </div>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
<script>
  new Chart(document.getElementById('lineChart'), {
    type: 'line',
    data: {
      labels: <%=chartLabels%>,
      datasets: [{
        label: 'Tin đăng mới',
        data: <%=chartValues%>,
        fill: true,
        backgroundColor: 'rgba(37,99,235,0.07)',
        borderColor: '#2563eb',
        borderWidth: 2,
        tension: 0.4,
        pointBackgroundColor: '#2563eb',
        pointRadius: 4
      }]
    },
    options: {
      responsive: true,
      plugins: { legend: { display: false } },
      scales: { y: { beginAtZero: true, ticks: { stepSize: 1 } } }
    }
  });

  new Chart(document.getElementById('donutChart'), {
    type: 'doughnut',
    data: {
      labels: <%=catLabels%>,
      datasets: [{
        data: <%=catValues%>,
        backgroundColor: ['#2563eb','#16a34a','#d97706','#dc2626','#7c3aed','#0891b2'],
        borderWidth: 2,
        borderColor: '#fff'
      }]
    },
    options: {
      responsive: true,
      plugins: { legend: { position: 'bottom', labels: { font: { size: 11, family: 'Inter' }, padding: 12 } } }
    }
  });
</script>

<%@ include file="admin-footer.jsp" %>
