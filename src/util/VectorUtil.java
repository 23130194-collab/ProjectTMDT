package util;

import com.fasterxml.jackson.databind.ObjectMapper;

public class VectorUtil {
    private static final ObjectMapper MAPPER = new ObjectMapper();

    /**
     * Tính toán Cosine Similarity giữa 2 vector float[]
     * Kết quả nằm trong khoảng [-1.0, 1.0], thông thường từ 0.0 đến 1.0 đối với vector chuẩn hóa.
     * Càng gần 1.0 thì 2 hình ảnh càng tương đồng.
     */
    public static double cosineSimilarity(float[] v1, float[] v2) {
        if (v1 == null || v2 == null || v1.length != v2.length) {
            return 0.0;
        }

        double dotProduct = 0.0;
        double normA = 0.0;
        double normB = 0.0;

        for (int i = 0; i < v1.length; i++) {
            dotProduct += v1[i] * v2[i];
            normA += v1[i] * v1[i];
            normB += v2[i] * v2[i];
        }

        if (normA == 0.0 || normB == 0.0) {
            return 0.0;
        }

        return dotProduct / (Math.sqrt(normA) * Math.sqrt(normB));
    }

    /**
     * Chuyển mảng float[] thành chuỗi JSON để lưu vào MySQL cột MEDIUMTEXT
     */
    public static String floatArrayToJson(float[] vector) {
        if (vector == null) return "[]";
        try {
            return MAPPER.writeValueAsString(vector);
        } catch (Exception e) {
            // Fallback thủ công nếu Jackson gặp sự cố
            StringBuilder sb = new StringBuilder("[");
            for (int i = 0; i < vector.length; i++) {
                sb.append(vector[i]);
                if (i < vector.length - 1) sb.append(",");
            }
            sb.append("]");
            return sb.toString();
        }
    }

    /**
     * Parse chuỗi JSON từ MySQL thành mảng float[] để tính toán
     */
    public static float[] jsonToFloatArray(String json) {
        if (json == null || json.trim().isEmpty() || "[]".equals(json.trim())) {
            return new float[0];
        }
        try {
            return MAPPER.readValue(json, float[].class);
        } catch (Exception e) {
            // Fallback phân tích chuỗi
            String clean = json.replace("[", "").replace("]", "").trim();
            if (clean.isEmpty()) return new float[0];
            String[] parts = clean.split(",");
            float[] result = new float[parts.length];
            for (int i = 0; i < parts.length; i++) {
                result[i] = Float.parseFloat(parts[i].trim());
            }
            return result;
        }
    }
}
