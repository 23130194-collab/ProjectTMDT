<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%
    User adminUser = (User) session.getAttribute("user");
    String adminPage = (String) request.getAttribute("adminPage");
    if (adminPage == null) adminPage = "dashboard";
    String adminMsg = (String) session.getAttribute("adminMsg");
    if (adminMsg != null) session.removeAttribute("adminMsg");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>MuaNgay Admin — <%= Character.toUpperCase(adminPage.charAt(0)) + adminPage.substring(1) %></title>
  <link rel="icon" type="image/svg+xml" href="<%= request.getContextPath() %>/assets/logos/muangay-logo-icon.svg">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    body { font-family: 'Inter', sans-serif; background: #f1f5f9; min-height: 100vh; display: flex; }

    /* ─── SIDEBAR ─── */
    .admin-sidebar {
      width: 240px; min-height: 100vh; background: #0f172a;
      display: flex; flex-direction: column; position: fixed;
      top: 0; left: 0; z-index: 40; box-shadow: 4px 0 24px rgba(0,0,0,.4);
    }
    .sidebar-logo {
      padding: 20px; border-bottom: 1px solid #1e293b;
      display: flex; align-items: center; gap: 10px; text-decoration: none;
    }
    .sidebar-logo img { width: 32px; height: 32px; border-radius: 8px; }
    .sidebar-brand { font-size: 14px; font-weight: 800; color: #fff; display: block; }
    .sidebar-brand span { color: #60a5fa; }
    .sidebar-sub { font-size: 10px; color: #94a3b8; font-weight: 500; }

    .sidebar-admin-info {
      padding: 12px 16px; border-bottom: 1px solid #1e293b;
      display: flex; align-items: center; gap: 10px;
    }
    .sidebar-avatar {
      width: 32px; height: 32px; border-radius: 50%; background: #2563eb;
      display: flex; align-items: center; justify-content: center;
      font-size: 12px; font-weight: 700; color: #fff; flex-shrink: 0;
    }
    .sidebar-admin-name { font-size: 12px; font-weight: 600; color: #fff; }
    .sidebar-admin-role { font-size: 10px; color: #94a3b8; }

    .sidebar-nav { flex: 1; padding: 16px 12px; overflow-y: auto; }
    .sidebar-section-label {
      font-size: 10px; font-weight: 700; color: #475569;
      text-transform: uppercase; letter-spacing: .08em;
      padding: 0 12px; margin: 16px 0 6px; display: block;
    }
    .sidebar-section-label:first-child { margin-top: 0; }

    .sidebar-link {
      display: flex; align-items: center; gap: 10px;
      padding: 9px 12px; border-radius: 8px;
      color: #94a3b8; font-size: 13px; font-weight: 500;
      text-decoration: none; transition: background .15s, color .15s;
      margin-bottom: 2px;
    }
    .sidebar-link:hover { background: #1e293b; color: #fff; }
    .sidebar-link.active { background: #2563eb; color: #fff; box-shadow: 0 4px 12px rgba(37,99,235,.35); }
    .sidebar-link svg { width: 16px; height: 16px; flex-shrink: 0; }

    .sidebar-bottom {
      padding: 12px; border-top: 1px solid #1e293b;
    }
    .sidebar-link-danger { color: #f87171; }
    .sidebar-link-danger:hover { background: rgba(239,68,68,.1); color: #fca5a5; }

    /* ─── MAIN ─── */
    .admin-main { margin-left: 240px; flex: 1; display: flex; flex-direction: column; min-height: 100vh; }

    .admin-topbar {
      background: #fff; border-bottom: 1px solid #e2e8f0;
      padding: 10px 24px; display: flex; align-items: center;
      justify-content: space-between; position: sticky; top: 0; z-index: 30;
      box-shadow: 0 1px 4px rgba(0,0,0,.06);
    }
    .topbar-breadcrumb { font-size: 13px; color: #64748b; }
    .topbar-breadcrumb strong { color: #1e293b; text-transform: capitalize; }
    .topbar-status { display: flex; align-items: center; gap: 6px; font-size: 12px; color: #64748b; }
    .status-dot { width: 8px; height: 8px; border-radius: 50%; background: #22c55e; display: inline-block; }

    .admin-toast {
      margin: 16px 24px 0; padding: 12px 16px;
      background: #f0fdf4; border: 1px solid #bbf7d0;
      border-radius: 10px; font-size: 13px; color: #166534; font-weight: 500;
    }

    /* ─── SHARED COMPONENTS ─── */
    .stat-card {
      background: #fff; border-radius: 14px; border: 1px solid #e2e8f0;
      padding: 20px; box-shadow: 0 1px 4px rgba(0,0,0,.05);
      transition: box-shadow .2s;
    }
    .stat-card:hover { box-shadow: 0 4px 16px rgba(0,0,0,.08); }
    .stat-label { font-size: 11px; color: #64748b; font-weight: 500; }
    .stat-value { font-size: 26px; font-weight: 700; color: #0f172a; margin: 4px 0; }
    .stat-sub { font-size: 11px; color: #94a3b8; }
    .stat-link { font-size: 11px; color: #2563eb; font-weight: 500; text-decoration: none; }
    .stat-link:hover { text-decoration: underline; }

    /* Badges */
    .badge {
      display: inline-flex; align-items: center;
      padding: 2px 8px; border-radius: 4px;
      font-size: 11px; font-weight: 700;
    }
    .badge-pending  { background: #fef3c7; color: #92400e; }
    .badge-active   { background: #dcfce7; color: #166534; }
    .badge-rejected { background: #fee2e2; color: #991b1b; }
    .badge-hidden   { background: #f1f5f9; color: #475569; }
    .badge-locked   { background: #fee2e2; color: #991b1b; }
    .badge-user     { background: #dbeafe; color: #1e40af; }
    .badge-admin    { background: #fae8ff; color: #86198f; }
    .badge-regex    { background: #ede9fe; color: #5b21b6; }

    /* Buttons */
    .btn { display: inline-flex; align-items: center; justify-content: center; gap: 4px;
           padding: 6px 12px; border-radius: 8px; font-size: 12px; font-weight: 600;
           cursor: pointer; border: none; text-decoration: none; transition: background .15s, opacity .15s; }
    .btn:hover { opacity: .88; }
    .btn-sm { padding: 4px 8px; font-size: 11px; border-radius: 6px; }
    .btn-primary { background: #2563eb; color: #fff; }
    .btn-danger  { background: #dc2626; color: #fff; }
    .btn-ghost   { background: #f1f5f9; color: #475569; border: 1px solid #e2e8f0; }
    .btn-text-danger { background: none; color: #dc2626; font-size: 11px; font-weight: 600;
                       padding: 4px 6px; border-radius: 4px; cursor: pointer; border: none; }
    .btn-text-danger:hover { background: #fee2e2; }
    .btn-text-warn { background: none; color: #d97706; font-size: 11px; font-weight: 600;
                     padding: 4px 6px; border-radius: 4px; cursor: pointer; border: none; }
    .btn-text-warn:hover { background: #fef3c7; }

    /* Table */
    .admin-table { width: 100%; border-collapse: collapse; }
    .admin-table th {
      padding: 12px 16px; text-align: left; font-size: 11px; font-weight: 600;
      color: #64748b; text-transform: uppercase; letter-spacing: .05em;
      background: #f8fafc; border-bottom: 1px solid #e2e8f0;
    }
    .admin-table th.text-right { text-align: right; }
    .admin-table td {
      padding: 12px 16px; font-size: 13px; color: #374151;
      border-bottom: 1px solid #f1f5f9;
    }
    .admin-table tr:hover td { background: #f8fafc; }
    .admin-table tr:last-child td { border-bottom: none; }
    .td-mono { font-family: monospace; font-size: 11px; color: #94a3b8; }
    .td-muted { color: #94a3b8; font-size: 12px; }
    .td-right { text-align: right; }
    .td-bold { font-weight: 600; }
    .td-link { color: #2563eb; text-decoration: none; font-weight: 500; }
    .td-link:hover { text-decoration: underline; }

    /* Table card container */
    .table-card {
      background: #fff; border-radius: 14px; border: 1px solid #e2e8f0;
      box-shadow: 0 1px 4px rgba(0,0,0,.05); overflow: hidden;
    }
    .table-empty { padding: 48px; text-align: center; color: #94a3b8; font-size: 14px; }

    /* Form card */
    .filter-card {
      background: #fff; border-radius: 14px; border: 1px solid #e2e8f0;
      padding: 16px; box-shadow: 0 1px 4px rgba(0,0,0,.05);
      display: flex; flex-wrap: wrap; gap: 12px; align-items: flex-end;
    }
    .form-group { display: flex; flex-direction: column; gap: 4px; }
    .form-label { font-size: 11px; font-weight: 600; color: #374151; }
    .form-input, .form-select {
      padding: 8px 12px; border: 1px solid #d1d5db; border-radius: 8px;
      font-size: 13px; font-family: 'Inter', sans-serif;
      outline: none; transition: border-color .15s, box-shadow .15s;
    }
    .form-input:focus, .form-select:focus {
      border-color: #2563eb; box-shadow: 0 0 0 3px rgba(37,99,235,.1);
    }
    .form-input-lg { min-width: 260px; }

    /* Pagination */
    .pagination { display: flex; gap: 4px; justify-content: center; margin-top: 16px; }
    .page-btn {
      width: 32px; height: 32px; display: flex; align-items: center; justify-content: center;
      border-radius: 8px; font-size: 12px; font-weight: 600; text-decoration: none;
      border: 1px solid #e2e8f0; background: #fff; color: #475569; transition: all .15s;
    }
    .page-btn:hover { background: #f1f5f9; }
    .page-btn.active { background: #2563eb; color: #fff; border-color: #2563eb; }

    /* Grid helpers */
    .grid-2 { display: grid; grid-template-columns: repeat(2, 1fr); gap: 16px; }
    .grid-4 { display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; }
    .grid-3-1 { display: grid; grid-template-columns: 2fr 1fr; gap: 24px; }
    .grid-2-1 { display: grid; grid-template-columns: 1fr 1fr; gap: 24px; }
    @media (max-width: 1024px) {
      .grid-4 { grid-template-columns: repeat(2, 1fr); }
      .grid-3-1 { grid-template-columns: 1fr; }
      .grid-2-1 { grid-template-columns: 1fr; }
    }

    /* Page title */
    .page-title { font-size: 20px; font-weight: 700; color: #0f172a; }
    .page-sub { font-size: 12px; color: #64748b; margin-top: 2px; }
    .page-header { display: flex; align-items: center; justify-content: space-between; }

    /* Modal */
    .modal-overlay {
      position: fixed; inset: 0; background: rgba(15,23,42,.55);
      z-index: 50; display: flex; align-items: center; justify-content: center;
      padding: 16px;
    }
    .modal-overlay.hidden { display: none; }
    .modal-box {
      background: #fff; border-radius: 16px; max-width: 480px; width: 100%;
      padding: 24px; box-shadow: 0 20px 60px rgba(0,0,0,.25);
    }
    .modal-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 16px; }
    .modal-title { font-size: 16px; font-weight: 700; color: #0f172a; }
    .modal-close { background: none; border: none; font-size: 20px; color: #94a3b8; cursor: pointer; padding: 2px 8px; border-radius: 4px; }
    .modal-close:hover { background: #f1f5f9; color: #374151; }

    /* Quick action card */
    .quick-action {
      display: flex; align-items: center; gap: 12px; padding: 12px;
      border-radius: 10px; text-decoration: none; transition: background .15s;
      font-size: 13px; font-weight: 500;
    }
    .qa-icon {
      width: 36px; height: 36px; border-radius: 8px;
      display: flex; align-items: center; justify-content: center;
      font-size: 15px; font-weight: 700; flex-shrink: 0;
    }
    .qa-amber  { background: #fef3c7; border: 1px solid #fde68a; color: #92400e; }
    .qa-amber-bg  { background: #fffbeb; border: 1px solid #fde68a; }
    .qa-amber-bg:hover { background: #fef3c7; }
    .qa-red    { background: #fee2e2; border: 1px solid #fecaca; color: #991b1b; }
    .qa-red-bg    { background: #fff5f5; border: 1px solid #fecaca; }
    .qa-red-bg:hover { background: #fee2e2; }
    .qa-slate  { background: #f1f5f9; border: 1px solid #e2e8f0; color: #334155; }
    .qa-slate-bg  { background: #f8fafc; border: 1px solid #e2e8f0; }
    .qa-slate-bg:hover { background: #f1f5f9; }
    .qa-blue   { background: #dbeafe; border: 1px solid #bfdbfe; color: #1e40af; }
    .qa-blue-bg   { background: #eff6ff; border: 1px solid #bfdbfe; }
    .qa-blue-bg:hover { background: #dbeafe; }
    .quick-actions-list { display: flex; flex-direction: column; gap: 8px; }

    /* Info card */
    .info-card {
      background: #fff; border-radius: 14px; border: 1px solid #e2e8f0;
      padding: 20px; box-shadow: 0 1px 4px rgba(0,0,0,.05);
    }
    .info-card-title { font-size: 13px; font-weight: 600; color: #0f172a; margin-bottom: 16px; }

    /* Tabs */
    .tab-bar { display: flex; gap: 6px; flex-wrap: wrap; }
    .tab-btn {
      padding: 6px 14px; border-radius: 8px; font-size: 12px; font-weight: 600;
      text-decoration: none; border: 1px solid #e2e8f0; background: #fff; color: #475569;
      transition: all .15s;
    }
    .tab-btn:hover { background: #f1f5f9; }
    .tab-btn.active { background: #2563eb; color: #fff; border-color: #2563eb; }

    /* Report card */
    .report-card {
      background: #fff; border-radius: 14px; padding: 20px;
      box-shadow: 0 1px 4px rgba(0,0,0,.05);
    }
    .report-card.pending-card { border: 1px solid #fde68a; }
    .report-card.resolved-card { border: 1px solid #bbf7d0; }
    .report-card.ignored-card { border: 1px solid #e2e8f0; }
    .report-meta { display: flex; align-items: center; justify-content: space-between; margin-bottom: 12px; }
    .report-meta-left { display: flex; align-items: center; gap: 8px; }
    .report-id { font-size: 11px; font-family: monospace; color: #94a3b8; }
    .report-date { font-size: 11px; color: #94a3b8; }
    .report-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 12px; }
    .report-info-box {
      padding: 10px 12px; background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px;
    }
    .report-info-label { font-size: 11px; font-weight: 600; color: #374151; margin-bottom: 4px; }
    .report-reason {
      padding: 10px 12px; background: #fff5f5; border: 1px solid #fecaca; border-radius: 8px;
      font-size: 12px; color: #991b1b; margin-bottom: 12px;
    }
    .report-note {
      padding: 10px 12px; background: #eff6ff; border: 1px solid #bfdbfe; border-radius: 8px;
      font-size: 12px; color: #1e40af; margin-bottom: 12px;
    }
    .report-actions { display: flex; flex-wrap: wrap; gap: 8px; align-items: flex-end; }

    /* Test result */
    .test-ok   { background: #f0fdf4; border: 1px solid #bbf7d0; color: #166534; border-radius: 8px; padding: 8px 12px; font-size: 12px; font-weight: 500; }
    .test-fail { background: #fff5f5; border: 1px solid #fecaca; color: #991b1b; border-radius: 8px; padding: 8px 12px; font-size: 12px; font-weight: 500; }
    .test-bar { background: #eff6ff; border: 1px solid #bfdbfe; border-radius: 10px; padding: 14px; margin-bottom: 4px; }
    .test-bar-row { display: flex; gap: 8px; }
    .test-title { font-size: 11px; font-weight: 600; color: #1e40af; margin-bottom: 8px; }

    /* Keyword toggle */
    .toggle-on  { background: #dcfce7; color: #166534; border: 1px solid #bbf7d0; }
    .toggle-off { background: #f1f5f9; color: #475569; border: 1px solid #e2e8f0; }

    /* Spacing utils */
    .mt-0 { margin-top: 0; } .mt-1 { margin-top: 4px; } .mt-2 { margin-top: 8px; }
    .mt-3 { margin-top: 12px; } .mt-4 { margin-top: 16px; } .mt-6 { margin-top: 24px; }
    .mb-1 { margin-bottom: 4px; } .mb-2 { margin-bottom: 8px; } .mb-4 { margin-bottom: 16px; }
    .gap-2 { gap: 8px; } .gap-3 { gap: 12px; }
    .flex { display: flex; } .flex-1 { flex: 1; } .flex-wrap { flex-wrap: wrap; }
    .items-center { align-items: center; } .items-start { align-items: flex-start; }
    .justify-between { justify-content: space-between; } .justify-end { justify-content: flex-end; }
    .text-xs { font-size: 11px; } .text-sm { font-size: 13px; }
    .font-mono { font-family: monospace; }
    .font-semibold { font-weight: 600; } .font-bold { font-weight: 700; }
    .text-slate-400 { color: #94a3b8; } .text-slate-500 { color: #64748b; }
    .text-slate-600 { color: #475569; } .text-slate-700 { color: #374151; }
    .text-slate-800 { color: #1e293b; } .text-slate-900 { color: #0f172a; }
    .text-blue-600  { color: #2563eb; } .text-green-600  { color: #16a34a; }
    .text-red-500   { color: #ef4444; } .text-red-600    { color: #dc2626; }
    .text-amber-600 { color: #d97706; } .text-orange-600 { color: #ea580c; }
    .truncate { overflow: hidden; white-space: nowrap; text-overflow: ellipsis; }
    .w-full { width: 100%; } .min-w-0 { min-width: 0; }
    .hidden { display: none !important; }
    .overflow-hidden { overflow: hidden; }
    .space-y { display: flex; flex-direction: column; gap: 16px; }
    .p-6 { padding: 24px; } .p-5 { padding: 20px; }
    .main-content { flex: 1; padding: 24px; display: flex; flex-direction: column; gap: 20px; }
  </style>
</head>
<body>

<!-- ═══════════════════════ SIDEBAR ═══════════════════════ -->
<aside class="admin-sidebar">
  <!-- Logo -->
  <a href="<%= request.getContextPath() %>/home" class="sidebar-logo">
    <img src="<%= request.getContextPath() %>/assets/logos/muangay-logo-icon.svg" alt="Logo">
    <div>
      <span class="sidebar-brand">Mua<span>Ngay</span></span>
      <span class="sidebar-sub">Admin Portal</span>
    </div>
  </a>

  <!-- Admin info -->
  <div class="sidebar-admin-info">
    <div class="sidebar-avatar">
      <%= adminUser != null && adminUser.getFullName() != null && !adminUser.getFullName().isEmpty()
          ? String.valueOf(adminUser.getFullName().charAt(0)).toUpperCase() : "A" %>
    </div>
    <div style="overflow:hidden">
      <div class="sidebar-admin-name" style="white-space:nowrap;overflow:hidden;text-overflow:ellipsis">
        <%= adminUser != null ? adminUser.getFullName() : "Admin" %>
      </div>
      <div class="sidebar-admin-role">Administrator</div>
    </div>
  </div>

  <!-- Navigation -->
  <nav class="sidebar-nav">
    <span class="sidebar-section-label">Tổng quan</span>
    <a href="<%= request.getContextPath() %>/admin/dashboard"
       class="sidebar-link <%= "dashboard".equals(adminPage) ? "active" : "" %>">
      <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
        <path stroke-linecap="round" stroke-linejoin="round"
              d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"/>
      </svg>
      Dashboard
    </a>

    <span class="sidebar-section-label">Quản lý nội dung</span>
    <a href="<%= request.getContextPath() %>/admin/posts"
       class="sidebar-link <%= "posts".equals(adminPage) ? "active" : "" %>">
      <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
        <path stroke-linecap="round" stroke-linejoin="round"
              d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/>
      </svg>
      Tin đăng
    </a>
    <a href="<%= request.getContextPath() %>/admin/reports"
       class="sidebar-link <%= "reports".equals(adminPage) ? "active" : "" %>">
      <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
        <path stroke-linecap="round" stroke-linejoin="round"
              d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/>
      </svg>
      Báo cáo vi phạm
    </a>

    <span class="sidebar-section-label">Quản lý hệ thống</span>
    <a href="<%= request.getContextPath() %>/admin/users"
       class="sidebar-link <%= "users".equals(adminPage) ? "active" : "" %>">
      <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
        <path stroke-linecap="round" stroke-linejoin="round"
              d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z"/>
      </svg>
      Người dùng
    </a>
    <a href="<%= request.getContextPath() %>/admin/keywords"
       class="sidebar-link <%= "keywords".equals(adminPage) ? "active" : "" %>">
      <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
        <path stroke-linecap="round" stroke-linejoin="round"
              d="M18.364 18.364A9 9 0 005.636 5.636m12.728 12.728A9 9 0 015.636 5.636m12.728 12.728L5.636 5.636"/>
      </svg>
      Từ khóa cấm
    </a>

    <span class="sidebar-section-label">Dịch vụ &amp; Doanh thu</span>
    <a href="<%= request.getContextPath() %>/admin/boost-packages"
       class="sidebar-link <%= "boost-packages".equals(adminPage) ? "active" : "" %>">
      <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
        <path stroke-linecap="round" stroke-linejoin="round"
              d="M13 10V3L4 14h7v7l9-11h-7z"/>
      </svg>
      Gói Đẩy Tin &amp; VIP
    </a>
  </nav>

  <!-- Bottom -->
  <div class="sidebar-bottom">
    <a href="<%= request.getContextPath() %>/home" class="sidebar-link" style="font-size:12px">
      <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="width:14px;height:14px">
        <path stroke-linecap="round" stroke-linejoin="round"
              d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"/>
      </svg>
      Xem giao diện user
    </a>
    <a href="<%= request.getContextPath() %>/logout"
       class="sidebar-link sidebar-link-danger" style="font-size:12px">
      <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="width:14px;height:14px">
        <path stroke-linecap="round" stroke-linejoin="round"
              d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"/>
      </svg>
      Đăng xuất
    </a>
  </div>
</aside>

<!-- ═══════════════════════ MAIN ═══════════════════════ -->
<div class="admin-main">

  <!-- Top bar -->
  <div class="admin-topbar">
    <div class="topbar-breadcrumb">
      <span style="color:#94a3b8">Admin</span>
      <span style="margin:0 6px;color:#cbd5e1">/</span>
      <strong><%= adminPage %></strong>
    </div>
    <div class="topbar-status">
      <span class="status-dot"></span>
      Hệ thống hoạt động bình thường
    </div>
  </div>

  <!-- Toast message -->
  <% if (adminMsg != null) { %>
  <div class="admin-toast">✅ <%= adminMsg %></div>
  <% } %>
