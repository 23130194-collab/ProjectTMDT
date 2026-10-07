package util;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class DataValidator {

    private static final String PASSWORD_PATTERN = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[^A-Za-z0-9])\\S{8,}$";
    private static final Pattern passwordPattern = Pattern.compile(PASSWORD_PATTERN);


    private static final String EMAIL_PATTERN =
            "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$";
    private static final Pattern emailPattern = Pattern.compile(EMAIL_PATTERN);

    public static boolean isPasswordValid(final String password) {
        if (password == null) {
            return false;
        }
        Matcher matcher = passwordPattern.matcher(password);
        return matcher.matches();
    }

    public static boolean isEmailValid(final String email) {
        if (email == null) {
            return false;
        }
        Matcher matcher = emailPattern.matcher(email);
        return matcher.matches();
    }

    public static String getPasswordRuleMessage() {
        return "Mật khẩu phải có ít nhất 8 ký tự, gồm chữ hoa, chữ thường, số và ký tự đặc biệt.";
    }
}
