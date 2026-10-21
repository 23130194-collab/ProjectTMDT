package service;

import dao.BannedKeywordDAO;
import model.BannedKeyword;

import java.util.List;
import java.util.regex.Pattern;
import java.util.regex.PatternSyntaxException;

/**
 * Dịch vụ kiểm duyệt nội dung tự động dựa trên danh sách từ khóa cấm.
 * Được gọi sau khi lưu tin đăng để tự động duyệt (ACTIVE) hoặc từ chối (REJECTED).
 */
public class ModerationService {

    private final BannedKeywordDAO bannedKeywordDAO = new BannedKeywordDAO();

    /**
     * Kiểm tra nội dung có chứa từ khóa cấm không.
     * @param text Nội dung cần kiểm tra (title + description)
     * @return Từ khóa vi phạm đầu tiên tìm thấy, hoặc null nếu sạch
     */
    public String findViolation(String text) {
        if (text == null || text.trim().isEmpty()) return null;
        String lower = text.toLowerCase();

        List<BannedKeyword> keywords = bannedKeywordDAO.getActive();
        System.err.println("[Moderation] Kiểm duyệt: \"" + text + "\" — " + keywords.size() + " từ khóa cấm đang bật");

        for (BannedKeyword kw : keywords) {
            if (kw.isRegex()) {
                try {
                    Pattern p = Pattern.compile(kw.getKeyword(), Pattern.CASE_INSENSITIVE | Pattern.UNICODE_CASE);
                    if (p.matcher(text).find()) {
                        System.err.println("[Moderation] VI PHẠM (regex): " + kw.getKeyword());
                        return kw.getKeyword();
                    }
                } catch (PatternSyntaxException e) {
                    // Bỏ qua regex lỗi
                }
            } else {
                if (lower.contains(kw.getKeyword().toLowerCase())) {
                    System.err.println("[Moderation] VI PHẠM (text): " + kw.getKeyword());
                    return kw.getKeyword();
                }
            }
        }
        System.err.println("[Moderation] Sạch — không vi phạm");
        return null;
    }

    /**
     * Kiểm tra nội dung tin đăng và trả về trạng thái phù hợp.
     * @param title Tiêu đề
     * @param description Mô tả
     * @return "ACTIVE" nếu sạch, "REJECTED" nếu vi phạm
     */
    public String moderate(String title, String description) {
        String combined = (title != null ? title : "") + " " + (description != null ? description : "");
        String violation = findViolation(combined);
        return violation == null ? "ACTIVE" : "REJECTED";
    }

    /**
     * Lấy lý do từ chối (từ khóa vi phạm).
     */
    public String getRejectionReason(String title, String description) {
        String combined = (title != null ? title : "") + " " + (description != null ? description : "");
        String violation = findViolation(combined);
        return violation != null ? "Nội dung chứa từ khóa bị cấm: \"" + violation + "\"" : null;
    }
}
