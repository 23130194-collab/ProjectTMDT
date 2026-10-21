<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, model.Report" %>
<%
    List<Report> reports = (List<Report>) request.getAttribute("reports");
    String statusFilter  = (String) request.getAttribute("statusFilter");
    if (statusFilter == null) statusFilter = "";
%>
<%@ include file="admin-header.jsp" %>

<div class="main-content">
  <div>
    <h1 class="page-title">Báo cáo vi phạm</h1>
    <p class="page-sub">Xử lý báo cáo vi phạm từ người dùng</p>
  </div>

  <!-- Status tabs -->
  <div class="tab-bar">
    <% String[] tabs = {"","PENDING","RESOLVED","IGNORED"};
       String[] tabLabels = {"Tất cả","Chờ xử lý","Đã giải quyết","Bỏ qua"};
       for (int t = 0; t < tabs.length; t++) { %>
    <a href="<%= request.getContextPath() %>/admin/reports<%= tabs[t].isEmpty() ? "" : "?status="+tabs[t] %>"
       class="tab-btn <%= tabs[t].equals(statusFilter) ? "active" : "" %>">
      <%= tabLabels[t] %>
    </a>
    <% } %>
  </div>

  <!-- Reports list -->
  <div style="display:flex;flex-direction:column;gap:14px">
    <% if (reports != null && !reports.isEmpty()) for (Report r : reports) {
        boolean isPending  = "PENDING".equals(r.getStatus());
        boolean isResolved = "RESOLVED".equals(r.getStatus());
        String cardCls = isPending ? "pending-card" : isResolved ? "resolved-card" : "ignored-card";
        String stBadge = isPending ? "badge-pending" : isResolved ? "badge-active" : "badge-hidden";
        String stLabel = isPending ? "Chờ xử lý"   : isResolved ? "Đã giải quyết" : "Bỏ qua";
    %>
    <div class="report-card <%= cardCls %>">
      <div class="report-meta">
        <div class="report-meta-left">
          <span class="report-id">Báo cáo #<%= r.getId() %></span>
          <span class="badge <%= stBadge %>"><%= stLabel %></span>
        </div>
        <span class="report-date">
          <%= r.getCreatedAt() != null ? r.getCreatedAt().toString().substring(0,16) : "" %>
        </span>
      </div>

      <div class="report-grid">
        <div class="report-info-box">
          <div class="report-info-label">👤 Người báo cáo</div>
          <div class="text-sm text-slate-700">
            <%= r.getReporterName() != null ? r.getReporterName() : "ID: "+r.getReporterId() %>
          </div>
        </div>
        <div class="report-info-box">
          <div class="report-info-label">📋 Tin bị báo cáo</div>
          <a href="<%= request.getContextPath() %>/product-detail?id=<%= r.getProductId() %>"
             target="_blank" class="td-link text-sm">
            <%= r.getProductTitle() != null ? r.getProductTitle() : "ID: "+r.getProductId() %>
          </a>
        </div>
      </div>

      <div class="report-reason"><strong>Lý do:</strong> <%= r.getReason() %></div>

      <% if (r.getAdminNote() != null && !r.getAdminNote().isEmpty()) { %>
      <div class="report-note"><strong>Ghi chú Admin:</strong> <%= r.getAdminNote() %></div>
      <% } %>

      <% if (isPending) { %>
      <form method="post" action="<%= request.getContextPath() %>/admin/reports" class="report-actions">
        <input type="hidden" name="reportId" value="<%= r.getId() %>">
        <input type="hidden" name="productId" value="<%= r.getProductId() %>">
        <div class="form-group flex-1" style="min-width:180px">
          <label class="form-label">Ghi chú Admin</label>
          <input name="adminNote" class="form-input" placeholder="Lý do xử lý...">
        </div>
        <button name="action" value="ignore" type="submit" class="btn btn-ghost">Bỏ qua</button>
        <button name="action" value="hidePost" type="submit" class="btn btn-primary"
                onclick="return confirm('Ẩn tin này?')">Ẩn tin đăng</button>
        <button name="action" value="deletePost" type="submit" class="btn btn-danger"
                onclick="return confirm('Xóa vĩnh viễn tin này?')">Xóa tin đăng</button>
      </form>
      <% } %>
    </div>
    <% } %>
    <% if (reports == null || reports.isEmpty()) { %>
    <div class="table-card table-empty">
      Không có báo cáo vi phạm nào<%= statusFilter.isEmpty() ? "" : " trong trạng thái này" %>.
    </div>
    <% } %>
  </div>
</div>

<%@ include file="admin-footer.jsp" %>
