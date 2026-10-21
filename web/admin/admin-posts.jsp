<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, model.Category" %>
<%
    List<Object[]> posts   = (List<Object[]>) request.getAttribute("posts");
    int totalPosts         = (int) request.getAttribute("totalPosts");
    int currentPage        = (int) request.getAttribute("currentPage");
    int totalPages         = (int) request.getAttribute("totalPages");
    String statusFilter    = (String) request.getAttribute("statusFilter");
    String keyword         = (String) request.getAttribute("keyword");
    String catIdFilter     = (String) request.getAttribute("catIdFilter");
    List<Category> cats    = (List<Category>) request.getAttribute("categories");
    if (statusFilter == null) statusFilter = "";
    if (keyword == null) keyword = "";
    if (catIdFilter == null) catIdFilter = "";
    String buildQuery = "status=" + statusFilter + "&keyword=" + keyword + "&catId=" + catIdFilter;
%>
<%@ include file="admin-header.jsp" %>

<div class="main-content">
  <!-- Header -->
  <div class="page-header">
    <div>
      <h1 class="page-title">Quản lý Tin đăng</h1>
      <p class="page-sub">Tổng cộng <strong><%= totalPosts %></strong> tin đăng</p>
    </div>
  </div>

  <!-- Filter form -->
  <form method="get" action="<%= request.getContextPath() %>/admin/posts" class="filter-card">
    <div class="form-group flex-1" style="min-width:220px">
      <label class="form-label">Tìm kiếm</label>
      <input class="form-input form-input-lg" name="keyword" value="<%= keyword %>"
             placeholder="Tiêu đề, tên người đăng...">
    </div>
    <div class="form-group">
      <label class="form-label">Trạng thái</label>
      <select class="form-select" name="status">
        <option value="">Tất cả</option>
        <option value="PENDING"  <%= "PENDING".equals(statusFilter)  ? "selected":"" %>>Chờ duyệt</option>
        <option value="ACTIVE"   <%= "ACTIVE".equals(statusFilter)   ? "selected":"" %>>Đang hiển thị</option>
        <option value="REJECTED" <%= "REJECTED".equals(statusFilter) ? "selected":"" %>>Bị từ chối</option>
        <option value="HIDDEN"   <%= "HIDDEN".equals(statusFilter)   ? "selected":"" %>>Đã ẩn</option>
      </select>
    </div>
    <div class="form-group">
      <label class="form-label">Danh mục</label>
      <select class="form-select" name="catId">
        <option value="">Tất cả</option>
        <% if (cats != null) for (Category c : cats) { %>
        <option value="<%= c.getId() %>" <%= String.valueOf(c.getId()).equals(catIdFilter) ? "selected":"" %>><%= c.getName() %></option>
        <% } %>
      </select>
    </div>
    <div class="flex gap-2">
      <button type="submit" class="btn btn-primary">🔍 Lọc</button>
      <a href="<%= request.getContextPath() %>/admin/posts" class="btn btn-ghost">Reset</a>
    </div>
  </form>

  <!-- Table -->
  <div class="table-card">
    <table class="admin-table">
      <thead>
        <tr>
          <th>ID</th>
          <th>Tiêu đề</th>
          <th>Danh mục</th>
          <th>Người đăng</th>
          <th>Giá</th>
          <th>Trạng thái</th>
          <th>Ngày đăng</th>
          <th class="text-right">Hành động</th>
        </tr>
      </thead>
      <tbody>
        <% if (posts != null && !posts.isEmpty()) {
           for (Object[] p : posts) {
             int pid = (int) p[0];
             String title    = (String) p[1];
             String status   = (String) p[2];
             long price = p[3] instanceof Long ? (Long)p[3] : ((Number)p[3]).longValue();
             String ownerName = (String) p[4];
             String catName   = (String) p[5];
             java.sql.Timestamp createdAt = (java.sql.Timestamp) p[6];
             String badgeCls = "PENDING".equals(status) ? "badge-pending" :
                               "ACTIVE".equals(status)  ? "badge-active"  :
                               "REJECTED".equals(status)? "badge-rejected": "badge-hidden";
             String stLabel  = "PENDING".equals(status) ? "Chờ duyệt" :
                               "ACTIVE".equals(status)  ? "Đang hiển thị" :
                               "REJECTED".equals(status)? "Đã từ chối" :
                               "HIDDEN".equals(status)  ? "Đã ẩn" : status;
        %>
        <tr>
          <td class="td-mono">#<%= pid %></td>
          <td>
            <a href="<%= request.getContextPath() %>/product-detail?id=<%= pid %>"
               target="_blank" class="td-link"
               style="display:block;max-width:220px;overflow:hidden;white-space:nowrap;text-overflow:ellipsis">
              <%= title != null ? title : "(Không có tiêu đề)" %>
            </a>
          </td>
          <td class="td-muted"><%= catName %></td>
          <td class="td-muted"><%= ownerName %></td>
          <td class="td-bold" style="font-size:12px"><%= String.format("%,.0f đ", (double)price) %></td>
          <td><span class="badge <%= badgeCls %>"><%= stLabel %></span></td>
          <td class="td-muted"><%= createdAt != null ? createdAt.toString().substring(0,10) : "" %></td>
          <td class="td-right">
            <div class="flex gap-2 justify-end">
              <% if ("PENDING".equals(status)) { %>
              <form method="post" action="<%= request.getContextPath() %>/admin/posts" style="display:inline">
                <input type="hidden" name="productId" value="<%= pid %>">
                <input type="hidden" name="action" value="approve">
                <input type="hidden" name="referer" value="<%= buildQuery %>">
                <button type="submit" class="btn btn-sm btn-primary">✓ Duyệt</button>
              </form>
              <form method="post" action="<%= request.getContextPath() %>/admin/posts" style="display:inline">
                <input type="hidden" name="productId" value="<%= pid %>">
                <input type="hidden" name="action" value="reject">
                <button type="submit" class="btn btn-sm btn-danger"
                        onclick="return confirm('Từ chối tin #<%= pid %>?')">✗ Từ chối</button>
              </form>
              <% } %>
              <% if ("ACTIVE".equals(status)) { %>
              <form method="post" action="<%= request.getContextPath() %>/admin/posts" style="display:inline">
                <input type="hidden" name="productId" value="<%= pid %>">
                <input type="hidden" name="action" value="hide">
                <button type="submit" class="btn btn-sm btn-ghost">Ẩn</button>
              </form>
              <% } %>
              <% if ("HIDDEN".equals(status)) { %>
              <form method="post" action="<%= request.getContextPath() %>/admin/posts" style="display:inline">
                <input type="hidden" name="productId" value="<%= pid %>">
                <input type="hidden" name="action" value="unhide">
                <button type="submit" class="btn btn-sm btn-primary">Hủy ẩn</button>
              </form>
              <% } %>
              <form method="post" action="<%= request.getContextPath() %>/admin/posts" style="display:inline">
                <input type="hidden" name="productId" value="<%= pid %>">
                <input type="hidden" name="action" value="delete">
                <button type="submit" class="btn-text-danger"
                        onclick="return confirm('Xóa vĩnh viễn tin #<%= pid %>?')">Xóa</button>
              </form>
            </div>
          </td>
        </tr>
        <% } } else { %>
        <tr><td colspan="8" class="table-empty">Không có tin đăng nào phù hợp.</td></tr>
        <% } %>
      </tbody>
    </table>
  </div>

  <!-- Pagination -->
  <% if (totalPages > 1) { %>
  <div class="pagination">
    <% for (int i = 1; i <= totalPages; i++) { %>
    <a href="<%= request.getContextPath() %>/admin/posts?<%= buildQuery %>&page=<%= i %>"
       class="page-btn <%= i == currentPage ? "active" : "" %>"><%= i %></a>
    <% } %>
  </div>
  <% } %>
</div>

<%@ include file="admin-footer.jsp" %>
