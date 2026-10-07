<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Chuyển hướng người dùng sang HomeController để load dữ liệu từ Database
    response.sendRedirect(request.getContextPath() + "/home");
%>