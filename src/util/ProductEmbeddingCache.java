package util;

import dao.ProductEmbeddingDAO;
import model.ProductEmbedding;
import service.ClipEmbeddingService;

import java.io.File;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * In-Memory Vector Cache & Background Task Worker cho tìm kiếm hình ảnh AI CLIP.
 * Giúp tính toán Cosine Similarity trực tiếp trên RAM siêu tốc (<10ms)
 * và tự động hóa trích xuất vector ngầm khi đăng tin mà không làm chậm request của người dùng.
 */
public class ProductEmbeddingCache {

    private static final Map<Integer, float[]> VECTOR_CACHE = new ConcurrentHashMap<>();
    private static final ExecutorService ASYNC_POOL = Executors.newFixedThreadPool(2);
    private static final ProductEmbeddingDAO EMBEDDING_DAO = new ProductEmbeddingDAO();
    private static volatile boolean isInitialized = false;

    /**
     * Nạp toàn bộ vector của các sản phẩm ACTIVE từ MySQL vào RAM một lần duy nhất
     */
    public static synchronized void ensureInitialized() {
        if (isInitialized) return;
        try {
            List<ProductEmbedding> activeList = EMBEDDING_DAO.getAllActiveProductEmbeddings();
            for (ProductEmbedding item : activeList) {
                if (item.getVector() != null && item.getVector().length > 0) {
                    VECTOR_CACHE.put(item.getProductId(), item.getVector());
                }
            }
            isInitialized = true;
            System.out.println("[ProductEmbeddingCache] Da nap thanh cong " + VECTOR_CACHE.size() + " vector vao bo nho RAM.");
        } catch (Exception e) {
            System.err.println("[ProductEmbeddingCache] Loi khoi tao vector cache: " + e.getMessage());
        }
    }

    /**
     * Nạp lại toàn bộ vector từ Database vào RAM
     */
    public static synchronized void reload() {
        isInitialized = false;
        ensureInitialized();
    }

    /**
     * Lấy toàn bộ bản đồ vector từ RAM (nhanh gấp hàng chục lần so với query DB liên tục)
     */
    public static Map<Integer, float[]> getVectorCache() {
        if (!isInitialized) {
            ensureInitialized();
        }
        return VECTOR_CACHE;
    }

    /**
     * Cập nhật vector trực tiếp vào RAM
     */
    public static void put(int productId, float[] vector) {
        if (vector != null && vector.length > 0) {
            VECTOR_CACHE.put(productId, vector);
        }
    }

    /**
     * Xóa vector khỏi RAM khi bài đăng bị xóa hoặc ẩn
     */
    public static void remove(int productId) {
        VECTOR_CACHE.remove(productId);
    }

    /**
     * Trích xuất vector bất đồng bộ (chạy ngầm trong ThreadPool) ngay khi người bán đăng tin
     */
    public static void asyncIndex(int productId, String absoluteImagePath) {
        if (absoluteImagePath == null || absoluteImagePath.trim().isEmpty()) return;

        ASYNC_POOL.submit(() -> {
            try {
                File imgFile = new File(absoluteImagePath);
                if (!imgFile.exists()) return;

                if (ClipEmbeddingService.isServiceAvailable()) {
                    float[] vector = ClipEmbeddingService.getEmbeddingFromPath(imgFile.getAbsolutePath());
                    if (vector != null && vector.length > 0) {
                        EMBEDDING_DAO.saveEmbedding(productId, vector);
                        VECTOR_CACHE.put(productId, vector);
                        System.out.println("[ProductEmbeddingCache] Tu dong index thanh cong vector san pham #" + productId);
                    }
                }
            } catch (Exception e) {
                System.err.println("[ProductEmbeddingCache] Loi asyncIndex san pham #" + productId + ": " + e.getMessage());
            }
        });
    }

    /**
     * Tự động quét và đồng bộ các sản phẩm cũ chưa có vector chạy ngầm mà KHÔNG block request tìm kiếm
     */
    public static void asyncSyncUnindexed(String appPath) {
        ASYNC_POOL.submit(() -> {
            try {
                if (!ClipEmbeddingService.isServiceAvailable()) return;

                Map<Integer, String> unindexed = EMBEDDING_DAO.getUnindexedActiveProducts();
                if (unindexed.isEmpty()) return;

                for (Map.Entry<Integer, String> entry : unindexed.entrySet()) {
                    int pid = entry.getKey();
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
                            EMBEDDING_DAO.saveEmbedding(pid, vec);
                            VECTOR_CACHE.put(pid, vec);
                        }
                    }
                }
            } catch (Exception ignored) {}
        });
    }

    public static int size() {
        return VECTOR_CACHE.size();
    }
}
