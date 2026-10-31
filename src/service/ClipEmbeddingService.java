package service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import util.VectorUtil;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.UUID;

public class ClipEmbeddingService {
    private static final String BASE_URL = "http://127.0.0.1:8000";
    private static final HttpClient HTTP_CLIENT = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(5))
            .build();
    private static final ObjectMapper MAPPER = new ObjectMapper();

    /**
     * Kiểm tra dịch vụ AI Python có đang hoạt động hay không
     */
    public static boolean isServiceAvailable() {
        try {
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(BASE_URL + "/health"))
                    .timeout(Duration.ofSeconds(2))
                    .GET()
                    .build();
            HttpResponse<String> response = HTTP_CLIENT.send(request, HttpResponse.BodyHandlers.ofString());
            return response.statusCode() == 200;
        } catch (Exception e) {
            return false;
        }
    }

    public static class AnalysisResult {
        private final float[] embedding;
        private final String predictedIntent;
        private final String predictedIntentName;
        private final double intentConfidence;

        public AnalysisResult(float[] embedding, String predictedIntent, String predictedIntentName, double intentConfidence) {
            this.embedding = embedding != null ? embedding : new float[0];
            this.predictedIntent = predictedIntent != null ? predictedIntent : "";
            this.predictedIntentName = predictedIntentName != null ? predictedIntentName : "";
            this.intentConfidence = intentConfidence;
        }

        public float[] getEmbedding() { return embedding; }
        public String getPredictedIntent() { return predictedIntent; }
        public String getPredictedIntentName() { return predictedIntentName; }
        public double getIntentConfidence() { return intentConfidence; }
    }

    /**
     * Gửi mảng byte của ảnh đến AI service để nhận về vector 512 chiều kèm dự đoán ý định (Zero-Shot Intent)
     */
    public static AnalysisResult getAnalysisFromBytes(byte[] imageBytes, String filename) throws IOException, InterruptedException {
        if (imageBytes == null || imageBytes.length == 0) {
            return new AnalysisResult(new float[0], "", "", 0);
        }

        String boundary = "---ClipBoundary" + UUID.randomUUID().toString().replace("-", "");
        byte[] multipartBody = createMultipartPayload(boundary, imageBytes, filename != null ? filename : "image.jpg");

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(BASE_URL + "/embed"))
                .timeout(Duration.ofSeconds(15))
                .header("Content-Type", "multipart/form-data; boundary=" + boundary)
                .POST(HttpRequest.BodyPublishers.ofByteArray(multipartBody))
                .build();

        HttpResponse<String> response = HTTP_CLIENT.send(request, HttpResponse.BodyHandlers.ofString());

        if (response.statusCode() == 200) {
            JsonNode root = MAPPER.readTree(response.body());
            JsonNode embeddingNode = root.get("embedding");
            float[] vector = new float[0];
            if (embeddingNode != null && embeddingNode.isArray()) {
                vector = MAPPER.convertValue(embeddingNode, float[].class);
            }
            String intent = root.has("predicted_intent") ? root.get("predicted_intent").asText("") : "";
            String intentName = root.has("predicted_intent_name") ? root.get("predicted_intent_name").asText("") : "";
            double confidence = root.has("intent_confidence") ? root.get("intent_confidence").asDouble(0.0) : 0.0;

            return new AnalysisResult(vector, intent, intentName, confidence);
        } else {
            System.err.println("[ClipEmbeddingService] Lỗi từ AI service: HTTP " + response.statusCode() + " - " + response.body());
        }

        return new AnalysisResult(new float[0], "", "", 0);
    }

    /**
     * Gửi mảng byte của ảnh đến AI service để nhận về vector 512 chiều
     */
    public static float[] getEmbeddingFromBytes(byte[] imageBytes, String filename) throws IOException, InterruptedException {
        return getAnalysisFromBytes(imageBytes, filename).getEmbedding();
    }

    /**
     * Trích xuất vector từ đường dẫn file ảnh trực tiếp trên máy
     */
    public static float[] getEmbeddingFromPath(String absoluteImagePath) {
        if (absoluteImagePath == null || absoluteImagePath.trim().isEmpty()) {
            return new float[0];
        }

        try {
            String formBody = "image_path=" + URLEncoder.encode(absoluteImagePath, StandardCharsets.UTF_8);
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(BASE_URL + "/embed-path"))
                    .timeout(Duration.ofSeconds(10))
                    .header("Content-Type", "application/x-www-form-urlencoded")
                    .POST(HttpRequest.BodyPublishers.ofString(formBody))
                    .build();

            HttpResponse<String> response = HTTP_CLIENT.send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() == 200) {
                JsonNode root = MAPPER.readTree(response.body());
                JsonNode embeddingNode = root.get("embedding");
                if (embeddingNode != null && embeddingNode.isArray()) {
                    return MAPPER.convertValue(embeddingNode, float[].class);
                }
            }
        } catch (Exception e) {
            System.err.println("[ClipEmbeddingService] Lỗi getEmbeddingFromPath: " + e.getMessage());
        }
        return new float[0];
    }

    // Helper tạo multipart payload dạng binary an toàn
    private static byte[] createMultipartPayload(String boundary, byte[] fileBytes, String filename) throws IOException {
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        String lineBreak = "\r\n";

        String header = "--" + boundary + lineBreak +
                "Content-Disposition: form-data; name=\"file\"; filename=\"" + filename + "\"" + lineBreak +
                "Content-Type: image/jpeg" + lineBreak + lineBreak;

        out.write(header.getBytes(StandardCharsets.UTF_8));
        out.write(fileBytes);
        out.write(lineBreak.getBytes(StandardCharsets.UTF_8));

        String footer = "--" + boundary + "--" + lineBreak;
        out.write(footer.getBytes(StandardCharsets.UTF_8));

        return out.toByteArray();
    }
}
