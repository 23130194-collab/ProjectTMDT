package controller;

import dao.ProductDAO;
import dao.ProductEmbeddingDAO;
import model.Product;
import model.ProductEmbedding;
import service.ClipEmbeddingService;
import util.ProductEmbeddingCache;
import util.VectorUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.util.*;

@WebServlet(name = "VisualSearchServlet", value = "/visual-search")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,      // 1MB
        maxFileSize = 1024 * 1024 * 10,       // 10MB
        maxRequestSize = 1024 * 1024 * 15     // 15MB
)
public class VisualSearchServlet extends HttpServlet {
    private final ProductDAO productDAO = new ProductDAO();
    private final ProductEmbeddingDAO embeddingDAO = new ProductEmbeddingDAO();

    @Override
    public void init() throws ServletException {
        super.init();
        // Nạp vector cache sẵn sàng vào RAM khi Servlet khởi chạy
        ProductEmbeddingCache.ensureInitialized();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String action = request.getParameter("action");
        response.setContentType("application/json;charset=UTF-8");

        if ("status".equals(action)) {
            boolean aiReady = ClipEmbeddingService.isServiceAvailable();
            int indexedCount = ProductEmbeddingCache.size();
            response.getWriter().write(String.format("{\"ai_service\":%b,\"indexed_products\":%d}", aiReady, indexedCount));
            return;
        }

        // Tự động quét và đồng bộ vector ngầm cho các sản phẩm trong DB chưa có vector
        if ("sync".equals(action)) {
            if (!ClipEmbeddingService.isServiceAvailable()) {
                response.getWriter().write("{\"status\":\"error\",\"message\":\"AI Service chưa chạy tại localhost:8000\"}");
                return;
            }
            String appPath = request.getServletContext().getRealPath("");
            ProductEmbeddingCache.asyncSyncUnindexed(appPath);
            response.getWriter().write("{\"status\":\"success\",\"message\":\"Đang đồng bộ vector ngầm cho các sản phẩm...\"}");
            return;
        }

        response.getWriter().write("{\"message\":\"VisualSearchServlet sẵn sàng\"}");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        response.setHeader("Cache-Control", "no-store");

        // 1. Kiểm tra AI Service
        if (!ClipEmbeddingService.isServiceAvailable()) {
            response.setStatus(HttpServletResponse.SC_SERVICE_UNAVAILABLE);
            response.getWriter().write("{\"status\":\"error\",\"message\":\"Dịch vụ AI CLIP chưa được khởi động trên máy (cổng 8000). Hãy chạy python ai_service/app.py\"}");
            return;
        }

        // 2. Nhận file ảnh tải lên
        Part filePart = request.getPart("searchImage");
        if (filePart == null || filePart.getSize() == 0) {
            filePart = request.getPart("image");
        }

        if (filePart == null || filePart.getSize() == 0) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"status\":\"error\",\"message\":\"Vui lòng chọn hoặc dán (Ctrl+V) một bức ảnh để tìm kiếm\"}");
            return;
        }

        // Kiểm tra dung lượng tối đa 10MB
        if (filePart.getSize() > 10 * 1024 * 1024) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"status\":\"error\",\"message\":\"Dung lượng ảnh tối đa là 10MB\"}");
            return;
        }

        byte[] imageBytes;
        try (InputStream in = filePart.getInputStream()) {
            imageBytes = in.readAllBytes();
        }

        try {
            // 3. Trích xuất vector của ảnh query và dự đoán ý định (Zero-Shot Multimodal Intent)
            ClipEmbeddingService.AnalysisResult analysis = ClipEmbeddingService.getAnalysisFromBytes(imageBytes, filePart.getSubmittedFileName());
            float[] queryVector = analysis.getEmbedding();
            if (queryVector == null || queryVector.length == 0) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("{\"status\":\"error\",\"message\":\"Không thể phân tích đặc trưng hình ảnh này\"}");
                return;
            }

            String predictedIntent = analysis.getPredictedIntent();
            String predictedIntentName = analysis.getPredictedIntentName();

            // 4. Lấy toàn bộ vector từ In-Memory Cache (tốc độ < 10ms, không truy vấn DB)
            Map<Integer, float[]> vectorCache = ProductEmbeddingCache.getVectorCache();

            // Kích hoạt đồng bộ ngầm nếu có sản phẩm cũ chưa có vector
            String appPath = request.getServletContext().getRealPath("");
            ProductEmbeddingCache.asyncSyncUnindexed(appPath);

            // 5. Đọc tham số Hybrid Filters (Tỉnh thành, Khoảng giá, Sắp xếp)
            String filterProvince = request.getParameter("province");
            String minPriceStr = request.getParameter("minPrice");
            String maxPriceStr = request.getParameter("maxPrice");
            String sortOrder = request.getParameter("sort"); // relevance, price_asc, price_desc

            double minPrice = 0;
            double maxPrice = Double.MAX_VALUE;
            try {
                if (minPriceStr != null && !minPriceStr.trim().isEmpty()) {
                    minPrice = Double.parseDouble(minPriceStr.trim());
                }
                if (maxPriceStr != null && !maxPriceStr.trim().isEmpty()) {
                    maxPrice = Double.parseDouble(maxPriceStr.trim());
                }
            } catch (Exception ignored) {}

            // 5b. k-NN Pseudo-label Consensus: Tinh chỉnh intent nếu có mẫu ảnh khớp rất cao trong kho (>= 0.93)
            Product bestVisualMatch = null;
            double topBaseSim = 0.0;
            for (Map.Entry<Integer, float[]> entry : vectorCache.entrySet()) {
                double baseSim = VectorUtil.cosineSimilarity(queryVector, entry.getValue());
                if (baseSim > topBaseSim) {
                    topBaseSim = baseSim;
                    bestVisualMatch = productDAO.getProductById(entry.getKey());
                }
            }

            if (bestVisualMatch != null && topBaseSim >= 0.93) {
                String titleLower = bestVisualMatch.getTitle().toLowerCase();
                if (titleLower.contains("chảo")) {
                    predictedIntent = "chao";
                    predictedIntentName = "Chảo xào / Chảo chiên";
                } else if (titleLower.contains("cơm điện") || titleLower.contains("nồi cơm")) {
                    predictedIntent = "noi_com_dien";
                    predictedIntentName = "Nồi cơm điện";
                } else if (titleLower.contains("nồi") || titleLower.contains("xoong")) {
                    predictedIntent = "noi_nau";
                    predictedIntentName = "Nồi nấu ăn / Xoong";
                } else if (titleLower.contains("iphone") || titleLower.contains("điện thoại")) {
                    predictedIntent = "dien_thoai";
                    predictedIntentName = "Điện thoại / Smartphone";
                } else if (titleLower.contains("macbook") || titleLower.contains("laptop")) {
                    predictedIntent = "laptop";
                    predictedIntentName = "Laptop / Máy tính";
                }
            }

            // 6. So sánh độ tương đồng kết hợp xử phạt ngữ nghĩa chéo (Semantic Negative Penalty & Boost)
            final double STRICT_THRESHOLD = 0.81;
            List<ProductResultHolder> matches = new ArrayList<>();
            double maxScore = 0.0;

            for (Map.Entry<Integer, float[]> entry : vectorCache.entrySet()) {
                Product p = productDAO.getProductById(entry.getKey());
                if (p == null || !"ACTIVE".equalsIgnoreCase(p.getStatus())) continue;

                // Lọc theo Tỉnh/Thành linh hoạt (chuẩn hóa loại bỏ tiền tố Tỉnh/Thành phố/TP và dấu tiếng Việt)
                if (!matchesProvince(p.getProvince(), filterProvince)) {
                    continue;
                }

                // Lọc theo Khoảng giá
                if (p.getPrice() < minPrice || p.getPrice() > maxPrice) {
                    continue;
                }

                double baseSim = VectorUtil.cosineSimilarity(queryVector, entry.getValue());

                // Tính hệ số phạt/thưởng đa phương thức (Semantic Penalty / Boost)
                double multiplier = calculateSemanticMultiplier(predictedIntent, p.getTitle());
                double finalScore = Math.min(1.0, baseSim * multiplier);

                if (finalScore > maxScore) {
                    maxScore = finalScore;
                }

                if (finalScore >= STRICT_THRESHOLD) {
                    matches.add(new ProductResultHolder(p, finalScore));
                }
            }

            // Lọc nâng cao: Nếu có sản phẩm top đầu rất khớp (>= 0.90), loại bỏ các kết quả chênh lệch quá 0.04
            // Nếu top đầu >= 0.85, loại bỏ các kết quả chênh lệch quá 0.06
            if (maxScore >= 0.90) {
                final double cutoff = Math.max(STRICT_THRESHOLD, maxScore - 0.04);
                matches.removeIf(item -> item.score < cutoff);
            } else if (maxScore >= 0.85) {
                final double cutoff = Math.max(STRICT_THRESHOLD, maxScore - 0.06);
                matches.removeIf(item -> item.score < cutoff);
            }

            List<ProductResultHolder> filteredProducts = matches;

            // Sắp xếp kết quả
            if ("price_asc".equalsIgnoreCase(sortOrder)) {
                filteredProducts.sort(Comparator.comparingDouble(a -> a.product.getPrice()));
            } else if ("price_desc".equalsIgnoreCase(sortOrder)) {
                filteredProducts.sort((a, b) -> Double.compare(b.product.getPrice(), a.product.getPrice()));
            } else {
                // Mặc định: theo độ khớp hình ảnh giảm dần
                filteredProducts.sort((a, b) -> Double.compare(b.score, a.score));
            }

            // Lấy tối đa top 20 sản phẩm khớp nhất
            int limit = Math.min(filteredProducts.size(), 20);
            StringBuilder json = new StringBuilder("{\"status\":\"success\",")
                    .append("\"count\":").append(limit).append(",")
                    .append("\"predicted_intent\":\"").append(escapeJson(predictedIntent)).append("\",")
                    .append("\"predicted_intent_name\":\"").append(escapeJson(predictedIntentName)).append("\",")
                    .append("\"intent_confidence\":").append(analysis.getIntentConfidence()).append(",")
                    .append("\"products\":[");

            for (int i = 0; i < limit; i++) {
                ProductResultHolder holder = filteredProducts.get(i);
                Product p = holder.product;
                if (i > 0) json.append(",");
                int matchPercent = calculateMatchPercent(holder.score);
                json.append("{")
                        .append("\"id\":").append(p.getId()).append(",")
                        .append("\"title\":\"").append(escapeJson(p.getTitle())).append("\",")
                        .append("\"price\":").append(p.getPrice()).append(",")
                        .append("\"image\":\"").append(escapeJson(p.getPrimaryImage() != null ? p.getPrimaryImage() : "")).append("\",")
                        .append("\"province\":\"").append(escapeJson(p.getProvince() != null ? p.getProvince() : "")).append("\",")
                        .append("\"condition\":\"").append(escapeJson(p.getConditionStatus() != null ? p.getConditionStatus() : "")).append("\",")
                        .append("\"similarity_percent\":").append(matchPercent)
                        .append("}");
            }
            json.append("]}");
            response.getWriter().write(json.toString());

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"status\":\"error\",\"message\":\"Đã xảy ra lỗi khi tìm kiếm hình ảnh: " + escapeJson(e.getMessage()) + "\"}");
        }
    }

    private static class SearchResultItem {
        int productId;
        double score;
        SearchResultItem(int productId, double score) {
            this.productId = productId;
            this.score = score;
        }
    }

    private static class ProductResultHolder {
        Product product;
        double score;
        ProductResultHolder(Product product, double score) {
            this.product = product;
            this.score = score;
        }
    }

    /**
     * Chuẩn hóa điểm tương đồng Cosine Similarity của CLIP ViT-B/32 sang % trực quan:
     * - Dưới 0.80: Không đạt chuẩn nhận diện cùng loại.
     * - Từ 0.81 đến 0.98: Scale mượt mà tương ứng 75% -> 98% độ tin cậy.
     */
    private static int calculateMatchPercent(double score) {
        if (score < 0.80) {
            return (int) Math.round(score * 70);
        }
        double normalized = (score - 0.81) / (0.98 - 0.81);
        if (normalized < 0.0) normalized = 0.0;
        if (normalized > 1.0) normalized = 1.0;
        int pct = (int) Math.round(75 + normalized * 23);
        if (score >= 0.99) pct = 99;
        return pct;
    }

    /**
     * Tính hệ số phạt/thưởng đa phương thức (Semantic Penalty / Boost):
     * Ngăn chặn tuyệt đối việc hiển thị chảo/nồi cơm điện khi ảnh là nồi nấu ăn, và ngược lại.
     */
    private static double calculateSemanticMultiplier(String intent, String rawTitle) {
        if (intent == null || intent.isEmpty() || rawTitle == null || rawTitle.isEmpty()) {
            return 1.0;
        }
        String title = rawTitle.toLowerCase();

        switch (intent) {
            case "noi_nau":
                // Ảnh là NỒI NẤU ĂN
                if (title.contains("chảo")) {
                    return 0.40; // Phạt nặng chảo
                }
                if (title.contains("nồi cơm") || title.contains("cơm điện")) {
                    return 0.50; // Phạt nồi cơm điện
                }
                if (title.contains("nồi") || title.contains("xoong")) {
                    return 1.15; // Thưởng điểm cho nồi nấu
                }
                break;

            case "chao":
                // Ảnh là CHẢO
                if (title.contains("nồi cơm") || (title.contains("nồi") && !title.contains("chảo"))) {
                    return 0.45; // Phạt nồi
                }
                if (title.contains("chảo")) {
                    return 1.15; // Thưởng điểm cho chảo
                }
                break;

            case "noi_com_dien":
                // Ảnh là NỒI CƠM ĐIỆN
                if (title.contains("chảo") || (title.contains("nồi") && !title.contains("cơm"))) {
                    return 0.45; // Phạt chảo và nồi nấu canh
                }
                if (title.contains("nồi cơm") || title.contains("cơm điện")) {
                    return 1.15; // Thưởng điểm cho nồi cơm điện
                }
                break;

            case "dien_thoai":
                // Ảnh là ĐIỆN THOẠI
                if (!title.contains("phone") && !title.contains("điện thoại") && !title.contains("iphone") && !title.contains("samsung")) {
                    return 0.40;
                }
                return 1.10;

            case "laptop":
                // Ảnh là LAPTOP
                if (!title.contains("laptop") && !title.contains("macbook") && !title.contains("máy tính")) {
                    return 0.40;
                }
                return 1.10;
        }

        return 1.0;
    }

    private static boolean matchesProvince(String productProvince, String filterProvince) {
        if (filterProvince == null || filterProvince.trim().isEmpty() || "all".equalsIgnoreCase(filterProvince)) {
            return true;
        }
        if (productProvince == null) return false;
        String pNorm = normalizeLocationName(productProvince);
        String fNorm = normalizeLocationName(filterProvince);
        return pNorm.contains(fNorm) || fNorm.contains(pNorm);
    }

    private static String normalizeLocationName(String s) {
        if (s == null) return "";
        String nfd = java.text.Normalizer.normalize(s, java.text.Normalizer.Form.NFD);
        return nfd.replaceAll("\\p{InCombiningDiacriticalMarks}+", "")
                  .toLowerCase()
                  .replace("đ", "d")
                  .replaceAll("^(tinh|thanh pho|tp\\.?|t\\.?p\\.?)\\s+", "")
                  .trim();
    }

    private String escapeJson(String value) {
        if (value == null) return "";
        return value.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", " ").replace("\r", "");
    }
}
