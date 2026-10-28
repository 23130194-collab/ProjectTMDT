package controller.admin;

import dao.BoostPackageDAO;
import dao.ProductBoostDAO;
import model.BoostPackage;
import model.ProductBoost;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet("/admin/boost-packages")
public class AdminBoostServlet extends HttpServlet {
    private final BoostPackageDAO boostPackageDAO = new BoostPackageDAO();
    private final ProductBoostDAO productBoostDAO = new ProductBoostDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        List<BoostPackage> packages = boostPackageDAO.getAllPackagesForAdmin();
        List<ProductBoost> history = productBoostDAO.getAllBoostHistoryForAdmin();
        double totalRevenue = productBoostDAO.getTotalBoostRevenue();
        int totalOrders = productBoostDAO.countTotalBoostOrders();

        request.setAttribute("packages", packages);
        request.setAttribute("history", history);
        request.setAttribute("totalRevenue", totalRevenue);
        request.setAttribute("totalOrders", totalOrders);
        request.setAttribute("adminPage", "boost-packages");

        request.getRequestDispatcher("/admin/admin-boost-packages.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        if ("toggle".equals(action)) {
            int id = parseInt(request.getParameter("id"));
            boolean active = Boolean.parseBoolean(request.getParameter("active"));
            boostPackageDAO.togglePackageStatus(id, active);
        } else if ("save".equals(action)) {
            int id = parseInt(request.getParameter("id"));
            String name = request.getParameter("name");
            String packageType = request.getParameter("packageType");
            double price = parseDouble(request.getParameter("price"));
            int durationDays = parseInt(request.getParameter("durationDays"));
            int bumpCount = parseInt(request.getParameter("bumpCount"));
            int priorityLevel = parseInt(request.getParameter("priorityLevel"));
            String badgeLabel = request.getParameter("badgeLabel");
            String badgeColor = request.getParameter("badgeColor");
            String description = request.getParameter("description");
            boolean active = "1".equals(request.getParameter("isActive")) || "true".equalsIgnoreCase(request.getParameter("isActive"));
            int sortOrder = parseInt(request.getParameter("sortOrder"));

            BoostPackage pkg = new BoostPackage(id, name, packageType, price, durationDays,
                    bumpCount, priorityLevel, badgeLabel, badgeColor, description, active, sortOrder);

            if (id > 0) {
                boostPackageDAO.updatePackage(pkg);
            } else {
                boostPackageDAO.insertPackage(pkg);
            }
        }

        response.sendRedirect(request.getContextPath() + "/admin/boost-packages");
    }

    private int parseInt(String value) {
        try { return value == null ? 0 : Integer.parseInt(value.trim()); }
        catch (NumberFormatException e) { return 0; }
    }

    private double parseDouble(String value) {
        try { return value == null ? 0.0 : Double.parseDouble(value.trim()); }
        catch (NumberFormatException e) { return 0.0; }
    }
}
