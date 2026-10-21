<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, model.User" %>
<%
    List<User> users    = (List<User>) request.getAttribute("users");
    int totalUsers      = (int) request.getAttribute("totalUsers");
    int currentPage     = (int) request.getAttribute("currentPage");
    int totalPages      = (int) request.getAttribute("totalPages");
    String keyword      = (String) request.getAttribute("keyword");
    String statusFilter = (String) request.getAttribute("statusFilter");
    if (keyword == null) keyword = "";
    if (statusFilter == null) statusFilter = "";
%>
<%@ include file="admin-header.jsp" %>

<div class="main-content">
  <div>
    <h1 class="page-title">Quản lý Người dùng</h1>
    <p class="page-sub">Tổng cộng <strong><%= totalUsers %></strong> tài khoản</p>
  </div>

  <!-- Filters -->
  <form method="get" action="<%= request.getContextPath() %>/admin/users" class="filter-card">
    <div class="form-group" style="flex:1;min-width:220px">
      <label class="form-label">Tìm kiếm</label>
      <input class="form-input" name="keyword" value="<%= keyword %>" placeholder="Họ tên, email...">
    </div>
    <div class="form-group">
      <label class="form-label">Trạng thái</label>
      <select class="form-select" name="status">
        <option value="">Tất cả</option>
        <option value="active" <%= "active".equals(statusFilter)?"selected":""%>>Hoạt động</option>
        <option value="locked" <%= "locked".equals(statusFilter)?"selected":""%>>Bị khóa</option>
        <option value="admin"  <%= "admin".equals(statusFilter) ?"selected":""%>>Admin</option>
      </select>
    </div>
    <div class="flex gap-2">
      <button type="submit" class="btn btn-primary">🔍 Lọc</button>
      <a href="<%= request.getContextPath() %>/admin/users" class="btn btn-ghost">Reset</a>
    </div>
  </form>

  <!-- Table -->
  <div class="table-card">
    <table class="admin-table">
      <thead>
        <tr>
          <th>ID</th>
          <th>Họ tên</th>
          <th>Email</th>
          <th>SĐT</th>
          <th>Vai trò</th>
          <th>Trạng thái</th>
          <th>Ngày tạo</th>
          <th class="text-right">Hành động</th>
        </tr>
      </thead>
      <tbody>
        <% if (users != null && !users.isEmpty()) for (User u : users) {
            boolean isAdmin  = "ADMIN".equals(u.getRole());
            boolean isLocked = "LOCKED".equals(u.getStatus());
        %>
        <tr>
          <td class="td-mono">#<%= u.getId() %></td>
          <td>
            <div class="font-semibold" style="color:#0f172a;font-size:13px">
              <%= u.getFullName() != null ? u.getFullName() : u.getUsername() %>
            </div>
            <div class="text-xs text-slate-400">@<%= u.getUsername() %></div>
          </td>
          <td class="td-muted"><%= u.getEmail() != null ? u.getEmail() : "" %></td>
          <td class="td-muted"><%= u.getPhone() != null ? u.getPhone() : "—" %></td>
          <td>
            <span class="badge <%= isAdmin ? "badge-admin" : "badge-user" %>">
              <%= isAdmin ? "Admin" : "User" %>
            </span>
          </td>
          <td>
            <span class="badge <%= isLocked ? "badge-locked" : "badge-active" %>">
              <%= isLocked ? "Bị khóa" : "Hoạt động" %>
            </span>
          </td>
          <td class="td-muted">
            <%= u.getCreatedAt() != null ? u.getCreatedAt().toString().substring(0,10) : "" %>
          </td>
          <td class="td-right">
            <div class="flex gap-2 justify-end flex-wrap">
              <% if (!isLocked) { %>
              <form method="post" action="<%= request.getContextPath() %>/admin/users" style="display:inline">
                <input type="hidden" name="userId" value="<%= u.getId() %>">
                <input type="hidden" name="action" value="lock">
                <button type="submit" class="btn btn-sm btn-danger"
                        onclick="return confirm('Khóa tài khoản <%= u.getUsername() %>?')">Khóa</button>
              </form>
              <% } else { %>
              <form method="post" action="<%= request.getContextPath() %>/admin/users" style="display:inline">
                <input type="hidden" name="userId" value="<%= u.getId() %>">
                <input type="hidden" name="action" value="unlock">
                <button type="submit" class="btn btn-sm btn-primary">Mở khóa</button>
              </form>
              <% } %>

              <% if (!isAdmin) { %>
              <form method="post" action="<%= request.getContextPath() %>/admin/users" style="display:inline">
                <input type="hidden" name="userId" value="<%= u.getId() %>">
                <input type="hidden" name="action" value="makeAdmin">
                <button type="submit" class="btn btn-sm btn-ghost"
                        onclick="return confirm('Cấp quyền Admin cho <%= u.getUsername() %>?')">→ Admin</button>
              </form>
              <% } else { %>
              <form method="post" action="<%= request.getContextPath() %>/admin/users" style="display:inline">
                <input type="hidden" name="userId" value="<%= u.getId() %>">
                <input type="hidden" name="action" value="makeUser">
                <button type="submit" class="btn btn-sm btn-ghost"
                        onclick="return confirm('Thu hồi quyền Admin của <%= u.getUsername() %>?')">→ User</button>
              </form>
              <% } %>

              <form method="post" action="<%= request.getContextPath() %>/admin/users" style="display:inline">
                <input type="hidden" name="userId" value="<%= u.getId() %>">
                <input type="hidden" name="action" value="resetPassword">
                <button type="submit" class="btn-text-warn"
                        onclick="return confirm('Reset mật khẩu cho <%= u.getUsername() %>?')">Reset MK</button>
              </form>
            </div>
          </td>
        </tr>
        <% } %>
        <% if (users == null || users.isEmpty()) { %>
        <tr><td colspan="8" class="table-empty">Không có người dùng nào phù hợp.</td></tr>
        <% } %>
      </tbody>
    </table>
  </div>

  <!-- Pagination -->
  <% if (totalPages > 1) { %>
  <div class="pagination">
    <% for (int i = 1; i <= totalPages; i++) { %>
    <a href="<%= request.getContextPath() %>/admin/users?keyword=<%= keyword %>&status=<%= statusFilter %>&page=<%= i %>"
       class="page-btn <%= i == currentPage ? "active":"" %>"><%= i %></a>
    <% } %>
  </div>
  <% } %>
</div>

<%@ include file="admin-footer.jsp" %>
