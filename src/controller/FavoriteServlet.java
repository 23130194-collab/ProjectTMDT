package controller;

import dao.FavoriteDAO;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/favorites")
public class FavoriteServlet extends HttpServlet {
    private final FavoriteDAO dao=new FavoriteDAO();
    protected void doGet(HttpServletRequest req,HttpServletResponse resp)throws ServletException,IOException{
        User u=user(req); if(u==null){resp.sendRedirect(req.getContextPath()+"/07-dang-nhap-xac-thuc.jsp");return;}
        req.setAttribute("favorites",dao.list(u.getId()));req.getRequestDispatcher("/favorites.jsp").forward(req,resp);
    }
    protected void doPost(HttpServletRequest req,HttpServletResponse resp)throws IOException{
        User u=user(req);resp.setContentType("application/json;charset=UTF-8");
        if(u==null){resp.setStatus(401);resp.getWriter().write("{\"success\":false,\"message\":\"Vui lòng đăng nhập để lưu tin yêu thích.\"}");return;}
        String action=req.getParameter("action");boolean ok=false;
        if("add".equals(action)){int id=parse(req.getParameter("productId"));ok=id>0&&dao.add(u.getId(),id);}
        else if("remove".equals(action)){int id=parse(req.getParameter("productId"));ok=id>0&&dao.remove(u.getId(),id);}
        else if("clearSold".equals(action))ok=dao.clearSold(u.getId());
        resp.getWriter().write("{\"success\":"+ok+"}");
    }
    private User user(HttpServletRequest r){HttpSession s=r.getSession(false);return s==null?null:(User)s.getAttribute("user");}
    private int parse(String s){try{return Integer.parseInt(s);}catch(Exception e){return -1;}}
}
