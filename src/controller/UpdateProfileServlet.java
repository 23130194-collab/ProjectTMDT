package controller;

import model.User;
import service.AuthService;
import util.DataValidator;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.Map;

@WebServlet(name = "UpdateProfileServlet", value = "/update-profile")
public class UpdateProfileServlet extends HttpServlet {
    private static final String PROFILE_PAGE = "/08-ho-so-ca-nhan.jsp";
    private static final String VIETNAM_MOBILE_PATTERN = "^(03[2-9]|05[25689]|07[06789]|08[1-9]|09[0-9])[0-9]{7}$";
    private final AuthService authService = new AuthService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        User current = (User) session.getAttribute("user");
        if (current == null) {
            response.sendRedirect(request.getContextPath() + "/07-dang-nhap-xac-thuc.jsp");
            return;
        }

        String fullName = trim(request.getParameter("fullName"));
        String email = trim(request.getParameter("email"));
        String phone = trim(request.getParameter("phone"));
        String province = trim(request.getParameter("province"));
        String ward = trim(request.getParameter("ward"));
        String addressDetail = trim(request.getParameter("addressDetail"));

        Map<String, String> errors = validate(fullName, email, phone, province, ward, addressDetail);
        if (!errors.containsKey("email") && authService.isProfileEmailTaken(email, current.getId())) {
            errors.put("email", "Email này đã được tài khoản khác sử dụng.");
        }
        if (!errors.containsKey("phone") && authService.isProfilePhoneTaken(phone, current.getId())) {
            errors.put("phone", "Số điện thoại này đã được tài khoản khác sử dụng.");
        }
        if (errors.isEmpty() && sameAsCurrent(current, fullName, email, phone, province, ward, addressDetail)) {
            String unchanged = "Hãy thay đổi ít nhất một thông tin.";
            errors.put("fullName", unchanged);
            errors.put("email", unchanged);
            errors.put("phone", unchanged);
            errors.put("province", unchanged);
            errors.put("ward", unchanged);
            errors.put("addressDetail", unchanged);
        }
        if (!errors.isEmpty()) {
            Map<String, String> values = new LinkedHashMap<>();
            values.put("fullName", fullName);
            values.put("email", email);
            values.put("phone", phone);
            values.put("province", province);
            values.put("ward", ward);
            values.put("addressDetail", addressDetail);
            session.setAttribute("profileFieldErrors", errors);
            session.setAttribute("profileFormValues", values);
            response.sendRedirect(request.getContextPath() + PROFILE_PAGE);
            return;
        }

        current.setFullName(fullName);
        current.setEmail(email);
        current.setPhone(phone);
        current.setProvince(province);
        current.setWard(ward);
        current.setAddressDetail(addressDetail);
        authService.updateProfile(current);
        User updated = authService.getUserById(current.getId());
        if (updated != null) updated.setPassword(null);
        session.setAttribute("user", updated);
        session.setAttribute("profileMessage", "Đã cập nhật thông tin cá nhân.");
        session.removeAttribute("profileMessageError");
        response.sendRedirect(request.getContextPath() + PROFILE_PAGE);
    }

    private Map<String, String> validate(String name, String email, String phone, String province, String ward, String detail) {
        Map<String, String> errors = new LinkedHashMap<>();
        if (name == null || !name.matches("^\\S+(?:\\s+\\S+)+$")) {
            errors.put("fullName", "Nhập họ và tên gồm ít nhất hai từ, có khoảng trắng ở giữa.");
        }
        if (!DataValidator.isEmailValid(email)) errors.put("email", "Vui lòng nhập email hợp lệ.");
        if (phone == null || !phone.matches(VIETNAM_MOBILE_PATTERN)) {
            errors.put("phone", "Số điện thoại phải có 10 số và là đầu số di động Việt Nam hợp lệ.");
        }
        if (province == null) errors.put("province", "Vui lòng chọn tỉnh/thành phố.");
        if (ward == null) errors.put("ward", "Vui lòng chọn phường/xã.");
        if (detail == null) errors.put("addressDetail", "Vui lòng nhập số nhà, tên đường hoặc địa chỉ chi tiết.");
        return errors;
    }

    private boolean sameAsCurrent(User user, String name, String email, String phone,
                                  String province, String ward, String detail) {
        return equal(user.getFullName(), name) && equal(user.getEmail(), email)
                && equal(user.getPhone(), phone) && equal(user.getProvince(), province)
                && equal(user.getWard(), ward) && equal(user.getAddressDetail(), detail);
    }

    private boolean equal(String a, String b) {
        return (a == null ? "" : a.trim()).equalsIgnoreCase(b == null ? "" : b.trim());
    }

    private String trim(String value) {
        return value == null ? null : value.trim();
    }
}
