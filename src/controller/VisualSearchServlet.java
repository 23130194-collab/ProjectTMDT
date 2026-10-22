package controller;

import dao.ProductDAO;
import dao.ProductEmbeddingDAO;
import model.Product;
import model.ProductEmbedding;
import service.ClipEmbeddingService;
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
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String action = request.getParameter("action");
        response.setContentType("application/json;charset=UTF-8");

        if ("status".equals(action)) {
            boolean aiReady = ClipEmbeddingService.isServiceAvailable();
            int indexedCount = embeddingDAO.countIndexedProducts();
            response.getWriter().write(String.format("{\"ai_service\":%b,\"indexed_products\":%d}", aiReady, indexedCount));
            return;
        }

        // Tự động quét và đồng bộ vector cho các sản phẩm cũ trong DB chưa có vector
        if ("sync".equals(action)) {
            if (!ClipEmbeddingService.isServiceAvailable()) {
                response.getWriter().write("{\"status\":\"error\",\"message\":\"AI Service chưa chạy tại localhost:8000\"}");
                return;
            }

            Map<Integer, String> unindexed = embeddingDAO.getUnindexedActiveProducts();
            int synced = 0;
            String appPath = request.getServletContext().getRealPath("");

            for (Map.Entry<Integer, String> entry : unindexed.entrySet()) {
                int pid = entry.getKey();
                String imgRelPath = entry.getValue(); // e.g. "uploads/products/abc.jpg"
                try {
                    String fullPath = appPath + File.separator + imgRelPath.replace("/", File.separator);
                    File imgFile = new File(fullPath);
                    if (imgFile.exists()) {
                        float[] vec = ClipEmbeddingService.getEmbeddingFromPath(imgFile.getAbsolutePath());
                        if (vec.length > 0) {
                            embeddingDAO.saveEmbedding(pid, vec);
                            synced++;
                        }
                    }
                } catch (Exception ignored) {}
            }

            response.getWriter().write(String.format("{\"status\":\"success\",\"synced\":%d,\"total_unindexed\":%d}", synced, unindexed.size()));
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
            response.getWriter().write("{\"status\":\"error\",\"message\":\"Dịch vụ AI CLIP chưa được khởi động trên máy (cổng 8000). Hãy chạy python3 ai_service/app.py\"}");
            return;
        }

        // 2. Nhận file ảnh tải lên
        Part filePart = request.getPart("searchImage");
        if (filePart == null || filePart.getSize() == 0) {
            filePart = request.getPart("image");
        }

        if (filePart == null || filePart.getSize() == 0) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"status\":\"error\",\"message\":\"Vui lòng chọn một bức ảnh để tìm kiếm\"}");
            return;
        }

        byte[] imageBytes;
        try (InputStream in = filePart.getInputStream()) {
            imageBytes = in.readAllBytes();
        }

        try {
            // 3. Trích xuất vector của ảnh tìm kiếm
            float[] queryVector = ClipEmbeddingService.getEmbeddingFromBytes(imageBytes, filePart.getSubmittedFileName());
            if (queryVector == null || queryVector.length == 0) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("{\"status\":\"error\",\"message\":\"Không thể phân tích đặc trưng hình ảnh này\"}");
                return;
            }

            // 4. Lấy tất cả vector của các sản phẩm ACTIVE từ MySQL
            // Tự động kiểm tra và sync bất kỳ sản phẩm ACTIVE nào chưa có vector
            autoSyncExistingProducts(request);
            List<ProductEmbedding> activeEmbeddings = embeddingDAO.getAllActiveProductEmbeddings();

            // 5. So sánh độ tương đồng Cosine Similarity
            List<SearchResultItem> results = new ArrayList<>();
            double maxScore = 0.0;
            for (ProductEmbedding item : activeEmbeddings) {
                double score = VectorUtil.cosineSimilarity(queryVector, item.getVector());
                if (score > maxScore) {
                    maxScore = score;
                }
                // Chỉ nhận các sản phẩm có độ tương đồng từ 58% trở lên (loại bỏ đồ vật khác loại)
                if (score >= 0.58) {
                    results.add(new SearchResultItem(item.getProductId(), score));
                }
            }

            // Sắp xếp điểm tương đồng giảm dần
            results.sort((a, b) -> Double.compare(b.score, a.score));

            // Lọc nâng cao: Nếu có sản phẩm top đầu rất khớp, loại bỏ các kết quả bị chênh lệch quá xa
            if (maxScore >= 0.60) {
                final double cutoff = Math.max(0.58, maxScore - 0.10);
                results.removeIf(item -> item.score < cutoff);
            }

            // Lấy tối đa top 15 sản phẩm khớp nhất
            int limit = Math.min(results.size(), 15);
            StringBuilder json = new StringBuilder("{\"status\":\"success\",\"count\":").append(limit).append(",\"products\":[");

            int count = 0;
            for (int i = 0; i < limit; i++) {
                SearchResultItem item = results.get(i);
                Product p = productDAO.getProductById(item.productId);
                if (p != null) {
                    if (count > 0) json.append(",");
                    int matchPercent = (int) Math.round(item.score * 100);
                    json.append("{")
                            .append("\"id\":").append(p.getId()).append(",")
                            .append("\"title\":\"").append(escapeJson(p.getTitle())).append("\",")
                            .append("\"price\":").append(p.getPrice()).append(",")
                            .append("\"image\":\"").append(escapeJson(p.getPrimaryImage() != null ? p.getPrimaryImage() : "")).append("\",")
                            .append("\"province\":\"").append(escapeJson(p.getProvince() != null ? p.getProvince() : "")).append("\",")
                            .append("\"condition\":\"").append(escapeJson(p.getConditionStatus() != null ? p.getConditionStatus() : "")).append("\",")
                            .append("\"similarity_percent\":").append(matchPercent)
                            .append("}");
                    count++;
                }
            }
            json.append("]}");
            response.getWriter().write(json.toString());

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"status\":\"error\",\"message\":\"Đã xảy ra lỗi khi tìm kiếm hình ảnh: " + escapeJson(e.getMessage()) + "\"}");
        }
    }

    private void autoSyncExistingProducts(HttpServletRequest request) {
        try {
            Map<Integer, String> unindexed = embeddingDAO.getUnindexedActiveProducts();
            if (unindexed.isEmpty()) return;

            String appPath = request.getServletContext().getRealPath("");
            for (Map.Entry<Integer, String> entry : unindexed.entrySet()) {
                String relPath = entry.getValue();
                if (relPath == null || relPath.trim().isEmpty()) continue;

                String cleanPath = relPath.replace("/", File.separator);
                if (cleanPath.startsWith(File.separator)) {
                    cleanPath = cleanPath.substring(1);
                }

                File imgFile = new File(appPath + File.separator + cleanPath);
                if (!imgFile.exists()) {
                    imgFile = new File(appPath, cleanPath);
                }

                if (imgFile.exists()) {
                    float[] vec = ClipEmbeddingService.getEmbeddingFromPath(imgFile.getAbsolutePath());
                    if (vec != null && vec.length > 0) {
                        embeddingDAO.saveEmbedding(entry.getKey(), vec);
                    }
                }
            }
        } catch (Exception ignored) {}
    }

    private static class SearchResultItem {
        int productId;
        double score;
        SearchResultItem(int productId, double score) {
            this.productId = productId;
            this.score = score;
        }
    }

    private String escapeJson(String value) {
        if (value == null) return "";
        return value.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", " ").replace("\r", "");
    }
}
