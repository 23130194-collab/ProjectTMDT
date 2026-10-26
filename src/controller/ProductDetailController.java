package controller;

import dao.ProductDAO;
import dao.FavoriteDAO;
import dao.ProductImageDAO;
import dao.UserDao;
import model.Product;
import model.ProductImage;
import model.User;
import util.JsonUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/product-detail")
public class ProductDetailController extends HttpServlet {
    private ProductDAO productDAO = new ProductDAO();
    private ProductImageDAO productImageDAO = new ProductImageDAO();
    private UserDao userDao = new UserDao();
    private FavoriteDAO favoriteDAO = new FavoriteDAO();

    // Thứ tự chuẩn của specs theo từng danh mục (phải khớp với key lưu trong PostAdController)
    private static final Map<Integer, List<String>> SPEC_ORDER = new LinkedHashMap<>();
    static {
        SPEC_ORDER.put(1, Arrays.asList(
            "Loại thiết bị", "Hãng sản xuất", "Dòng máy", "Tình trạng",
            "Dung lượng / RAM", "Màu sắc", "Pin", "Bảo hành & Phụ kiện"
        ));
        SPEC_ORDER.put(2, Arrays.asList(
            "Loại phương tiện", "Hãng xe", "Dòng xe / Đời xe", "Năm đăng ký",
            "Tình trạng giấy tờ", "Số km đã đi", "Dung tích động cơ", "Tình trạng máy móc"
        ));
        SPEC_ORDER.put(3, Arrays.asList(
            "Loại thiết bị", "Thương hiệu", "Công suất / Dung tích",
            "Tình trạng hoạt động", "Ngoại quan", "Chính sách hỗ trợ"
        ));
        SPEC_ORDER.put(4, Arrays.asList(
            "Loại đồ dùng", "Chất liệu chính", "Kích thước",
            "Màu sắc", "Tình trạng ngoại quan", "Tháo lắp & Vận chuyển"
        ));
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String idParam = req.getParameter("id");
        if (idParam != null && !idParam.isEmpty()) {
            try {
                int id = Integer.parseInt(idParam);
                Product product = productDAO.getProductById(id);
                if (product != null) {
                    // Chỉ cho xem bài ACTIVE, trừ khi là chủ bài hoặc admin
                    String status = product.getStatus();
                    boolean isActive = "ACTIVE".equals(status);
                    jakarta.servlet.http.HttpSession sess = req.getSession(false);
                    User currentUser = (sess != null) ? (User) sess.getAttribute("user") : null;
                    boolean isOwner = currentUser != null && currentUser.getId() == product.getUserId();
                    boolean isAdmin = currentUser != null && "ADMIN".equalsIgnoreCase(currentUser.getRole());

                    if (!isActive && !isOwner && !isAdmin) {
                        resp.sendRedirect(req.getContextPath() + "/home?message=not_found");
                        return;
                    }

                    List<ProductImage> images = productImageDAO.getImagesByProductId(id);
                    Map<String, String> specsMap = JsonUtil.jsonToMap(product.getSpecifications());

                    // Lấy thông tin người bán từ DB
                    User seller = userDao.getUserById(product.getUserId());


                    // Sắp xếp specs theo thứ tự chuẩn của danh mục
                    List<String[]> specsList = new ArrayList<>();
                    List<String> orderedKeys = SPEC_ORDER.get(product.getCategoryId());
                    if (orderedKeys != null) {
                        // Thêm theo thứ tự chuẩn trước
                        for (String key : orderedKeys) {
                            if (specsMap.containsKey(key)) {
                                specsList.add(new String[]{key, specsMap.get(key)});
                            }
                        }
                        // Thêm các key không thuộc danh sách chuẩn (nếu có) vào cuối
                        for (Map.Entry<String, String> entry : specsMap.entrySet()) {
                            if (!orderedKeys.contains(entry.getKey())) {
                                specsList.add(new String[]{entry.getKey(), entry.getValue()});
                            }
                        }
                    } else {
                        // Nếu không có thứ tự chuẩn thì giữ nguyên
                        for (Map.Entry<String, String> entry : specsMap.entrySet()) {
                            specsList.add(new String[]{entry.getKey(), entry.getValue()});
                        }
                    }

                    req.setAttribute("product", product);
                    req.setAttribute("isProductOwner", isOwner);
                    req.setAttribute("images", images);
                    req.setAttribute("productSpecs", specsList);
                    req.setAttribute("seller", seller);
                    req.setAttribute("isFavorited", currentUser != null && favoriteDAO.contains(currentUser.getId(), id));
                    req.getRequestDispatcher("02-chi-tiet-san-pham.jsp").forward(req, resp);
                    return;
                }
            } catch (NumberFormatException e) {
                // Ignore and fallback
            }
        }
        // Fallback or not found
        resp.sendRedirect(req.getContextPath() + "/home");
    }
}
