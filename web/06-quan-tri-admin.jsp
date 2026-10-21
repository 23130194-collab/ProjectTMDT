<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Trang admin cũ — chuyển hướng sang Admin Portal mới
    response.sendRedirect(request.getContextPath() + "/admin/dashboard");
%>
