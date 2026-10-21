<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, model.BannedKeyword" %>
<%
    List<BannedKeyword> keywords = (List<BannedKeyword>) request.getAttribute("keywords");
%>
<%@ include file="admin-header.jsp" %>

<div class="main-content">
  <div class="page-header">
    <div>
      <h1 class="page-title">Từ khóa cấm</h1>
      <p class="page-sub">Danh sách từ khóa tự động từ chối tin đăng vi phạm</p>
    </div>
    <button onclick="document.getElementById('addModal').classList.remove('hidden')"
            class="btn btn-primary">
      <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
        <path stroke-linecap="round" stroke-linejoin="round" d="M12 4v16m8-8H4"/>
      </svg>
      Thêm từ khóa
    </button>
  </div>

  <!-- Test tool -->
  <div class="test-bar">
    <p class="test-title">🔍 Thử kiểm tra nội dung trực tiếp</p>
    <div class="test-bar-row">
      <input id="testInput" type="text" placeholder="Nhập nội dung cần kiểm tra..."
             class="form-input flex-1">
      <button onclick="testContent()" class="btn btn-primary" style="margin-left:8px">Kiểm tra</button>
    </div>
    <div id="testResult" class="mt-2 hidden"></div>
  </div>

  <!-- Table -->
  <div class="table-card">
    <table class="admin-table">
      <thead>
        <tr>
          <th>ID</th>
          <th>Từ khóa / Regex</th>
          <th>Mô tả</th>
          <th>Loại</th>
          <th>Trạng thái</th>
          <th>Ngày thêm</th>
          <th class="text-right">Hành động</th>
        </tr>
      </thead>
      <tbody>
        <% if (keywords != null) for (BannedKeyword kw : keywords) { %>
        <tr>
          <td class="td-mono">#<%= kw.getId() %></td>
          <td class="font-mono font-semibold" style="color:#1e293b"><%= kw.getKeyword() %></td>
          <td class="td-muted"><%= kw.getDescription() != null ? kw.getDescription() : "" %></td>
          <td>
            <span class="badge <%= kw.isRegex() ? "badge-regex" : "badge-hidden" %>">
              <%= kw.isRegex() ? "Regex" : "Text" %>
            </span>
          </td>
          <td>
            <span class="badge <%= kw.isActive() ? "toggle-on badge-active" : "toggle-off badge-hidden" %>">
              <%= kw.isActive() ? "Đang bật" : "Tắt" %>
            </span>
          </td>
          <td class="td-muted">
            <%= kw.getCreatedAt() != null ? kw.getCreatedAt().toString().substring(0,10) : "" %>
          </td>
          <td class="td-right">
            <div class="flex gap-2 justify-end">
              <form method="post" action="<%= request.getContextPath() %>/admin/keywords" style="display:inline">
                <input type="hidden" name="action" value="toggle">
                <input type="hidden" name="id" value="<%= kw.getId() %>">
                <input type="hidden" name="active" value="<%= !kw.isActive() %>">
                <button type="submit" class="btn btn-sm btn-ghost">
                  <%= kw.isActive() ? "Tắt" : "Bật" %>
                </button>
              </form>
              <form method="post" action="<%= request.getContextPath() %>/admin/keywords" style="display:inline">
                <input type="hidden" name="action" value="delete">
                <input type="hidden" name="id" value="<%= kw.getId() %>">
                <button type="submit" class="btn-text-danger"
                        onclick="return confirm('Xóa từ khóa này?')">Xóa</button>
              </form>
            </div>
          </td>
        </tr>
        <% } %>
        <% if (keywords == null || keywords.isEmpty()) { %>
        <tr><td colspan="7" class="table-empty">Chưa có từ khóa cấm nào.</td></tr>
        <% } %>
      </tbody>
    </table>
  </div>
</div>

<!-- Add Modal -->
<div id="addModal" class="modal-overlay hidden">
  <div class="modal-box">
    <div class="modal-header">
      <span class="modal-title">Thêm từ khóa cấm</span>
      <button onclick="document.getElementById('addModal').classList.add('hidden')" class="modal-close">×</button>
    </div>
    <form method="post" action="<%= request.getContextPath() %>/admin/keywords"
          style="display:flex;flex-direction:column;gap:14px">
      <input type="hidden" name="action" value="add">
      <div class="form-group">
        <label class="form-label">Từ khóa hoặc Regex <span style="color:#dc2626">*</span></label>
        <input name="keyword" required class="form-input font-mono"
               placeholder="vd: heroin  hoặc  (ma\s?túy|cần\s?sa)">
      </div>
      <div class="form-group">
        <label class="form-label">Mô tả</label>
        <input name="description" class="form-input" placeholder="Mục đích của từ khóa này">
      </div>
      <label style="display:flex;align-items:center;gap:8px;font-size:13px;cursor:pointer">
        <input type="checkbox" name="isRegex" value="true" id="isRegexCheck"
               style="width:16px;height:16px;border-radius:3px;cursor:pointer">
        Đây là biểu thức Regex
      </label>
      <div class="flex gap-2 mt-2">
        <button type="button" onclick="document.getElementById('addModal').classList.add('hidden')"
                class="btn btn-ghost flex-1">Hủy</button>
        <button type="submit" class="btn btn-primary flex-1">Lưu từ khóa</button>
      </div>
    </form>
  </div>
</div>

<script>
  const kwData = [<%
    if (keywords != null) {
        boolean f = true;
        for (BannedKeyword kw : keywords) {
            if (!f) out.print(",");
            out.print("{k:'" + kw.getKeyword().replace("'","\\'").replace("\\","\\\\") + "',r:" + kw.isRegex() + ",a:" + kw.isActive() + "}");
            f = false;
        }
    }
  %>];

  function testContent() {
    const text = document.getElementById('testInput').value;
    const res  = document.getElementById('testResult');
    if (!text.trim()) return;
    let found = null;
    for (const kw of kwData) {
      if (!kw.a) continue;
      if (kw.r) {
        try { if (new RegExp(kw.k, 'i').test(text)) { found = kw.k; break; } } catch(e) {}
      } else {
        if (text.toLowerCase().includes(kw.k.toLowerCase())) { found = kw.k; break; }
      }
    }
    res.classList.remove('hidden', 'test-ok', 'test-fail');
    if (found) {
      res.className = 'test-fail';
      res.textContent = '❌ Nội dung VI PHẠM — chứa từ khóa cấm: "' + found + '"';
    } else {
      res.className = 'test-ok';
      res.textContent = '✅ Nội dung SẠCH — không phát hiện từ khóa vi phạm';
    }
  }
  document.getElementById('testInput').addEventListener('keydown', e => {
    if (e.key === 'Enter') { e.preventDefault(); testContent(); }
  });
</script>

<%@ include file="admin-footer.jsp" %>
